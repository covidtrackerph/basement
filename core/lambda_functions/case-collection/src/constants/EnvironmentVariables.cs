using System;

namespace CaseCollection
{
    public static class EnvironmentVariables
    {
        private const string DRIVE_CONFIG_SECRET_ID = "DRIVE_CONFIG_SECRET_ID";
        private const string COVIDTRACKER_DB_CONNECTION_SECRET_ID = "COVIDTRACKER_DB_CONNECTION_SECRET_ID";

        public static string DriveConfigSecretId = Environment.GetEnvironmentVariable(DRIVE_CONFIG_SECRET_ID);
        public static string CovidTrackerDbConnectionSecretId = Environment.GetEnvironmentVariable(COVIDTRACKER_DB_CONNECTION_SECRET_ID);
        public static bool IsDevelopment = Environment.GetEnvironmentVariable("environment") == "Development";
    }
}