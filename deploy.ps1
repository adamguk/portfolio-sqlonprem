$ErrorActionPreference = "Stop"

Write-Host "==========================================" 
Write-Host "     Starting Warehouse Deployment        " 
Write-Host "==========================================" 

$SourceCredential = Get-Credential -UserName "sa" -Message "Enter Source Database Password"
$SourceUsername = $SourceCredential.UserName
$SourcePassword = $SourceCredential.GetNetworkCredential().Password

$DestinationCredential = Get-Credential -UserName "sa" -Message "Enter Destination Database Password"
$DestinationUsername = $DestinationCredential.UserName
$DestinationPassword = $DestinationCredential.GetNetworkCredential().Password

$SSISCatalogSecurePassword = Read-Host -Prompt "Enter SSIS Catalog Master Key Password" -AsSecureString
$SSISCatalogPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SSISCatalogSecurePassword)
)

# --- DWH server (NAS / Docker) ---
$DwhServer = "192.168.50.185"
$Port = "1433"
$Database = "DWH_ONPREM"
$DwhServerInstance = "$DwhServer,$Port"

# --- SSIS server (local Windows instance hosting the Catalog) ---
$SSISServerInstance = "DESKTOP-8Q39CF7,56231"
$IspacSourcePath = ".\SSIS\SSIS_DWHONPREM\bin\Development\SSIS_DWHONPREM.ispac"
$IspacLocalPath = "C:\Temp\SSIS_DWHONPREM.ispac"

$DeploymentSteps = @(
    @{ Name = "Database & Schemas"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\01_init_db.sql"; UseTargetDB = $false; TargetServer = "DWH" },
    @{ Name = "RBAC"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\01a_rbac.sql"; UseTargetDB = $true; TargetServer = "DWH" },
    @{ Name = "SSIS Catalog Init"; Path = ".\scripts\InitialDeployment\IntegrationDeployments\01b_init_catalog.sql"; UseTargetDB = $false; TargetServer = "SSIS" },
    @{ Name = "Staging Tables"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\02_create_tables_staging.sql"; UseTargetDB = $true; TargetServer = "DWH" },
    @{ Name = "Operations Tables"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\03_create_tables_etl.sql"; UseTargetDB = $true; TargetServer = "DWH" },
    @{ Name = "Intermediate Views"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\04_create_views_intermediate.sql"; UseTargetDB = $true; TargetServer = "DWH" },
    @{ Name = "Mart Tables"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\05_create_tables_mart.sql"; UseTargetDB = $true; TargetServer = "DWH" },
    @{ Name = "Procedures"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\06_create_procedures.sql"; UseTargetDB = $true; TargetServer = "DWH" },
    @{ Name = "AgentJobs"; Path = ".\scripts\InitialDeployment\DatabaseDeployments\07_create_agent_jobs.sql"; UseTargetDB = $false; TargetServer = "DWH" },
    @{ Name = "SSIS Catalog Deployment"; Path = ".\scripts\InitialDeployment\IntegrationDeployments\08_deploy_ssis_catalog.sql"; UseTargetDB = $false; TargetServer = "SSIS" },
    @{ Name = "SSIS Environment Deployment"; Path = ".\scripts\InitialDeployment\IntegrationDeployments\11_create_environment_prod.sql"; UseTargetDB = $false; TargetServer = "SSIS" },
    @{ Name = "SSIS AgentJobs Deployment"; Path = ".\scripts\InitialDeployment\IntegrationDeployments\10_create_agent_jobs_ssis.sql"; UseTargetDB = $false; TargetServer = "SSIS" }
)

$DeploymentFailed = $false

foreach ($Step in $DeploymentSteps) {
    Write-Host ""
    Write-Host "Deploying: $($Step.Name)..." 

    # Only the Catalog deployment step actually needs the .ispac staged locally.
    if ($Step.Name -eq "SSIS Catalog Deployment") {
        try {
            Write-Host "Staging .ispac to local path: $IspacLocalPath"
            New-Item -ItemType Directory -Path (Split-Path $IspacLocalPath) -Force | Out-Null
            Copy-Item -Path $IspacSourcePath -Destination $IspacLocalPath -Force
        }
        catch {
            Write-Host ""
            Write-Host "[FATAL ERROR] Failed to stage .ispac before step: $($Step.Name)"
            Write-Host $_.Exception.Message -ForegroundColor Red
            $DeploymentFailed = $true
            break
        }
    }

    $TargetInstance = if ($Step.TargetServer -eq "SSIS") { $SSISServerInstance } else { $DwhServerInstance }

    try {
        if ($Step.Name -eq "SSIS Environment Deployment") {
            sqlcmd -S $TargetInstance -E -v "AdventureWorksPassword=$SourcePassword" -v "DwhPassword=$DestinationPassword" -i $Step.Path -b
        }
        elseif ($Step.Name -eq "SSIS Catalog Init") {
            sqlcmd -S $TargetInstance -E -v SSISCatalogPassword=$SSISCatalogPassword -i $Step.Path -b
        }
        elseif ($Step.TargetServer -eq "SSIS") {
            # SSIS Catalog operations require Windows/Integrated Authentication.
            sqlcmd -S $TargetInstance -E -i $Step.Path -b
        }
        elseif ($Step.UseTargetDB) {
            sqlcmd -S $TargetInstance -U $DestinationUsername -P $DestinationPassword -d $Database -i $Step.Path -b
        }
        else {
            sqlcmd -S $TargetInstance -U $DestinationUsername -P $DestinationPassword -i $Step.Path -b
        }

        Write-Host "[SUCCESS] $($Step.Name) deployed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host "[FATAL ERROR] Deployment aborted during step: $($Step.Name)"
        Write-Host $_.Exception.Message -ForegroundColor Red
        $DeploymentFailed = $true
        break
    }
}

if ($DeploymentFailed) {
    Write-Host ""
    Write-Host "[ABORTED] Deployment did not complete successfully." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==========================================" 
Write-Host "     Deployment Process Complete!         " 
Write-Host "=========================================="