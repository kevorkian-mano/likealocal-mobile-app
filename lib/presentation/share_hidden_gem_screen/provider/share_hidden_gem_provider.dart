import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../models/share_hidden_gem_model.dart';

class ShareHiddenGemProvider extends ChangeNotifier {
  ShareHiddenGemModel shareHiddenGemModel = ShareHiddenGemModel();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController placeTitleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController localTipsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  ShareHiddenGemProvider() {
    _initListeners();
    loadDraft();
  }

  void _initListeners() {
    placeTitleController.addListener(() => saveDraft());
    locationController.addListener(() => saveDraft());
    descriptionController.addListener(() => saveDraft());
    localTipsController.addListener(() => saveDraft());
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    placeTitleController.text = prefs.getString('draft_title') ?? '';
    locationController.text = prefs.getString('draft_location') ?? '';
    descriptionController.text = prefs.getString('draft_description') ?? '';
    localTipsController.text = prefs.getString('draft_tips') ?? '';
    shareHiddenGemModel.selectedCategory = prefs.getString('draft_category');
    shareHiddenGemModel.selectedMediaPath = prefs.getString('draft_media');
    notifyListeners();
  }

  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', placeTitleController.text);
    await prefs.setString('draft_location', locationController.text);
    await prefs.setString('draft_description', descriptionController.text);
    await prefs.setString('draft_tips', localTipsController.text);
    if (shareHiddenGemModel.selectedCategory != null) {
      await prefs.setString('draft_category', shareHiddenGemModel.selectedCategory!);
    }
    if (shareHiddenGemModel.selectedMediaPath != null) {
      await prefs.setString('draft_media', shareHiddenGemModel.selectedMediaPath!);
    }
  }

  void updateCategory(String? value) {
    shareHiddenGemModel.selectedCategory = value;
    saveDraft();
    notifyListeners();
  }

  Future<void> pickImageFromCamera() async {
    try {
      // Request camera permission
      PermissionStatus cameraStatus = await Permission.camera.request();

      if (cameraStatus.isGranted) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );

        if (image != null) {
          shareHiddenGemModel.selectedMediaPath = image.path;
          notifyListeners();
        }
      } else {
        _showPermissionDeniedMessage(
          'Camera permission is required to take photos.',
        );
      }
    } catch (e) {
      _showErrorMessage('Failed to take photo. Please try again.');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      // Request storage permission
      PermissionStatus storageStatus = await Permission.storage.request();

      if (storageStatus.isGranted || storageStatus.isLimited) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );

        if (image != null) {
          shareHiddenGemModel.selectedMediaPath = image.path;
          notifyListeners();
        }
      } else {
        _showPermissionDeniedMessage(
          'Storage permission is required to select photos.',
        );
      }
    } catch (e) {
      _showErrorMessage('Failed to select photo. Please try again.');
    }
  }

  void adjustPin() {
    // Implement map pin adjustment logic
    shareHiddenGemModel.isPinAdjusted =
        !(shareHiddenGemModel.isPinAdjusted ?? false);
    notifyListeners();
  }

  String? validatePlaceTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a place title';
    }
    if (value.trim().length < 3) {
      return 'Place title must be at least 3 characters';
    }
    return null;
  }

  String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a location';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide a description';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  @override
  void dispose() {
    placeTitleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    localTipsController.dispose();
    super.dispose();
  }

  Future<void> publishToommunity(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (shareHiddenGemModel.selectedCategory == null) {
      _showErrorMessage('Please select a category');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final gemsProvider = Provider.of<GemsProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (userProvider.user == null) throw Exception('User not logged in');

      final newGem = HiddenGem(
        id: '',
        name: placeTitleController.text,
        description: descriptionController.text,
        category: shareHiddenGemModel.selectedCategory!,
        vibe: 'Local Favorite', // Default vibe for contributions
        rating: 0.0,
        imageUrl: shareHiddenGemModel.selectedMediaPath ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
        latitude: 38.7223, // Placeholder Lisbon Lat
        longitude: -9.1393, // Placeholder Lisbon Lng
        localsTip: localTipsController.text,
        recommendedDishes: [],
        contributorId: userProvider.user!.id,
      );

      await gemsProvider.addGem(newGem, userProvider.user!);

      // Clear draft after successful submission
      await _clearForm();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hidden gem submitted for moderation!'),
          backgroundColor: const Color(0xFF1B3022),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showErrorMessage(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red[800]),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearForm() async {
    placeTitleController.clear();
    locationController.clear();
    descriptionController.clear();
    localTipsController.clear();
    shareHiddenGemModel = ShareHiddenGemModel();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_location');
    await prefs.remove('draft_description');
    await prefs.remove('draft_tips');
    await prefs.remove('draft_category');
    await prefs.remove('draft_media');
    
    notifyListeners();
  }

  void _showPermissionDeniedMessage(String message) {
    debugPrint(message);
  }

  void _showErrorMessage(String message) {
    debugPrint(message);
  }
}
