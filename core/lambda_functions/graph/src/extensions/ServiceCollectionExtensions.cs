using System;
using System.Linq;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Graph
{
    public static class ServiceRegistrationExtension
    {
        public static void AddServiceRegistrations(this IServiceCollection services, IConfiguration configuration)
        {
            var appServices = typeof(Startup).Assembly.DefinedTypes
                            .Where(x => typeof(IServiceRegistration)
                            .IsAssignableFrom(x) && !x.IsInterface && !x.IsAbstract)
                            .Select(Activator.CreateInstance)
                            .Cast<IServiceRegistration>().ToList();

            appServices.ForEach(svc => svc.RegisterAppServices(services, configuration));
        }
    }
}