Param([string] $demoSettingsFile)

$scriptDir = (split-path $myinvocation.mycommand.path -parent)
Set-Location $scriptDir

# "========= Initialization =========" #
pushd ".."
# Get settings from user configuration file
if($demoSettingsFile -eq $nul -or $demoSettingsFile -eq "")
{
	$demoSettingsFile = "Config.Local.xml"
}

[xml] $xmlDemoSettings = Get-Content $demoSettingsFile

# Import required settings from config.local.xml if neccessary #
[string] $workingDir = $xmlDemoSettings.configuration.localPaths.workingDir
[string] $solutionWorkingDir = $xmlDemoSettings.configuration.localPaths.endSolutionWorkingDir
[string] $solutionDir = Resolve-Path $xmlDemoSettings.configuration.localPaths.endSolutionDir

[string] $webConfig = $xmlDemoSettings.configuration.localPaths.webConfig
[string] $webReleaseConfig = $xmlDemoSettings.configuration.localPaths.webReleaseConfig
[string] $appConfig = $xmlDemoSettings.configuration.localPaths.appConfig
[string] $serviceConfiguration = $xmlDemoSettings.configuration.localPaths.serviceConfiguration
[string] $serviceDefinition = $xmlDemoSettings.configuration.localPaths.serviceDefinition

[string] $mediaServicesAccountName = $xmlDemoSettings.configuration.appSettings.mediaServicesAccountName
[string] $mediaServicesAccountKey = $xmlDemoSettings.configuration.appSettings.mediaServicesAccountKey
[string] $storageAccountConnectionString = $xmlDemoSettings.configuration.appSettings.storageAccountConnectionString
[string] $serviceBusConnectionString = $xmlDemoSettings.configuration.appSettings.serviceBusConnectionString
[string] $diagnosticsStorageAccountConnectionString = $xmlDemoSettings.configuration.appSettings.diagnosticsStorageAccountConnectionString

[string] $facebookApplicationId = $xmlDemoSettings.configuration.appSettings.cloudService.facebookApplicationId
[string] $facebookApplicationSecret = $xmlDemoSettings.configuration.appSettings.cloudService.facebookApplicationSecret
[string] $twitterConsumerKey = $xmlDemoSettings.configuration.appSettings.cloudService.twitterConsumerKey
[string] $twitterConsumerSecret = $xmlDemoSettings.configuration.appSettings.cloudService.twitterConsumerSecret

[string] $dbConnectionString = $xmlDemoSettings.configuration.appSettings.cloudService.dbConnectionString

[string] $apiBaseUrl = $xmlDemoSettings.configuration.appSettings.cloudService.apiBaseUrl

popd
# "========= Main Script =========" #

if (!(Test-Path "$workingDir"))
{
	New-Item "$workingDir" -type directory | Out-Null
}

write-host
write-host
write-host "========= Copying Begin solution for Segment 5 to working directory... ========="
if (!(Test-Path "$solutionWorkingDir"))
{
	New-Item "$solutionWorkingDir" -type directory | Out-Null
}
Copy-Item "$solutionDir\*" "$solutionWorkingDir" -recurse -Force
write-host "Copying Begin solution to working directory done!"


write-host
write-host
write-host "========= Update Web.config... ========="
$webConfigFilePath = Join-Path $solutionWorkingDir $webConfig
# Begin updating Web.config file
[string] $webConfigFile = Resolve-Path $webConfigFilePath 
$xml = New-Object xml
$xml.psbase.PreserveWhitespace = $true
$xml.Load($webConfigFile)
$xml.SelectNodes("//connectionStrings/add[@name = 'DefaultConnection']").setAttribute("connectionString", $dbConnectionString)

$xml.SelectNodes("//appSettings/add[@key = 'FacebookApplicationId']").setAttribute("value", $facebookApplicationId)
$xml.SelectNodes("//appSettings/add[@key = 'FacebookApplicationSecret']").setAttribute("value", $facebookApplicationSecret)
$xml.SelectNodes("//appSettings/add[@key = 'TwitterConsumerKey']").setAttribute("value", $twitterConsumerKey)
$xml.SelectNodes("//appSettings/add[@key = 'TwitterConsumerSecret']").setAttribute("value", $twitterConsumerSecret)

$xml.SelectNodes("//appSettings/add[@key = 'MediaServicesAccountName']").setAttribute("value", $mediaServicesAccountName)
$xml.SelectNodes("//appSettings/add[@key = 'MediaServicesAccountKey']").setAttribute("value", $mediaServicesAccountKey)
$xml.SelectNodes("//appSettings/add[@key = 'MediaServicesStorageAccountConnectionString']").setAttribute("value", $storageAccountConnectionString)
$xml.SelectNodes("//appSettings/add[@key = 'ServiceBusConnectionString']").setAttribute("value", $serviceBusConnectionString)

$xml.Save($webConfigFile)
# End updating Web.config file
write-host "Update Web.config done!"


write-host
write-host
write-host "========= Update app.config... ========="
$appConfigFilePath = Join-Path $solutionWorkingDir $appConfig
# Begin updating app.config file
[string] $appConfigFile = Resolve-Path $appConfigFilePath 
$xml = New-Object xml
$xml.psbase.PreserveWhitespace = $true
$xml.Load($appConfigFile)
$xml.SelectNodes("//connectionStrings/add[@name = 'DefaultConnection']").setAttribute("connectionString", $dbConnectionString)

$xml.SelectNodes("//appSettings/add[@key = 'MediaServicesAccountName']").setAttribute("value", $mediaServicesAccountName)
$xml.SelectNodes("//appSettings/add[@key = 'MediaServicesAccountKey']").setAttribute("value", $mediaServicesAccountKey)
$xml.SelectNodes("//appSettings/add[@key = 'MediaServicesStorageAccountConnectionString']").setAttribute("value", $storageAccountConnectionString)
$xml.SelectNodes("//appSettings/add[@key = 'ApiBaseUrl']").setAttribute("value", $apiBaseUrl)

$xml.Save($appConfigFile)
# End updating app.config file
write-host "Update app.config done!"


write-host
write-host
write-host "========= Update Web.Release.config... ========="
$webConfigReleaseFilePath = Join-Path $solutionWorkingDir $webReleaseConfig
# Begin updating Web.Release.config file
[string] $webConfigReleaseFile = Resolve-Path $webConfigReleaseFilePath 
$xml = New-Object xml
$xml.psbase.PreserveWhitespace = $true
$xml.Load($webConfigReleaseFile)
$xml.SelectNodes("//appSettings/add[@key = 'FacebookApplicationId']").setAttribute("value", $facebookApplicationId)
$xml.SelectNodes("//appSettings/add[@key = 'FacebookApplicationSecret']").setAttribute("value", $facebookApplicationSecret)
$xml.SelectNodes("//appSettings/add[@key = 'TwitterConsumerKey']").setAttribute("value", $twitterConsumerKey)
$xml.SelectNodes("//appSettings/add[@key = 'TwitterConsumerSecret']").setAttribute("value", $twitterConsumerSecret)

$xml.SelectNodes("//appSettings/add[@key = 'StorageConnectionString']").setAttribute("value", $storageAccountConnectionString)

$xml.Save($webConfigReleaseFile)
# End updating Web.Release.config file
write-host "Update Web.Release.config done!"


write-host
write-host
write-host "========= Update ServiceConfiguration.Cloud.cscfg... ========="
$serviceConfigurationFilePath = Join-Path $solutionWorkingDir $serviceConfiguration

# Begin updating ServiceConfiguration.Cloud.cscfg file
[string] $serviceConfigurationFile = Resolve-Path $serviceConfigurationFilePath 
$xml = New-Object xml
$xml.psbase.PreserveWhitespace = $true
$xml.Load($serviceConfigurationFile)

$xml.ServiceConfiguration.SelectNodes("*[@name = 'BuildClips']").ConfigurationSettings.SelectNodes("*[@name = 'Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString']").setAttribute("value", $diagnosticsStorageAccountConnectionString)
$xml.ServiceConfiguration.SelectNodes("*[@name = 'BuildClips']").ConfigurationSettings.SelectNodes("*[@name = 'Microsoft.WindowsAzure.Plugins.Caching.ConfigStoreConnectionString']").setAttribute("value", $storageAccountConnectionString)
$xml.ServiceConfiguration.SelectNodes("*[@name = 'BackgroundService']").ConfigurationSettings.SelectNodes("*[@name = 'Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString']").setAttribute("value", $diagnosticsStorageAccountConnectionString)

$xml.Save($serviceConfigurationFile)
# End updating ServiceConfiguration.Cloud.cscfg file
write-host "Update ServiceConfiguration.Cloud.cscfg done!"


write-host
write-host
write-host "========= Update ServiceDefinition.csdef... ========="
$serviceDefinitionFilePath = Join-Path $solutionWorkingDir $serviceDefinition

# Begin updating ServiceDefinition.csdef file
[string] $serviceDefinitionFile = Resolve-Path $serviceDefinitionFilePath 
$xml = New-Object xml
$xml.psbase.PreserveWhitespace = $true
$xml.Load($serviceDefinitionFile)

$xml.ServiceDefinition.WebRole.Endpoints.InputEndpoint.setAttribute("port", "80")

$xml.Save($serviceDefinitionFile)
# End updating ServiceDefinition.csdef file
write-host "Update ServiceDefinition.csdef done!"