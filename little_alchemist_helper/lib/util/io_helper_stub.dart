import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

/// Web stub: catalog is available only from assets or in-memory after file selection.
Future<String?> readUserCatalogIfExists(String? path) async => null;

/// On web, path is not persisted (no durable file storage at this layer).
Future<String?> saveCatalogAndReturnPath(Uint8List bytes) async => null;

Future<String?> saveUserCatalogOverlayAndReturnPath(Uint8List bytes) async =>
    null;

Future<Uint8List?> readFileAsBytes(String path) async => null;

Future<String?> pickSaveZipPath(String defaultFileName) async => null;

Future<String?> pickSaveTextPath(String defaultFileName) async => null;

bool shouldUseShareSheetForSaving() => false;

bool supportsDirectSaveDialog() => false;

Future<ShareResultStatus?> shareFileForSaving({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  Rect? sharePositionOrigin,
}) async => null;

Future<void> writeBytesToPath(String path, Uint8List bytes) async {}

Future<bool> ensureExportWritePermission() async => true;

Future<String> writeBytesToAppDocumentsFile(
  String fileName,
  Uint8List bytes,
) async => fileName;
