import 'package:provider/provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/location_service.dart';
import '../../widgets/custom_button.dart';
import '../place_details_screen/place_details_screen.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/mock_data/mock_gems.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../routes/app_routes.dart';

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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 56, bottom: 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                        'HIDDEN PLACE DETECTED',
                                        style: TextStyleHelper.instance.label10BoldInter.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      Text(
                                        'Crimson Bar & Grill is\njust 200m away!',
                                        style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                          color: Colors.white,
                                        ),
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
                                    'Show Path',
                                    style: TextStyleHelper.instance.label10BoldInter.copyWith(
                                      color: Color(0xFF1B3022),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

                              // 1. Keyword Search Filtering (FR2-3)
                              if (_searchQuery.isNotEmpty) {
                                displayGems = displayGems.where((gem) => 
                                  gem.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                  gem.vibe.toLowerCase().contains(_searchQuery.toLowerCase())
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
      bottomNavigationBar: _buildBottomBar(),
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

  Widget _buildBottomBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x33C1C9C1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.explore_outlined, 'Explore', isSelected: true),
          _buildNavItem(Icons.map_outlined, 'Map'),
          _buildNavItem(Icons.add_circle_outline, 'Add'),
          _buildNavItem(Icons.chat_bubble_outline, 'Guide'),
          _buildNavItem(Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? Color(0xFF3E5641) : Colors.grey[400]),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFF3E5641) : Colors.grey[400],
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
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
                      Icon(Icons.bookmark_border, color: Color(0xFF1B3022), size: 20),
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
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Advanced Discovery', style: TextStyleHelper.instance.title20BoldOutfit),
              SizedBox(height: 24),
              _buildFilterToggle('Super User Recommendations', 'Filter by Local Legends only (FR2-8)'),
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
      },
    );
  }

  Widget _buildFilterToggle(String title, String subtitle) {
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
        Switch(value: false, onChanged: (_) {}, activeColor: Color(0xFF1B3022)),
      ],
    );
  }
}


