using System.Windows;
using BytService.App.Models;
using BytService.App.Services;

namespace BytService.App;

public partial class RequestDialog : Window
{
    private readonly RequestService _requestService;
    private readonly AppUser _actor;
    private readonly RepairRequest _request;

    private RequestDialog(RequestService requestService, AppUser actor, RepairRequest request)
    {
        InitializeComponent();
        _requestService = requestService;
        _actor = actor;
        _request = request;
        Loaded += RequestDialog_OnLoaded;
    }

    public static Task<RequestDialog> CreateNewAsync(RequestService requestService, AppUser actor)
    {
        var request = new RepairRequest
        {
            CreatedAt = DateTime.Today,
            StatusName = "Новая заявка",
            PlannedCompletionDate = DateTime.Today.AddDays(5),
            ClientId = actor.IsClient ? actor.UserId : 0
        };

        return Task.FromResult(new RequestDialog(requestService, actor, request));
    }

    public static Task<RequestDialog> CreateForEditAsync(RequestService requestService, AppUser actor, RepairRequest request)
    {
        var copy = new RepairRequest
        {
            RequestId = request.RequestId,
            RequestNumber = request.RequestNumber,
            CreatedAt = request.CreatedAt,
            ApplianceType = request.ApplianceType,
            ApplianceModel = request.ApplianceModel,
            ProblemDescription = request.ProblemDescription,
            StatusCode = request.StatusCode,
            StatusName = request.StatusName,
            ClientId = request.ClientId,
            ClientName = request.ClientName,
            AssignedMasterId = request.AssignedMasterId,
            PlannedCompletionDate = request.PlannedCompletionDate,
            ExtendedUntil = request.ExtendedUntil,
            ExtensionApprovedByClient = request.ExtensionApprovedByClient,
            CompletionDate = request.CompletionDate,
            RepairPartsUsed = request.RepairPartsUsed,
            QualityManagerId = request.QualityManagerId,
            AssistantMasterId = request.AssistantMasterId
        };

        return Task.FromResult(new RequestDialog(requestService, actor, copy));
    }

    private async void RequestDialog_OnLoaded(object sender, RoutedEventArgs e)
    {
        var clients = await _requestService.GetUsersByRoleAsync("CLIENT");
        var masters = await _requestService.GetUsersByRoleAsync("MASTER");
        var statuses = await _requestService.GetStatusesAsync();

        ClientComboBox.ItemsSource = clients;
        MasterComboBox.ItemsSource = masters;
        AssistantMasterComboBox.ItemsSource = masters;
        StatusComboBox.ItemsSource = statuses;

        CreatedAtDatePicker.SelectedDate = _request.CreatedAt;
        ApplianceTypeTextBox.Text = _request.ApplianceType;
        ApplianceModelTextBox.Text = _request.ApplianceModel;
        ProblemDescriptionTextBox.Text = _request.ProblemDescription;
        ClientComboBox.SelectedValue = _request.ClientId == 0 ? null : _request.ClientId;
        StatusComboBox.SelectedValue = string.IsNullOrWhiteSpace(_request.StatusName) ? "Новая заявка" : _request.StatusName;
        MasterComboBox.SelectedValue = _request.AssignedMasterId;
        PlannedCompletionDatePicker.SelectedDate = _request.PlannedCompletionDate;
        CompletionDatePicker.SelectedDate = _request.CompletionDate;
        RepairPartsTextBox.Text = _request.RepairPartsUsed;
        AssistantMasterComboBox.SelectedValue = _request.AssistantMasterId;
        ExtendedUntilDatePicker.SelectedDate = _request.ExtendedUntil;
        ClientApprovedCheckBox.IsChecked = _request.ExtensionApprovedByClient;

        QualitySection.Visibility = _actor.IsQualityManager ? Visibility.Visible : Visibility.Collapsed;

        if (_actor.IsClient)
        {
            ClientComboBox.SelectedValue = _actor.UserId;
            ClientComboBox.IsEnabled = false;
            MasterComboBox.IsEnabled = false;
            AssistantMasterComboBox.IsEnabled = false;
        }

        if (_actor.IsMaster)
        {
            ClientComboBox.IsEnabled = false;
        }
    }

    private async void SaveButton_OnClick(object sender, RoutedEventArgs e)
    {
        try
        {
            if (!ValidateInput())
            {
                return;
            }

            _request.CreatedAt = CreatedAtDatePicker.SelectedDate ?? DateTime.Today;
            _request.ApplianceType = ApplianceTypeTextBox.Text.Trim();
            _request.ApplianceModel = ApplianceModelTextBox.Text.Trim();
            _request.ProblemDescription = ProblemDescriptionTextBox.Text.Trim();
            _request.ClientId = (int)(ClientComboBox.SelectedValue ?? 0);
            _request.StatusName = StatusComboBox.SelectedValue?.ToString() ?? "Новая заявка";
            _request.AssignedMasterId = MasterComboBox.SelectedValue is int masterId ? masterId : null;
            _request.PlannedCompletionDate = PlannedCompletionDatePicker.SelectedDate;
            _request.CompletionDate = CompletionDatePicker.SelectedDate;
            _request.RepairPartsUsed = RepairPartsTextBox.Text.Trim();
            _request.AssistantMasterId = AssistantMasterComboBox.SelectedValue is int assistantMasterId ? assistantMasterId : null;
            _request.ExtendedUntil = ExtendedUntilDatePicker.SelectedDate;
            _request.ExtensionApprovedByClient = ClientApprovedCheckBox.IsChecked == true;
            _request.QualityManagerId = _actor.IsQualityManager ? _actor.UserId : _request.QualityManagerId;

            await _requestService.SaveRequestAsync(_request, _actor);
            DialogResult = true;
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                $"Не удалось сохранить заявку.\n{exception.Message}",
                "Ошибка сохранения",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        }
    }

    private bool ValidateInput()
    {
        if (string.IsNullOrWhiteSpace(ApplianceTypeTextBox.Text) ||
            string.IsNullOrWhiteSpace(ApplianceModelTextBox.Text) ||
            string.IsNullOrWhiteSpace(ProblemDescriptionTextBox.Text))
        {
            MessageBox.Show("Заполните тип техники, модель и описание проблемы.", "Проверка данных", MessageBoxButton.OK, MessageBoxImage.Warning);
            return false;
        }

        if (ClientComboBox.SelectedValue is null)
        {
            MessageBox.Show("Выберите клиента.", "Проверка данных", MessageBoxButton.OK, MessageBoxImage.Warning);
            return false;
        }

        if (ExtendedUntilDatePicker.SelectedDate.HasValue && ClientApprovedCheckBox.IsChecked != true && _actor.IsQualityManager)
        {
            MessageBox.Show("Продление срока возможно только после согласования с клиентом.", "Проверка данных", MessageBoxButton.OK, MessageBoxImage.Warning);
            return false;
        }

        return true;
    }

    private void CancelButton_OnClick(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
    }
}
