using System.Windows;
using BytService.App.Services;

namespace BytService.App;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        try
        {
            var settings = ApplicationSettings.Load();
            var authService = new AuthService(settings);
            var loginWindow = new LoginWindow(authService, settings);
            loginWindow.Show();
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                $"Не удалось запустить приложение.\n{exception.Message}",
                "Ошибка запуска",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
            Shutdown();
        }
    }
}

