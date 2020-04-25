using GraphQL;

namespace Graph
{
    public class GraphResult
    {
        public object Data { get; set; }
    }

    public class GraphResultError : GraphResult
    {
        public ExecutionErrors Errors { get; set; }
    }
}