using System.Windows;
using BytService.App.Models;
using BytService.App.Services;

namespace BytService.App;

public partial class CommentDialog : Window
{
    private readonly RequestService _requestService;
    private readonly AppUser _currentUser;
    private readonly RepairRequest _request;

    public CommentDialog(RequestService requestService, AppUser currentUser, RepairRequest request)
    {
        InitializeComponent();
        _requestService = requestService;
        _currentUser = currentUser;
        _request = request;
        HeaderTextBlock.Text = $"Комментарии по заявке {_request.RequestNumber}";
        Loaded += async (_, _) => await LoadCommentsAsync();
        AddCommentButton.Visibility = _currentUser.IsMaster ? Visibility.Visible : Visibility.Collapsed;
        CommentTextBox.Visibility = _currentUser.IsMaster ? Visibility.Visible : Visibility.Collapsed;
    }

    private async Task LoadCommentsAsync()
    {
        CommentsDataGrid.ItemsSource = await _requestService.GetCommentsAsync(_request.RequestId);
    }

    private async void AddCommentButton_OnClick(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(CommentTextBox.Text))
        {
            MessageBox.Show("Введите текст комментария.", "Проверка данных", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        await _requestService.AddCommentAsync(_request.RequestId, _currentUser.UserId, CommentTextBox.Text);
        CommentTextBox.Clear();
        await LoadCommentsAsync();
    }

    private void CloseButton_OnClick(object sender, RoutedEventArgs e)
    {
        Close();
    }
}

