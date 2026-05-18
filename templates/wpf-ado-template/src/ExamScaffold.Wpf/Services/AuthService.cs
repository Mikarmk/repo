using System;
using System.Data.SqlClient;
using ExamScaffold.Wpf.Models;

namespace ExamScaffold.Wpf.Services
{
    public sealed class AuthService
    {
        private readonly DbConnectionFactory _connectionFactory;

        public AuthService(ApplicationSettings settings)
        {
            _connectionFactory = new DbConnectionFactory(settings);
        }

        public AppUser Authenticate(string login, string password)
        {
            using (var connection = _connectionFactory.Create())
            using (var command = new SqlCommand(@"
SELECT TOP (1)
    u.UserId,
    u.Login,
    u.FullName,
    r.Code,
    r.Name,
    ISNULL(u.Phone, N''),
    ISNULL(u.Email, N'')
FROM dbo.AppUsers u
INNER JOIN dbo.Roles r ON r.RoleId = u.RoleId
WHERE u.Login = @Login AND u.PasswordHash = @PasswordHash AND u.IsActive = 1;", connection))
            {
                command.Parameters.AddWithValue("@Login", login);
                command.Parameters.AddWithValue("@PasswordHash", password);

                connection.Open();

                using (var reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return new AppUser
                    {
                        UserId = reader.GetInt32(0),
                        Login = reader.GetString(1),
                        FullName = reader.GetString(2),
                        RoleCode = reader.GetString(3),
                        RoleName = reader.GetString(4),
                        Phone = reader.GetString(5),
                        Email = reader.GetString(6)
                    };
                }
            }
        }
    }
}
