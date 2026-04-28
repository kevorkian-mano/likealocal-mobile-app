import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return MapsPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3022), // Matching the dark theme
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 76,
                      left: 24,
                      right: 24,
                      bottom: 128,
                    ),
                    decoration: BoxDecoration(color: const Color(0xFFF7FBF2)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0x4CD3E8D2),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFD3E8D2),
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Used Pins',
                            style: TextStyle(
                              color: const Color(0xFF191D19),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.33,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You\'ve used 2 of your 5 monthly pins.\nUpgrade to Premium for unlimited wandering.',
                            style: TextStyle(
                              color: const Color(0xFF424941),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '2',
                                    style: TextStyle(
                                      color: const Color(0xFF1B3022),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '/ 5 Pins',
                                    style: TextStyle(
                                      color: const Color(0xFF424941),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF1B3022),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                child: Text(
                                  'Go Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 44),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFECEFE8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search my saved spots...',
                              style: TextStyle(
                                color: const Color(0xFFC2C9C0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            'Filter',
                            style: TextStyle(
                              color: const Color(0xFF191D19),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Cards
                    _buildMapCard(
                      context,
                      'Zooba Zamalek',
                      'Zamalek, Cairo',
                      'https://placehold.co/345x230/png',
                    ),
                    SizedBox(height: 24),
                    _buildMapCard(
                      context,
                      'Crimson Bar & Grill',
                      'Zamalek, Cairo',
                      'https://placehold.co/345x230/png',
                    ),
                    SizedBox(height: 24),
                    // World Overview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'World Overview',
                          style: TextStyle(
                            color: const Color(0xFF191D19),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.mapViewPage);
                          },
                          child: Text(
                            'Expand Map',
                            style: TextStyle(
                              color: const Color(0xFF1B3022),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.mapViewPage);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDEE5DD),
                          image: DecorationImage(
                            image: AssetImage('assets/images/img_map.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1B3022),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            child: Icon(Icons.fullscreen, color: Colors.white, size: 24),
                          ),
                        ),
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
              color: const Color(0xF2F8FAF8),
              border: Border(bottom: BorderSide(color: const Color(0x33C1C9C1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LikeALocal',
                  style: TextStyle(
                    color: const Color(0xFF191C1A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(AppRoutes.userProfilePage);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF000000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
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
);
  }

  Widget _buildMapCard(BuildContext context, String title, String location, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.placeDetailsScreen);
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFF1F4EE),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0x19C2C9C0),
            ),
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF191D19),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    location,
                    style: TextStyle(
                      color: const Color(0xFF1B3022),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}
