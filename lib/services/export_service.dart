import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/storage_service.dart';

class ExportService {
  static Future<void> exportAsJson() async {
    final entries = await StorageService.getAllEntries();
    final jsonList = entries.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/mood_tracker_backup.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: 'My mood tracker backup');
  }
}
