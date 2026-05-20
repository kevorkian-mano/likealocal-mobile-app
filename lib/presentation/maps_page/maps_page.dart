import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../core/providers/gems_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/services/offline_map_service.dart';
import '../../widgets/offline_aware_tile_provider.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/premium_upgrade_sheet.dart';
import '../../widgets/safe_image.dart';

class MapsPage extends StatefulWidget {
  final HiddenGem? initialGem;
  const MapsPage({super.key, this.initialGem});

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return MapsPage(initialGem: args is HiddenGem ? args : null);
  }

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  String _selectedCategory = 'All';
  bool _superUserOnly = false;
  bool _trendingOnly = false;
  RangeValues _priceRange = const RangeValues(0, 1000);
  ll.LatLng? _mapCenter;
  LatLngBounds? _mapBounds;
  double _mapDownloadProgress = 0.0;
  bool _isMapDownloading = false;
  StreamSubscription<double>? _downloadSubscription;

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialGem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          ll.LatLng(widget.initialGem!.latitude, widget.initialGem!.longitude),
          16,
        );
      });
    }
  }

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
                    (gem) =>
                        gem.vibe.toLowerCase().contains(
                          _selectedCategory.toLowerCase(),
                        ) ||
                        gem.category.toLowerCase().contains(
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

            if (_trendingOnly) {
              approvedGems = approvedGems
                  .where((g) => g.isTrending)
                  .toList();
            }

            // FR2-3: Filter by map center if moved
            if (_mapCenter != null) {
              approvedGems.sort((a, b) {
                final distA = LocationService.calculateDistance(
                  _mapCenter!.latitude,
                  _mapCenter!.longitude,
                  a.latitude,
                  a.longitude,
                );
                final distB = LocationService.calculateDistance(
                  _mapCenter!.latitude,
                  _mapCenter!.longitude,
                  b.latitude,
                  b.longitude,
                );
                return distA.compareTo(distB);
              });
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
                          onPositionChanged: (pos, hasGesture) {
                            if (hasGesture) {
                              setState(() {
                                _mapCenter = pos.center;
                                _mapBounds = pos.visibleBounds;
                              });
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.likelocal.app',
                            tileProvider: OfflineAwareTileProvider(),
                          ),
                          // FR0-8: Visual Density Indicator
                          CircleLayer(
                            circles: _calculateDensityPulses(approvedGems),
                          ),
                          CircleLayer(
                            circles: [
                              if (userLoc != null)
                                CircleMarker(
                                  point: ll.LatLng(
                                    userLoc.latitude,
                                    userLoc.longitude,
                                  ),
                                  radius: 800,
                                  color: const Color(
                                    0xFF1B3022,
                                  ).withOpacity(0.05),
                                  borderColor: const Color(0xFF1B3022),
                                  borderStrokeWidth: 1,
                                  useRadiusInMeter: true,
                                ),
                            ],
                          ),
                          MarkerLayer(
                            markers: approvedGems
                                .map(
                                  (gem) => Marker(
                                    point: ll.LatLng(
                                      gem.latitude,
                                      gem.longitude,
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showGemQuickView(context, gem),
                                      child: Icon(
                                        Icons.location_on,
                                        color: gem.rating > 4.5
                                            ? Colors.orange
                                            : Colors.green,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
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
              label: const Text('🌟 Super Users Only'),
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
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showAdvancedFilter(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3022),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryBar(),
              _buildOfflineDownloadPrompt(context),
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

    // FR10-1: Real pin count from Firestore via UserProvider
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        if (user == null) return const SizedBox.shrink();

        final int pinLimit = user.isSuperUser
            ? 999
            : (user.isPro ? 100 : 3);
        final int usedPins = user.savedGems.length;
        final double progress = pinLimit >= 999 ? 1.0 : (usedPins / pinLimit).clamp(0.0, 1.0);
        final bool atLimit = usedPins >= pinLimit && pinLimit < 999;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: atLimit
                ? const Color(0xFFFFF3E0)
                : const Color(0xFFE8F2E9),
            borderRadius: BorderRadius.circular(32),
            border: atLimit
                ? Border.all(color: Colors.orange.withOpacity(0.4))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.push_pin_outlined,
                    color: atLimit ? Colors.orange[700] : const Color(0xFF1B3022),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saved Pins',
                    style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                      color: const Color(0xFF191C1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user.isSuperUser
                    ? 'Local Legend — unlimited pins! 🌟'
                    : user.isPro
                        ? 'You\'ve saved $usedPins of $pinLimit pins. Pro plan active.'
                        : atLimit
                            ? 'Pin limit reached! Upgrade to save more places.'
                            : 'You\'ve saved $usedPins of $pinLimit free pins.',
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  color: const Color(0xFF4D6353),
                  height: 1.4,
                ),
              ),
              if (!user.isSuperUser) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFD7E8DE),
                    color: atLimit ? Colors.orange : const Color(0xFF1B3022),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (!user.isPro && !user.isSuperUser)
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
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.userProfilePage),
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
                        'View Pins',
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
      },
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
            SafeImage(
              imageUrl: gem.imageUrl,
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
                    style: TextStyleHelper.instance.title18SemiBoldInter
                        .copyWith(color: const Color(0xFF191C1A)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF2E7D32),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: FutureBuilder<List<Placemark>>(
                          future: placemarkFromCoordinates(
                              gem.latitude, gem.longitude),
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
                                  : '${gem.latitude.toStringAsFixed(3)}°, ${gem.longitude.toStringAsFixed(3)}°';
                            } else {
                              locationText = gem.category.isNotEmpty
                                  ? '${gem.category} · ${gem.latitude.toStringAsFixed(3)}°'
                                  : '${gem.latitude.toStringAsFixed(3)}°, ${gem.longitude.toStringAsFixed(3)}°';
                            }
                            return Text(
                              locationText,
                              style: TextStyleHelper.instance.body14MediumInter
                                  .copyWith(color: const Color(0xFF4D6353)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
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

  Widget _buildOfflineDownloadPrompt(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        if (user == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B3022).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1B3022).withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.download_for_offline_outlined,
                    color: Color(0xFF1B3022),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isMapDownloading
                          ? 'Downloading offline map tiles...'
                          : 'Download this area for offline use',
                      style: TextStyleHelper.instance.body12MediumInter.copyWith(
                        color: const Color(0xFF1B3022),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!(user.isPro || user.isSuperUser)) {
                        PremiumUpgradeSheet.show(context);
                        return;
                      }
                      if (_isMapDownloading) return;

                      // 🗺️ Calculate bounds
                      final userLoc = Provider.of<GemsProvider>(context, listen: false).userLocation;
                      final center = userLoc != null
                          ? ll.LatLng(userLoc.latitude, userLoc.longitude)
                          : const ll.LatLng(30.0444, 31.2357);
                      final currentCenter = _mapCenter ?? center;
                      
                      double minLat = _mapBounds != null ? _mapBounds!.southWest.latitude : (currentCenter.latitude - 0.015);
                      double maxLat = _mapBounds != null ? _mapBounds!.northEast.latitude : (currentCenter.latitude + 0.015);
                      double minLng = _mapBounds != null ? _mapBounds!.southWest.longitude : (currentCenter.longitude - 0.015);
                      double maxLng = _mapBounds != null ? _mapBounds!.northEast.longitude : (currentCenter.longitude + 0.015);

                      // Limit area to prevent infinite tile download loops
                      if ((maxLat - minLat).abs() > 0.04 || (maxLng - minLng).abs() > 0.04) {
                        minLat = currentCenter.latitude - 0.015;
                        maxLat = currentCenter.latitude + 0.015;
                        minLng = currentCenter.longitude - 0.015;
                        maxLng = currentCenter.longitude + 0.015;
                      }

                      setState(() {
                        _isMapDownloading = true;
                        _mapDownloadProgress = 0.0;
                      });

                      _downloadSubscription?.cancel();
                      _downloadSubscription = OfflineMapService.downloadAreaTiles(
                        packageId: 'custom_area',
                        minLat: minLat,
                        maxLat: maxLat,
                        minLng: minLng,
                        maxLng: maxLng,
                      ).listen((progress) {
                        setState(() {
                          _mapDownloadProgress = progress;
                        });
                      }, onError: (err) {
                        setState(() {
                          _isMapDownloading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to download tiles: $err'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }, onDone: () {
                        setState(() {
                          _isMapDownloading = false;
                          _mapDownloadProgress = 1.0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Offline map download complete! (FR9-4)'),
                            backgroundColor: Color(0xFF1B3022),
                          ),
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B3022),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isMapDownloading
                            ? '${(_mapDownloadProgress * 100).toInt()}%'
                            : 'Download',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isMapDownloading) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _mapDownloadProgress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFF1B3022).withOpacity(0.1),
                    color: const Color(0xFF1B3022),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<CircleMarker> _calculateDensityPulses(List<HiddenGem> gems) {
    if (gems.isEmpty) return [];

    final Map<String, List<HiddenGem>> grid = {};
    const double gridSize = 0.005;

    for (final gem in gems) {
      final int latIndex = (gem.latitude / gridSize).floor();
      final int lngIndex = (gem.longitude / gridSize).floor();
      final String key = '${latIndex}_$lngIndex';
      grid.putIfAbsent(key, () => []).add(gem);
    }

    return grid.entries.map((entry) {
      final List<HiddenGem> cluster = entry.value;
      double avgLat = 0, avgLng = 0;
      for (final g in cluster) {
        avgLat += g.latitude;
        avgLng += g.longitude;
      }
      avgLat /= cluster.length;
      avgLng /= cluster.length;

      final double density = cluster.length.toDouble();
      return CircleMarker(
        point: ll.LatLng(avgLat, avgLng),
        radius: 100 + (density * 50),
        color: const Color(0xFFFFD700).withOpacity(density > 3 ? 0.25 : 0.1),
        useRadiusInMeter: true,
      );
    }).toList();
  }

  void _showAdvancedFilter(BuildContext context) {
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
                'Advanced Discovery',
                style: TextStyleHelper.instance.title20BoldOutfit,
              ),
              const SizedBox(height: 24),
              Text(
                'Price Range (EGP)',
                style: TextStyleHelper.instance.body14BoldInter,
              ),
              RangeSlider(
                values: _priceRange,
                max: 5000,
                divisions: 50,
                activeColor: const Color(0xFF1B3022),
                labels: RangeLabels(
                  'EGP ${_priceRange.start.round()}',
                  'EGP ${_priceRange.end.round()}',
                ),
                onChanged: (val) {
                  setModalState(() => _priceRange = val);
                  setState(() => _priceRange = val);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Only',
                    style: TextStyleHelper.instance.body14BoldInter,
                  ),
                  Switch(
                    value: _trendingOnly,
                    onChanged: (v) {
                      setModalState(() => _trendingOnly = v);
                      setState(() => _trendingOnly = v);
                    },
                    activeThumbColor: const Color(0xFF1B3022),
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
}
