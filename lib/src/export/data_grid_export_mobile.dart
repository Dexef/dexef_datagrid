import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataGridExportPlatform {
  static Future<void> downloadFile(
      String filename, Uint8List bytes, String mimeType) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exported data: $filename',
      );
    } catch (e) {
      print('Error exporting file: $e');
    }
  }

  static Future<void> downloadPdfFile(
      String filename, Uint8List pdfBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exported PDF: $filename',
      );
    } catch (e) {
      print('Error exporting PDF: $e');
    }
  }
}
