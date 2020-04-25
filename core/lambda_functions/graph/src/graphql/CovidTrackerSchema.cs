using GraphQL;
using GraphQL.Types;

namespace Graph {
    public class CovidTrackerSchema : Schema
    {
        public CovidTrackerSchema(IDependencyResolver resolver) : base(resolver)
        {
            Query = resolver.Resolve<CovidTrackerQuery>(); 
        }
    }
}