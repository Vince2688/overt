import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/exercise.dart';

class FileStorage {
  static Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/exercises.json');
  }

  static Future<List<Exercise>> readExercises() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final data = json.decode(contents);
      return (data['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeExercises(List<Exercise> exercises) async {
    final file = await _localFile;
    final data = {'exercises': exercises.map((e) => e.toJson()).toList()};
    await file.writeAsString(json.encode(data), flush: true);
  }
}
