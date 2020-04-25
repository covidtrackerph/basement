using Graph.Models;
using GraphQL.Types;
namespace Graph
{
    public class CaseStatisticType : ObjectGraphType<CaseStatistic>
    {
        public CaseStatisticType()
        {
            Field(q => q.Total).Description("Total cases");
            Field(q => q.New).Description("New cases");
            Field(q => q.Dead).Description("Total admitted cases");
            Field(q => q.Recovered).Description("Total recovered cases");
            Field(q => q.Admitted).Description("Total admitted cases");
        }
    }
}