import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_entry.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _weightController = TextEditingController();
  final _sleepController = TextEditingController();

  bool showEntryForm = true;
  DateTime? startDate;

  Future<void> _saveEntry() async {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final sleep = double.tryParse(_sleepController.text.trim()) ?? 0.0;
    final today = DateTime.now();

    final box = Hive.box<DailyEntry>('daily_entries');

    if (box.isEmpty) {
      startDate = DateTime(today.year, today.month, today.day);
      await Hive.box('meta').put('start_date', startDate!.toIso8601String());
    } else {
      startDate = DateTime.parse(Hive.box('meta').get('start_date'));
    }

    final existingIndex = box.values.toList().indexWhere(
      (e) => e.date.year == today.year &&
             e.date.month == today.month &&
             e.date.day == today.day,
    );

    final entry = DailyEntry(
      date: today,
      weight: weight,
      sleepHours: sleep,
      caloriesBreakfast: 0,
      caloriesLunch: 0,
      caloriesDinner: 0,
      caloriesSnack: 0,
      workoutCompleted: false,
    );

    if (existingIndex != -1) {
      final key = box.keyAt(existingIndex);
      await box.put(key, entry);
    } else {
      await box.add(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved!')),
    );

    _weightController.clear();
    _sleepController.clear();

    setState(() {
      showEntryForm = false;
    });
  }

  Future<void> _checkOffToday() async {
    final box = Hive.box<DailyEntry>('daily_entries');
    final today = DateTime.now();

    final existingIndex = box.values.toList().indexWhere(
      (e) => e.date.year == today.year &&
             e.date.month == today.month &&
             e.date.day == today.day,
    );

    DailyEntry entry;
    if (existingIndex != -1) {
      entry = box.getAt(existingIndex)!;
      entry.workoutCompleted = true;
      await entry.save();
    } else {
      entry = DailyEntry(
        date: today,
        weight: 0,
        sleepHours: 0,
        caloriesBreakfast: 0,
        caloriesLunch: 0,
        caloriesDinner: 0,
        caloriesSnack: 0,
        workoutCompleted: true,
      );
      await box.add(entry);
    }

    setState(() {});
  }

  void _clearAllEntries() async {
    final box = Hive.box<DailyEntry>('daily_entries');
    await box.clear();
    await Hive.box('meta').clear();
    startDate = null;
    print('✅ All Hive data cleared.');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DailyEntry>('daily_entries');
    final metaBox = Hive.box('meta');
    final entries = box.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final today = DateTime.now();

    startDate ??= metaBox.get('start_date') != null
        ? DateTime.parse(metaBox.get('start_date'))
        : DateTime(today.year, today.month, today.day);

    final daysElapsed = today.difference(startDate!).inDays;
    final totalDays = 105;
    final days = List.generate(totalDays, (i) => startDate!.add(Duration(days: i)));

    final weightSpots = <FlSpot>[FlSpot(0, 230.0)];

    for (int i = 0; i < days.length; i++) {
      final entry = entries.firstWhere(
        (e) => e.date.year == days[i].year &&
               e.date.month == days[i].month &&
               e.date.day == days[i].day,
        orElse: () => DailyEntry(
          date: days[i],
          weight: 0,
          sleepHours: 0,
          caloriesBreakfast: 0,
          caloriesLunch: 0,
          caloriesDinner: 0,
          caloriesSnack: 0,
          workoutCompleted: false,
        ),
      );
      if (entry.weight > 0) {
        weightSpots.add(FlSpot(i + 1, entry.weight));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Today'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _clearAllEntries,
              child: const Text('🗑️ Clear All Data'),
            ),
            const SizedBox(height: 16),
            if (showEntryForm)
              Column(
                children: [
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (lbs)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _sleepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sleep (hours)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveEntry,
                    child: const Text('Save Entry'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () => setState(() => showEntryForm = true),
                child: const Text('Re-enter Today'),
              ),

            const SizedBox(height: 24),
            const Text('📊 Weight Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 10 == 0 || value == 0 || value == 105) {
                            return Text('Day ${value.toInt()}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weightSpots,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.purple,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('📅 15-Week Challenge Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _checkOffToday,
              child: const Text('✅ Check Off Today'),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalDays,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final dayDate = days[index];
                final isToday = dayDate.year == today.year &&
                                dayDate.month == today.month &&
                                dayDate.day == today.day;
                final isChecked = box.values.any((e) =>
                  e.workoutCompleted &&
                  e.date.year == dayDate.year &&
                  e.date.month == dayDate.month &&
                  e.date.day == dayDate.day);

                return Container(
                  decoration: BoxDecoration(
                    color: isChecked ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Day ${index + 1}',
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isChecked ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
