using System.Configuration;

namespace BytService.App.Services;

public sealed class ApplicationSettings
{
    public string ConnectionString { get; set; } = string.Empty;
    public string FeedbackUrl { get; set; } = string.Empty;

    public static ApplicationSettings Load()
    {
        var connectionSettings = ConfigurationManager.ConnectionStrings["AppDb"];
        if (connectionSettings == null)
        {
            throw new ConfigurationErrorsException("В App.config отсутствует строка подключения AppDb.");
        }

        return new ApplicationSettings
        {
            ConnectionString = connectionSettings.ConnectionString,
            FeedbackUrl = ConfigurationManager.AppSettings["FeedbackUrl"] ?? string.Empty
        };
    }
}
