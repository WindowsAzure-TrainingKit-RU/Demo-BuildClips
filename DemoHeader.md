<a name="demo2" />
# Demo : BUILD Clips#

## Overview ##

In this demo, we will show how to build and deploy an ASP.NET web site that enables users to browse, play, and upload their own personal videos.  We will then extend the web site to include Web APIs that power a Windows 8 experience.  Finally, the web site project will be deployed to Windows Azure Web Sites and scaled using multiple paid shared instances.

<a name="Goals" />
### Goals ###
In this demo, you will see how to:

1. Extend a Web application to communicate with a Windows 8 application
1. Add Windows Azure Media Services to upload and encode videos
1. Add real-time communication between Web and Windows 8 apps using SignalR
1. Scale an application using Windows Azure Caching
1. Deploy and manage Windows Azure apps using New Relic (optional)

<a name="Technologies" />
### Key Technologies ###

- ASP.NET MVC 4 Web API
- Windows Azure Media Services
- Windows Azure Caching
- Windows Azure Add-ons

<a name="Prerequisites" />
### System Prerequisites ###
- Visual Studio 2012 Express for Web
- Visual Studio 2012 Express for Windows 8
- [ASP.Net Fall 2012 Update] (http://www.asp.net/vnext/overview/fall-2012-update)
- [Player Framework for Windows 8 (v1.0)](http://playerframework.codeplex.com/releases/view/97333)
- [Smooth Streaming Client SDK](http://visualstudiogallery.msdn.microsoft.com/04423d13-3b3e-4741-a01c-1ae29e84fea6)
- [Windows Azure Tools for Microsoft Visual Studio 1.8](http://www.microsoft.com/windowsazure/sdk/)

<a name="Setup" />
### Setup and Configuration ###

In order to execute this demo, you first need to set up your environment by completing the following tasks: 

1. [Creating a Service Bus Namespace for the SignalR Backplane](#setup1)

1. [Creating Storage Accounts for Media and Diagnostics](#setup2)

1. [Creating a Media Services Account](#setup3)

1. [Creating a Cloud Service](#setup4)

1. [Creating a Windows Azure SQL Database (optional)](#setup5)

1. [Downloading the Publish Settings File for the Subscription](#setup6)

1. [Configuring Identity Providers](#setup7)

1. [Running the Setup Scripts](#setup8)

1. [Deploying a Cloud Service and Configuring New Relic (optional)](#setup9)

As you proceed with these manual configuration tasks, you will be required to update information in a configuration file named **Config.local.xml** that you will find in the **source** folder of the demo. This file is used by the setup scripts to configure the demo and includes, among other settings, storage, database, and service bus connection strings, working directory, cloud service names, media services account credentials, and identity provider settings.

In the **source** folder, you will find several scripts that carry out different setup and cleanup tasks including:
 
- **Setup.Local.cmd**: verifies dependencies, creates the working directory and copies the source files to this directory, updates the configuration of the solutions with the configured settings. You typically run this script once, before running the demo for the first time.
- **Cleanup.Local.cmd**: deletes the working directory and local database and resets the storage emulator. This script will allow you to reset the environment to its original state, after you have finished the demo.
- **Reset.Local.cmd**: executes the cleanup script to reset the environment and runs a reduced setup that does not verify dependencies. This script prepares the environment for running the demo again.
- **Setup.Deployment.cmd**: configures the solution used by segment #5. This script is used before deploying the solution to Windows Azure.

<a name="setup1" />
**Creating a Service Bus Namespace for the SignalR Backplane**

To create a service namespace:

1. Go to the **Windows Azure Management Portal**.

1. In the navigation pane, select **SERVICE BUS** and then click **CREATE** in the command bar.

1. In the **CREATE A NAMESPACE** dialog box, enter the **NAMESPACE NAME**, select a **REGION**, and then click the check mark to confirm the action.

	> **Note:** Make sure to select the same region for all the assets that you create in Windows Azure for this demo, typically, the one that is closest to you.

	![Creating a new Service Namespace](Images/service-bus-add-namespace.png?raw=true)

1. Select the newly created namespace, click **ACCESS KEY** in the command bar, and then copy the **CONNECTION STRING** setting to the clipboard.

	![Service Bus Namespace Access Key](Images/access-key-servicebus-namespace.png?raw=true)

1. Now, open the **Config.local.xml** file in the **source** folder, locate the **serviceBusConnectionString** setting in the **appSettings** section, and then paste the contents of the clipboard, replacing its current value. Alternatively, you may replace the individual placeholders for the namespace name and namespace key, which you can also obtain as a result of the previous step.

<a name="setup2" />
**Creating Storage Accounts for Media and Diagnostics**

To create the storage accounts:

1. Go to the **Windows Azure Management Portal**.

1. In the navigation pane, select **STORAGE**, click **NEW** in the command bar, and then **QUICK CREATE**.

1. Enter a unique subdomain for the **URL** of the storage account that you will use to store your media, select a **REGION/AFFINITY GROUP**, and then click the **CREATE STORAGE ACCOUNT** check mark.

	> **Note:** Make sure to select the same region for all the assets that you create in Windows Azure for this demo, typically, the one that is closest to you.

	![Creating a new Service Namespace](Images/storage-account-create.png?raw=true)

1. Select the newly created storage account, click **MANAGE KEYS** in the command bar, and then copy the value of the **STORAGE ACCOUNT NAME** and **PRIMARY ACCESS KEY** settings.

	![Media Service Access Key](Images/storage-account-access-keys.png?raw=true)

1. In the **appSettings** section of the **Config.local.xml** file, locate the **storageAccountConnectionString** setting and replace the placeholders for account name and account key with the corresponding values obtained in the previous step.

1. Repeat the previous procedure to create an additional storage account, this time to store diagnostics data.

1. Once the account is created and you have obtained its account name and key, locate the **diagnosticsStorageAccountConnectionString** setting in the **appSettings** section of the **Config.local.xml** file and replace the corresponding placeholders.

<a name="setup3" />
**Creating a Media Services Account**

To create a new Media Services account:

1. Go to the **Windows Azure Management Portal**.

1. In the navigation pane, select **MEDIA SERVICES**, click **NEW** in the command bar, and then **QUICK CREATE**.

1. Enter the **NAME** of the service, select a **REGION**, select the **STORAGE ACCOUNT** that you created previously to hold your media from the drop-down list, and then click the **CREATE MEDIA SERVICE** check mark.

	> **Note:** Make sure to select the same region for all the assets that you create in Windows Azure for this demo, typically, the one that is closest to you.

	![Creating the Media Service](Images/create-media-service.png?raw=true)

1. Select the newly created service, click **MANAGE KEYS** in the command bar, and then copy the value of the **MEDIA SERVICE ACCOUNT NAME** and **PRIMARY MEDIA SERVICE ACCESS KEY** settings.

	![Media Service Access Key](Images/media-service-access-keys.png?raw=true)

1. In the **appSettings** section of the **Config.local.xml** file, locate the **mediaServicesAccountName** and **mediaServicesAccountKey** settings and replace the placeholders with the corresponding values obtained in the previous step.

<a name="setup4" />
**Creating a Cloud Service**

To create a new cloud service:
	
1. Go to the **Windows Azure Management Portal**.

1. In the navigation pane, select **CLOUD SERVICES**, click **NEW** in the command bar, and then **QUICK CREATE**.

1. Enter a unique subdomain for the **URL** of the cloud service, select a **REGION**, and then click the **CREATE CLOUD SERVICE** check mark.

	> **Note:** Make sure to select the same region for all the assets that you create in Windows Azure for this demo, typically, the one that is closest to you.

	![Creating the Cloud Service](Images/create-cloud-service.png?raw=true)

> **Note:** A cloud service is necessary for one of the segments in this demo that shows how to publish to a cloud service from Visual Studio. The segment walks through the steps but does not proceed with the deployment. In addition, the final, optional, segment of this demo, [Deploying and Managing Windows Azure Apps](#segment5), also requires a cloud service where you deploy the demo's solution. You may use a single cloud service for both purposes. However, if you prefer to minimize the risk of accidentally overwriting the deployment while showing the first segment, you may want to create an additional cloud service for this other segment.

1. In the **appSettings** section of the **Config.local.xml** file, locate the **cloudService** subsection and replace the placeholder in the **apiBaseUrl** setting with the name of the newly created cloud service. 

> **Note:** If you created two cloud services, one to show Visual Studio publishing and another for the optional segment, make sure that you specify the one that you intend to use for the optional segment.

<a name="setup5" />
**Creating a Windows Azure SQL Database (optional)**

The deployment for the final, optional, segment of this demo, [Deploying and Managing Windows Azure Apps](#segment5), requires the creation of a SQL Database. You may skip this section if you do not intend to show this segment.

To create the database:

1. Go to the **Windows Azure Management Portal**.

1. In the navigation pane, select **SQL DATABASES**, click **NEW** in the command bar, and then **QUICK CREATE**.

1. Enter a **DATABASE NAME**, choose a **SERVER** from the drop-down list, and then click the **CREATE SQL DATABASE** check mark.

	![Creating a Windows Azure SQL Database](Images/sql-database-create.png?raw=true)

1. Now, select the newly created database to access its **DASHBOARD** and then click **Show connection strings** under the **quick glance** section. Take note of the ADO.NET connection string.

	![SQL Database Connection String](Images/sql-database-connection-strings.png?raw=true)

1. In the **appSettings** section of the **Config.local.xml** file, locate the **cloudService** subsection and replace the placeholder for the **dbConnectionString** setting with the value obtained in the previous step. Make sure to replace the password placeholder in the connection string (see {your_password_here}) with your SQL Database server password.

<a name="setup6" />
**Downloading the Publish Settings File for the Subscription**

1. Go to [https://windows.azure.com/download/publishprofile.aspx]() to download the publish settings file for your subscription. Save the file to your **Downloads** folder. You will need this file during the demo.

<a name="setup7" />
**Configuring Identity Providers**

The application used in this demo allows users to log in using one of several configured identity providers. To configure them:

1. Choose one or more identity providers from the list below and follow the steps to register your app with that provider. Remember to make a note of the client identity and secret values generated by a provider. 
	- [Facebook] [1]
	- [Twitter] [2]

[1]: https://www.windowsazure.com/en-us/develop/mobile/how-to-guides/register-for-facebook-authentication/
[2]: https://www.windowsazure.com/en-us/develop/mobile/how-to-guides/register-for-twitter-authentication/

	Note that you need to create at least two entries in each provider, one for running the application locally using [http://127.0.0.1:81]() as the return (or callback) URL and the other for the URL of the site when deployed to Windows Azure Web Sites (e.g. [http://{YOUR-SITE-NAME}.azurewebsites.net/]()). 

	>**Important:** Make sure that the URL for the Windows Azure Web Sites scenario that you specify to the identity provider is available when you deploy the site during the demo, so choose a site name that is unlikely to be in use. Alternatively, you may create the site in advance to reserve its name and, during the demo, simply walk through the process without creating the site. 
	
	In addition, an (optional) segment in this demo requires you to deploy the application as a cloud service. If you intend to complete this segment, you also need to configure a third entry for the cloud service's URL (e.g. [http://{YOUR-CLOUD-SERVICE-NAME}.cloudapp.net]()). Use the cloud service name that you created earlier, as described in [Creating a Cloud Service](#setup4).

	> **Note:** Currently, the Windows 8 application only supports authentication using **Facebook** or **Twitter** accounts

1. In the **Config.local.xml** file, enter the information generated by the identity provider for each configured deployment scenario, local, web site, and cloud service. In each of the subsections of the **appSettings** section, **local**, **website**, and **cloudService**, enter the corresponding application ID (or consumer key) and application secret (or consumer secret) pairs returned by the identity provider. Also, in the **appSettings** section locate the **website** subsection and replace the placeholder in the **apiBaseUrl** setting with the name of the site. 

1. Save the **Config.local.xml** file.

<a name="setup8" />
**Running the Setup Scripts**

Once you have completed the previous tasks and updated the **Config.local.xml** file with the necessary settings, you may now run the setup scripts that will first copy the solutions to the working folder and then configure them.

1. Ensure that you have saved any changes to the **Config.local.xml** file.

1. Run the **Setup.local.cmd** script that you will find in the **source** folder of the demo's install location.

<a name="setup9" />
**Deploying the Application as a Cloud Service and Configuring New Relic (optional)**

The following procedure sets up the deployment used for the final, optional, segment of this demo, [Deploying and Managing Windows Azure Apps](#segment5). It shows how to acquire the New Relic (free) add-on from the Windows Azure Store, configure it for the solution, and deploy the application to a cloud service.

1. In the **Windows Azure Management Portal**, click **New** and then **Store**.

1. Select the **New Relic** from the list of available add-ons.

	![Adding New Relic Add-On](Images/adding-new-relic-add-on.png?raw=true "Adding New Relic Add-On")

1. Select the **Standard (FREE)** plan, enter a **NAME** for the add-on, and then click **Next**.
	![Personalize-new-relic-add-on](Images/personalize-new-relic-add-on.png?raw=true "Adding New Relic Add-On")

1. Once created, select the add-on and click **Connection Info** in the command bar. Copy the value of the **License Key** to the clipboard.

	![New Relic Connection Info](Images/NewRelic-ConnectionInfo.png?raw=true "New Relic Connection Info")

	![Azure License Key](Images/NewRelic-License-Key-Azure.png?raw=true "Azure License Key")

1. In Visual Studio, open the **BuildClips.sln** stored in the working directory, inside the **BuildClips.Web\BuildClipsDeploy** folder.

1. Open the **Package Manager Console**, select **BuildClips** in the **Default Project** drop-down list, and install the **NewRelicWindowsAzure** NuGet package using the following command:

		Install-Package NewRelicWindowsAzure

	![Adding New Relic dependencies](Images/NewRelicWindowsAzure-package.png?raw=true "Adding New Relic dependencies")

1. When prompted, enter the obtained **License Key** and the **Name** chosen when creating the add-on.

	![Setting New Relic License Key](Images/NewRelic-License-Key.png?raw=true "Setting New Relic License Key")

1. Open the **_Layout.cshtml** file in the **Views\Shared** folder and add the following lines to enable Browser-side metrics on New Relic dashboard.

	<!-- mark:6,11 -->
````HTML
<html lang="en">
	<head>
		...
		@Scripts.Render("~/bundles/modernizr")
		@Scripts.Render("~/bundles/jquery", "~/bundles/jqueryui")
		@Html.Raw(NewRelic.Api.Agent.NewRelic.GetBrowserTimingHeader())
	</head>
	<body>
		...
		@RenderSection("scripts", required: false)
        @Html.Raw(NewRelic.Api.Agent.NewRelic.GetBrowserTimingFooter())
    </body>
</html>
````

1. Repeat the previous step with the **_Layout.Login.cshtml** file in the **Views\Shared** folder.

	<!-- mark:5,10 -->
````HTML
<html lang="en">
	<head>
		...
		@Scripts.Render("~/bundles/modernizr")
		@Html.Raw(NewRelic.Api.Agent.NewRelic.GetBrowserTimingHeader())
	</head>
	<body>
		...
		@RenderSection("scripts", required: false)
        @Html.Raw(NewRelic.Api.Agent.NewRelic.GetBrowserTimingFooter())
    </body>
</html>
````


1. Now, right-click the **BuildClips.Azure** project in **Solution Explorer** and then select **Publish**.

1. In the **Publish Windows Azure Application** wizard, if this the first time you publish an application to the Windows Azure subscription that you will use for this demo, choose **Import**, browse to the **Downloads** folder and select the publish settings file that you downloaded earlier from the Management Portal. 

1. Now, choose the subscription and then click **Next**.

1. In the **Settings** page of the wizard, make sure to select the service that you created earlier in the **Cloud Service** drop-down list, select the **Production** environment, the **Release** build configuration, the **Cloud** service configuration, and then click **Next**.

	![Publishing the Cloud Service](Images/cloud-service-publish.png?raw=true "Publishing the Cloud Service")

1. Finally, in the **Summary** page, verify that you have entered the correct settings and then click **Publish**.

	![Publishing Settings Summary](Images/cloud-service-publish-summary.png?raw=true "Publishing Settings Summary")

1. Wait for the deployment to complete.

1. Finally, go to the deployed application's URL and sign in.

	> Note: You may sign in using one of the registered identity providers. Alternatively, you can register as a local user by going to /Account/Register.

1. In the home page, select **Upload** in the navigation bar, and then upload a few sample videos from the **[installdir]\setup\assets\videos** directory. This will exercise the application and generate metrics that can be displayed by New Relic.

<a name="Demo" />
## Demo ##
This demo is composed of the following segments:

1. [Building and Extending Web Apps to Windows 8](#segment1)
1. [Windows Azure Media Services](#segment2)
1. [Building N-Tier Cloud Services with Real-Time Communications](#segment3)
1. [Scaling with Windows Azure Caching](#segment4)
1. [Deploying and Managing Windows Azure apps](#segment5)

$$$segment1

$$$segment2

$$$segment3

$$$segment4

$$$segment5