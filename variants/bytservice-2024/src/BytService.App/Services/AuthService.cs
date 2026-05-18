using BytService.App.Models;
using System.Data.SqlClient;

namespace BytService.App.Services;

public sealed class AuthService
{
    private readonly DatabaseContext _databaseContext;

    public AuthService(ApplicationSettings settings)
    {
        _databaseContext = new DatabaseContext(settings);
    }

    public async Task<AppUser?> AuthenticateAsync(string login, string password)
    {
        const string sql = """
            SELECT
                u.UserId,
                u.FullName,
                u.Phone,
                u.Login,
                u.IsActive,
                r.Code AS RoleCode,
                r.Name AS RoleName
            FROM dbo.Users u
            INNER JOIN dbo.Roles r ON r.RoleId = u.RoleId
            WHERE u.Login = @login
              AND u.PasswordHash = @passwordHash
              AND u.IsActive = 1;
            """;

        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@login", login.Trim());
        command.Parameters.AddWithValue("@passwordHash", PasswordHasher.ComputeHash(password));

        await using var reader = await command.ExecuteReaderAsync();
        if (!await reader.ReadAsync())
        {
            return null;
        }

        return new AppUser
        {
            UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
            FullName = reader.GetString(reader.GetOrdinal("FullName")),
            Phone = reader.GetString(reader.GetOrdinal("Phone")),
            Login = reader.GetString(reader.GetOrdinal("Login")),
            IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
            RoleCode = reader.GetString(reader.GetOrdinal("RoleCode")),
            RoleName = reader.GetString(reader.GetOrdinal("RoleName"))
        };
    }
}
