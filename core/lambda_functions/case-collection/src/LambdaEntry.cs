
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Amazon.SecretsManager;
using Microsoft.Extensions.DependencyInjection;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.LambdaJsonSerializer))]
namespace CaseCollection
{
    public class LambdaEntry
    {
        private readonly ICaseProvider _provider;
        private readonly ICaseStore _store;

        public LambdaEntry()
        {
            var startup = new Startup();
            var serviceCollection = new ServiceCollection();
            startup.ConfigureServices(serviceCollection);
            var sp = serviceCollection.BuildServiceProvider();
            _provider = sp.GetService<ICaseProvider>();
            _store = sp.GetService<ICaseStore>();
        }

        public async Task<APIGatewayProxyResponse> RunAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            try
            {
                context.Logger.LogLine(request.Body);
                context.Logger.LogLine("Fetching cases from source");
                var cases = await _provider.GetCasesAsync();
                context.Logger.LogLine("Deleting all records");
                var affected = await _store.DeleteAllAsync();
                context.Logger.LogLine($"Deleted {affected} records");
                await _store.InsertAllAsync(cases);
                context.Logger.LogLine($"Inserted {cases.Count()} cases");
                return new APIGatewayProxyResponse
                {
                    StatusCode = (int)HttpStatusCode.OK,
                    Body = "{\"status\": \"success\"}",
                    Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
                };
            }
            catch (Exception exc)
            {
                context.Logger.LogLine(exc.Message);
                context.Logger.LogLine(exc.StackTrace);
                return new APIGatewayProxyResponse
                {
                    StatusCode = (int)HttpStatusCode.BadRequest,
                    Body = "{\"status\": \"failed\", \"error\": \"" + exc.Message + "\"}",
                    Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
                };
            }
        }
    }


}