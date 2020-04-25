using System;
using CsvHelper.Configuration.Attributes;

namespace CaseCollection.Providers
{
    public class DriveCase
    {
        [TypeConverter(typeof(IntConverter))]
        public int Age { get; set; }

        public string AgeGroup { get; set; }

        public string Sex { get; set; }

        public DateTime? DateRepConf { get; set; }

        public DateTime? DateRecover { get; set; }

        public DateTime? DateDied { get; set; }

        // Recovered, Died or null
        public string RemovalType { get; set; }

        /// Date of removal
        public DateTime? DateRepRem { get; set; }

        // Yes, No or null
        public string Admitted { get; set; }

        // Region residence
        public string RegionRes { get; set; }

        // Province residence
        public string ProvCityRes { get; set; }
    }

    public class DriveCaseCode : DriveCase
    {
        public string CaseCode { get; set; }
    }

    public class DriveCaseNo : DriveCase
    {
        public string CaseNo { get; set; }
    }
}
