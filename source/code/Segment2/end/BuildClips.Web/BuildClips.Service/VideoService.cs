﻿namespace BuildClips.Services
{
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;

    using BuildClips.Services.Models;
    using Microsoft.WindowsAzure.MediaServices.Client;
    using Microsoft.WindowsAzure;
    
    public class VideoService
    {
        private readonly VideosContext context;

        public VideoService()
        {
            this.context = new VideosContext();
        }

        public IQueryable<Video> GetAll()
        {
            return this.context.Videos.OrderByDescending(v => v.Id);
        }

        public async Task<Video> GetVideoAsync(int id)
        {
            var token = new CancellationToken();
            var video = await this.context.Videos.FindAsync(token, id);

            return video;
        }

        public async Task<Video> CreateVideoAsync(string title, string description, string name, string type, Stream dataStream)
        {
            // Create an instance of the CloudMediaContext
            var mediaContext = new CloudMediaContext(
                                             CloudConfigurationManager.GetSetting("MediaServicesAccountName"),
                                             CloudConfigurationManager.GetSetting("MediaServicesAccountKey"));

            // Create the Media Services asset from the uploaded video
            var asset = mediaContext.CreateAssetFromStream(name, dataStream);

            // Get the Media Services asset URL
            var videoUrl = mediaContext.GetAssetVideoUrl(asset);

            // Launch the smooth streaming encoding job and store its ID
            var jobId = mediaContext.ConvertAssetToSmoothStreaming(asset);

            var video = new Video
                {
                    Title = title,
                    Description = description,
                    SourceVideoUrl = videoUrl,
                    JobId = jobId
                };

            this.context.Videos.Add(video);
            await this.context.SaveChangesAsync();

            return video;
        }

        public IEnumerable<Video> GetActiveJobs()
        {
            var activeJobs = this.context.Videos.Where(v => !string.IsNullOrEmpty(v.JobId));

            if (activeJobs.Any())
            {
                var mediaContext = new CloudMediaContext(
                                                 CloudConfigurationManager.GetSetting("MediaServicesAccountName"),
                                                 CloudConfigurationManager.GetSetting("MediaServicesAccountKey"));

                foreach (var video in activeJobs)
                {
                    var job = mediaContext.GetJob(video.JobId);
                    if (job != null)
                    {
                        // The video status will be Encoding unless the encoding job is finished or error
                        video.JobStatus = (job.State == JobState.Finished || job.State == JobState.Error)
                                            ? JobStatus.Completed : JobStatus.Encoding;

                        yield return video;
                    }
                }
            }

            yield break;
        }

        public void Publish(int id)
        {
            var video = this.context.Videos.FirstOrDefault(v => v.Id == id);

            if (video == null)
            {
                return;
            }

            var mediaContext = new CloudMediaContext(
                                             CloudConfigurationManager.GetSetting("MediaServicesAccountName"),
                                             CloudConfigurationManager.GetSetting("MediaServicesAccountKey"));
            video.EncodedVideoUrl = mediaContext.PublishJobAsset(video.JobId);

            video.JobId = null;

            this.context.SaveChanges();
        }

        public async Task DeleteVideoAsync(int id)
        {
            var video = this.context.Videos.FirstOrDefault(v => v.Id == id);

            this.context.Videos.Remove(video);

            await this.context.SaveChangesAsync();
        }
    }
}
