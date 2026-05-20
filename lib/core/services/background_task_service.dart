import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import '../models/hidden_gem_model.dart';
import '../models/user_model.dart';

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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return true;

    final userDoc = await FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    ).collection('users').doc(userId).get();
    if (!userDoc.exists) return true;
    final user = UserModel.fromMap(userDoc.data()!, userDoc.id);

    if (user.savedGems.isEmpty) return true;

    // 1. Get current location
    Position position = await Geolocator.getCurrentPosition();

    // 2. Fetch specific user saved gems
    final chunks = <List<String>>[];
    final savedGems = List<String>.from(user.savedGems);
    for (var i = 0; i < savedGems.length; i += 10) {
      chunks.add(savedGems.sublist(i, i + 10 > savedGems.length ? savedGems.length : i + 10));
    }

    for (var chunk in chunks) {
      final gemsSnapshot = await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      )
          .collection('gems')
          .where(FieldPath.documentId, whereIn: chunk)
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
            title: "Saved Gem Nearby! 💎",
            body: "You are near ${gem.name}. Why not check it out?",
            payload: gem.id,
          );
          // Only notify for one gem to avoid spamming in background task
          return true;
        }
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return true;

    // Calculate sum of views and saves from the user's gems
    final gemsSnapshot = await FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    )
        .collection('gems')
        .where('contributorId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .get();

    int totalViews = 0;
    int totalSaves = 0;

    for (var doc in gemsSnapshot.docs) {
      final gem = HiddenGem.fromMap(doc.data(), doc.id);
      totalViews += gem.views;
      totalSaves += gem.saves;
    }

    await NotificationService().showLocalNotification(
      id: 999,
      title: "Your Weekly Impact! 🌟",
      body: "Your gems were viewed $totalViews times and saved $totalSaves times. Keep exploring!",
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
