using System.Security.Cryptography;
using System.Text;

namespace BytService.App.Services;

public static class PasswordHasher
{
    public static string ComputeHash(string rawPassword)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(rawPassword));
        return Convert.ToHexString(bytes);
    }
}

