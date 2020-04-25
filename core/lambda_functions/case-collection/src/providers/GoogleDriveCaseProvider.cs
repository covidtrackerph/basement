using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using CaseCollection.Models;
using CsvHelper;
using CsvHelper.Configuration;
using CsvHelper.TypeConversion;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;

namespace CaseCollection.Providers
{
    internal class GoogleDriveCaseProvider : ICaseProvider
    {
        private readonly HttpClient _client;
        private readonly string _apiKey;

        public GoogleDriveCaseProvider(HttpClient client, IOptions<DriveConfig> options)
        {
            _client = client;
            _apiKey = options.Value.ApiKey;
        }

        public async Task<IEnumerable<Case>> GetCasesAsync()
        {
            var covidMainFolder = await ListFilesAsync(CovidData.RootFolderId);

            var latestDataDropFolder = covidMainFolder.Files
                .Where(q => q.Name?.Contains("DOH COVID Data Drop_") ?? false)
                .OrderByDescending(q => q.CreatedTime).FirstOrDefault();

            var latestCSV = await ListFilesAsync(latestDataDropFolder.Id);

            var latestCaseCSVFile = latestCSV.Files
                .Where(q => (q.Name?.Contains("Case Information") ?? false) && q.MimeType == "text/csv")
                .OrderByDescending(q => q.CreatedTime).FirstOrDefault();

            var caseCSV = await GetFileAsync(latestCaseCSVFile.Id);

            var csv = await GetCsvAsync(caseCSV.WebContentLink);

            return ParseCases(csv);
        }

        private async Task<DriveFile> ListFilesAsync(string fileId)
        {
            var queryParams = $"key={_apiKey}";
            queryParams += "&supportsAllDrives=true";
            queryParams += "&fields=kind,files(kind,name,id,mimeType,createdTime)";
            queryParams += "&spaces=drive";
            queryParams += $"&q='{fileId}' in parents";
            _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            var response = await _client.GetAsync($"drive/v3/files?{queryParams}");
            var body = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                return JsonConvert.DeserializeObject<DriveFile>(body);
            }
            else
            {
                throw new Exception(body);
            }
        }

        private async Task<DriveFile> GetFileAsync(string fileId)
        {
            var queryParams = $"key={_apiKey}";
            queryParams += "&fields=kind,name,id,mimeType,createdTime,webContentLink";
            _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            var response = await _client.GetAsync($"drive/v3/files/{fileId}?{queryParams}");
            var body = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                return JsonConvert.DeserializeObject<DriveFile>(body);
            }
            else
            {
                throw new Exception(body);
            }
        }

        private async Task<string> GetCsvAsync(string downloadLink)
        {
            _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("text/csv"));

            var response = await _client.GetAsync(downloadLink);
            var content = await response.Content.ReadAsStringAsync();
            if (response.IsSuccessStatusCode)
            {
                return content;
            }
            else
            {
                throw new Exception(content);
            }
        }

        public IEnumerable<Case> ParseCases(string caseCsv)
        {
            using (var reader = new StringReader(caseCsv))
            using (var csv = new CsvReader(reader, CultureInfo.InvariantCulture))
            {
                try
                {
                    var records = csv.GetRecords<DriveCaseCode>().ToList();

                    return records.Select(q => new Case
                    {
                        CaseNo = q.CaseCode,
                        Age = q.Age,
                        AgeGroup = q.AgeGroup,
                        Sex = q.Sex,
                        DateConfirmed = q.DateRepConf,
                        DateRecovered = q.DateRecover,
                        DateDied = q.DateDied,
                        DateRemoved = q.DateRepRem,
                        RemovalType = q.RemovalType,
                        Admitted = q.Admitted == "Yes",
                        Region = q.RegionRes,
                        Residence = q.ProvCityRes,
                        InsertedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    });
                }
                catch (Exception exc)
                {
                    throw exc;
                }
            }
        }
    }
}