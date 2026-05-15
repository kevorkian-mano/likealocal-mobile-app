import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/services/ai_service.dart';
import '../../widgets/custom_button.dart';
import '../place_details_screen/place_details_screen.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/premium_upgrade_sheet.dart';

class ExplorePageWithNotifScreen extends StatefulWidget {
  const ExplorePageWithNotifScreen({super.key});

  static Widget builder(BuildContext context) {
    return const ExplorePageWithNotifScreen();
  }

  @override
  State<ExplorePageWithNotifScreen> createState() =>
      _ExplorePageWithNotifScreenState();
}

class _ExplorePageWithNotifScreenState
    extends State<ExplorePageWithNotifScreen> {
  String _searchQuery = '';
  String? _dismissedNotifId; // FR11-7: track dismissed admin broadcast
  bool _superUserOnly = false; // FR7-5: Local legends only filter

  @override
  void initState() {
    super.initState();
    // FR8-3: Start listening for new chat messages for push notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<ChatProvider>(
          context,
          listen: false,
        ).startListeningForNewMessages(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // FR9-3: Offline mode indicator
                  const OfflineBanner(),
                  // FR11-7: Admin broadcast notification banner
                  _buildNotificationBanner(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 56, bottom: 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            if (!userProvider.isAuthenticated) {
                              return Container(
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  0,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F7F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFD7E8DE),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Color(0xFF1B3022),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Guest Mode',
                                          style: TextStyleHelper
                                              .instance
                                              .body14BoldInter
                                              .copyWith(
                                                color: const Color(0xFF1B3022),
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You are exploring in guest mode. Sign up to save places, chat with locals, and add your own hidden gems!',
                                      style: TextStyleHelper
                                          .instance
                                          .body12MediumInter
                                          .copyWith(
                                            color: const Color(0xFF4D6353),
                                            height: 1.4,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.signUpPage,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1B3022,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.pricingPage,
                                          ),
                                          child: const Text(
                                            'View Premium Plans',
                                            style: TextStyle(
                                              color: Color(0xFF1B3022),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEFE8),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) => setState(
                                            () => _searchQuery = value,
                                          ),
                                          style: TextStyleHelper
                                              .instance
                                              .body14MediumInter,
                                          decoration: InputDecoration(
                                            hintText: 'Search hidden gems...',
                                            hintStyle: TextStyleHelper
                                                .instance
                                                .body14MediumInter
                                                .copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.aiChatbotScreen,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: appTheme.midnightPine,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(seconds: 2),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return GestureDetector(
                                    onTap: () => _showFilterSheet(context),
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1B3022),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFFFFD700).withValues(
                                              alpha: 0.3 * (1 - value.abs()),
                                            ),
                                            blurRadius: 10 * (1 - value.abs()),
                                            spreadRadius: 5 * (1 - value.abs()),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.tune,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildBackgroundRadar(),
                            ],
                          ),
                        ),
                        Consumer<GemsProvider>(
                          builder: (context, gemsProvider, _) {
                            final categories = gemsProvider.uniqueCategories;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: categories
                                    .map(
                                      (cat) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => setState(
                                            () => _searchQuery = cat,
                                          ),
                                          child: _buildChip(
                                            cat,
                                            _searchQuery == cat
                                                ? appTheme.midnightPine
                                                : const Color(0xFFD7E8DE),
                                            _searchQuery == cat
                                                ? Colors.white
                                                : const Color(0xFF4D6353),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildAIItinerarySection(),
                        const SizedBox(height: 16),
                        SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<GemsProvider>(
                            builder: (context, gemsProvider, _) {
                              final nearest = gemsProvider.getNearestGem();
                              if (nearest == null ||
                                  gemsProvider.userLocation == null) {
                                return const SizedBox.shrink();
                              }

                              final distance =
                                  LocationService.calculateDistance(
                                    gemsProvider.userLocation!.latitude,
                                    gemsProvider.userLocation!.longitude,
                                    nearest.latitude,
                                    nearest.longitude,
                                  );

                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlaceDetailsScreen(gem: nearest),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1B3022),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 15,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'NEAREST GEM',
                                              style: TextStyleHelper
                                                  .instance
                                                  .label10BoldInter
                                                  .copyWith(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.8),
                                                    letterSpacing: 0.6,
                                                  ),
                                            ),
                                            Text(
                                              '${nearest.name} is\njust ${gemsProvider.formatDistance(distance * 1000)} away!',
                                              style: TextStyleHelper
                                                  .instance
                                                  .body14BoldInter
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            9999,
                                          ),
                                        ),
                                        child: Text(
                                          'View',
                                          style: TextStyleHelper
                                              .instance
                                              .label10BoldInter
                                              .copyWith(
                                                color: Color(0xFF1B3022),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // FR10-4, FR6-6: AI Itinerary Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer2<GemsProvider, UserProvider>(
                            builder: (context, gemsProvider, userProvider, _) {
                              final isPremium =
                                  (userProvider.user?.isPro ?? false) ||
                                  (userProvider.user?.isSuperUser ?? false);
                              return GestureDetector(
                                onTap: () {
                                  if (!isPremium) {
                                    PremiumUpgradeSheet.show(context);
                                  } else {
                                    _generateNewItinerary(context);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2C4C3B),
                                        Color(0xFF1B3022),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFFFD700,
                                      ).withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFFD700,
                                        ).withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFFD700,
                                          ).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome_motion_rounded,
                                          color: Color(0xFFFFD700),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'AI ITINERARY',
                                                  style: TextStyleHelper
                                                      .instance
                                                      .label10BoldInter
                                                      .copyWith(
                                                        color: const Color(
                                                          0xFFFFD700,
                                                        ),
                                                        letterSpacing: 1.2,
                                                      ),
                                                ),
                                                if (!isPremium) ...[
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.lock,
                                                    color: Color(0xFFFFD700),
                                                    size: 10,
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Plan your perfect day',
                                              style: TextStyleHelper
                                                  .instance
                                                  .title18SemiBoldInter
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Based on your vibes and nearby gems',
                                              style: TextStyleHelper
                                                  .instance
                                                  .body12MediumInter
                                                  .copyWith(
                                                    color: Colors.white70,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white30,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer2<GemsProvider, UserProvider>(
                            builder: (context, gemsProvider, userProvider, child) {
                              if (gemsProvider.isLoading) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF1B3022),
                                    ),
                                  ),
                                );
                              }

                              final userVibes =
                                  userProvider.user?.selectedVibes ?? [];
                              var displayGems = gemsProvider.approvedGems;

                              // FR7-5: Super User Filter
                              if (_superUserOnly) {
                                displayGems = displayGems
                                    .where((g) => g.contributorIsSuperUser)
                                    .toList();
                              }

                              // 1. Keyword & Code Search Filtering (FR2-3, FR4-15)
                              if (_searchQuery.isNotEmpty) {
                                final query = _searchQuery.trim().toLowerCase();
                                displayGems = displayGems
                                    .where(
                                      (gem) =>
                                          gem.name.toLowerCase().contains(
                                            query,
                                          ) ||
                                          gem.description
                                              .toLowerCase()
                                              .contains(query) ||
                                          gem.category.toLowerCase().contains(
                                            query,
                                          ) ||
                                          gem.vibe.toLowerCase().contains(
                                            query,
                                          ) ||
                                          gem.uniqueCode.toLowerCase() ==
                                              query ||
                                          gem.localsTip.toLowerCase().contains(
                                            query,
                                          ),
                                    )
                                    .toList();
                              }

                              // 2. Personalization Filter (Existing Vibe Matching)
                              bool showingVibeMatches = false;
                              if (_searchQuery.isEmpty &&
                                  userVibes.isNotEmpty) {
                                final matchingGems = displayGems
                                    .where(
                                      (gem) => userVibes.any(
                                        (vibe) => gem.vibe
                                            .toLowerCase()
                                            .contains(vibe.toLowerCase()),
                                      ),
                                    )
                                    .toList();

                                if (matchingGems.isNotEmpty) {
                                  displayGems = matchingGems;
                                  showingVibeMatches = true;
                                }
                              }

                              if (displayGems.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: Text(
                                      _searchQuery.isEmpty
                                          ? 'No matching gems found. Try exploring more vibes!'
                                          : 'No results for "$_searchQuery"',
                                      textAlign: TextAlign.center,
                                      style: TextStyleHelper
                                          .instance
                                          .body14MediumInter,
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showingVibeMatches)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome,
                                            color: Color(0xFF1B3022),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Matching your vibe',
                                            style: TextStyleHelper
                                                .instance
                                                .body14BoldInter
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF1B3022,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ...displayGems.map(
                                    (gem) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: _buildCard(context, gem),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  border: Border(bottom: BorderSide(color: Color(0x33C1C9C1))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LikeALocal',
                      style: TextStyleHelper.instance.title20BoldOutfit
                          .copyWith(
                            color: Color(0xFF191C1A),
                            letterSpacing: -0.5,
                          ),
                    ),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(AppRoutes.userProfilePage);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: CustomImageView(
                              imagePath: userProvider.user?.avatarUrl,
                              height: 36,
                              width: 36,
                              fit: BoxFit.cover,
                              radius: BorderRadius.circular(18),
                              placeHolder: ImageConstant.imgImageNotFound,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<GemsProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: () => _onSurpriseMe(context),
            backgroundColor: Color(0xFF1B3022),
            icon: Icon(Icons.auto_awesome, color: Colors.white),
            label: Text(
              'Surprise Me',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(selectedIndex: 0),
    );
  }

  void generateAiItinerary(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Localie is crafting your day...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final gemsProvider = Provider.of<GemsProvider>(context, listen: false);

      final vibes = userProvider.user?.selectedVibes ?? ['General'];
      final nearbyGemNames = gemsProvider.approvedGems
          .take(5)
          .map((g) => g.name)
          .toList();

      final itinerary = await AIService.generateItinerary(
        vibes,
        nearbyGemNames,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // close loading

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF1B3022)),
                    const SizedBox(width: 12),
                    Text(
                      'Your Personalized Day',
                      style: TextStyleHelper.instance.title20BoldOutfit,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Text(
                    itinerary,
                    style: TextStyleHelper.instance.body16MediumInter.copyWith(
                      height: 1.6,
                      color: const Color(0xFF4D6353),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: CustomButton(
                  text: 'Save Itinerary',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI Error: $e')));
    }
  }

  void _onSurpriseMe(BuildContext context) {
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final approvedGems = gemsProvider.approvedGems;
    if (approvedGems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No approved gems available yet!')),
      );
      return;
    }

    final userVibes = userProvider.user?.selectedVibes ?? [];
    HiddenGem? selectedGem;

    if (userVibes.isNotEmpty) {
      final matches = approvedGems
          .where(
            (gem) => userVibes.any(
              (vibe) => gem.vibe.toLowerCase().contains(vibe.toLowerCase()),
            ),
          )
          .toList();

      if (matches.isNotEmpty) {
        selectedGem = (matches..shuffle()).first;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('âœ¨ Found a gem matching your vibe!')),
        );
      }
    }

    selectedGem ??= (approvedGems..shuffle()).first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(gem: selectedGem),
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyleHelper.instance.body14MediumInter.copyWith(
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, HiddenGem gem) {
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);
    final userLoc = gemsProvider.userLocation;
    final isLocalLegend = gem.contributorIsSuperUser;

    String distanceText = '--- km away';
    if (userLoc != null) {
      double dist = LocationService.calculateDistance(
        userLoc.latitude,
        userLoc.longitude,
        gem.latitude,
        gem.longitude,
      );
      distanceText = '${dist.toStringAsFixed(1)} km away';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlaceDetailsScreen(gem: gem)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    gem.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: const Color(0xFFE8F2E9),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF1B3022),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      distanceText,
                      style: TextStyle(
                        color: Color(0xFF1B3022),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (gem.isTrending)
                  Positioned(top: 12, left: 12, child: _buildTrendingBadge()),
                if (isLocalLegend)
                  Positioned(
                    top: gem.isTrending ? 52 : 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LOCAL LEGEND',
                        style: TextStyle(
                          color: Color(0xFF1B3022),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gem.name,
                        style: TextStyleHelper.instance.title20BoldOutfit
                            .copyWith(color: Color(0xFF191C1A)),
                      ),
                      Consumer2<UserProvider, GemsProvider>(
                        builder: (context, userProvider, gemsProvider, _) {
                          final isSaved =
                              userProvider.user?.savedGems.contains(gem.id) ??
                              false;
                          return GestureDetector(
                            onTap: () async {
                              final user = userProvider.user;
                              if (user == null) {
                                _showGuestSignUpPrompt(
                                  context,
                                  'Sign up to save your favourite local gems and build your personal collection.',
                                );
                                return;
                              }
                              // OPTIMISTIC UPDATE
                              userProvider.updateSavedGemsLocally(gem.id, isSaved);

                              try {
                                await gemsProvider.toggleSaveGem(
                                  user.id,
                                  gem.id,
                                  isSaved,
                                );
                                if (!context.mounted) return;
                              } catch (e) {
                                // REVERT OPTIMISTIC UPDATE
                                userProvider.updateSavedGemsLocally(gem.id, !isSaved);
                                
                                if (!context.mounted) return;
                                if (e.toString().contains('LIMIT_REACHED')) {
                                  PremiumUpgradeSheet.show(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Color(0xFF1B3022),
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    gem.description,
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      color: Color(0xFF4D6353),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF1B3022),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          Icon(Icons.whatshot, color: Color(0xFFFFD700), size: 12),
          SizedBox(width: 4),
          Text(
            'TRENDING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Discovery',
                    style: TextStyleHelper.instance.title20BoldOutfit,
                  ),
                  SizedBox(height: 24),
                  _buildFilterToggle(
                    'Super User Recommendations',
                    'Filter by Local Legends only (FR7-5)',
                    _superUserOnly,
                    (val) {
                      setModalState(() => _superUserOnly = val);
                      setState(() => _superUserOnly = val); // update parent
                    },
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Price vs. Vibe Intensity',
                    style: TextStyleHelper.instance.body14BoldInter,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Balance your budget against the experience depth (FR2-9)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Slider(
                    value: 0.5,
                    onChanged: (_) {},
                    activeColor: Color(0xFF1B3022),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Deep Experience',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: 'Apply Filters',
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyleHelper.instance.body14BoldInter),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF1B3022),
        ),
      ],
    );
  }

  // FR11-7: Admin broadcast notification banner
  Widget _buildNotificationBanner() {
    return const SizedBox.shrink();
  }

  void _showGuestSignUpPrompt(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Color(0xFF1B3022)),
            const SizedBox(height: 16),
            Text(
              'Sign Up Required',
              style: TextStyleHelper.instance.title20BoldOutfit,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3022),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.signUpPage);
                },
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.signInPage);
              },
              child: const Text(
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advanced Filter',
                style: TextStyleHelper.instance.title20BoldOutfit,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Legends Only (Super Users)',
                    style: TextStyleHelper.instance.body14BoldInter,
                  ),
                  Switch(
                    value: _superUserOnly,
                    onChanged: (val) {
                      setModalState(() => _superUserOnly = val);
                      setState(() => _superUserOnly = val);
                    },
                    activeColor: const Color(0xFF1B3022),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Apply Filters',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIItinerarySection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (!userProvider.isAuthenticated) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [appTheme.midnightPine, const Color(0xFF3E5641)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: appTheme.midnightPine.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Daily Itinerary',
                    style: TextStyleHelper.instance.title18SemiBoldInter
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Personalized based on your vibes and recent interests.',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              _buildItineraryStep(
                'Morning',
                'Sunrise coffee at Sunset Peak',
                Icons.wb_sunny_outlined,
              ),
              _buildItineraryStep(
                'Afternoon',
                'Local art walk in Zamalek',
                Icons.palette_outlined,
              ),
              _buildItineraryStep(
                'Evening',
                'Hidden jazz bar discovery',
                Icons.nightlife_outlined,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _generateNewItinerary(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: appTheme.midnightPine,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Refresh Itinerary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItineraryStep(String time, String activity, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFFD700), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateNewItinerary(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);

    // FR10-4: Restricted to Premium users
    if (userProvider.user == null ||
        (!userProvider.user!.isPro && !userProvider.user!.isSuperUser)) {
      PremiumUpgradeSheet.show(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    try {
      final result = await AIService.generateItinerary(
        userProvider.user?.selectedVibes ?? [],
        gemsProvider.approvedGems.map((g) => g.name).toList(),
      );
      if (!context.mounted) return;
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFD700),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Your AI Journey',
                style: TextStyleHelper.instance.title20BoldOutfit,
              ),
              const SizedBox(height: 16),
              Text(
                result,
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Sounds Perfect!',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sync with Localie AI.')),
      );
    }
  }

  Widget _buildBackgroundRadar() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (!userProvider.isAuthenticated) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(left: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const _RadarPulse(),
              const Icon(Icons.radar, color: Color(0xFF1B3022), size: 16),
            ],
          ),
        );
      },
    );
  }
}

class _RadarPulse extends StatefulWidget {
  const _RadarPulse();
  @override
  __RadarPulseState createState() => __RadarPulseState();
}

class __RadarPulseState extends State<_RadarPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF1B3022).withOpacity(1 - _controller.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
