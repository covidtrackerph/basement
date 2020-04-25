using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Graph
{
    public class Startup
    {
        public IConfiguration Configuration { get; }

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
            services.AddServiceRegistrations(Configuration);
        }
    }
}
