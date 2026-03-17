import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuelPassService {
  static const String _prefsKey = 'fuel_pass_images';

  /// Returns the app's dedicated fuel pass directory
  static Future<Directory> _getDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/fuel_passes');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies an image from [sourcePath] into app storage and saves its path.
  /// Returns the saved file path.
  static Future<String> saveImage(String sourcePath) async {
    final dir = await _getDir();
    final fileName =
        'fuel_pass_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destFile = File('${dir.path}/$fileName');
    await File(sourcePath).copy(destFile.path);

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefsKey) ?? [];
    existing.add(destFile.path);
    await prefs.setStringList(_prefsKey, existing);

    return destFile.path;
  }

  /// Returns all saved fuel pass image paths (only existing files).
  static Future<List<String>> getSavedPasses() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_prefsKey) ?? [];
    // Filter out deleted files
    final valid = <String>[];
    for (final p in paths) {
      if (await File(p).exists()) valid.add(p);
    }
    if (valid.length != paths.length) {
      await prefs.setStringList(_prefsKey, valid);
    }
    return valid;
  }

  /// Deletes the image file and removes from prefs.
  static Future<void> deletePass(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefsKey) ?? [];
    existing.remove(path);
    await prefs.setStringList(_prefsKey, existing);
  }
}
