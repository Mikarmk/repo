using System.Data.SqlClient;

namespace ExamScaffold.Wpf.Services
{
    public sealed class DbConnectionFactory
    {
        private readonly ApplicationSettings _settings;

        public DbConnectionFactory(ApplicationSettings settings)
        {
            _settings = settings;
        }

        public SqlConnection Create()
        {
            return new SqlConnection(_settings.ConnectionString);
        }
    }
}
