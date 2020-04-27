using System;

namespace CaseCollection.Models
{
    public class Case
    {
        public long CaseId { get; set; }
        public string CaseNo { get; set; }
        public int? Age { get; set; }
        public string AgeGroup { get; set; }
        public string Sex { get; set; }
        public DateTime? DateConfirmed { get; set; }
        public DateTime? DateRecovered { get; set; }
        public DateTime? DateDied { get; set; }
        public string RemovalType { get; set; }
        public DateTime? DateRemoved { get; set; }
        public bool? Admitted { get; set; }
        public string HealthStatus { get; set; }
        public string Region { get; set; }
        public string Province { get; set; }
        public string City { get; set; }
        public DateTime? InsertedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}