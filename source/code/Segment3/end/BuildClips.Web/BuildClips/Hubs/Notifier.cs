using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR.Hubs;
using BuildClips.Services.Models;

namespace BuildClips.Hubs
{
    public class Notifier : Hub
    {
        public void VideoUpdated(int videoId, JobStatus status)
        {
            Clients.All.onVideoUpdate(videoId, status);
        }
    }
}