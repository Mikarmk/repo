using System.Windows;
using ExamScaffold.Wpf.Models;

namespace ExamScaffold.Wpf
{
    public partial class ProfileWindow : Window
    {
        public ProfileWindow(AppUser user)
        {
            InitializeComponent();
            FullNameTextBlock.Text = user.FullName;
            RoleTextBlock.Text = "Роль: " + user.RoleName;
            LoginTextBlock.Text = "Логин: " + user.Login;
            ContactTextBlock.Text = "Телефон: " + user.Phone + "\nEmail: " + user.Email;
        }
    }
}
