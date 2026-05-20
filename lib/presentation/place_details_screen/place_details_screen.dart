import '../edit_gem_page/edit_gem_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../core/models/gem_review_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/services/ai_service.dart';
import '../../core/utils/gem_ranking_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/premium_upgrade_sheet.dart';
import '../../widgets/safe_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final HiddenGem? gem;

  const PlaceDetailsScreen({super.key, this.gem});

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      // Handle deep link by fetching from GemsProvider
      final gem = Provider.of<GemsProvider>(context, listen: false).gems
          .firstWhere(
            (g) => g.id == args,
            orElse: () => throw Exception('Gem not found'),
          );
      return PlaceDetailsScreen(gem: gem);
    }
    return PlaceDetailsScreen(gem: args as HiddenGem?);
  }

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  @override
  void initState() {
    super.initState();
    if (widget.gem != null) {
      Future.microtask(() {
        Provider.of<GemsProvider>(
          context,
          listen: false,
        ).incrementViews(widget.gem!.id);
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).trackInteraction(widget.gem!.category, widget.gem!.vibe);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gem == null) {
      return const Scaffold(
        body: Center(child: Text('Gem details not found.')),
      );
    }
    final displayGem = widget.gem!;
    final currentUser = Provider.of<UserProvider>(context).user;
    final bool isOwner = currentUser?.id == displayGem.contributorId;
    final bool isSaved =
        currentUser?.savedGems.contains(displayGem.id) ?? false;
    
    // Calculate match percentage based on user preferences
    final userPreferences = currentUser?.selectedVibes ?? [];
    final matchPercentage = GemRankingHelper.calculateMatchPercentage(
      displayGem,
      userPreferences,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 380,
                  child: displayGem.mediaUrls.isEmpty 
                    ? SafeImage(imageUrl: displayGem.imageUrl, fit: BoxFit.cover)
                    : PageView.builder(
                        itemCount: displayGem.mediaUrls.length,
                        itemBuilder: (context, index) {
                          return SafeImage(imageUrl: displayGem.mediaUrls[index], fit: BoxFit.cover);
                        },
                      ),
                ),
                Positioned(
                  left: 20,
                  top: 48,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 48,
                  child: Row(
                    children: [
                      _buildCodeTag(displayGem.uniqueCode),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showReportDialog(context, displayGem),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.report_problem_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (userPreferences.isNotEmpty)
                  Positioned(
                    bottom: 48,
                    left: 20,
                    child: _buildAnimatedVibeMatch('$matchPercentage% Match'),
                  ),
              ],
            ),

            Container(
              transform: Matrix4.translationValues(0, -32, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayGem.name,
                          style: TextStyleHelper
                              .instance
                              .headline30ExtraBoldOutfit
                              .copyWith(color: const Color(0xFF191C1A)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (currentUser == null) {
                            _showGuestSignUpPrompt(
                              context,
                              'You need an account to set location reminders.',
                            );
                            return;
                          }
                          try {
                            await Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).toggleReminder(displayGem.id);
                            final isReminding =
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).user?.reminders.contains(displayGem.id) ??
                                false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isReminding
                                      ? 'Reminder set for when you are nearby!'
                                      : 'Reminder removed',
                                ),
                                backgroundColor: const Color(0xFF1B3022),
                              ),
                            );
                          } catch (e) {
                            if (e.toString().contains('LIMIT_REACHED')) {
                              PremiumUpgradeSheet.show(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to set reminder'),
                                ),
                              );
                            }
                          }
                        },
                        child: Icon(
                          currentUser?.reminders.contains(displayGem.id) == true 
                              ? Icons.notifications_active 
                              : Icons.notifications_none,
                          color: currentUser?.reminders.contains(displayGem.id) == true 
                              ? const Color(0xFF1B3022) 
                              : const Color(0xFF191C1A),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          if (currentUser == null) {
                            _showGuestSignUpPrompt(
                              context,
                              'You need an account to save favorite places.',
                            );
                            return;
                          }
                          try {
                            await Provider.of<GemsProvider>(
                              context,
                              listen: false,
                            ).toggleSaveGem(
                              currentUser.id,
                              displayGem.id,
                              isSaved,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isSaved
                                      ? 'Removed from favorites'
                                      : 'Saved to favorites',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (e.toString().contains('LIMIT_REACHED')) {
                              PremiumUpgradeSheet.show(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update favorites'),
                                ),
                              );
                            }
                          }
                        },
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: isSaved
                              ? const Color(0xFF1B3022)
                              : const Color(0xFF191C1A),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF3E5641),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: FutureBuilder<List<Placemark>>(
                          future: placemarkFromCoordinates(
                              displayGem.latitude, displayGem.longitude),
                          builder: (context, snapshot) {
                            String locationText;
                            if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              final p = snapshot.data!.first;
                              final List<String> parts = [];
                              void addPart(String? val) {
                                if (val == null || val.trim().isEmpty) return;
                                final trimmed = val.trim();
                                final normalized = trimmed.toLowerCase();
                                if (RegExp(r'^[\d\s\-\+,ºª\.]+$').hasMatch(normalized)) {
                                  return;
                                }
                                for (var existing in parts) {
                                  final extNorm = existing.toLowerCase();
                                  if (extNorm == normalized ||
                                      extNorm.contains(normalized) ||
                                      normalized.contains(extNorm)) {
                                    return;
                                  }
                                }
                                parts.add(trimmed);
                              }

                              addPart(p.thoroughfare);
                              addPart(p.subLocality);
                              addPart(p.locality);
                              addPart(p.subAdministrativeArea);
                              addPart(p.administrativeArea);
                              addPart(p.country);

                              locationText = parts.isNotEmpty
                                  ? parts.take(2).join(', ')
                                  : '${displayGem.latitude.toStringAsFixed(3)}°, ${displayGem.longitude.toStringAsFixed(3)}°';
                            } else {
                              locationText = displayGem.category.isNotEmpty
                                  ? '${displayGem.category} · ${displayGem.latitude.toStringAsFixed(3)}°'
                                  : '${displayGem.latitude.toStringAsFixed(3)}°, ${displayGem.longitude.toStringAsFixed(3)}°';
                            }
                            return Text(
                              locationText,
                              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                                color: const Color(0xFF4D6353),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (isOwner) _buildStatusBadge(displayGem.status),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instanceFor(
                      app: Firebase.app(),
                      databaseId: 'default',
                    )
                        .collection('users')
                        .doc(displayGem.contributorId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        final acceptsMessages = data['acceptsMessages'] ?? true;
                        if (!acceptsMessages) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colors.red.shade700,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Doesn't Accept Direct Messages",
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildTTSButton(displayGem.description),
                  const SizedBox(height: 12),
                  Text(
                    displayGem.description,
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      height: 1.7,
                      color: const Color(0xFF3A302A).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isOwner) _buildOwnerActions(context, displayGem),
                  const SizedBox(height: 32),
                  _buildEmojiSentimentBar(),
                  const SizedBox(height: 32),
                  // removed old busy times call
                  const SizedBox(height: 32),
                  _buildNearbySimilarVibes(),
                  const SizedBox(height: 32),
                  _buildReviewsSection(),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFE8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.tips_and_updates_outlined,
                              color: Color(0xFF3E5641),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Local Tip',
                              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                color: const Color(0xFF191C1A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reading tip aloud... (TTS feature hook)'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Icon(Icons.volume_up_outlined, color: Color(0xFF1B3022), size: 18),
                            ),
                            if (displayGem.contributorIsSuperUser) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFFB8860B),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Local Legend',
                                      style: TextStyleHelper
                                          .instance
                                          .label10BoldInter
                                          .copyWith(
                                            color: const Color(0xFFB8860B),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayGem.localsTip,
                                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                                  color: const Color(0xFF4D6353),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            _buildTTSButton(displayGem.localsTip),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (displayGem.recommendedDishes.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Try these dishes',
                      style: TextStyleHelper.instance.title20BoldOutfit
                          .copyWith(color: const Color(0xFF191C1A)),
                    ),
                    const SizedBox(height: 16),
                    ...displayGem.recommendedDishes.map(
                      (dish) => _buildDishItem(dish),
                    ),
                  ],
                  const SizedBox(height: 40),
                  _buildDynamicBusyTimes(displayGem.category),
                  const SizedBox(height: 24),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instanceFor(
                      app: Firebase.app(),
                      databaseId: 'default',
                    )
                        .collection('users')
                        .doc(displayGem.contributorId)
                        .get(),
                    builder: (context, snapshot) {
                      bool isAvailable = true;
                      bool acceptsMessages = true;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        acceptsMessages = data['acceptsMessages'] ?? true;
                        final isDndEnabled = data['isDndEnabled'] ?? false;
                        final start = data['dndStartHour'] ?? 22;
                        final end = data['dndEndHour'] ?? 8;

                        if (!acceptsMessages) isAvailable = false;
                        if (isDndEnabled) {
                          final now = DateTime.now().hour;
                          if (start > end) {
                            if (now >= start || now < end) isAvailable = false;
                          } else {
                            if (now >= start && now < end) isAvailable = false;
                          }
                        }
                      }

                      if (!acceptsMessages) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.red,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Owner currently doesn't accept direct messages",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (isAvailable) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.nightlight_round,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Owner is currently away (FR5-4)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.map_outlined,
                          label: 'Show Map',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.mapsPage,
                              arguments: displayGem,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // FR3-13: Share this gem
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onPressed: () {
                          // FR3-13: Share summary with image and local tip
                          final shareText = '🗺️ Discover "${displayGem.name}" on LikeALocal!\n\n'
                              'Vibe: ${displayGem.vibe}\n'
                              'Local Tip: "${displayGem.localsTip}"\n\n'
                              'Search for Code: ${displayGem.uniqueCode} to find it yourself!';
                          Share.share(shareText, subject: 'Discover ${displayGem.name}!');
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChatActionButton(context, displayGem, currentUser),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // FR3-7: Set reminder for this place
                  if (currentUser != null)
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.notifications_outlined,
                            label: 'Set Reminder',
                            onPressed: () =>
                                _showSetReminderDialog(context, displayGem),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestSignUpPrompt(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Color(0xFF1B3022)),
            SizedBox(height: 16),
            Text(
              'Sign Up Required',
              style: TextStyleHelper.instance.title20BoldOutfit,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B3022),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close modal
                  Navigator.pushNamed(context, AppRoutes.signUpPage);
                },
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close modal
                Navigator.pushNamed(context, AppRoutes.signInPage);
              },
              child: Text(
                'Already have an account? Log In',
                style: TextStyle(
                  color: Color(0xFF1B3022),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiSentimentBar() {
    final emojis = ['❤️', '🔥', '😮', '🙌', '🤤'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Vibe',
          style: TextStyleHelper.instance.body14BoldInter.copyWith(
            color: Color(0xFF191C1A),
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: emojis
              .map(
                (emoji) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFF0F4EC)),
                  ),
                  child: Text(emoji, style: TextStyle(fontSize: 20)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAnimatedVibeMatch(String text) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3 * value),
                  blurRadius: 15 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF1B3022),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF1B3022),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicBusyTimes(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Dynamic Crowd Level',
                  style: TextStyleHelper.instance.body14BoldInter.copyWith(
                    color: Color(0xFF191C1A),
                  ),
                ),
                SizedBox(width: 8),
                _buildLiveIndicator(),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFE8F2E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category.toLowerCase().contains('cafe') ? 'Usually Busy' : 'Quiet',
                style: TextStyle(
                  color: Color(0xFF3E5641),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(12, (index) {
            final now = DateTime.now().hour;
            final isCurrentHour = (index * 2) <= now && now < ((index + 1) * 2);
            // Dynamic check
            int baseHeight = [10, 15, 30, 45, 60, 55, 40, 25, 20, 35, 50, 20][index];
            if (category.toLowerCase() == 'nightlife' && index > 8) baseHeight += 20;
            if (category.toLowerCase() == 'cafe' && index > 3 && index < 7) baseHeight += 20;

            return Container(
              width: 20,
              height: baseHeight.toDouble().clamp(0, 100),
              decoration: BoxDecoration(
                color: isCurrentHour ? const Color(0xFF1B3022) : const Color(0xFFD7E8DE),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '12 PM',
              style: TextStyle(fontSize: 10, color: Color(0xFF4D6353)),
            ),
            Text(
              '6 PM',
              style: TextStyle(fontSize: 10, color: Color(0xFF4D6353)),
            ),
            Text(
              '12 AM',
              style: TextStyle(fontSize: 10, color: Color(0xFF4D6353)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(1 - value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 4 * value,
                spreadRadius: 2 * value,
              ),
            ],
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildDishItem(String dish) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFFF0F4EC)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(0xFF3E5641),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                dish,
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  color: Color(0xFF3A302A),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFF9F7F2),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_outline, size: 14, color: Color(0xFF1B3022)),
                  SizedBox(width: 4),
                  Text(
                    'Must Try',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B3022),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isPrimary ? Color(0xFF1B3022) : Color(0xFFD7E8DE),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : Color(0xFF1B3022),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : Color(0xFF1B3022),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySimilarVibes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Vibes Nearby',
          style: TextStyleHelper.instance.body14BoldInter.copyWith(
            color: Color(0xFF191C1A),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Consumer<GemsProvider>(
            builder: (context, provider, child) {
              final similarGems = provider.approvedGems.where((g) => 
                g.id != widget.gem!.id && 
                (g.vibe == widget.gem!.vibe || g.category == widget.gem!.category)
              ).toList();

              if (similarGems.isEmpty) return const Text('No similar vibes found yet.');

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: similarGems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final gem = similarGems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.placeDetailsScreen,
                        arguments: gem,
                      );
                    },
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(gem.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          gem.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final displayGem = widget.gem!;
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                color: Color(0xFF191C1A),
              ),
            ),
            if (currentUser != null)
              GestureDetector(
                onTap: () => _showWriteReviewDialog(
                  context,
                  displayGem,
                  gemsProvider,
                  currentUser,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B3022),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Write Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        // FR3-10: AI Review Summary
        _buildAiSummaryTile(displayGem.id, gemsProvider),
        SizedBox(height: 12),
        // FR3-8: Real Firestore reviews stream
        StreamBuilder<QuerySnapshot>(
          stream: gemsProvider.getReviewsStream(displayGem.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Color(0xFF1B3022)),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF9F7F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No reviews yet. Be the first!',
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }
            final reviews = snapshot.data!.docs
                .map(
                  (d) =>
                      GemReview.fromMap(d.data() as Map<String, dynamic>, d.id),
                )
                .toList();
            return Column(
              children: reviews.map((review) {
                final isOwner = currentUser?.id == review.userId;
                final isAdmin = currentUser?.isAdmin == true;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFFF0F4EC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: review.avatarUrl.isNotEmpty
                                ? CachedNetworkImageProvider(review.avatarUrl)
                                : null,
                            backgroundColor: Color(0xFFD7E8DE),
                            child: review.avatarUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Color(0xFF1B3022),
                                  )
                                : null,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              review.userName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < review.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Color(0xFFFFD700),
                                size: 12,
                              ),
                            ),
                          ),
                          if (isOwner || isAdmin) ...[
                            SizedBox(width: 8),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_vert,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onSelected: (val) async {
                                if (val == 'edit') {
                                  _showEditReviewDialog(
                                    context,
                                    displayGem.id,
                                    review,
                                    gemsProvider,
                                  );
                                } else if (val == 'delete') {
                                  await gemsProvider.deleteReview(
                                    displayGem.id,
                                    review.id,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Review deleted')),
                                    );
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                if (isOwner)
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Review'),
                                  ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        review.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4D6353),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // FR3-10: AI summary tile
  Widget _buildAiSummaryTile(String gemId, GemsProvider gemsProvider) {
    return FutureBuilder<QuerySnapshot>(
      future: gemsProvider.getReviewsStream(gemId).first,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B3022), Color(0xFF2C4C3B)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: FutureBuilder<String>(
                  future: AIService.summarizeReviews(
                    snapshot.data!.docs
                        .map((d) => (d.data() as Map)['text'] as String? ?? '')
                        .toList(),
                  ),
                  builder: (ctx, aiSnap) {
                    return Text(
                      aiSnap.data ?? 'Analyzing reviews...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWriteReviewDialog(
    BuildContext context,
    HiddenGem gem,
    GemsProvider gemsProvider,
    user,
  ) {
    double rating = 4.0;
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Review',
                style: TextStyleHelper.instance.title20BoldOutfit,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setState(() => rating = (i + 1).toDouble()),
                    child: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Color(0xFFFFD700),
                      size: 36,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3022),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  onPressed: () async {
                    if (textController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await gemsProvider.addReview(
                      gemId: gem.id,
                      userId: user.id,
                      userName: user.fullName,
                      avatarUrl: user.avatarUrl,
                      rating: rating,
                      text: textController.text.trim(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Review submitted!'),
                          backgroundColor: Color(0xFF1B3022),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Submit Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditReviewDialog(
    BuildContext context,
    String gemId,
    GemReview review,
    GemsProvider gemsProvider,
  ) {
    double rating = review.rating;
    final textController = TextEditingController(text: review.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Review',
                style: TextStyleHelper.instance.title20BoldOutfit,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setState(() => rating = (i + 1).toDouble()),
                    child: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Color(0xFFFFD700),
                      size: 36,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Update your review...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3022),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await gemsProvider.editReview(
                      gemId,
                      review.id,
                      rating: rating,
                      text: textController.text.trim(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Review updated!')),
                      );
                    }
                  },
                  child: Text(
                    'Update Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FR3-7: Show dialog to set location-based reminder
  void _showSetReminderDialog(BuildContext context, HiddenGem gem) {
    double radiusMeters = 500.0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Location Reminder',
                style: TextStyleHelper.instance.title20BoldOutfit,
              ),
              SizedBox(height: 8),
              Text(
                'Get notified when you\'re near this place',
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF9F7F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Radius',
                      style: TextStyleHelper.instance.body14BoldInter,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF1B3022),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: radiusMeters,
                            min: 100,
                            max: 2000,
                            divisions: 19,
                            label:
                                '${(radiusMeters / 1000).toStringAsFixed(1)}km',
                            onChanged: (val) =>
                                setState(() => radiusMeters = val),
                            activeColor: Color(0xFF1B3022),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You\'ll be notified when within ${(radiusMeters / 1000).toStringAsFixed(1)}km of "${gem.name}"',
                      style: TextStyleHelper.instance.body12MediumInter
                          .copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3022),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final currentUser = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).user;
                      if (currentUser == null) return;

                      final gemsProvider = Provider.of<GemsProvider>(
                        context,
                        listen: false,
                      );
                      await gemsProvider.createReminder(
                        userId: currentUser.id,
                        gem: gem,
                        radiusMeters: radiusMeters,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reminder set! You\'ll be notified when nearby.',
                            ),
                            backgroundColor: Color(0xFF1B3022),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error setting reminder: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Set Reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeTag(String code) {
    if (code.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3022).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, HiddenGem gem) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) {
      _showGuestSignUpPrompt(
        context,
        'You need an account to report inaccurate information.',
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.report_gmailerrorred_outlined, color: Colors.red[900], size: 28),
            const SizedBox(width: 10),
            Text(
              'Report This Place',
              style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                color: const Color(0xFF1B3022),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help us keep the community safe. What is wrong with "${gem.name}"?',
                style: const TextStyle(fontSize: 13, color: Color(0xFF4D6353)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Reason for report',
                  hintText: 'e.g. Inaccurate location, Spam, Closed',
                  labelStyle: const TextStyle(color: Color(0xFF1B3022)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1B3022), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Detailed description',
                  hintText: 'Provide details to help moderators review...',
                  labelStyle: const TextStyle(color: Color(0xFF1B3022)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1B3022), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4D6353), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3022),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final reportReason = nameCtrl.text.trim();
                final reportDesc = descCtrl.text.trim();

                // Close the dialog instantly and show user feedback immediately
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted. Thank you for making LikeLocal safer!'),
                    backgroundColor: Color(0xFF1B3022),
                  ),
                );

                // Run database updates in the background with a timeout so they don't block/hang
                try {
                  FirebaseFirestore.instanceFor(
                    app: Firebase.app(),
                    databaseId: 'default',
                  ).collection('alert').add({
                    'name': reportReason,
                    'description': reportDesc,
                    'placeId': gem.id,
                    'placeName': gem.name,
                    'reporterId': currentUser.id,
                    'reporterName': currentUser.fullName,
                    'timestamp': FieldValue.serverTimestamp(),
                  }).timeout(const Duration(seconds: 1)).then((_) {
                    debugPrint('✅ Firestore report created successfully.');
                  }).catchError((e) {
                    debugPrint('⚠️ Firestore report background write timeout/error: $e');
                  });
                } catch (e) {
                  debugPrint('⚠️ Firestore Offline/Error starting alert write: $e');
                }

                try {
                  Provider.of<GemsProvider>(
                    context,
                    listen: false,
                  ).updateGem(gem.id, {'reportCount': FieldValue.increment(1)})
                   .timeout(const Duration(seconds: 1)).then((_) {
                    debugPrint('✅ Firestore gem reportCount updated successfully.');
                  }).catchError((e) {
                    debugPrint('⚠️ Firestore updateGem background write timeout/error: $e');
                  });
                } catch (e) {
                  debugPrint('⚠️ updateGem Firestore Error starting write: $e');
                }
              }
            },
            child: const Text(
              'Submit Report',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(GemStatus status) {
    Color color;
    String label;
    switch (status) {
      case GemStatus.approved:
        color = Colors.green;
        label = 'APPROVED';
        break;
      case GemStatus.pending:
        color = Colors.orange;
        label = 'PENDING REVIEW';
        break;
      case GemStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        break;
      case GemStatus.draft:
        color = Colors.grey;
        label = 'DRAFT';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildOwnerActions(BuildContext context, HiddenGem gem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Manage Your Contribution', style: TextStyleHelper.instance.body14BoldInter),
            // FR3-16: Engagement metrics
            Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${gem.views}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 12),
                const Icon(Icons.bookmark_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${gem.saves}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGemPage(gem: gem),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B3022),
                  side: const BorderSide(color: Color(0xFF1B3022)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, gem),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, HiddenGem gem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to remove this gem from the map?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<GemsProvider>(
                context,
                listen: false,
              ).deleteGem(gem.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to map/explore
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gem deleted successfully.')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTTSButton(String text) {
    return GestureDetector(
      onTap: () async {
        if (_isSpeaking) {
          await _flutterTts.stop();
          setState(() => _isSpeaking = false);
        } else {
          setState(() => _isSpeaking = true);
          await _flutterTts.setLanguage("en-US");
          await _flutterTts.setPitch(1.0);
          await _flutterTts.speak(text);
          _flutterTts.setCompletionHandler(() {
            setState(() => _isSpeaking = false);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F2E9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF1B3022).withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
              color: const Color(0xFF1B3022),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _isSpeaking ? 'Stop Reading' : 'Listen to Description',
              style: TextStyleHelper.instance.label10BoldInter.copyWith(color: const Color(0xFF1B3022), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildChatActionButton(BuildContext context, HiddenGem gem, UserModel? currentUser) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(gem.contributorId).get(),
      builder: (context, snapshot) {
        bool isAvailable = true;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final acceptsMessages = data['acceptsMessages'] ?? true;
          final isDndEnabled = data['isDndEnabled'] ?? false;
          final start = data['dndStartHour'] ?? 22;
          final end = data['dndEndHour'] ?? 8;

          if (!acceptsMessages) isAvailable = false;
          if (isDndEnabled) {
            final now = DateTime.now().hour;
            if (start > end) {
              if (now >= start || now < end) isAvailable = false;
            } else {
              if (now >= start && now < end) isAvailable = false;
            }
          }
        }

        return Stack(
          alignment: Alignment.topRight,
          children: [
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              onPressed: () async {
                if (currentUser == null) {
                  _showGuestSignUpPrompt(context, 'You need an account to chat with the post owner.');
                  return;
                }
                
                if (!isAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contributor is currently offline or has disabled chats.'))
                  );
                  return;
                }

                try {
                  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                  await chatProvider.startNewChat(currentUser, gem.contributorId, gem.name);
                  
                  final chatId = currentUser.id.compareTo(gem.contributorId) < 0 
                      ? '${currentUser.id}_${gem.contributorId}' 
                      : '${gem.contributorId}_${currentUser.id}';
                      
                  final chatPreview = ChatPreview(
                    id: chatId,
                    userName: 'Local Contributor',
                    userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150',
                    lastMessage: 'Ask me anything about ${gem.name}!',
                    lastMessageTime: DateTime.now(),
                    relatedGemName: gem.name,
                    targetUserId: gem.contributorId,
                  );

                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatDetailsScreen,
                    arguments: chatPreview,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                }
              },
              isPrimary: true,
            ),
            if (!isAvailable)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                ),
              ),
          ],
        );
      },
    );
  }
}





