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
    @{ Name = "Staging Tables"; Path = ".\scripts\02_create_tables_staging.sql"; UseTargetDB = $true },
    @{ Name = "Intermediate Views"; Path = ".\scripts\03_create_views_intermediate.sql"; UseTargetDB = $true },
    @{ Name = "Mart Tables"; Path = ".\scripts\04_create_tables_mart.sql"; UseTargetDB = $true },
    @{ Name = "Procedures"; Path = ".\scripts\05_create_procedures.sql"; UseTargetDB = $true },
    @{ Name = "AgentJobs"; Path = ".\scripts\06_create_agent_jobs.sql"; UseTargetDB = $false }
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

Write-Host ""
Write-Host "==========================================" 
Write-Host "     Deployment Process Complete!         " 
Write-Host "==========================================" 