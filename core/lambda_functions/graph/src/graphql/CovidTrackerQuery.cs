
using Graph.Models;
using System;
using GraphQL.Types;

namespace Graph
{
    public class CovidTrackerQuery : ObjectGraphType
    {
        public CovidTrackerQuery(ICaseStore store)
        {

            Field<ListGraphType<CaseType>>(
                "cases",
                resolve:
                    context => store.GetAllAsync(),
                description: "List all cases"
            );

            Field<CaseType>(
                "case",
                arguments:
                    new QueryArguments(new QueryArgument<NonNullGraphType<StringGraphType>> { Name = "caseNo" }),
                resolve:
                    context => store.GetByCaseNoAsync(context.GetArgument<string>("caseNo")),
                description: "Get case by caseNo"
            );

            Field<CaseStatisticType>(
                "statistics",
                resolve:
                    context => store.GetStatisticsAsync(),
                description: "Get COVID19 case statistics"
            );

            Field<ListGraphType<DateIntAccumulationType>>(
                "accumulation",
                arguments:
                    new QueryArguments(new QueryArgument<NonNullGraphType<CumulativeTypeEnumType>> { Name = "type" }),
                resolve:
                    context => store.GetAccumulationAsync(context.GetArgument<Accumulate>("type")),
                description: "Get an accumulation of cases by accumulation type and ordered by date of confirmation descending"
            );

        }
    }
}