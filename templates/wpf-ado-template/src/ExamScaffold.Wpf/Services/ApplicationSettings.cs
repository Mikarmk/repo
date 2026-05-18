using System;
using System.Configuration;

namespace ExamScaffold.Wpf.Services
{
    public sealed class ApplicationSettings
    {
        public string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["AppDb"].ConnectionString; }
        }

        public string ApplicationTitle
        {
            get { return ConfigurationManager.AppSettings["ApplicationTitle"] ?? "Exam Scaffold"; }
        }

        public bool EnableCaptcha
        {
            get
            {
                bool value;
                return bool.TryParse(ConfigurationManager.AppSettings["EnableCaptcha"], out value) && value;
            }
        }

        public int BlockDurationSeconds
        {
            get
            {
                int value;
                return int.TryParse(ConfigurationManager.AppSettings["BlockDurationSeconds"], out value) ? Math.Max(1, value) : 10;
            }
        }
    }
}
