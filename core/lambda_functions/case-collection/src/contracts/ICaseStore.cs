using System.Collections.Generic;
using System.Threading.Tasks;
using CaseCollection.Models;

namespace CaseCollection
{
    public interface ICaseStore
    {
        Task InsertAllAsync(IEnumerable<Case> cases);    
        Task<int> DeleteAllAsync();
    }
}