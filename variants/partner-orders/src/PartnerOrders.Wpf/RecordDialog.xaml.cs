using System.Windows;
using ExamScaffold.Wpf.Models;

namespace ExamScaffold.Wpf
{
    public partial class RecordDialog : Window
    {
        public RecordDialog(MainRecord record)
        {
            InitializeComponent();

            if (record == null)
            {
                return;
            }

            TitleTextBox.Text = record.Title;
            SubtitleTextBox.Text = record.Subtitle;
            DescriptionTextBox.Text = record.Description;
        }

        private void CloseButton_OnClick(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}
