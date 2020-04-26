using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Graph.Models;
using Npgsql;
using Dapper;
using Microsoft.Extensions.Options;

namespace Graph.Stores
{
    internal class CaseStore : ICaseStore
    {
        private readonly Func<NpgsqlConnection> _connectionFactory;

        public CaseStore(IOptions<StoreConfig> options)
        {
            _connectionFactory = () => new NpgsqlConnection(options.Value.ConnectionString);// new NpgsqlConnection(options.Value.ConnectionString);
        }

        public async Task<IEnumerable<Accumulation<DateTime, int>>> GetAccumulationAsync(Accumulate type)
        {
            var builder = new SqlBuilder();
            //note the 'where' in-line comment is required, it is a replacement token
            var query = @"
                with data as (
                    select
                        date_trunc('day', dateconfirmed) as date,
                        count(*)
                    from covidtracker.cases
                    /**where**/
                    group by 1
                    order by 1 asc nulls last
                )
                select 
                    date as accumulator,
                    sum(count) over (
                        order by 
                            date asc 
                        rows between unbounded 
                            preceding and 
                            current row
                    ) as value
                from data
                order by date desc
           ";

            var selector = builder.AddTemplate(query);
            string condition;
            switch (type)
            {
                case Accumulate.Admitted:
                    condition = "admitted and dateremoved is null";
                    break;
                case Accumulate.Died:
                    condition = "removaltype = 'Died'";
                    break;
                case Accumulate.Recovered:
                    condition = "removaltype = 'Recovered'";
                    break;
                default:
                case Accumulate.Total:
                    condition = "true";
                    break;
            }
            builder.Where(condition);
            using (var con = _connectionFactory())
            {
                return await con.QueryAsync<Accumulation<DateTime, int>>(selector.RawSql);
            }
        }

        public async Task<IEnumerable<AgeGenderDistribution>> GetAgeGenderDistributionAsync(Accumulate type)
        {
            var builder = new SqlBuilder();
            //note the 'where' in-line comment is required, it is a replacement token
            var query = @"
                select 
                    agegroup, 
                    sex, 
                    count(*) as value
                from 
                    covidtracker.cases
                /**where**/
                group by 
                    agegroup, sex
                order by 
                    sex;
           ";

            var selector = builder.AddTemplate(query);
            string condition;
            switch (type)
            {
                case Accumulate.Admitted:
                    condition = "admitted and dateremoved is null";
                    break;
                case Accumulate.Died:
                    condition = "removaltype = 'Died'";
                    break;
                case Accumulate.Recovered:
                    condition = "removaltype = 'Recovered'";
                    break;
                default:
                case Accumulate.Total:
                    condition = "true";
                    break;
            }
            builder.Where(condition);
            using (var con = _connectionFactory())
            {
                return await con.QueryAsync<AgeGenderDistribution>(selector.RawSql);
            }
        }

        public async Task<IEnumerable<Case>> GetAllAsync()
        {
            var query = @"
                select
                    *
                from
                    covidtracker.cases
            ";
            using (var con = _connectionFactory())
            {
                return await con.QueryAsync<Case>(query);
            }
        }

        public async Task<Case> GetByCaseNoAsync(string caseNo)
        {
            var query = @"
                select
                    *
                from
                    covidtracker.cases
                where
                    caseno = @caseNo
            ";
            using (var con = _connectionFactory())
            {
                return await con.QuerySingleAsync<Case>(query, new { caseNo });
            }
        }

        public async Task<CaseStatistic> GetStatisticsAsync()
        {
            var query = @"
                with cases as (
                    select 
                        (removaltype = 'Recovered' or daterecovered is not null) as isrecovered,
                        (removaltype = 'Died' or datedied is not null) as isdead,
                        (dateremoved is not null) as isremoved,
                        admitted,
                        dateconfirmed
                    from 
                        covidtracker.cases
                ),
                caseadmit as (
                    select 
                        isrecovered,
                        isdead,
                        (admitted and isremoved = false) as isadmitted
                    from 
                        cases
                ),
                total as (
                    select 
                        count(*) 
                    from 
                        cases
                ),
                total_new as (
                    select 
                        dateconfirmed,
                        count(*) 
                    from 
                        cases
                    group by
                        dateconfirmed
                    order by
                        dateconfirmed desc nulls last
                    limit 1
                ),
                recovered as (
                    select 
                        count(*) 
                    from 
                        cases 
                    where 
                        isrecovered
                ),
                dead as (
                    select 
                        count(*) 
                    from 
                        cases 
                    where 
                        isdead
                ),
                admitted as (
                    select 
                        count(*) 
                    from 
                        caseadmit 
                    where 
                        isadmitted
                )
                select 
                    (select count from total) as total,
                    (select count from total_new) as new,
                    (select count from recovered) as recovered,
                    (select count from dead) as dead,
                    (select count from admitted) as admitted
            ";
            using (var con = _connectionFactory())
            {
                return await con.QuerySingleAsync<CaseStatistic>(query);
            }
        }
    }
}