using System;

namespace Graph
{
    public static class EnvironmentVariables
    {
        private const string COVIDTRACKER_DB_CONNECTION_SECRET_ID = "COVIDTRACKER_DB_CONNECTION_SECRET_ID";
        public static string CovidTrackerDbConnectionSecretId = Environment.GetEnvironmentVariable(COVIDTRACKER_DB_CONNECTION_SECRET_ID);
        public static bool IsDevelopment = Environment.GetEnvironmentVariable("environment") == "Development";
    }
}