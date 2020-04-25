using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Graph.Registrations
{
    internal class RegisterOptions : IServiceRegistration
    {
        public void RegisterAppServices(IServiceCollection services, IConfiguration configuration)
        {
            services.Configure<StoreConfig>(configuration.GetSection(EnvironmentVariables.CovidTrackerDbConnectionSecretId));
        }
    }
}