class ExerciseSet {
  int id;
  bool completed;

  ExerciseSet({required this.id, this.completed = false});

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(id: json['id'], completed: json['completed'] ?? false);
  }

  Map<String, dynamic> toJson() => {'id': id, 'completed': completed};
}