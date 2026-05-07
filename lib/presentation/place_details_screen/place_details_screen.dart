import 'package:provider/provider.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../core/providers/gems_provider.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/mock_data/mock_gems.dart';
import '../../core/models/chat_model.dart';
import '../../routes/app_routes.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final HiddenGem? gem;

  const PlaceDetailsScreen({Key? key, this.gem}) : super(key: key);

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as HiddenGem?;
    return PlaceDetailsScreen(gem: args);
  }

  @override
  Widget build(BuildContext context) {
    if (gem == null) {
      return const Scaffold(body: Center(child: Text('Gem details not found.')));
    }
    final displayGem = gem!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 380,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(gem!.imageUrl),
                      fit: BoxFit.cover,
                    ),
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
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 48,
                  left: 20,
                  child: _buildVibeMatchIndicator('98% Match'),
                ),
              ],
            ),
            Container(
              transform: Matrix4.translationValues(0, -32, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              decoration: BoxDecoration(
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
                          gem!.name,
                          style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
                            color: Color(0xFF191C1A),
                          ),
                        ),
                      ),
                      Icon(Icons.bookmark_outline, color: Color(0xFF191C1A), size: 28),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF3E5641), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Zamalek, Cairo',
                        style: TextStyleHelper.instance.body14MediumInter.copyWith(
                          color: Color(0xFF4D6353),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    gem!.description,
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      height: 1.7,
                      color: Color(0xFF3A302A).withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildEmojiSentimentBar(),
                  SizedBox(height: 32),
                  _buildBusyTimesSection(),
                  SizedBox(height: 32),
                  _buildNearbySimilarVibes(),
                  SizedBox(height: 32),
                  _buildReviewsSection(),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFFECEFE8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates_outlined, color: Color(0xFF3E5641), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Local Tip',
                              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                color: Color(0xFF191C1A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          displayGem.localsTip,
                          style: TextStyleHelper.instance.body14MediumInter.copyWith(
                            color: Color(0xFF4D6353),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (displayGem.recommendedDishes.isNotEmpty) ...[
                    SizedBox(height: 32),
                    Text(
                      'Try these dishes',
                      style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                        color: Color(0xFF191C1A),
                      ),
                    ),
                    SizedBox(height: 16),
                    ...displayGem.recommendedDishes.map((dish) => _buildDishItem(dish)).toList(),
                  ],
                  SizedBox(height: 40),
                  if (true) // Simulated availability check
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.nightlight_round, color: Colors.orange, size: 14),
                          SizedBox(width: 8),
                          Text(
                            'Owner is currently away (FR5-4)',
                            style: TextStyle(fontSize: 12, color: Colors.orange[800], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.map_outlined,
                          label: 'Show Map',
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'Chat',
                          onPressed: () {
                            final chatPreview = ChatPreview(
                              id: 'new_${displayGem.name}',
                              userName: 'Local Contributor',
                              userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150',
                              lastMessage: 'Ask me anything about ${displayGem.name}!',
                              lastMessageTime: DateTime.now(),
                              relatedGemName: displayGem.name,
                            );
                            Navigator.pushNamed(
                              context,
                              AppRoutes.chatDetailsScreen,
                              arguments: chatPreview,
                            );
                          },
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
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
          style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Color(0xFF191C1A)),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: emojis.map((emoji) => Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFF0F4EC)),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 20)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildVibeMatchIndicator(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Color(0xFF1B3022), size: 16),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBusyTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Live Crowd Level',
                  style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Color(0xFF191C1A)),
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
                'Quiet',
                style: TextStyle(color: Color(0xFF3E5641), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(12, (index) {
            final height = [10, 15, 30, 45, 60, 55, 40, 25, 20, 35, 50, 20][index];
            return Container(
              width: 20,
              height: height.toDouble(),
              decoration: BoxDecoration(
                color: index == 4 ? Color(0xFF1B3022) : Color(0xFFD7E8DE),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('12 PM', style: TextStyle(fontSize: 10, color: Color(0xFF4D6353))),
            Text('6 PM', style: TextStyle(fontSize: 10, color: Color(0xFF4D6353))),
            Text('12 AM', style: TextStyle(fontSize: 10, color: Color(0xFF4D6353))),
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
              BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 4 * value, spreadRadius: 2 * value)
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
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B3022)),
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
              Icon(icon, color: isPrimary ? Colors.white : Color(0xFF1B3022), size: 20),
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
          style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Color(0xFF191C1A)),
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          child: Consumer<GemsProvider>(
            builder: (context, provider, child) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.gems.length,
                separatorBuilder: (context, index) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final gem = provider.gems[index];
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
                          image: NetworkImage(gem!.imageUrl),
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
                          gem!.name,
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Color(0xFF191C1A)),
            ),
            Text(
              'See All',
              style: TextStyle(fontSize: 12, color: Color(0xFF3E5641), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
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
                  CircleAvatar(radius: 12, backgroundColor: Color(0xFFD7E8DE)),
                  SizedBox(width: 8),
                  Text('Fatma S.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Row(
                    children: List.generate(5, (i) => Icon(Icons.star, color: Color(0xFFFFD700), size: 12)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'This place is absolutely magical at night. The vibe is unlike anything else in Cairo.',
                style: TextStyle(fontSize: 12, color: Color(0xFF4D6353), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



