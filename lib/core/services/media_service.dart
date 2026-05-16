import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadGemImage(File imageFile, String gemId) async {
    try {
      // Store the image directly in the database as a Base64 string!
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      // Store the image directly in the database as a Base64 string!
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
