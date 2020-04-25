using System;
using CaseCollection.Providers;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace CaseCollection
{
    public class Startup
    {
        private readonly IConfiguration Configuration;
        public Startup()
        {
            var builder = new ConfigurationBuilder();
            builder.AddSecretsManager(configurator: options =>
            {
                options.ConfigureSecretsManagerConfig = c =>
                {
                    c.RegionEndpoint = Amazon.RegionEndpoint.APSoutheast1;
                };
            });

            Configuration = builder.Build();
        }


        public void ConfigureServices(IServiceCollection services)
        {
            var storeconfig = Configuration.GetSection(EnvironmentVariables.CovidTrackerDbConnectionSecretId);
            services.Configure<StoreConfig>(storeconfig);
            services.Configure<DriveConfig>(Configuration.GetSection(EnvironmentVariables.DriveConfigSecretId));
            services.AddTransient<ICaseStore, CaseStore>();
            services.AddHttpClient<ICaseProvider, GoogleDriveCaseProvider>(q =>
            {
                q.BaseAddress = new Uri("https://www.googleapis.com");
            });
        }
    }
}