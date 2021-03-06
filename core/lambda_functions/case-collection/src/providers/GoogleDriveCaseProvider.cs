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
using iText.IO.Source;
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas.Parser;
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
                var d = await client.GetAsync($"https://bit.ly/datadropph");
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
            var newLineIndex = linkString.IndexOf('\n') + 1;
            linkString = linkString.Substring(newLineIndex);
            var colonIndex = linkString.IndexOf('\n');
            var bitLyURL = linkString.Substring(0, colonIndex);

            bitLyURL = bitLyURL.Trim();
            string driveId;

            // Extract drive ID from bit.ly request headers
            using (var client = new HttpClient())
            {
                var d = await client.GetAsync($"{bitLyURL}");
                var path = d.RequestMessage.RequestUri.AbsolutePath;
                driveId = path.Split('/').LastOrDefault();
            }

            // Download the csv
            var latestCSVDriveInfo = await ListFilesAsync(driveId);
            var latestCaseCSVDriveFileInfo = latestCSVDriveInfo.Files
                .Where(q => (q.Name?.Contains("Case Information") ?? false) && q.MimeType == "text/csv")
                .OrderByDescending(q => q.CreatedTime).FirstOrDefault();
            var caseCSV = await GetFileAsync(latestCaseCSVDriveFileInfo.Id);
            var csv = await DownloadFileAsStreamAsync(caseCSV.WebContentLink, "text/csv");
            // var csvString = Encoding.UTF8.GetString(csv);

            return ParseCasesStream(csv);
        }

        public static string ExtractTextFromPdf(byte[] path)
        {
            var source = new RandomAccessSourceFactory().CreateSource(new MemoryStream(path).ToArray());
            using (PdfReader reader = new PdfReader(source, new ReaderProperties()))
            using (PdfDocument pdfDoc = new PdfDocument(reader))
            {
                StringBuilder text = new StringBuilder();
                for (int i = 1; i <= pdfDoc.GetNumberOfPages(); i++)
                {
                    var pageText = PdfTextExtractor.GetTextFromPage(pdfDoc.GetPage(i));
                    text.Append(pageText);
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

        private async Task<Stream> DownloadFileAsStreamAsync(string downloadLink, string fileType)
        {
            _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue(fileType));

            var response = await _client.GetAsync(downloadLink);
            var content = await response.Content.ReadAsStreamAsync();
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
                        DateRemoved = q.DateDied != null ? q.DateDied : q.DateRecover,
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

        public IEnumerable<Case> ParseCasesStream(Stream caseCsv)
        {
            using (var reader = new StreamReader(caseCsv))
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
                        DateRemoved = q.DateDied != null ? q.DateDied : q.DateRecover,
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