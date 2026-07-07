import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  static final ImageStorageService instance = ImageStorageService._();
  ImageStorageService._();

  Future<String> saveImage(File source) async {
    final dir = await _imagesDir();
    final ext = p.extension(source.path).isEmpty ? '.jpg' : p.extension(source.path);
    final name = '${const Uuid().v4()}$ext';
    final dest = File(p.join(dir.path, name));
    await source.copy(dest.path);
    return dest.path;
  }

  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Delete image error: $e');
    }
  }

  Future<void> deleteImages(Iterable<String> paths) async {
    for (final path in paths) {
      await deleteImage(path);
    }
  }

  Future<Directory> _imagesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'warranty_images'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
