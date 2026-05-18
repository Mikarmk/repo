namespace BytService.App.Models;

public sealed class AppUser
{
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Login { get; set; } = string.Empty;
    public string RoleCode { get; set; } = string.Empty;
    public string RoleName { get; set; } = string.Empty;
    public bool IsActive { get; set; }

    public bool IsOperator => RoleCode == "OPERATOR";
    public bool IsMaster => RoleCode == "MASTER";
    public bool IsClient => RoleCode == "CLIENT";
    public bool IsQualityManager => RoleCode == "QUALITY_MANAGER";
    public bool CanManageUsers => IsOperator || IsQualityManager;
}

