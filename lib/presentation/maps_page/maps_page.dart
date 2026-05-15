import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  static Widget builder(BuildContext context) {
    return const MapsPage();
  }

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  String _selectedCategory = 'All';
  bool _superUserOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer<GemsProvider>(
          builder: (context, gemsProvider, child) {
            final userLoc = gemsProvider.userLocation;
            var approvedGems = gemsProvider.approvedGems;

            if (_selectedCategory != 'All') {
              approvedGems = approvedGems
                  .where(
                    (gem) => gem.vibe.toLowerCase().contains(
                      _selectedCategory.toLowerCase(),
                    ),
                  )
                  .toList();
            }

            if (_superUserOnly) {
              approvedGems = approvedGems
                  .where((g) => g.contributorIsSuperUser)
                  .toList();
            }

            final center = userLoc != null 
                ? ll.LatLng(userLoc.latitude, userLoc.longitude) 
                : const ll.LatLng(30.0444, 31.2357);

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 14,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.likelocal.app',
                          ),
                          CircleLayer(
                            circles: [
                              ...approvedGems.map((gem) => CircleMarker(
                                point: ll.LatLng(gem.latitude, gem.longitude),
                                radius: 50 * (gem.rating / 5),
                                color: const Color(0xFFFFD700).withOpacity(0.15),
                                useRadiusInMeter: true,
                              )),
                              if (userLoc != null)
                                CircleMarker(
                                  point: ll.LatLng(userLoc.latitude, userLoc.longitude),
                                  radius: 800,
                                  color: const Color(0xFF1B3022).withOpacity(0.05),
                                  borderColor: const Color(0xFF1B3022),
                                  borderStrokeWidth: 1,
                                  useRadiusInMeter: true,
                                ),
                            ],
                          ),
                          MarkerLayer(
                            markers: approvedGems.map((gem) => Marker(
                              point: ll.LatLng(gem.latitude, gem.longitude),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showGemQuickView(context, gem),
                                child: Icon(
                                  Icons.location_on,
                                  color: gem.rating > 4.5 ? Colors.orange : Colors.green,
                                  size: 40,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPinsCard(
                              context,
                              !Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).isAuthenticated,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Nearby Secret Spots',
                              style: TextStyleHelper.instance.title20BoldOutfit,
                            ),
                            const SizedBox(height: 12),
                            if (approvedGems.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No spots in this category yet.'),
                              ),
                            ...approvedGems
                                .take(3)
                                .map(
                                  (gem) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildMapCard(context, gem),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                _buildTopOverlay(context),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(selectedIndex: 1),
    );
  }

  void _showGemQuickView(BuildContext context, HiddenGem gem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: _buildMapCard(context, gem),
      ),
    );
  }

  Widget _buildCategoryBar() {
    final categories = ['All', 'Food', 'Culture', 'Chill', 'Adventure'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('🌟 Legends Only'),
              selected: _superUserOnly,
              onSelected: (val) => setState(() => _superUserOnly = val),
              selectedColor: const Color(0xFFFFD700).withOpacity(0.3),
              checkmarkColor: const Color(0xFF1B3022),
              labelStyle: const TextStyle(
                color: Color(0xFF1B3022),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: _superUserOnly
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF1B3022).withOpacity(0.2),
                ),
              ),
            ),
          ),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (val) => setState(() => _selectedCategory = cat),
                selectedColor: const Color(0xFF1B3022),
                labelStyle: TextStyle(
                  color: _selectedCategory == cat
                      ? Colors.white
                      : const Color(0xFF1B3022),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          border: const Border(bottom: BorderSide(color: Color(0x33C1C9C1))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LikeALocal Maps',
                      style: TextStyleHelper.instance.title20BoldOutfit
                          .copyWith(
                            color: const Color(0xFF191C1A),
                            letterSpacing: -0.5,
                          ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.userProfilePage,
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
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
              const SizedBox(height: 12),
              _buildCategoryBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinsCard(BuildContext context, bool isGuest) {
    if (isGuest) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7F2),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFD7E8DE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF1B3022),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Guest Mode',
                  style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                    color: const Color(0xFF191C1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sign up to unlock detailed maps, save favorite spots, and get tailored recommendations.',
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: const Color(0xFF4D6353),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.pricingPage),
                  child: const Text(
                    'View Plans',
                    style: TextStyle(
                      color: Color(0xFF1B3022),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.signUpPage),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3022),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2E9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Used Pins',
            style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
              color: const Color(0xFF191C1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ve used 2 of your 5 monthly pins.\nUpgrade for unlimited wandering.',
            style: TextStyleHelper.instance.body14MediumInter.copyWith(
              color: const Color(0xFF4D6353),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.4,
            backgroundColor: const Color(0xFFD7E8DE),
            color: const Color(0xFF1B3022),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.pricingPage),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Text(
                  'Go Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(BuildContext context, HiddenGem gem) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(AppRoutes.placeDetailsScreen, arguments: gem);
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFBEAFA7).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              gem.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gem.name,
                    style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                      color: const Color(0xFF191C1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF3E5641), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Zamalek, Cairo',
                        style: TextStyleHelper.instance.body14MediumInter.copyWith(
                          color: const Color(0xFF4D6353),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

