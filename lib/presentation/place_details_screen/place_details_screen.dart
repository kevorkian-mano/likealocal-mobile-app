import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return PlaceDetailsScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF8FAF7)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 350,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/635x353/png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.80),
                                  Colors.transparent
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star, color: const Color(0xFFFFACA1), size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      '4.9',
                                      style: TextStyle(
                                        color: const Color(0xFFFFACA1),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Crimson Bar & Grill',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Zamalek, Cairo',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.80),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.40),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.arrow_back, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Known for its European and Italian-inspired menu, it serves breakfast, lunch, and dinner, featuring dishes like sea bass carpaccio and steak. It is highly popular for cocktails, sunset views, and brunch, with, often, a lively, busy, atmosphere.',
                            style: TextStyle(
                              color: const Color(0xFF424942),
                              fontSize: 16,
                              height: 1.63,
                            ),
                          ),
                          SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEEDE0),
                              border: Border.all(color: const Color(0x4CC2C8C1)),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOCAL TIP',
                                  style: TextStyle(
                                    color: const Color(0xFF1B3022),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.20,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Considered high-end/expensive compared to local standards.',
                                  style: TextStyle(
                                    color: const Color(0xFF191C1A),
                                    fontSize: 14,
                                    height: 1.63,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage("https://placehold.co/47x47/png"),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Amr Mohamedi',
                                  style: TextStyle(
                                    color: const Color(0xFF191C1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.chatWithPostOwnerPage);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B3022),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(
                                    'Chat',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reviews',
                                style: TextStyle(
                                  color: const Color(0xFF191C1A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Write one',
                                style: TextStyle(
                                  color: const Color(0xFF1B3022),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Manuel (You)', style: TextStyle(fontWeight: FontWeight.w700)),
                                Text('2D AGO', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                            subtitle: Text('Allah Makan Gameel'),
                          ),
                          Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Eyad Ahmed', style: TextStyle(fontWeight: FontWeight.w700)),
                                Text('1W AGO', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                            subtitle: Text('Makansh A7san 7aga'),
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
    );
  }
}
