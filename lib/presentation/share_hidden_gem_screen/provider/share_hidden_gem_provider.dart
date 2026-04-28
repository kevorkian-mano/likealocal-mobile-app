import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void dispose() {
    placeTitleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    localTipsController.dispose();
    super.dispose();
  }

  void updateCategory(String? value) {
    shareHiddenGemModel.selectedCategory = value;
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
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Clear form after successful submission
      _clearForm();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hidden gem published successfully!'),
          backgroundColor: appTheme.gray_900_01,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to explore screen after successful submission
      NavigatorService.pushNamed(AppRoutes.onboardingScreen);
    } catch (e) {
      _showErrorMessage('Failed to publish. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _clearForm() {
    placeTitleController.clear();
    locationController.clear();
    descriptionController.clear();
    localTipsController.clear();
    shareHiddenGemModel = ShareHiddenGemModel();
    notifyListeners();
  }

  void _showPermissionDeniedMessage(String message) {
    // In a real app, you would show this to the user
    debugPrint(message);
  }

  void _showErrorMessage(String message) {
    // In a real app, you would show this to the user
    debugPrint(message);
  }
}
