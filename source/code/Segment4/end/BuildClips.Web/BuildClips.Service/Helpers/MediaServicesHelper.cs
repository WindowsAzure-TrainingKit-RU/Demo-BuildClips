namespace BuildClips.Services
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Net;
    using System.Threading;

    using Microsoft.Win32;
    using Microsoft.WindowsAzure;
    using Microsoft.WindowsAzure.MediaServices.Client;
    using Microsoft.WindowsAzure.StorageClient;

    public static class MediaServicesHelper
    {
        private const string VideoFileTitlePrefix = "Video";
        private const string Mp4ContentType = "video/mp4";
        private const string Mp4FileExtension = "mp4";
        private const string ManifestFileExtension = "ism";
        private const string H264SmoothStreamingEncodingPreset = "H264 Smooth Streaming SD 16x9";
        private const string EncoderProcessorId = "nb:mpid:UUID:70bdc2c3-ebf4-42a9-8542-5afc1e55d217";
        private const int CheckFirstManifestAvailabilityWaitTime = 45;
        private const int CheckManifestAvailabilityWaitTime = 10;

        public static IAsset CreateAssetFromStream(this CloudMediaContext context, string name, Stream stream)
        {
            var temporalDirectoryPath = Path.GetTempPath();

            var videoFileName = string.Format(
                "{0}_{1}{2}", MediaServicesHelper.VideoFileTitlePrefix, Guid.NewGuid(), Path.GetExtension(name));
            var videoFilePath = Path.Combine(temporalDirectoryPath, videoFileName);

            using (var fileStream = File.Create(videoFilePath))
            {
                stream.CopyTo(fileStream);
            }

            var asset = context.Assets.Create(name, AssetCreationOptions.None);

            asset.AlternateId = videoFileName;

            var assetFile = asset.AssetFiles.Create(videoFileName);
            assetFile.Upload(videoFilePath);

            File.Delete(videoFilePath);

            return asset;
        }

        public static string ConvertAssetToSmoothStreaming(this CloudMediaContext context, IAsset asset)
        {
            var processor = context.MediaProcessors.Where(m => m.Id == MediaServicesHelper.EncoderProcessorId).FirstOrDefault();

            var job = context.Jobs.Create(asset.Name);

            var task = job.Tasks.AddNew(
                "MP4->SS Task",
                processor,
                MediaServicesHelper.H264SmoothStreamingEncodingPreset,
                TaskOptions.None);

            task.InputAssets.Add(asset);
            task.OutputAssets.AddNew(asset.Name + "_encoded", true, AssetCreationOptions.None);

            job.Submit();

            return job.Id;
        }

        public static string PublishJobAsset(this CloudMediaContext context, string jobId)
        {
            var job = context.Jobs.Where(j => j.Id == jobId).FirstOrDefault();
            var asset = job.OutputMediaAssets[0];

            // Since the ODATA Linq provider doesn't support the First method, the files are first filtered using Where
            // Then, the First result of the filtered list is selected
            var manifestFile =
                asset.AssetFiles.Where(f => f.Name.EndsWith(string.Concat(".", MediaServicesHelper.ManifestFileExtension))).First();

            var originLocator = context.CreateOriginLocator(asset);

            var encodedVideoUrl = originLocator.GetFileUrl(manifestFile);

            BlockUntilFileIsAvailable(encodedVideoUrl);

            return encodedVideoUrl;
        }

        public static string GetAssetVideoUrl(this CloudMediaContext context, IAsset asset)
        {
            var locator = context.CreateSasLocator(asset, AccessPermissions.Read, TimeSpan.FromDays(30));

            context.ChangeContentTypeForFiles(asset);

            return locator.GetFileUrl(asset.AlternateId);
        }

        public static IJob GetJob(this CloudMediaContext context, string jobId)
        {
            return context.Jobs.Where(j => j.Id == jobId).FirstOrDefault();
        }

        private static ILocator CreateOriginLocator(this CloudMediaContext context, IAsset asset)
        {
            var streamingPolicy = context.AccessPolicies.Create(
                "Streaming policy", TimeSpan.FromDays(1), AccessPermissions.Read);

            return context.Locators.CreateLocator(
                LocatorType.OnDemandOrigin,
                asset, streamingPolicy, DateTime.UtcNow.AddMinutes(-5));
        }

        private static string GetFileUrl(this ILocator locator, IAssetFile file)
        {
            return locator.GetFileUrl(file.Name);
        }

        private static string GetFileUrl(this ILocator locator, string fileName)
        {
            var url = string.Empty;

            if (locator.Type == LocatorType.Sas)
            {
                url = locator.GetSasFileUrl(fileName);
            }
            else if (locator.Type == LocatorType.OnDemandOrigin)
            {
                url = locator.GetOriginFileUrl(fileName);
            }

            return url;
        }

        private static string GetOriginFileUrl(this ILocator locator, string fileName)
        {
            return locator.Path + fileName + "/manifest";
        }

        private static string GetSasFileUrl(this ILocator locator, string fileName)
        {
            string url;

            var queryPos = locator.Path.IndexOf('?');
            if (queryPos < 0)
            {
                var addSlash = locator.Path.EndsWith("/") ? string.Empty : "/";
                url = string.Concat(locator.Path, addSlash, fileName);
            }
            else
            {
                var slashPos = locator.Path.IndexOf("/?", StringComparison.InvariantCultureIgnoreCase);
                var slash = slashPos + 1 == queryPos ? string.Empty : "/";
                url = locator.Path.Replace("?", string.Concat(slash, fileName, "?"));
            }

            return url;
        }

        public static ILocator CreateSasLocator(this CloudMediaContext context, IAsset asset, AccessPermissions permissions, TimeSpan duration)
        {
            var accessPolicy = context.AccessPolicies.Create("Sas policy", duration, permissions);

            return context.Locators.CreateSasLocator(asset, accessPolicy, DateTime.UtcNow.AddMinutes(-5));
        }
        
        private static void BlockUntilFileIsAvailable(string fileUrl)
        {
            var uri = new Uri(fileUrl, UriKind.Absolute);

            var statusCode = HttpStatusCode.BadRequest;

            var checkManifestAvailabilityMaxCount = 1;

            while (statusCode != HttpStatusCode.OK
                   && checkManifestAvailabilityMaxCount <= MediaServicesHelper.CheckFirstManifestAvailabilityWaitTime)
            {
                var request = WebRequest.CreateDefault(uri);
                try
                {
                    var response = (HttpWebResponse)request.GetResponse();
                    statusCode = response.StatusCode;
                }
                catch (WebException exception)
                {
                    statusCode = ((HttpWebResponse)exception.Response).StatusCode;

                    Thread.Sleep(
                        TimeSpan.FromSeconds(
                            checkManifestAvailabilityMaxCount == 1
                                ? MediaServicesHelper.CheckFirstManifestAvailabilityWaitTime
                                : MediaServicesHelper.CheckManifestAvailabilityWaitTime));

                    checkManifestAvailabilityMaxCount++;
                }
            }

            if (checkManifestAvailabilityMaxCount > MediaServicesHelper.CheckFirstManifestAvailabilityWaitTime)
            {
                throw new Exception(string.Format("The file {0} is unavailable", fileUrl));
            }
        }

        // This is a workaround for a bug in the Media Services Preview where the Content-Type is not set correctly 
        // on the blob during ingest from the SDK. This results in the Content-Type being returned from the SAS URL as 
        // application/octet-stream.
        // The method assumes that at least one locator has already been created previously, which it uses to obtain the 
        // asset container name. 
        // Note that the call to this method can be removed once the bug is fixed.
        private static void ChangeContentTypeForFiles(this CloudMediaContext context, IAsset asset)
        {
            var locator = asset.Locators.FirstOrDefault();
            if (locator != null)
            {
                var connectionString = CloudConfigurationManager.GetSetting("MediaServicesStorageAccountConnectionString");
                var account = CloudStorageAccount.Parse(connectionString);
                var client = account.CreateCloudBlobClient();

                var containerUrl = new Uri(locator.Path).GetLeftPart(UriPartial.Path);
                foreach (var assetFile in asset.AssetFiles)
                {
                    var fileExtension = Path.GetExtension(assetFile.Name);
                    string contentType = MediaServicesHelper.MapExtensionToContentType(fileExtension);
                    if (contentType != null)
                    {
                        var blobPath = containerUrl + "/" + assetFile.Name;
                        var blob = client.GetBlobReference(blobPath);
                        blob.Properties.ContentType = contentType;
                        blob.SetProperties();
                    }
                }
            }
        }

        private static string MapExtensionToContentType(string extension)
        {
            var registryKey = Registry.ClassesRoot.OpenSubKey(extension.ToLower());
            if (registryKey != null)
            {
                var contentType = registryKey.GetValue("Content Type");
                if (contentType != null)
                {
                    return contentType.ToString();
                }
            }

            return null;
        }
    }
}
