import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../models/share_hidden_gem_model.dart';
import '../../../core/models/hidden_gem_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/gems_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/media_service.dart';
import '../map_picker_page.dart';
import 'package:latlong2/latlong2.dart' as ll;


class ShareHiddenGemProvider extends ChangeNotifier {
  ShareHiddenGemModel shareHiddenGemModel = ShareHiddenGemModel();
  final MediaService _mediaService = MediaService();

  double selectedLat = 30.0444;
  double selectedLng = 31.2357;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void adjustPin(BuildContext context) async {
    final ll.LatLng? result = await Navigator.push<ll.LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(initialPosition: ll.LatLng(selectedLat, selectedLng)),
      ),
    );

    if (result != null) {
      selectedLat = result.latitude;
      selectedLng = result.longitude;
      locationController.text = '${selectedLat.toStringAsFixed(4)}, ${selectedLng.toStringAsFixed(4)}';
      notifyListeners();
    }
  }

  final TextEditingController placeTitleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController localTipsController = TextEditingController();
  final TextEditingController recommendedDishesController = TextEditingController();

  String? validatePlaceTitle(String? value) => value == null || value.isEmpty ? 'Required' : null;
  String? validateCategory(String? value) => value == null || value.isEmpty ? 'Required' : null;
  String? validateLocation(String? value) => value == null || value.isEmpty ? 'Required' : null;
  String? validateDescription(String? value) => value == null || value.isEmpty ? 'Required' : null;

  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isAiAnalyzing = false;
  File? selectedImageFile;

  ShareHiddenGemProvider() {
    _loadDraft();
  }

  void handleExistingGem(HiddenGem? gem) {
    if (gem == null) return;
    placeTitleController.text = gem.name;
    locationController.text = '${gem.latitude}, ${gem.longitude}';
    descriptionController.text = gem.description;
    localTipsController.text = gem.localsTip;
    recommendedDishesController.text = gem.recommendedDishes.join(', ');
    shareHiddenGemModel.selectedCategory = gem.category;
    // Note: Image editing would require more logic, for now we keep existing URL
    notifyListeners();
  }

  @override
  void dispose() {

    placeTitleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    localTipsController.dispose();
    recommendedDishesController.dispose();
    super.dispose();
  }

  // --- Draft Management (FR4-13) ---
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    placeTitleController.text = prefs.getString('draft_title') ?? '';
    locationController.text = prefs.getString('draft_location') ?? '';
    descriptionController.text = prefs.getString('draft_description') ?? '';
    localTipsController.text = prefs.getString('draft_tips') ?? '';
    recommendedDishesController.text = prefs.getString('draft_dishes') ?? '';
    shareHiddenGemModel.selectedCategory = prefs.getString('draft_category');
    notifyListeners();
  }

  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', placeTitleController.text);
    await prefs.setString('draft_location', locationController.text);
    await prefs.setString('draft_description', descriptionController.text);
    await prefs.setString('draft_tips', localTipsController.text);
    await prefs.setString('draft_dishes', recommendedDishesController.text);
    if (shareHiddenGemModel.selectedCategory != null) {
      await prefs.setString('draft_category', shareHiddenGemModel.selectedCategory!);
    }
  }

  // --- Media & AI (FR4-2, FR4-3) ---
  Future<void> pickImageFromCamera() => pickImage(ImageSource.camera);
  Future<void> pickImageFromGallery() => pickImage(ImageSource.gallery);

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) {
        selectedImageFile = File(image.path);
        shareHiddenGemModel.selectedMediaPath = image.path;
        notifyListeners();
        _runAiAnalysis();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _runAiAnalysis() async {
    if (selectedImageFile == null) return;
    isAiAnalyzing = true;
    notifyListeners();

    final suggestions = await AIService.suggestTagsAndCategory(selectedImageFile!);
    
    if (suggestions['category'] != null) {
      shareHiddenGemModel.selectedCategory = suggestions['category'];
    }
    // Could also append tags to description or a tags field
    
    isAiAnalyzing = false;
    notifyListeners();
  }

  // --- Submission Logic (FR4-1 to FR4-7, FR4-11) ---
  String _generateGemCode() {
    final rnd = Random();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return 'LAL-${List.generate(6, (i) => chars[rnd.nextInt(chars.length)]).join()}';
  }

  Future<void> publishToommunity(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a photo of the place')));
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final gemsProvider = Provider.of<GemsProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) throw Exception('Auth Error: Please sign in again.');

      // 1. Upload Media (Real Storage)
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrl = await _mediaService.uploadGemImage(selectedImageFile!, tempId);

      // 2. Build Advanced Model
      final newGem = HiddenGem(
        id: '', // Firestore will set this
        name: placeTitleController.text.trim(),
        description: descriptionController.text.trim(),
        category: shareHiddenGemModel.selectedCategory ?? 'Other',
        vibe: 'Verified Local',
        rating: 5.0,
        imageUrl: imageUrl,
        latitude: selectedLat,
        longitude: selectedLng,
        localsTip: localTipsController.text.trim(),
        recommendedDishes: recommendedDishesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        contributorId: user.id,
        isVerified: user.isSuperUser,
        status: user.isSuperUser ? GemStatus.approved : GemStatus.pending,
        uniqueCode: _generateGemCode(),
        createdAt: DateTime.now(),

      );

      // 3. Save & Award Gamification (FR4-1, FR4-14, FR4-15)
      await gemsProvider.addGem(newGem, user);

      await _clearFormAndDraft();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WOW! ${newGem.name} shared! Code: ${newGem.uniqueCode}'),
          backgroundColor: const Color(0xFF1B3022),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearFormAndDraft() async {
    placeTitleController.clear();
    locationController.clear();
    descriptionController.clear();
    localTipsController.clear();
    recommendedDishesController.clear();
    selectedImageFile = null;
    shareHiddenGemModel = ShareHiddenGemModel();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_location');
    await prefs.remove('draft_description');
    await prefs.remove('draft_tips');
    await prefs.remove('draft_dishes');
    await prefs.remove('draft_category');
    await prefs.remove('gem_draft');
    notifyListeners();
  }

  void updateCategory(String? value) {
    shareHiddenGemModel.selectedCategory = value;
    saveDraft();
    notifyListeners();
  }
}
