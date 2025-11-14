import 'package:workout_tracker/models/exercise_set.dart';

class Exercise {
  int id;
  String name;
  DateTime lastUpdated;
  List<ExerciseSet> sets;
  List<String> history; // 🆕 new field

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    DateTime? lastUpdated,
    List<String>? history,
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       history = history ?? [];

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      sets: (json['sets'] as List).map((s) => ExerciseSet.fromJson(s)).toList(),
      history: List<String>.from(json['history'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lastUpdated': lastUpdated.toIso8601String(),
    'sets': sets.map((s) => s.toJson()).toList(),
    'history': history,
  };

  double get completionRate {
    if (sets.isEmpty) return 0;
    final completed = sets.where((s) => s.completed).length;
    return completed / sets.length;
  }

  void resetIfNewDay() {
    final now = DateTime.now();
    final isNewDay =
        lastUpdated.year != now.year ||
        lastUpdated.month != now.month ||
        lastUpdated.day != now.day;

    if (isNewDay) {
      // Record completion if finished previous day
      if (completionRate == 1.0) {
        final formatted = _formatDate(lastUpdated);
        if (!history.contains(formatted)) history.add(formatted);
      }

      for (final s in sets) {
        s.completed = false;
      }
      lastUpdated = now;
    }
  }

  void updateHistoryIfCompleted() {
    if (completionRate == 1.0) {
      final today = _formatDate(DateTime.now());
      if (!history.contains(today)) {
        history.add(today);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
