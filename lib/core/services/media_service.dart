import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a gem image to Firebase Storage and returns the download URL.
  /// Falls back to base64 encoding stored in Firestore if Storage upload fails.
  Future<String> uploadGemImage(File imageFile, String gemId) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('gems/$gemId/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Fallback: store as base64 in Firestore if Storage is unavailable
      try {
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } catch (e2) {
        throw Exception('Failed to upload image: $e2');
      }
    }
  }

  /// Uploads a profile picture to Firebase Storage and returns the download URL.
  /// Falls back to base64 encoding stored in Firestore if Storage upload fails.
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('avatars/$userId/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Fallback: store as base64 if Storage is unavailable
      try {
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } catch (e2) {
        throw Exception('Failed to upload profile picture: $e2');
      }
    }
  }
}
