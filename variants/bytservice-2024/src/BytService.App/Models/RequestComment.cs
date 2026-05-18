namespace BytService.App.Models;

public sealed class RequestComment
{
    public int CommentId { get; set; }
    public int RequestId { get; set; }
    public int MasterId { get; set; }
    public string MasterName { get; set; } = string.Empty;
    public string CommentText { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

