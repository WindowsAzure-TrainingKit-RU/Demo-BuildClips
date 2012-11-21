param([switch]$ResetAzure,[switch]$ResetLocal,[switch]$SetupAzure,[switch]$SetupLocal,[switch]$CleanupLocal,[switch]$CleanupAzure,[switch]$SetupDeployment)

if ($SetupLocal.IsPresent) {
    Write-Warning "This script will setup your machine by performing the following tasks:"
    Write-Host ""
    Write-Host "1. Run the Dependency Checker"
    Write-Host "2. Set powershell execution policy to unrestricted"
    Write-Host "3. Copy the Begin solution to the working directory"
    Write-Host "4. Copy the Begin solution of Segment 2 to the working directory"
    Write-Host "5. Copy assets code to the working directory"
    Write-Host "6. Update the Web config settings for the Begin solution"
    Write-Host "7. Update the Web config settings for the Begin solution for Segment 2"
    Write-Host "8. Update the App config settings for the Begin solution"
    Write-Host "9. Reset Azure Compute Emulator and Dev Storage" -ForegroundColor Yellow
    Write-Host "10. Configure IIS Express Web Site"
    Write-Host "11. Install the code snippets for the demo"
    Write-Host "12. Open Manual Reset steps file"
}

if ($ResetLocal.IsPresent) {
    Write-Warning "This script will reset your machine by performing the following tasks:"
    Write-Host ""
    Write-Host "1. Remove the working directory for the demo"
    Write-Host "2. Remove the code snippets for the demo"
    Write-Host "3. Drop local database"
    Write-Host "4. Remove IIS Express Web Site"
    Write-Host "5. Run the Dependency Checker"
    Write-Host "6. Set powershell execution policy to unrestricted"
    Write-Host "7. Copy the Begin solution to the working directory"
    Write-Host "8. Copy the Begin solution of Segment 2 to the working directory"
    Write-Host "9. Copy assets code to the working directory"
    Write-Host "10. Update the Web config settings for the Begin solution"
    Write-Host "11. Update the Web config settings for the Begin solution for Segment 2"
    Write-Host "12. Update the App config settings for the Begin solution"
    Write-Host "13. Reset Azure Compute Emulator and Dev Storage" -ForegroundColor Yellow
    Write-Host "14. Configure IIS Express Web Site"
    Write-Host "15. Install the code snippets for the demo"
    Write-Host "16. Open Manual Reset steps file"
}

if ($CleanupLocal.IsPresent) {
    Write-Warning "This script will cleanup your machine by performing the following tasks:"
    Write-Host ""
    Write-Host "1. Remove the working directory for the demo"
    Write-Host "2. Remove the code snippets for the demo"
    Write-Host "3. Drop local database"
    Write-Host "4. Remove IIS Express Web Site"
}

if ($SetupAzure.IsPresent) {
    Write-Host "This demo does not require any setup step in Windows Azure" -ForegroundColor Green
    Write-Host ""
    #TBC
}

if ($ResetAzure.IsPresent) {
    Write-Host "This demo does not require any reset step in Windows Azure" -ForegroundColor Green
    Write-Host ""
    #TBC
}

if ($CleanupAzure.IsPresent) {
    Write-Host "This demo does not require any cleanup step in Windows Azure" -ForegroundColor Green
    Write-Host ""
    #TBC
}

if ($SetupDeployment.IsPresent) {
    Write-Warning "This script will setup the deployment for Segment 5 by performing the following tasks:"
    Write-Host ""
    Write-Host "1. Copy Begin solution for Segment 5 to working directory"
    Write-Host "2. Update Web.config for solution of Segment 5"
    Write-Host "3. Update App.config for solution of Segment 5"
    Write-Host "4. Update Web.Release.config for solution of Segment 5"
    Write-Host "5. Update ServiceConfiguration.Cloud.cscfg for solution of Segment 5"
    Write-Host "6. Update ServiceDefinition.csdef for solution of Segment 5"
}

Write-Host ""

$title = ""
$message = "Are you sure you want to continue?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$confirmation = $host.ui.PromptForChoice($title, $message, $options, 1)

if ($confirmation -eq 0) {
    exit 0
}
else {
    exit 1
}


