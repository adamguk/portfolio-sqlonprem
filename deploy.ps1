$ErrorActionPreference = "Stop"

Write-Host "==========================================" 
Write-Host "     Starting Warehouse Deployment        " 
Write-Host "==========================================" 

$Credential = Get-Credential -UserName "sa" -Message "Enter dbserver Password"
$Username = $Credential.UserName
$Password = $Credential.GetNetworkCredential().Password

$Server = "192.168.50.185"
$Port = "1433"
$Database = "DWH_ONPREM"
$ServerInstance = "$Server,$Port"

$DeploymentSteps = @(
    @{ Name = "Database & Schemas"; Path = ".\scripts\01_init_db.sql"; UseTargetDB = $false },
    @{ Name = "RBAC"; Path = ".\scripts\01a_rbac.sql"; UseTargetDB = $true },
    @{ Name = "Staging Tables"; Path = ".\scripts\02_create_tables_staging.sql"; UseTargetDB = $true },
    @{ Name = "Operations Tables"; Path = ".\scripts\03_create_tables_etl.sql"; UseTargetDB = $true },
    @{ Name = "Intermediate Views"; Path = ".\scripts\04_create_views_intermediate.sql"; UseTargetDB = $true },
    @{ Name = "Mart Tables"; Path = ".\scripts\05_create_tables_mart.sql"; UseTargetDB = $true },
    @{ Name = "Procedures"; Path = ".\scripts\06_create_procedures.sql"; UseTargetDB = $true },
    @{ Name = "AgentJobs"; Path = ".\scripts\07_create_agent_jobs.sql"; UseTargetDB = $false }
)

foreach ($Step in $DeploymentSteps) {
    Write-Host ""
    Write-Host "Deploying: $($Step.Name)..." 
    
    try {
        if ($Step.UseTargetDB) {
            sqlcmd -S $ServerInstance -U $Username -P $Password -d $Database -i $Step.Path -b
        }
        else {
            sqlcmd -S $ServerInstance -U $Username -P $Password -i $Step.Path -b
        }

        Write-Host "[SUCCESS] $($Step.Name) deployed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host "[FATAL ERROR] Deployment aborted during step: $($Step.Name)"
        Write-Host $_.Exception.Message -ForegroundColor Red
        break
    }
}

# ==========================================
#   SSIS Catalog Deployment
# ==========================================
Write-Host ""
Write-Host "==========================================" 
Write-Host "     Deploying SSIS Catalog & Project     " 
Write-Host "==========================================" 

$SSISServer = "DESKTOP-8Q39CF7"
$SSISFolderName = "DWH_OnPrem"
$SSISProjectName = "SSIS_DWHONPREM"
$IspacPath = ".\SSIS\SSIS_DWHONPREM\bin\Development\SSIS_DWHONPREM.ispac"

try {
    Add-Type -AssemblyName "Microsoft.SqlServer.Management.IntegrationServices"

    $SSISConnectionString = "Data Source=$SSISServer;Initial Catalog=master;Integrated Security=SSPI;"
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection $SSISConnectionString
    $IntegrationServices = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices $SqlConnection

    $Catalog = $IntegrationServices.Catalogs["SSISDB"]

    if (-not $Catalog) {
        Write-Host "SSISDB Catalog not found - creating it now..."
        $MasterKeySecure = Read-Host -Prompt "Enter a new SSIS Catalog Master Key password" -AsSecureString
        $MasterKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($MasterKeySecure)
        )

        $Catalog = New-Object Microsoft.SqlServer.Management.IntegrationServices.Catalog(
            $IntegrationServices, "SSISDB", $MasterKeyPlain
        )
        $Catalog.Create()
        Write-Host "[SUCCESS] SSISDB Catalog created."
    }
    else {
        Write-Host "SSISDB Catalog already exists - skipping creation."
    }

    $Folder = $Catalog.Folders[$SSISFolderName]

    if (-not $Folder) {
        Write-Host "Folder '$SSISFolderName' not found - creating it now..."
        $Folder = New-Object Microsoft.SqlServer.Management.IntegrationServices.CatalogFolder(
            $Catalog, $SSISFolderName, ""
        )
        $Folder.Create()
        Write-Host "[SUCCESS] Folder '$SSISFolderName' created."
    }
    else {
        Write-Host "Folder '$SSISFolderName' already exists - skipping creation."
    }

    Write-Host "Deploying project '$SSISProjectName'..."
    [byte[]] $IspacBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $IspacPath))
    $Folder.DeployProject($SSISProjectName, $IspacBytes)

    Write-Host "[SUCCESS] SSIS project deployed to $SSISFolderName/$SSISProjectName!" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "[FATAL ERROR] SSIS Catalog deployment failed"
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" 
Write-Host "     Deployment Process Complete!         " 
Write-Host "=========================================="