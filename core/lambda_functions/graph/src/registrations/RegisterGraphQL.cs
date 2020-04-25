using GraphQL;
using GraphQL.Server;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Graph.Registrations
{
    internal class RegisterGraphQL : IServiceRegistration
    {
        public void RegisterAppServices(IServiceCollection services, IConfiguration configuration)
        {
            services.AddScoped<IDependencyResolver>(q => new FuncDependencyResolver(q.GetRequiredService));

            services.AddScoped<CovidTrackerSchema>();
            services.AddGraphQL(o => {
                o.ExposeExceptions = true;
            })
            .AddGraphTypes(ServiceLifetime.Scoped);
        }
    }
}