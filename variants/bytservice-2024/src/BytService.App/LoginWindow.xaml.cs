using System.Windows;
using BytService.App.Services;

namespace BytService.App;

public partial class LoginWindow : Window
{
    private readonly AuthService _authService;
    private readonly ApplicationSettings _settings;

    public LoginWindow(AuthService authService, ApplicationSettings settings)
    {
        InitializeComponent();
        _authService = authService;
        _settings = settings;
    }

    private async void SignInButton_OnClick(object sender, RoutedEventArgs e)
    {
        ErrorTextBlock.Visibility = Visibility.Collapsed;

        if (string.IsNullOrWhiteSpace(LoginTextBox.Text) || string.IsNullOrWhiteSpace(PasswordBox.Password))
        {
            ErrorTextBlock.Text = "Введите логин и пароль.";
            ErrorTextBlock.Visibility = Visibility.Visible;
            return;
        }

        try
        {
            var user = await _authService.AuthenticateAsync(LoginTextBox.Text, PasswordBox.Password);
            if (user is null)
            {
                ErrorTextBlock.Text = "Неверный логин или пароль.";
                ErrorTextBlock.Visibility = Visibility.Visible;
                return;
            }

            var mainWindow = new MainWindow(user, _settings);
            mainWindow.Show();
            Close();
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                $"Ошибка при авторизации.\n{exception.Message}",
                "Ошибка",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        }
    }
}
