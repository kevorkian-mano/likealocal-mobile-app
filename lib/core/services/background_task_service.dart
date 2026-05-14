import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification_service.dart';
import '../models/hidden_gem_model.dart';

const String taskProximityCheck = "proximityCheckTask";
const String taskWeeklySummary = "weeklySummaryTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Executing background task: $task");

    // Ensure Firebase is initialized for background execution
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Already initialized or failed
    }

    if (task == taskProximityCheck) {
      return await _handleProximityCheck();
    } else if (task == taskWeeklySummary) {
      return await _handleWeeklySummary();
    }

    return Future.value(true);
  });
}

Future<bool> _handleProximityCheck() async {
  try {
    // 1. Get current location
    Position position = await Geolocator.getCurrentPosition();

    // 2. Fetch some approved gems (in a real app, use geofencing or specific user saved gems)
    // For demo, we'll fetch all approved gems and check distance
    final gemsSnapshot = await FirebaseFirestore.instance
        .collection('gems')
        .where('status', isEqualTo: 'approved')
        .get();

    for (var doc in gemsSnapshot.docs) {
      final gem = HiddenGem.fromMap(doc.data(), doc.id);

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        gem.latitude,
        gem.longitude,
      );

      // If within 500 meters
      if (distance < 500) {
        await NotificationService().showLocalNotification(
          id: gem.id.hashCode,
          title: "Gem Nearby! 💎",
          body: "You are near ${gem.name}. Why not check it out?",
          payload: gem.id,
        );
        // Only notify for one gem to avoid spamming in background task
        break;
      }
    }
    return true;
  } catch (e) {
    print("Error in proximity check: $e");
    return false;
  }
}

Future<bool> _handleWeeklySummary() async {
  try {
    // Mocking a weekly summary for Super Users
    // In a real app, you'd calculate stats from Firestore
    await NotificationService().showLocalNotification(
      id: 999,
      title: "Your Weekly Impact! 🌟",
      body: "Your gems were viewed 150 times this week. Keep exploring!",
    );
    return true;
  } catch (e) {
    print("Error in weekly summary: $e");
    return false;
  }
}

class BackgroundTaskService {
  static final BackgroundTaskService _instance =
      BackgroundTaskService._internal();
  factory BackgroundTaskService() => _instance;
  BackgroundTaskService._internal();

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false for production
    );
  }

  Future<void> scheduleProximityChecks() async {
    await Workmanager().registerPeriodicTask(
      "1",
      taskProximityCheck,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> scheduleWeeklySummary() async {
    await Workmanager().registerPeriodicTask(
      "2",
      taskWeeklySummary,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(hours: 1), // Delay the first run
    );
  }
}
