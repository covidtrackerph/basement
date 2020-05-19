using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using CaseCollection.Models;
using CsvHelper;
using CsvHelper.Configuration;
using CsvHelper.TypeConversion;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.parser;
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
            // Extract main drive ID from bit.ly request headers
            string rootPDFId;
            using (var client = new HttpClient())
            {
                var d = await client.GetAsync($"http://bit.ly/datadropph");
                var path = d.RequestMessage.RequestUri.AbsolutePath;
                rootPDFId = path.Split('/').LastOrDefault();
            }

            var covidMainFolder = await ListFilesAsync(rootPDFId);

            // Get the PDF File
            var pdfDriveFileInfo = covidMainFolder.Files.Where(q => q.Name?.Contains("READ ME") ?? false).OrderByDescending(q => q.CreatedTime).FirstOrDefault();
            var pdfDriveFile = await GetFileAsync(pdfDriveFileInfo.Id);
            var pdf = await DownloadFileAsync(pdfDriveFile.WebContentLink, "text/pdf");

            var doc = ExtractTextFromPdf(pdf);

            // Get the bit.ly link

            var index = doc.IndexOf("Link to DOH Data Drop");
            var linkString = doc.Substring(index);
            var newLineIndex = linkString.IndexOf('\n');
            var colonIndex = linkString.IndexOf(':') + 1;
            var bitLyURL = linkString.Substring(colonIndex, newLineIndex - colonIndex);
            bitLyURL = bitLyURL.Trim();
            string driveId;

            // Extract drive ID from bit.ly request headers
            using (var client = new HttpClient())
            {
                var d = await client.GetAsync($"https://{bitLyURL}");
                var path = d.RequestMessage.RequestUri.AbsolutePath;
                driveId = path.Split('/').LastOrDefault();
            }

            // Download the csv
            var latestCSVDriveInfo = await ListFilesAsync(driveId);
            var latestCaseCSVDriveFileInfo = latestCSVDriveInfo.Files
                .Where(q => (q.Name?.Contains("Case Information") ?? false) && q.MimeType == "text/csv")
                .OrderByDescending(q => q.CreatedTime).FirstOrDefault();
            var caseCSV = await GetFileAsync(latestCaseCSVDriveFileInfo.Id);
            var csv = await DownloadFileAsync(caseCSV.WebContentLink, "text/csv");
            var csvString = Encoding.UTF8.GetString(csv);

            return ParseCases(csvString);
        }

        public static string ExtractTextFromPdf(byte[] path)
        {
            using (PdfReader reader = new PdfReader(path))
            {
                StringBuilder text = new StringBuilder();
                for (int i = 1; i <= reader.NumberOfPages; i++)
                {
                    text.Append(PdfTextExtractor.GetTextFromPage(reader, i));
                }
                return text.ToString();
            }
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

        private async Task<byte[]> DownloadFileAsync(string downloadLink, string fileType)
        {
            _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue(fileType));

            var response = await _client.GetAsync(downloadLink);
            var content = await response.Content.ReadAsByteArrayAsync();
            if (response.IsSuccessStatusCode)
            {
                return content;
            }
            else
            {
                throw new Exception("Error downloading file");
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
                        Province = q.ProvRes,
                        City = q.CityMunRes,
                        HealthStatus = q.HealthStatus,
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