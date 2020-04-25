
using System;
using System.Text.Json;
using System.Threading.Tasks;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using GraphQL;
using GraphQL.Types;
using Microsoft.Extensions.DependencyInjection;
using Graph.Models;
using AutoMapper;
using System.Collections.Generic;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.LambdaJsonSerializer))]
namespace Graph
{
    public class LambdaEntry
    {
        private readonly ISchema _schema;
        private readonly IDocumentExecuter _executer;

        public LambdaEntry()
        {
            var startup = new Startup();
            var serviceCollection = new ServiceCollection();
            startup.ConfigureServices(serviceCollection);
            var sp = serviceCollection.BuildServiceProvider();
            _schema = sp.GetService<CovidTrackerSchema>();
            _executer = sp.GetService<IDocumentExecuter>();
            _schema.Initialize();
        }

        public async Task<APIGatewayProxyResponse> RunAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var query = JsonSerializer.Deserialize<GraphqlQuery>(request.Body,
                                   new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
                         );

            if (query == null) throw new ArgumentNullException(nameof(query));

            try
            {
                var execOptions = new ExecutionOptions
                {
                    Schema = _schema,
                    Query = query.Query,
                    OperationName = query.OperationName
                };

                var config = new MapperConfiguration(cfg =>
                {
                    cfg.CreateMap<ExecutionResult, GraphResult>();
                    cfg.CreateMap<ExecutionResult, GraphResultError>();
                });

                var mapper = new Mapper(config);
                string output;

                var result = await _executer.ExecuteAsync(execOptions).ConfigureAwait(false);
                var serializerOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                };
                if (result.Errors?.Count > 0)
                {
                    output = JsonSerializer.Serialize(mapper.Map<GraphResultError>(result), serializerOptions);
                }
                else
                {
                    output = JsonSerializer.Serialize(mapper.Map<GraphResult>(result), serializerOptions);
                }

                context.Logger.Log("GraphQL execution result: " + output);
                return new APIGatewayProxyResponse
                {
                    StatusCode = 200,
                    Body = output,
                    Headers = new Dictionary<string, string> {
                        { "Content-Type", "application/json" },
                        { "Access-Control-Allow-Origin", "*" },
                        { "Access-Control-Allow-Headers", "*" },
                        { "Access-Control-Allow-Method", "*" }
                    }

                };
            }

            catch (Exception ex)
            {
                context.Logger.Log("Document exexuter exception " + ex);
                return new APIGatewayProxyResponse
                {
                    StatusCode = 500,
                    Headers = new Dictionary<string, string> {
                        { "Content-Type", "application/json" },
                        { "Access-Control-Allow-Origin", "*" },
                        { "Access-Control-Allow-Headers", "*" },
                        { "Access-Control-Allow-Method", "*" }
                    }
                };
            }
        }
    }


}