import 'dart:html' as html;
import 'dart:typed_data';

class DataGridExportPlatform {
  static void downloadFile(String filename, Uint8List bytes, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  static void downloadPdfFile(String filename, Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
