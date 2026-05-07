import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/providers/gems_provider.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/mock_data/mock_gems.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../routes/app_routes.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const MapsPage();
  }

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? _mapController;
  String _selectedCategory = 'All';

  final String _mapStyle = '''
  [
    { "elementType": "geometry", "stylers": [ { "color": "#f5f5f5" } ] },
    { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] },
    { "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] },
    { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#eeeeee" } ] },
    { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#ffffff" } ] },
    { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#c9c9c9" } ] }
  ]
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer<GemsProvider>(
          builder: (context, gemsProvider, child) {
            final userLoc = gemsProvider.userLocation;
            var approvedGems = gemsProvider.approvedGems;

            // Apply Map Filter (FR3-12)
            if (_selectedCategory != 'All') {
              approvedGems = approvedGems.where((gem) => 
                gem.vibe.toLowerCase().contains(_selectedCategory.toLowerCase())
              ).toList();
            }

            // Create Visual Heatmap (FR3-9)
            final Set<Circle> heatmapCircles = approvedGems.map((gem) => Circle(
              circleId: CircleId('heat_${gem.id}'),
              center: LatLng(gem.latitude, gem.longitude),
              radius: 300 * (gem.rating / 5),
              fillColor: const Color(0xFFFFD700).withOpacity(0.15),
              strokeWidth: 0,
            )).toSet();

            if (userLoc != null) {
              heatmapCircles.add(Circle(
                circleId: const CircleId('user_influence'),
                center: LatLng(userLoc.latitude, userLoc.longitude),
                radius: 800,
                fillColor: const Color(0xFF1B3022).withOpacity(0.05),
                strokeColor: const Color(0xFF1B3022),
                strokeWidth: 1,
              ));
            }

            final markers = approvedGems.map((gem) => Marker(
              markerId: MarkerId(gem.id),
              position: LatLng(gem.latitude, gem.longitude),
              infoWindow: InfoWindow(title: gem.name, snippet: '${gem.rating} ★ - ${gem.vibe}'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                gem.rating > 4.5 ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen
              ),
            )).toSet();

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: userLoc != null 
                              ? LatLng(userLoc.latitude, userLoc.longitude) 
                              : const LatLng(30.0444, 31.2357),
                          zoom: 14,
                        ),
                        markers: markers,
                        circles: heatmapCircles,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _mapController?.setMapStyle(_mapStyle);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPinsCard(context),
                            const SizedBox(height: 24),
                            Text('Nearby Secret Spots', style: TextStyleHelper.instance.title20BoldOutfit),
                            const SizedBox(height: 12),
                            if (approvedGems.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No spots in this category yet.'),
                              ),
                            ...approvedGems.take(3).map((gem) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMapCard(context, gem),
                            )).toList(),
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
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCategoryBar() {
    final categories = ['All', 'Food', 'Culture', 'Chill', 'Adventure'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(cat),
            selected: _selectedCategory == cat,
            onSelected: (val) => setState(() => _selectedCategory = cat),
            selectedColor: const Color(0xFF1B3022),
            labelStyle: TextStyle(
              color: _selectedCategory == cat ? Colors.white : const Color(0xFF1B3022),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        )).toList(),
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
                      style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                        color: const Color(0xFF191C1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.userProfilePage),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
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

  Widget _buildPinsCard(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Text('Go Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
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
          _buildNavItem(Icons.explore_outlined, 'Explore'),
          _buildNavItem(Icons.map, 'Map', isSelected: true),
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

  Widget _buildMapCard(BuildContext context, HiddenGem gem) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed(
          AppRoutes.placeDetailsScreen,
          arguments: gem,
        );
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Color(0xFFBEAFA7).withOpacity(0.2)),
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
                      color: Color(0xFF191C1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF3E5641), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Zamalek, Cairo',
                        style: TextStyleHelper.instance.body14MediumInter.copyWith(
                          color: Color(0xFF4D6353),
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

  Widget _buildDensityPulse(double top, double left, double size) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color(0xFFFFD700).withOpacity(0.4),
              Color(0xFFFFD700).withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}

