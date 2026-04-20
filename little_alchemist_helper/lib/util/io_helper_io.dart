import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

Future<String?> readUserCatalogIfExists(String? path) async {
  if (path == null || path.isEmpty) {
    return null;
  }
  final File f = File(path);
  if (!await f.exists()) {
    return null;
  }
  return f.readAsString();
}

Future<String?> saveCatalogAndReturnPath(Uint8List bytes) async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final File dest = File('${dir.path}/AlchemyCardData.json');
  await dest.writeAsBytes(bytes);
  return dest.path;
}

Future<String?> saveUserCatalogOverlayAndReturnPath(Uint8List bytes) async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final File dest = File('${dir.path}/user_catalog_overlay.json');
  await dest.writeAsBytes(bytes);
  return dest.path;
}

Future<Uint8List?> readFileAsBytes(String path) async {
  final File f = File(path);
  if (!await f.exists()) {
    return null;
  }
  return f.readAsBytes();
}

Future<String?> pickSaveZipPath(String defaultFileName) {
  return FilePicker.saveFile(
    dialogTitle: 'Save ZIP',
    fileName: defaultFileName,
    type: FileType.custom,
    allowedExtensions: <String>['zip'],
  );
}

Future<String?> pickSaveTextPath(String defaultFileName) {
  return FilePicker.saveFile(
    dialogTitle: 'Save text file',
    fileName: defaultFileName,
    type: FileType.custom,
    allowedExtensions: <String>['txt'],
  );
}

bool shouldUseShareSheetForSaving() => Platform.isIOS;

bool supportsDirectSaveDialog() => !(Platform.isIOS || Platform.isAndroid);

Future<ShareResultStatus?> shareFileForSaving({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  Rect? sharePositionOrigin,
}) async {
  try {
    final Directory tempDir = await getTemporaryDirectory();
    final String safeName = fileName.trim().isEmpty ? 'export.bin' : fileName;
    final String tempPath =
        '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    final File tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes, flush: true);
    final ShareResult result = await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(tempFile.path, mimeType: mimeType)],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
    return result.status;
  } on Object catch (e, st) {
    debugPrint('shareFileForSaving failed: $e');
    debugPrintStack(stackTrace: st);
    return null;
  }
}

Future<void> writeBytesToPath(String path, Uint8List bytes) async {
  final File f = File(path);
  await f.writeAsBytes(bytes, flush: true);
}

Future<bool> ensureExportWritePermission() async {
  if (!Platform.isAndroid) {
    return true;
  }
  PermissionStatus status = await Permission.storage.status;
  if (status.isGranted) {
    return true;
  }
  status = await Permission.storage.request();
  return status.isGranted;
}

Future<String> writeBytesToAppDocumentsFile(
  String fileName,
  Uint8List bytes,
) async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final File dest = File('${dir.path}/$fileName');
  await dest.writeAsBytes(bytes, flush: true);
  return dest.path;
}
