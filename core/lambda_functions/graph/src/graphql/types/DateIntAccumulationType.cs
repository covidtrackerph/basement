using System;
using Graph.Models;
using GraphQL.Types;
namespace Graph
{
    public class DateIntAccumulationType : ObjectGraphType<Accumulation<DateTime, int>>
    {
        public DateIntAccumulationType()
        {
            Field(q => q.Accumulator).Description("Field accumulated against");
            Field(q => q.Value, nullable: true).Description("Total value of accumulation");
        }
    }
}