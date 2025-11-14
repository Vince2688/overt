import 'package:flutter/material.dart';
import 'package:workout_tracker/models/exercise_set.dart';
import '../models/exercise.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise? existingExercise;

  const EditExerciseScreen({super.key, this.existingExercise});

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final nameController = TextEditingController();
  int setCount = 3;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.existingExercise != null;
    if (isEditing) {
      nameController.text = widget.existingExercise!.name;
      setCount = widget.existingExercise!.sets.length;
    }
  }

  void _save() {
    if (nameController.text.isEmpty) return;

    List<ExerciseSet> sets = [];
    if (isEditing) {
      final old = widget.existingExercise!;
      // Keep old completion state for sets that still exist
      for (int i = 0; i < setCount; i++) {
        if (i < old.sets.length) {
          sets.add(ExerciseSet(id: i + 1, completed: old.sets[i].completed));
        } else {
          sets.add(ExerciseSet(id: i + 1, completed: false));
        }
      }
    } else {
      sets = List.generate(setCount, (i) => ExerciseSet(id: i + 1));
    }

    final exercise = Exercise(
      id: isEditing
          ? widget.existingExercise!.id
          : DateTime.now().millisecondsSinceEpoch,
      name: nameController.text,
      sets: sets,
    );

    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Exercise' : 'Add Exercise')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Number of Sets:'),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: setCount,
                  items: List.generate(
                    10,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                  ),
                  onChanged: (v) => setState(() => setCount = v ?? 3),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update Exercise' : 'Save Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
