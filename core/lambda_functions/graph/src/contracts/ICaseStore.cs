using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Graph.Models;

namespace Graph
{
    public interface ICaseStore
    {
        Task<IEnumerable<Case>> GetAllAsync();
        Task<Case> GetByCaseNoAsync(string caseNo);
        Task<CaseStatistic> GetStatisticsAsync();
        Task<IEnumerable<Accumulation<DateTime, int>>> GetAccumulationAsync(Accumulate type);
        Task<IEnumerable<AgeGenderDistribution>> GetAgeGenderDistributionAsync(Accumulate type);
    }
}