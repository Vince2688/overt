import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../utils/file_storage.dart';
import 'edit_exercise_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final data = await FileStorage.readExercises();
    for (var e in data) {
      e.resetIfNewDay();
    }
    setState(() => exercises = data);
    _saveExercises();
  }

  Future<void> _saveExercises() async {
    await FileStorage.writeExercises(exercises);
  }

  void _addExercise() async {
    final newExercise = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditExerciseScreen()),
    );
    if (newExercise != null) {
      setState(() => exercises.add(newExercise));
      _saveExercises();
    }
  }

  void _deleteExercise(Exercise e) {
    setState(() => exercises.remove(e));
    _saveExercises();
  }

  void _toggleSet(Exercise exercise, int index) {
    setState(() {
      exercise.sets[index].completed = !exercise.sets[index].completed;
      exercise.lastUpdated = DateTime.now();
      exercise
          .updateHistoryIfCompleted(); // 🆕 record completion if all sets done
    });
    _saveExercises();
  }

  void _editExercise(Exercise e) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditExerciseScreen(existingExercise: e),
      ),
    );
    if (updated != null) {
      setState(() {
        final index = exercises.indexOf(e);
        exercises[index] = updated;
      });
      _saveExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker')),
      body: exercises.isEmpty
          ? const Center(child: Text('No exercises yet. Tap + to add one!'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 100),
              itemCount: exercises.length,
              itemBuilder: (context, i) {
                final e = exercises[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: e.completionRate,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          color: e.completionRate == 1.0
                              ? Colors.green
                              : Colors.blue,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${(e.completionRate * 100).toStringAsFixed(0)}% complete',
                          style: TextStyle(
                            color: e.completionRate == 1.0
                                ? Colors.green[700]
                                : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      ...e.sets.map((s) {
                        return CheckboxListTile(
                          title: Text('Set ${s.id}'),
                          value: s.completed,
                          onChanged: (_) => _toggleSet(e, s.id - 1),
                        );
                      }),
                      if (e.history.isNotEmpty) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🏁 Workout History:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: e.history.reversed
                                    .map(
                                      (d) => Chip(
                                        label: Text(d),
                                        backgroundColor: Colors.green[100],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editExercise(e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExercise(e),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}
