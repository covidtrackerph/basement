using Graph.Models;
using GraphQL.Types;
namespace Graph
{
    public class AgeGenderDistributionType : ObjectGraphType<AgeGenderDistribution>
    {
        public AgeGenderDistributionType()
        {
            Field(q => q.AgeGroup).Description("Age group");
            Field(q => q.Sex).Description("Gender");
            Field(q => q.Value).Description("Total value of distribution");
        }
    }
}