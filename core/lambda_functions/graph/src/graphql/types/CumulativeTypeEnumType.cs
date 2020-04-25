using Graph.Models;
using GraphQL.Types;
namespace Graph
{
    public class CumulativeTypeEnumType : EnumerationGraphType<Accumulate>
    {
        public CumulativeTypeEnumType()
        {
            Name = "Type";
            Description = "Type of accumulation";
        }
    }
}