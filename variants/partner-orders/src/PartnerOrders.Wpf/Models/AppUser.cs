namespace ExamScaffold.Wpf.Models
{
    public sealed class AppUser
    {
        public int UserId { get; set; }
        public string Login { get; set; }
        public string FullName { get; set; }
        public string RoleCode { get; set; }
        public string RoleName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
    }
}
