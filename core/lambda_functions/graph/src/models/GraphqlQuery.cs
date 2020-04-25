using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace Graph.Models
{
    public class GraphqlQuery
    {
        public string OperationName { get; set; }

        public string Query { get; set; }

        [JsonConverter(typeof(ObjectDictionaryConverter))]
        public Dictionary<string, object> Variables { get; set; }
    }
}