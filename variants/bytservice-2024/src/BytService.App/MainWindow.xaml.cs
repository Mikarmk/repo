using System.Windows;
using BytService.App.Models;
using BytService.App.Services;

namespace BytService.App;

public partial class MainWindow : Window
{
    private readonly AppUser _currentUser;
    private readonly ApplicationSettings _settings;
    private readonly RequestService _requestService;
    private List<RepairRequest> _requests = new();

    public MainWindow(AppUser currentUser, ApplicationSettings settings)
    {
        InitializeComponent();
        _currentUser = currentUser;
        _settings = settings;
        _requestService = new RequestService(settings);

        WelcomeTextBlock.Text = _currentUser.FullName;
        RoleTextBlock.Text = $"Роль: {_currentUser.RoleName}";
        UsersTabItem.Visibility = _currentUser.CanManageUsers ? Visibility.Visible : Visibility.Collapsed;
        ApplyPermissions();
        Loaded += async (_, _) => await ReloadAsync();
    }

    private async Task ReloadAsync()
    {
        try
        {
            _requests = await _requestService.GetRequestsAsync(_currentUser, SearchTextBox.Text);
            RequestsDataGrid.ItemsSource = _requests;

            var statistics = await _requestService.GetStatisticsAsync();
            CompletedRequestsTextBlock.Text = statistics.CompletedRequestsCount.ToString();
            AverageRepairDaysTextBlock.Text = statistics.AverageRepairDays.ToString("0.##");
            OverdueRequestsTextBlock.Text = statistics.OverdueRequestsCount.ToString();
            StatisticsDataGrid.ItemsSource = statistics.ProblemTypes;

            if (_currentUser.CanManageUsers)
            {
                UsersDataGrid.ItemsSource = await _requestService.GetAllUsersAsync();
            }
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                $"Ошибка загрузки данных.\n{exception.Message}",
                "Ошибка",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        }
    }

    private void ApplyPermissions()
    {
        AddRequestButton.IsEnabled = !_currentUser.IsMaster;
        DeleteRequestButton.IsEnabled = _currentUser.IsOperator || _currentUser.IsQualityManager;
    }

    private RepairRequest? GetSelectedRequest()
    {
        return RequestsDataGrid.SelectedItem as RepairRequest;
    }

    private async void RefreshButton_OnClick(object sender, RoutedEventArgs e)
    {
        await ReloadAsync();
    }

    private async void SearchTextBox_OnTextChanged(object sender, System.Windows.Controls.TextChangedEventArgs e)
    {
        await ReloadAsync();
    }

    private async void AddRequestButton_OnClick(object sender, RoutedEventArgs e)
    {
        var dialog = await RequestDialog.CreateNewAsync(_requestService, _currentUser);
        dialog.Owner = this;
        if (dialog.ShowDialog() == true)
        {
            await ReloadAsync();
        }
    }

    private async void EditRequestButton_OnClick(object sender, RoutedEventArgs e)
    {
        var request = GetSelectedRequest();
        if (request is null)
        {
            MessageBox.Show("Выберите заявку для редактирования.", "Предупреждение", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        if (_currentUser.IsClient && request.ClientId != _currentUser.UserId)
        {
            MessageBox.Show("Заказчик может изменять только свои заявки.", "Доступ запрещен", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        var dialog = await RequestDialog.CreateForEditAsync(_requestService, _currentUser, request);
        dialog.Owner = this;
        if (dialog.ShowDialog() == true)
        {
            await ReloadAsync();
        }
    }

    private async void DeleteRequestButton_OnClick(object sender, RoutedEventArgs e)
    {
        var request = GetSelectedRequest();
        if (request is null)
        {
            MessageBox.Show("Выберите заявку для удаления.", "Предупреждение", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        var result = MessageBox.Show(
            $"Удалить заявку {request.RequestNumber}?",
            "Подтверждение удаления",
            MessageBoxButton.YesNo,
            MessageBoxImage.Question);

        if (result != MessageBoxResult.Yes)
        {
            return;
        }

        await _requestService.DeleteRequestAsync(request.RequestId);
        await ReloadAsync();
    }

    private async void CommentsButton_OnClick(object sender, RoutedEventArgs e)
    {
        var request = GetSelectedRequest();
        if (request is null)
        {
            MessageBox.Show("Выберите заявку, чтобы открыть комментарии.", "Предупреждение", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        var dialog = new CommentDialog(_requestService, _currentUser, request);
        dialog.Owner = this;
        dialog.ShowDialog();
        await ReloadAsync();
    }

    private void QrButton_OnClick(object sender, RoutedEventArgs e)
    {
        var request = GetSelectedRequest();
        if (request is null)
        {
            MessageBox.Show("Выберите заявку для показа QR-кода.", "Предупреждение", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        var dialog = new QrCodeWindow(_settings.FeedbackUrl, request.RequestNumber);
        dialog.Owner = this;
        dialog.ShowDialog();
    }

    private void RequestsDataGrid_OnSelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        var selected = GetSelectedRequest();
        EditRequestButton.IsEnabled = selected is not null;
        CommentsButton.IsEnabled = selected is not null;
        QrButton.IsEnabled = selected is not null;
        DeleteRequestButton.IsEnabled = selected is not null && (_currentUser.IsOperator || _currentUser.IsQualityManager);
    }

    private async void AddUserButton_OnClick(object sender, RoutedEventArgs e)
    {
        var dialog = new UserDialog(_requestService);
        dialog.Owner = this;
        if (dialog.ShowDialog() == true)
        {
            await ReloadAsync();
        }
    }
}

