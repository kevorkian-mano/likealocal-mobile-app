import 'package:flutter/material.dart';

class MapViewPage extends StatelessWidget {
  const MapViewPage({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return MapViewPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Map image
            Positioned.fill(
              child: Opacity(
                opacity: 0.60,
                child: Image.network(
                  "https://placehold.co/390x820/png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Map markers
            Positioned(
              left: 120,
              top: 217,
              child: _buildMapMarker(const Color(0xFF3D5242)),
            ),
            Positioned(
              left: 62,
              top: 504,
              child: _buildMapMarker(const Color(0xFF4A5A4D)),
            ),
            Positioned(
              left: 175,
              top: 332,
              child: _buildMainMarker(),
            ),
            
            // App Bar area
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xCCF8FAF8),
                  border: Border(bottom: BorderSide(color: const Color(0x33C1C9C2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    Text(
                      'LikeALocal',
                      style: TextStyle(
                        color: const Color(0xFF191C1A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    CircleAvatar(
                      radius: 23,
                      backgroundImage: NetworkImage("https://placehold.co/47x47/png"),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom drawer (restaurant card)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 50,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0x66C1C9C2),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 20,
                          right: 20,
                          bottom: 24,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Image.network(
                                    "https://placehold.co/298x165/png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Crimson Bar\n& Grill',
                                            style: TextStyle(
                                              color: const Color(0xFF3A302A),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD7E8DB),
                                              borderRadius: BorderRadius.circular(9999),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star, size: 12, color: Color(0xFF1B3022)),
                                                SizedBox(width: 4),
                                                Text(
                                                  '4.9',
                                                  style: TextStyle(
                                                    color: const Color(0xFF1B3022),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '2 mins away • 0.3 miles',
                                        style: TextStyle(
                                          color: const Color(0xFF414942),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B3022),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Get Directions',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF353B35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.directions_walk, color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMarker(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: Colors.white),
      ),
    );
  }
  
  Widget _buildMainMarker() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1B3022),
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 10),
          )
        ]
      ),
      child: Icon(Icons.star, color: Colors.white, size: 20),
    );
  }
}
