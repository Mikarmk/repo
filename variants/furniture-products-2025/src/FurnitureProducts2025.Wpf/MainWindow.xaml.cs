using System;
using System.Windows;
using ExamScaffold.Wpf.Models;
using ExamScaffold.Wpf.Services;

namespace ExamScaffold.Wpf
{
    public partial class MainWindow : Window
    {
        private readonly AppUser _currentUser;
        private readonly ApplicationSettings _settings;
        private readonly MainRecordService _mainRecordService;

        public MainWindow(AppUser currentUser, ApplicationSettings settings)
        {
            InitializeComponent();
            _currentUser = currentUser;
            _settings = settings;
            _mainRecordService = new MainRecordService(settings);

            WelcomeTextBlock.Text = currentUser.FullName;
            RoleTextBlock.Text = "Роль: " + currentUser.RoleName;
            Title = settings.ApplicationTitle;
            Loaded += MainWindowOnLoaded;
        }

        private void MainWindowOnLoaded(object sender, RoutedEventArgs e)
        {
            Reload();
        }

        private void Reload()
        {
            try
            {
                RecordsDataGrid.ItemsSource = _mainRecordService.GetRecords(SearchTextBox.Text.Trim());
            }
            catch (Exception exception)
            {
                MessageBox.Show("Ошибка загрузки данных.\n" + exception.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private MainRecord GetSelectedRecord()
        {
            return RecordsDataGrid.SelectedItem as MainRecord;
        }

        private void SearchTextBox_OnTextChanged(object sender, System.Windows.Controls.TextChangedEventArgs e)
        {
            Reload();
        }

        private void RefreshButton_OnClick(object sender, RoutedEventArgs e)
        {
            Reload();
        }

        private void ProfileButton_OnClick(object sender, RoutedEventArgs e)
        {
            var profileWindow = new ProfileWindow(_currentUser);
            profileWindow.Owner = this;
            profileWindow.ShowDialog();
        }

        private void AddButton_OnClick(object sender, RoutedEventArgs e)
        {
            var dialog = new RecordDialog(null);
            dialog.Owner = this;
            dialog.ShowDialog();
        }

        private void EditButton_OnClick(object sender, RoutedEventArgs e)
        {
            var selectedRecord = GetSelectedRecord();
            if (selectedRecord == null)
            {
                MessageBox.Show("Сначала выберите запись.", "Предупреждение", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var dialog = new RecordDialog(selectedRecord);
            dialog.Owner = this;
            dialog.ShowDialog();
        }
    }
}
