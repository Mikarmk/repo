namespace BytService.App.Models;

public sealed class RepairStatistics
{
    public int CompletedRequestsCount { get; set; }
    public double AverageRepairDays { get; set; }
    public int OverdueRequestsCount { get; set; }
    public List<ProblemTypeStatistics> ProblemTypes { get; set; } = new();
}

public sealed class ProblemTypeStatistics
{
    public string ApplianceType { get; set; } = string.Empty;
    public int RequestsCount { get; set; }
}

