namespace ExamScaffold.Wpf.Models
{
    public sealed class MainRecord
    {
        public int RecordId { get; set; }
        public string Title { get; set; }
        public string Subtitle { get; set; }
        public string Description { get; set; }
        public string StatusText { get; set; }
        public string DateText { get; set; }
        public decimal NumericValue { get; set; }
    }
}
