using System.IO;
using System.Windows;
using System.Windows.Media.Imaging;
using QRCoder;

namespace BytService.App;

public partial class QrCodeWindow : Window
{
    public QrCodeWindow(string feedbackUrl, string requestNumber)
    {
        InitializeComponent();
        HeaderTextBlock.Text = $"QR-код для оценки по заявке {requestNumber}";
        UrlTextBlock.Text = feedbackUrl;
        QrImage.Source = BuildQrImage(feedbackUrl);
    }

    private static BitmapImage BuildQrImage(string value)
    {
        using var qrGenerator = new QRCodeGenerator();
        using var qrData = qrGenerator.CreateQrCode(value, QRCodeGenerator.ECCLevel.Q);
        var qrCode = new PngByteQRCode(qrData);
        var bytes = qrCode.GetGraphic(20);

        using var stream = new MemoryStream(bytes);
        var image = new BitmapImage();
        image.BeginInit();
        image.CacheOption = BitmapCacheOption.OnLoad;
        image.StreamSource = stream;
        image.EndInit();
        image.Freeze();
        return image;
    }

    private void CloseButton_OnClick(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
