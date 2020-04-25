using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace CaseCollection.Providers
{
    internal class DriveFile
    {
        [JsonProperty("kind")]
        public string Kind { get; set; }

        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("mimeType")]
        public string MimeType { get; set; }

        [JsonProperty("webContentLink")]
        public string WebContentLink { get; set; }

        [JsonProperty("files")]
        public IEnumerable<DriveFile> Files { get; set; }

        [JsonProperty("createdTime")]
        public DateTime CreatedTime { get; set; }
    }
}
