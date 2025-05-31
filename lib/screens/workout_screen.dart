import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late List<Exercise> exercises;
  late Box customBox;

  @override
  void initState() {
    super.initState();
    customBox = Hive.box('custom_amounts');
    exercises = _getWorkoutForToday();
  }

  List<Exercise> _getWorkoutForToday() {
    final weekday = DateTime.now().weekday;

    List<Exercise> base = switch (weekday) {
      1 => [ // Monday – Full Body
        Exercise('Jumping Jacks', 3, '30 reps'),
        Exercise('Push-Ups', 4, '12 reps'),
        Exercise('Bodyweight Squats', 4, '15 reps'),
        Exercise('Sit-Ups', 3, '15 reps'),
        Exercise('Run', 3, '0.25 miles'),
      ],
      2 => [ // Tuesday – Core & Cardio
        Exercise('Mountain Climbers', 3, '40 reps'),
        Exercise('Plank', 4, '45 sec'),
        Exercise('Leg Raises', 4, '12 reps'),
        Exercise('High Knees', 3, '40 reps'),
        Exercise('Run', 3, '0.3 miles'),
      ],
      3 => [ // Wednesday – Lower Body
        Exercise('Lunges', 4, '10 per leg'),
        Exercise('Wall Sit', 3, '60 sec'),
        Exercise('Calf Raises', 4, '20 reps'),
        Exercise('Step-Ups (on bench)', 3, '10 per leg'),
        Exercise('Jog', 3, '0.3 miles'),
      ],
      4 => [ // Thursday – Upper Body
        Exercise('Push-Ups', 4, '15 reps'),
        Exercise('Tricep Dips (chair)', 3, '12 reps'),
        Exercise('Pike Push-Ups', 3, '8 reps'),
        Exercise('Arm Circles (forward/back)', 3, '30 sec'),
        Exercise('Run', 3, '0.25 miles'),
      ],
      5 => [ // Friday – Cardio & Core
        Exercise('Jog', 4, '0.25 miles'),
        Exercise('Burpees', 3, '10 reps'),
        Exercise('Bicycle Crunches', 3, '30 reps'),
        Exercise('Flutter Kicks', 3, '30 sec'),
        Exercise('Jumping Jacks', 3, '40 reps'),
      ],
      6 => [ // Saturday – Endurance & Full Body
        Exercise('Run', 4, '0.3 miles'),
        Exercise('Bodyweight Squats', 4, '20 reps'),
        Exercise('Push-Ups', 4, '12 reps'),
        Exercise('Sit-Ups', 3, '20 reps'),
        Exercise('Wall Sit', 3, '45 sec'),
      ],
      _ => [],
    };

    // Apply custom overrides
    for (var ex in base) {
      final saved = customBox.get(ex.name);
      if (saved is String) {
        ex.recommendedAmount = saved;
      }
    }

    return base;
  }

  void _editAmountDialog(Exercise ex) async {
    final controller = TextEditingController(text: ex.recommendedAmount);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Amount - ${ex.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'e.g., 15 reps or 0.25 miles'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        ex.recommendedAmount = result;
        customBox.put(ex.name, result); // Save persistently
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRestDay = exercises.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: isRestDay
          ? const Center(child: Text('Rest Day — No workout today!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                final isComplete = ex.setsCompleted.every((c) => c);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: isComplete ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: List.generate(ex.setsCompleted.length, (i) {
                            return FilterChip(
                              label: Text('Set ${i + 1}'),
                              selected: ex.setsCompleted[i],
                              onSelected: (selected) {
                                setState(() {
                                  ex.setsCompleted[i] = selected;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text('Recommended: ${ex.recommendedAmount}'),
                        TextButton.icon(
                          onPressed: () => _editAmountDialog(ex),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Amount'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              ex.setsCompleted.add(false);
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Set'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class Exercise {
  final String name;
  List<bool> setsCompleted;
  String recommendedAmount;

  Exercise(this.name, int sets, this.recommendedAmount)
      : setsCompleted = List.filled(sets, false);
}
