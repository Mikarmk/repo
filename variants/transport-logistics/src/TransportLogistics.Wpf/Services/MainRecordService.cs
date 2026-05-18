using System.Collections.Generic;
using System.Data.SqlClient;
using ExamScaffold.Wpf.Models;

namespace ExamScaffold.Wpf.Services
{
    public sealed class MainRecordService
    {
        private readonly DbConnectionFactory _connectionFactory;

        public MainRecordService(ApplicationSettings settings)
        {
            _connectionFactory = new DbConnectionFactory(settings);
        }

        public List<MainRecord> GetRecords(string searchText)
        {
            var records = new List<MainRecord>();

            using (var connection = _connectionFactory.Create())
            using (var command = new SqlCommand(@"
SELECT
    RecordId,
    Title,
    Subtitle,
    Description,
    StatusText,
    DateText,
    NumericValue
FROM dbo.v_MainRecords
WHERE @SearchText = N'' OR Title LIKE N'%' + @SearchText + N'%' OR Subtitle LIKE N'%' + @SearchText + N'%'
ORDER BY Title;", connection))
            {
                command.Parameters.AddWithValue("@SearchText", searchText ?? string.Empty);
                connection.Open();

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        records.Add(new MainRecord
                        {
                            RecordId = reader.GetInt32(0),
                            Title = reader.GetString(1),
                            Subtitle = reader.GetString(2),
                            Description = reader.GetString(3),
                            StatusText = reader.GetString(4),
                            DateText = reader.GetString(5),
                            NumericValue = reader.GetDecimal(6)
                        });
                    }
                }
            }

            return records;
        }
    }
}
