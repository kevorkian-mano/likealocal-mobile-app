import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/hidden_gem_model.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import '../share_hidden_gem_screen/provider/share_hidden_gem_provider.dart';
import '../../widgets/safe_image.dart';

/// A standalone page that lets the current user edit one of their shared gems.
/// Uses [ShareHiddenGemProvider] seeded with the existing gem data so all
/// existing logic (upload, update, draft) stays in one place.
class EditGemPage extends StatelessWidget {
  final HiddenGem gem;
  const EditGemPage({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShareHiddenGemProvider()..handleExistingGem(gem),
      child: const _EditGemBody(),
    );
  }
}

class _EditGemBody extends StatelessWidget {
  const _EditGemBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShareHiddenGemProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Column(
        children: [
          // ── Green App Bar ──────────────────────────────────
          Container(
            color: const Color(0xFF1B3022),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Edit Hidden Gem',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.eco, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form Body ─────────────────────────────────────
          Expanded(
            child: Form(
              key: provider.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Media ──────────────────────────────
                    _sectionLabel('Photos'),
                    const SizedBox(height: 8),
                    _MediaUploadArea(provider: provider),
                    const SizedBox(height: 20),

                    // ── Place Title ────────────────────────
                    _sectionLabel('Place Title'),
                    const SizedBox(height: 8),
                    CustomEditText(
                      hintText: 'e.g. The Hidden Garden Café',
                      controller: provider.placeTitleController,
                      validator: provider.validatePlaceTitle,
                    ),
                    const SizedBox(height: 16),

                    // ── Category ───────────────────────────
                    _sectionLabel('Category'),
                    const SizedBox(height: 8),
                    _CategoryDropdown(provider: provider),
                    const SizedBox(height: 16),

                    // ── Location ───────────────────────────
                    _sectionLabel('Location'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomEditText(
                            hintText: 'Lat, Lng (tap map to pick)',
                            controller: provider.locationController,
                            validator: provider.validateLocation,
                            isTimeInput: true,
                            onTap: () => provider.adjustPin(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => provider.adjustPin(context),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B3022),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.map_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Description ────────────────────────
                    _sectionLabel('Description'),
                    const SizedBox(height: 8),
                    CustomEditText(
                      hintText: 'Describe what makes this place special...',
                      controller: provider.descriptionController,
                      validator: provider.validateDescription,
                      isMultiline: true,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // ── Local's Tip ─────────────────────────
                    _sectionLabel("Local's Tip"),
                    const SizedBox(height: 8),
                    CustomEditText(
                      hintText:
                          'What do locals know that tourists don\'t?',
                      controller: provider.localTipsController,
                      isMultiline: true,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // ── Recommended Dishes ─────────────────
                    _sectionLabel('Recommended Highlights'),
                    const SizedBox(height: 8),
                    CustomEditText(
                      hintText: 'e.g. Grilled kofta, Mango juice...',
                      controller: provider.recommendedDishesController,
                      isMultiline: true,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    // ── Save Button ────────────────────────
                    _SaveButton(provider: provider),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      );
}

// ── Category Dropdown ─────────────────────────────────────────────────────────
class _CategoryDropdown extends StatefulWidget {
  final ShareHiddenGemProvider provider;
  const _CategoryDropdown({required this.provider});

  @override
  State<_CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<_CategoryDropdown> {
  static const _categories = [
    'Food & Drinks',
    'Nature',
    'Art & Culture',
    'Shopping',
    'Entertainment',
    'Sports & Adventure',
    'Relaxation',
    'Hidden Dining',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    String? currentVal = widget.provider.shareHiddenGemModel.selectedCategory;
    if (currentVal != null && !_categories.contains(currentVal)) {
      currentVal = null;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB0BEC5)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentVal,
          hint: const Text(
            'Select category',
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'Inter',
              fontSize: 15,
            ),
          ),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontSize: 15,
          ),
          items: _categories
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Inter',
                        fontSize: 15,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            widget.provider.updateCategory(val);
          },
        ),
      ),
    );
  }
}

// ── Media Upload Area ─────────────────────────────────────────────────────────
class _MediaUploadArea extends StatelessWidget {
  final ShareHiddenGemProvider provider;
  const _MediaUploadArea({required this.provider});

  @override
  Widget build(BuildContext context) {
    final media = provider.shareHiddenGemModel.selectedMediaPaths;

    if (media.isEmpty) {
      return GestureDetector(
        onTap: () => provider.pickImageFromGallery(),
        child: Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            color: const Color(0xFFECEFE8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC1C8C0),
              width: 1.5,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  color: Color(0xFF1B3022), size: 38),
              SizedBox(height: 8),
              Text(
                'Tap to add / change photos',
                style: TextStyle(
                  color: Color(0xFF1B3022),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length + 1, // +1 for "add more" button
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          if (i == media.length) {
            // "Add more" tile
            return GestureDetector(
              onTap: () => provider.pickImageFromGallery(),
              child: Container(
                width: 85,
                height: 115,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFE8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFC1C8C0), width: 1.5),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFF1B3022), size: 28),
                    SizedBox(height: 4),
                    Text('Add',
                        style: TextStyle(
                            color: Color(0xFF1B3022), fontSize: 12)),
                  ],
                ),
              ),
            );
          }

          final src = media[i];
          final idx = i; // capture for closure
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(src, 115, 115),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => provider.removeMedia(idx),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String src, double w, double h) {
    if (src.startsWith('http')) {
      return SafeImage(
        imageUrl: src,
        width: w,
        height: h,
        fit: BoxFit.cover,
        placeholder: _placeholder(w, h),
      );
    }
    // local file path
    if (src.startsWith('/') ||
        src.startsWith('file://') ||
        RegExp(r'^[A-Za-z]:\\').hasMatch(src)) {
      final path = src.replaceFirst('file://', '');
      return Image.file(File(path),
          width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(w, h));
    }
    // base64 fallback
    try {
      return Image.memory(base64Decode(src),
          width: w, height: h, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(w, h));
    } catch (_) {
      return _placeholder(w, h);
    }
  }

  Widget _placeholder(double w, double h) => Container(
        width: w,
        height: h,
        color: const Color(0xFFECEFE8),
        child:
            const Icon(Icons.image_not_supported, color: Color(0xFF1B3022)),
      );
}

// ── Save Button ───────────────────────────────────────────────────────────────
class _SaveButton extends StatefulWidget {
  final ShareHiddenGemProvider provider;
  const _SaveButton({required this.provider});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  @override
  Widget build(BuildContext context) {
    final loading = widget.provider.isLoading;
    return CustomButton(
      text: loading ? 'Saving...' : 'Save Changes',
      backgroundColor: const Color(0xFF1B3022),
      textColor: Colors.white,
      borderRadius: 14,
      fontFamily: 'Outfit',
      fontSize: 16,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      onPressed: loading
          ? null
          : () => widget.provider.publishToommunity(context),
    );
  }
}
