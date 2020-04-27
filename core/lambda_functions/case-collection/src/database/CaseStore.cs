using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using CaseCollection.Models;
using PostgreSQLCopyHelper;
using Dapper;
using Microsoft.Extensions.Options;
using Npgsql;

namespace CaseCollection
{
    public class CaseStore : ICaseStore
    {
        private readonly Func<NpgsqlConnection> _connectionFactory;

        public CaseStore(IOptions<StoreConfig> options)
        {
            _connectionFactory = () => new NpgsqlConnection(options.Value.ConnectionString);// new NpgsqlConnection(options.Value.ConnectionString);
        }

        public async Task<int> DeleteAllAsync()
        {
            var sql = @"
            delete from
                covidtracker.cases
            where true;
           ";
            using (var con = _connectionFactory())
            {
                return await con.ExecuteAsync(sql);
            }
        }

        public async Task InsertAllAsync(IEnumerable<Case> cases)
        {
            var copyHelper = new PostgreSQLCopyHelper<Case>("covidtracker", "cases")
                            .MapVarchar("caseno", q => q.CaseNo)
                            .MapInteger("age", q => q.Age)
                            .MapVarchar("agegroup", q => q.AgeGroup)
                            .MapVarchar("sex", q => q.Sex)
                            .MapTimeStamp("dateconfirmed", q => q.DateConfirmed)
                            .MapTimeStamp("daterecovered", q => q.DateRecovered)
                            .MapTimeStamp("datedied", q => q.DateDied)
                            .MapVarchar("removaltype", q => q.RemovalType)
                            .MapTimeStamp("dateremoved", q => q.DateRemoved)
                            .MapBoolean("admitted", q => q.Admitted)
                            .MapVarchar("healthstatus", q => q.HealthStatus)
                            .MapVarchar("region", q => q.Region)
                            .MapVarchar("province", q => q.Province)
                            .MapVarchar("city", q => q.City)
                            .MapTimeStamp("insertedat", q => q.InsertedAt)
                            .MapTimeStamp("updatedat", q => q.UpdatedAt);

            using (var con = _connectionFactory())
            {
                await con.OpenAsync();
                await copyHelper.SaveAllAsync(con, cases);
            }
        }
    }
}