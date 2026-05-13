import 'package:provider/provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/location_service.dart';
import '../../widgets/custom_button.dart';
import '../place_details_screen/place_details_screen.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class ExplorePageWithNotifScreen extends StatefulWidget {
  const ExplorePageWithNotifScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const ExplorePageWithNotifScreen();
  }

  @override
  State<ExplorePageWithNotifScreen> createState() => _ExplorePageWithNotifScreenState();
}

class _ExplorePageWithNotifScreenState extends State<ExplorePageWithNotifScreen> {
  String _searchQuery = '';
  bool _superUserOnly = false; // FR7-5: Local legends only filter

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
                // Removed: _buildNotificationBanner() - FR11-7 admin notifications
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
                                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F7F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFD7E8DE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info_outline, color: Color(0xFF1B3022), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Guest Mode',
                                          style: TextStyleHelper.instance.body14BoldInter.copyWith(color: const Color(0xFF1B3022)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You are exploring in guest mode. Sign up to save places, chat with locals, and add your own hidden gems!',
                                      style: TextStyleHelper.instance.body12MediumInter.copyWith(color: const Color(0xFF4D6353), height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => Navigator.pushNamed(context, AppRoutes.signUpPage),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1B3022),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: () => Navigator.pushNamed(context, AppRoutes.pricingPage),
                                          child: const Text('View Premium Plans', style: TextStyle(color: Color(0xFF1B3022), fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEFE8),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search, color: Colors.grey, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) => setState(() => _searchQuery = value),
                                          style: TextStyleHelper.instance.body14MediumInter,
                                          decoration: InputDecoration(
                                            hintText: 'Search hidden gems...',
                                            hintStyle: TextStyleHelper.instance.body14MediumInter.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
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
                                            color: Color(0xFFFFD700).withOpacity(0.3 * (1 - value.abs())),
                                            blurRadius: 10 * (1 - value.abs()),
                                            spreadRadius: 5 * (1 - value.abs()),
                                          )
                                        ],
                                      ),
                                      child: Icon(Icons.tune, color: Colors.white, size: 20),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            spacing: 8,
                            children: [
                              _buildChip('Food', appTheme.midnightPine, Colors.white),
                              _buildChip('Adventure', Color(0xFFD7E8DE), Color(0xFF4D6353)),
                              _buildChip('Culture', Color(0xFFD7E8DE), Color(0xFF4D6353)),
                              _buildChip('Chill', Color(0xFFD7E8DE), Color(0xFF4D6353)),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<GemsProvider>(
                            builder: (context, gemsProvider, _) {
                              final nearest = gemsProvider.getNearestGem();
                              if (nearest == null || gemsProvider.userLocation == null) {
                                return const SizedBox.shrink();
                              }
                              
                              final distance = LocationService.calculateDistance(
                                gemsProvider.userLocation!.latitude,
                                gemsProvider.userLocation!.longitude,
                                nearest.latitude,
                                nearest.longitude
                              );
                              
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaceDetailsScreen(gem: nearest),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1B3022),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
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
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.location_on, color: Colors.white, size: 20),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'NEAREST GEM',
                                              style: TextStyleHelper.instance.label10BoldInter.copyWith(
                                                color: Colors.white.withOpacity(0.8),
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                            Text(
                                              '${nearest.name} is\njust ${gemsProvider.formatDistance(distance)} away!',
                                              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Text(
                                          'View',
                                          style: TextStyleHelper.instance.label10BoldInter.copyWith(
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
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer2<GemsProvider, UserProvider>(
                            builder: (context, gemsProvider, userProvider, child) {
                              if (gemsProvider.isLoading) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: CircularProgressIndicator(color: Color(0xFF1B3022)),
                                  ),
                                );
                              }

                              final userVibes = userProvider.user?.selectedVibes ?? [];
                              var displayGems = gemsProvider.approvedGems;

                              // FR7-5: Super User Filter
                              if (_superUserOnly) {
                                displayGems = displayGems.where((g) => g.contributorIsSuperUser).toList();
                              }

                              // 1. Keyword & Code Search Filtering (FR2-3, FR4-15)
                              if (_searchQuery.isNotEmpty) {
                                final query = _searchQuery.trim().toLowerCase();
                                displayGems = displayGems.where((gem) => 
                                  gem.name.toLowerCase().contains(query) ||
                                  gem.description.toLowerCase().contains(query) ||
                                  gem.category.toLowerCase().contains(query) ||
                                  gem.vibe.toLowerCase().contains(query) ||
                                  gem.uniqueCode.toLowerCase() == query ||
                                  gem.localsTip.toLowerCase().contains(query)
                                ).toList();
                              }

                              // 2. Personalization Filter (Existing Vibe Matching)
                              bool showingVibeMatches = false;
                              if (_searchQuery.isEmpty && userVibes.isNotEmpty) {
                                final matchingGems = displayGems.where((gem) => 
                                  userVibes.any((vibe) => gem.vibe.toLowerCase().contains(vibe.toLowerCase()))
                                ).toList();
                                
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
                                      style: TextStyleHelper.instance.body14MediumInter,
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showingVibeMatches)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.auto_awesome, color: Color(0xFF1B3022), size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Matching your vibe',
                                            style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                              color: const Color(0xFF1B3022),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ...displayGems.map((gem) => Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: _buildCard(context, gem),
                                  )).toList(),
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
                  color: Colors.white.withOpacity(0.95),
                  border: Border(bottom: BorderSide(color: Color(0x33C1C9C1))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LikeALocal',
                      style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                        color: Color(0xFF191C1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushNamed(AppRoutes.userProfilePage);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(selectedIndex: 0),
    );
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
      final matches = approvedGems.where((gem) => 
        userVibes.any((vibe) => gem.vibe.toLowerCase().contains(vibe.toLowerCase()))
      ).toList();
      
      if (matches.isNotEmpty) {
        selectedGem = (matches..shuffle()).first;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ Found a gem matching your vibe!')),
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
        userLoc.latitude, userLoc.longitude, gem.latitude, gem.longitude
      );
      distanceText = '${dist.toStringAsFixed(1)} km away';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailsScreen(gem: gem),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      distanceText,
                      style: TextStyle(color: Color(0xFF1B3022), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (gem.isTrending)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildTrendingBadge(),
                  ),
                if (isLocalLegend)
                  Positioned(
                    top: gem.isTrending ? 52 : 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LOCAL LEGEND',
                        style: TextStyle(color: Color(0xFF1B3022), fontSize: 9, fontWeight: FontWeight.bold),
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
                        style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                          color: Color(0xFF191C1A),
                        ),
                      ),
                      Consumer2<UserProvider, GemsProvider>(
                        builder: (context, userProvider, gemsProvider, _) {
                          final isSaved = userProvider.user?.savedGems.contains(gem.id) ?? false;
                          return GestureDetector(
                            onTap: () async {
                              final user = userProvider.user;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sign up to save your favourite places!')),
                                );
                                return;
                              }
                              await gemsProvider.toggleSaveGem(user.id, gem.id, isSaved);
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

  Widget _buildGlassTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
          Text('TRENDING', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildVibeMatchBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: Color(0xFF1B3022), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Advanced Discovery', style: TextStyleHelper.instance.title20BoldOutfit),
                  SizedBox(height: 24),
                  _buildFilterToggle(
                    'Super User Recommendations', 
                    'Filter by Local Legends only (FR7-5)',
                    _superUserOnly,
                    (val) {
                      setModalState(() => _superUserOnly = val);
                      setState(() => _superUserOnly = val); // update parent
                    }
                  ),
                  SizedBox(height: 24),
                  Text('Price vs. Vibe Intensity', style: TextStyleHelper.instance.body14BoldInter),
                  SizedBox(height: 8),
                  Text('Balance your budget against the experience depth (FR2-9)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Slider(
                    value: 0.5,
                    onChanged: (_) {},
                    activeColor: Color(0xFF1B3022),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text('Deep Experience', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 32),
                  CustomButton(text: 'Apply Filters', onPressed: () => Navigator.pop(context)),
                  SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildFilterToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyleHelper.instance.body14BoldInter),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: Color(0xFF1B3022)),
      ],
    );
  }
}



