namespace BytService.App.Models;

public sealed class RepairRequest
{
    public int RequestId { get; set; }
    public string RequestNumber { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public string ApplianceType { get; set; } = string.Empty;
    public string ApplianceModel { get; set; } = string.Empty;
    public string ProblemDescription { get; set; } = string.Empty;
    public string StatusCode { get; set; } = string.Empty;
    public string StatusName { get; set; } = string.Empty;
    public int ClientId { get; set; }
    public string ClientName { get; set; } = string.Empty;
    public int? AssignedMasterId { get; set; }
    public string AssignedMasterName { get; set; } = string.Empty;
    public DateTime? PlannedCompletionDate { get; set; }
    public DateTime? ExtendedUntil { get; set; }
    public bool ExtensionApprovedByClient { get; set; }
    public DateTime? CompletionDate { get; set; }
    public string RepairPartsUsed { get; set; } = string.Empty;
    public string LatestComment { get; set; } = string.Empty;
    public int? QualityManagerId { get; set; }
    public string QualityManagerName { get; set; } = string.Empty;
    public int? AssistantMasterId { get; set; }
    public string AssistantMasterName { get; set; } = string.Empty;
}

