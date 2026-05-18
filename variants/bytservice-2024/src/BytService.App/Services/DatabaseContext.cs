using System.Data.SqlClient;

namespace BytService.App.Services;

public sealed class DatabaseContext
{
    private readonly ApplicationSettings _settings;

    public DatabaseContext(ApplicationSettings settings)
    {
        _settings = settings;
    }

    public SqlConnection CreateConnection()
    {
        return new SqlConnection(_settings.ConnectionString);
    }
}
