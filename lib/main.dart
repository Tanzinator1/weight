import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/daily_entry.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/food_tracker_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
  );

  final InitializationSettings initSettings = InitializationSettings(
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  tz.initializeTimeZones();
  await _scheduleDailyReminder();
}

Future<void> _scheduleDailyReminder() async {
  final now = tz.TZDateTime.now(tz.local);
  final next9AM = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0)
      .add(now.isAfter(tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0)) ? Duration(days: 1) : Duration.zero);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Daily Log Reminder',
    'Remember to log today\'s weight and sleep!',
    next9AM,
    const NotificationDetails(
      iOS: DarwinNotificationDetails(),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(DailyEntryAdapter());

  await Hive.openBox<DailyEntry>('daily_entries');
  await Hive.openBox('custom_amounts');
  await Hive.openBox('meta');

  await _initializeNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack15',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NavigationController(),
    );
  }
}

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutScreen(),
    const FoodTrackerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Food',
          ),
        ],
      ),
    );
  }
}
