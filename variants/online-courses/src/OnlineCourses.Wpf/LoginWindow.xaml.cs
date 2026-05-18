using System;
using System.Text;
using System.Windows;
using System.Windows.Threading;
using ExamScaffold.Wpf.Services;

namespace ExamScaffold.Wpf
{
    public partial class LoginWindow : Window
    {
        private readonly ApplicationSettings _settings;
        private readonly AuthService _authService;
        private readonly Random _random;
        private DispatcherTimer _blockTimer;
        private int _failedAttempts;
        private int _secondsLeft;
        private string _captchaValue;

        public LoginWindow()
        {
            InitializeComponent();
            _settings = new ApplicationSettings();
            _authService = new AuthService(_settings);
            _random = new Random();
            TitleTextBlock.Text = _settings.ApplicationTitle;
            Title = "Авторизация";
        }

        private void LoginButton_OnClick(object sender, RoutedEventArgs e)
        {
            if (_secondsLeft > 0)
            {
                MessageBox.Show("Система временно заблокирована. Дождитесь завершения таймера.", "Блокировка входа", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (CaptchaPanel.Visibility == Visibility.Visible && !string.Equals(CaptchaTextBox.Text, _captchaValue, StringComparison.OrdinalIgnoreCase))
            {
                StatusTextBlock.Text = "CAPTCHA введена неверно.";
                BuildCaptcha();
                return;
            }

            try
            {
                var user = _authService.Authenticate(LoginTextBox.Text.Trim(), PasswordBox.Password.Trim());
                if (user == null)
                {
                    RegisterFailedAttempt();
                    return;
                }

                var mainWindow = new MainWindow(user, _settings);
                mainWindow.Show();
                Close();
            }
            catch (Exception exception)
            {
                MessageBox.Show("Ошибка подключения к базе данных.\n" + exception.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void RegisterFailedAttempt()
        {
            _failedAttempts++;
            StatusTextBlock.Text = "Неверный логин или пароль.";

            if (_settings.EnableCaptcha && _failedAttempts >= 2)
            {
                CaptchaPanel.Visibility = Visibility.Visible;
                BuildCaptcha();
            }

            if (_failedAttempts >= 3)
            {
                StartBlock();
            }
        }

        private void StartBlock()
        {
            _secondsLeft = _settings.BlockDurationSeconds;

            _blockTimer = new DispatcherTimer();
            _blockTimer.Interval = TimeSpan.FromSeconds(1);
            _blockTimer.Tick += BlockTimerOnTick;
            _blockTimer.Start();

            StatusTextBlock.Text = "Слишком много ошибок. Вход заблокирован на " + _secondsLeft + " секунд.";
        }

        private void BlockTimerOnTick(object sender, EventArgs e)
        {
            _secondsLeft--;
            StatusTextBlock.Text = "Слишком много ошибок. Вход заблокирован на " + _secondsLeft + " секунд.";

            if (_secondsLeft > 0)
            {
                return;
            }

            _blockTimer.Stop();
            _failedAttempts = 0;
            StatusTextBlock.Text = string.Empty;
            CaptchaTextBox.Clear();
        }

        private void BuildCaptcha()
        {
            const string alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
            var builder = new StringBuilder();

            for (var index = 0; index < 5; index++)
            {
                builder.Append(alphabet[_random.Next(0, alphabet.Length)]);
            }

            _captchaValue = builder.ToString();
            CaptchaTextBlock.Text = "CAPTCHA: " + _captchaValue + "  *  #  /";
        }
    }
}
