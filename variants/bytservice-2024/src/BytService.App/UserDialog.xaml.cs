using System.Windows;
using System.Windows.Controls;
using BytService.App.Services;

namespace BytService.App;

public partial class UserDialog : Window
{
    private readonly RequestService _requestService;

    public UserDialog(RequestService requestService)
    {
        InitializeComponent();
        _requestService = requestService;
        RoleComboBox.SelectedIndex = 0;
    }

    private async void SaveButton_OnClick(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(FullNameTextBox.Text) ||
            string.IsNullOrWhiteSpace(PhoneTextBox.Text) ||
            string.IsNullOrWhiteSpace(LoginTextBox.Text) ||
            string.IsNullOrWhiteSpace(PasswordBox.Password) ||
            RoleComboBox.SelectedItem is not ComboBoxItem selectedRole)
        {
            MessageBox.Show("Заполните все поля формы.", "Проверка данных", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        try
        {
            await _requestService.CreateUserAsync(
                FullNameTextBox.Text,
                PhoneTextBox.Text,
                LoginTextBox.Text,
                PasswordBox.Password,
                selectedRole.Tag?.ToString() ?? "CLIENT");

            DialogResult = true;
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                $"Не удалось создать пользователя.\n{exception.Message}",
                "Ошибка",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        }
    }

    private void CancelButton_OnClick(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
    }
}

