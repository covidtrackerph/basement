using System.Collections.Generic;
using System.Threading.Tasks;
using CaseCollection.Models;

namespace CaseCollection
{
    public interface ICaseProvider
    {
        Task<IEnumerable<Case>> GetCasesAsync();
    }
}
