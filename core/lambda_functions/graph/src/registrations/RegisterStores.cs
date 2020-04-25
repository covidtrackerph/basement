using Graph.Stores;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Graph.Registrations
{
    internal class RegisterStores : IServiceRegistration
    {
        public void RegisterAppServices(IServiceCollection services, IConfiguration configuration)
        {
            services.AddScoped<ICaseStore, CaseStore>();
        }
    }
}