using CsvHelper;
using CsvHelper.Configuration;
using CsvHelper.TypeConversion;

namespace CaseCollection
{
    public class IntConverter : DefaultTypeConverter
    {
        public override object ConvertFromString(string text, IReaderRow row, MemberMapData memberMapData)
        {
            int.TryParse(text, out int result);
            return result;
        }

        public override string ConvertToString(object value, IWriterRow row, MemberMapData memberMapData)
        {
            return value?.ToString();
        }
    }
}