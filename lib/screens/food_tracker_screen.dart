import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_entry.dart';

class FoodTrackerScreen extends StatefulWidget {
  const FoodTrackerScreen({super.key});

  @override
  State<FoodTrackerScreen> createState() => _FoodTrackerScreenState();
}

class _FoodTrackerScreenState extends State<FoodTrackerScreen> {
  final _calorieController = TextEditingController();
  String selectedMeal = 'Breakfast';

  void _addCalories() async {
    final int calories = int.tryParse(_calorieController.text.trim()) ?? 0;
    if (calories <= 0) return;

    final box = Hive.box<DailyEntry>('daily_entries');
    final today = DateTime.now();
    final entryIndex = box.values.toList().indexWhere(
      (e) => e.date.year == today.year &&
             e.date.month == today.month &&
             e.date.day == today.day,
    );

    if (entryIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log today\'s entry first on Home tab.')),
      );
      return;
    }

    final entry = box.getAt(entryIndex)!;
    switch (selectedMeal) {
      case 'Breakfast':
        entry.caloriesBreakfast += calories;
        break;
      case 'Lunch':
        entry.caloriesLunch += calories;
        break;
      case 'Dinner':
        entry.caloriesDinner += calories;
        break;
      case 'Snack':
        entry.caloriesSnack += calories;
        break;
    }

    await entry.save();
    _calorieController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DailyEntry>('daily_entries');
    final today = DateTime.now();
    final entry = box.values.firstWhere(
      (e) => e.date.year == today.year &&
             e.date.month == today.month &&
             e.date.day == today.day,
      orElse: () => DailyEntry(
        date: today,
        weight: 0,
        sleepHours: 0,
        caloriesBreakfast: 0,
        caloriesLunch: 0,
        caloriesDinner: 0,
        caloriesSnack: 0,
        workoutCompleted: false,
      ),
    );

    final total = entry.caloriesBreakfast +
        entry.caloriesLunch +
        entry.caloriesDinner +
        entry.caloriesSnack;

    return Scaffold(
      appBar: AppBar(title: const Text('Food Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🍳 Breakfast: ${entry.caloriesBreakfast} cal'),
            Text('🍱 Lunch: ${entry.caloriesLunch} cal'),
            Text('🍽️ Dinner: ${entry.caloriesDinner} cal'),
            Text('🍫 Snack: ${entry.caloriesSnack} cal'),
            const SizedBox(height: 12),
            Text('🧮 Total: $total cal', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            TextField(
              controller: _calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories'),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedMeal,
              onChanged: (val) => setState(() => selectedMeal = val!),
              items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                  .map((meal) => DropdownMenuItem(value: meal, child: Text(meal)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addCalories,
              child: const Text('Add Calories'),
            ),
          ],
        ),
      ),
    );
  }
}
