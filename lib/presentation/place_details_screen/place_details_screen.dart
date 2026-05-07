import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/hidden_gem_model.dart';
import '../../core/models/gem_review_model.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import '../../core/models/chat_model.dart';
import '../../routes/app_routes.dart';
import '../../core/providers/user_provider.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final HiddenGem? gem;

  const PlaceDetailsScreen({Key? key, this.gem}) : super(key: key);

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as HiddenGem?;
    return PlaceDetailsScreen(gem: args);
  }

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.gem != null) {
      Future.microtask(() => 
        Provider.of<GemsProvider>(context, listen: false).incrementViews(widget.gem!.id)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gem == null) {
      return const Scaffold(body: Center(child: Text('Gem details not found.')));
    }
    final displayGem = widget.gem!;
    final currentUser = Provider.of<UserProvider>(context).user;
    final bool isOwner = currentUser?.id == displayGem.contributorId;
    final bool isSaved = currentUser?.savedGems.contains(displayGem.id) ?? false;

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
                      image: NetworkImage(displayGem.imageUrl),
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
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 48,
                  child: Row(
                    children: [
                      _buildCodeTag(displayGem.uniqueCode),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showReportDialog(context, displayGem),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
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
              decoration: const BoxDecoration(
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
                          displayGem.name,
                          style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
                            color: const Color(0xFF191C1A),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (currentUser == null) {
                            _showGuestSignUpPrompt(context, 'You need an account to save favorite places.');
                            return;
                          }
                          try {
                            await Provider.of<GemsProvider>(context, listen: false)
                                .toggleSaveGem(currentUser.id, displayGem.id, isSaved);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isSaved ? 'Removed from favorites' : 'Saved to favorites'))
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update favorites'))
                            );
                          }
                        },
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_outline, 
                          color: isSaved ? const Color(0xFF1B3022) : const Color(0xFF191C1A), 
                          size: 28
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF3E5641), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Zamalek, Cairo',
                        style: TextStyleHelper.instance.body14MediumInter.copyWith(
                          color: const Color(0xFF4D6353),
                        ),
                      ),
                    ],
                  ),
                  if (isOwner) _buildStatusBadge(displayGem.status),
                  const SizedBox(height: 24),
                  Text(
                    displayGem.description,
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      height: 1.7,
                      color: const Color(0xFF3A302A).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isOwner) _buildOwnerActions(context, displayGem),
                  const SizedBox(height: 32),
                  _buildEmojiSentimentBar(),
                  const SizedBox(height: 32),
                  _buildBusyTimesSection(),
                  const SizedBox(height: 32),
                  _buildNearbySimilarVibes(),
                  const SizedBox(height: 32),
                  _buildReviewsSection(),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFE8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF3E5641), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Local Tip',
                              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                                color: const Color(0xFF191C1A),
                              ),
                            ),
                            if (displayGem.contributorIsSuperUser) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFD700)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFB8860B), size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Local Legend',
                                      style: TextStyleHelper.instance.label10BoldInter.copyWith(
                                        color: const Color(0xFFB8860B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayGem.localsTip,
                          style: TextStyleHelper.instance.body14MediumInter.copyWith(
                            color: const Color(0xFF4D6353),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (displayGem.recommendedDishes.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Try these dishes',
                      style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                        color: const Color(0xFF191C1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...displayGem.recommendedDishes.map((dish) => _buildDishItem(dish)).toList(),
                  ],
                  const SizedBox(height: 40),
                  if (true) // Simulated availability check
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.nightlight_round, color: Colors.orange, size: 14),
                          const SizedBox(width: 8),
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
                      const SizedBox(width: 12),
                      // FR3-13: Share this gem
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onPressed: () {
                          final shareText = '🗺️ Discover "${displayGem.name}" on LikeALocal!\nCode: ${displayGem.uniqueCode}\n${displayGem.description}';
                          Clipboard.setData(ClipboardData(text: shareText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [Icon(Icons.copy, color: Colors.white, size: 16), SizedBox(width: 8), Expanded(child: Text('Link copied to clipboard!'))]),
                              backgroundColor: Color(0xFF1B3022),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'Chat',
                          onPressed: () {
                            if (currentUser == null) {
                              _showGuestSignUpPrompt(context, 'You need an account to chat with the post owner.');
                              return;
                            }
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestSignUpPrompt(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Color(0xFF1B3022)),
            SizedBox(height: 16),
            Text(
              'Sign Up Required',
              style: TextStyleHelper.instance.title20BoldOutfit,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B3022),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close modal
                  Navigator.pushNamed(context, AppRoutes.signUpPage);
                },
                child: Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close modal
                Navigator.pushNamed(context, AppRoutes.signInPage);
              },
              child: Text('Already have an account? Log In', style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold)),
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
                          image: NetworkImage(gem.imageUrl),
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
                          gem.name,
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
    final displayGem = widget.gem!;
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Color(0xFF191C1A))),
            if (currentUser != null)
              GestureDetector(
                onTap: () => _showWriteReviewDialog(context, displayGem, gemsProvider, currentUser),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B3022),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.rate_review_outlined, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Write Review', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        // FR3-10: AI Review Summary
        _buildAiSummaryTile(displayGem.id, gemsProvider),
        SizedBox(height: 12),
        // FR3-8: Real Firestore reviews stream
        StreamBuilder<QuerySnapshot>(
          stream: gemsProvider.getReviewsStream(displayGem.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF1B3022))));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Color(0xFFF9F7F2), borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text('No reviews yet. Be the first!', style: TextStyleHelper.instance.body14MediumInter.copyWith(color: Colors.grey))),
              );
            }
            final reviews = snapshot.data!.docs
                .map((d) => GemReview.fromMap(d.data() as Map<String, dynamic>, d.id))
                .toList();
            return Column(
              children: reviews.map((review) {
                final isOwner = currentUser?.id == review.userId;
                final isAdmin = currentUser?.isAdmin == true;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
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
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: review.avatarUrl.isNotEmpty ? NetworkImage(review.avatarUrl) : null,
                            backgroundColor: Color(0xFFD7E8DE),
                            child: review.avatarUrl.isEmpty ? Icon(Icons.person, size: 14, color: Color(0xFF1B3022)) : null,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(review.userName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < review.rating.round() ? Icons.star : Icons.star_border,
                              color: Color(0xFFFFD700), size: 12,
                            )),
                          ),
                          if (isOwner || isAdmin) ...
                            [
                              SizedBox(width: 8),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.more_vert, size: 16, color: Colors.grey),
                                onSelected: (val) async {
                                  if (val == 'edit') {
                                    _showEditReviewDialog(context, displayGem.id, review, gemsProvider);
                                  } else if (val == 'delete') {
                                    await gemsProvider.deleteReview(displayGem.id, review.id);
                                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review deleted')));
                                  }
                                },
                                itemBuilder: (_) => [
                                  if (isOwner) PopupMenuItem(value: 'edit', child: Text('Edit Review')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(review.text, style: TextStyle(fontSize: 12, color: Color(0xFF4D6353), height: 1.4)),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // FR3-10: AI summary tile
  Widget _buildAiSummaryTile(String gemId, GemsProvider gemsProvider) {
    return FutureBuilder<QuerySnapshot>(
      future: gemsProvider.getReviewsStream(gemId).first,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SizedBox.shrink();
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1B3022), Color(0xFF2C4C3B)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: FutureBuilder<String>(
                  future: AIService.summarizeReviews(
                    snapshot.data!.docs.map((d) => (d.data() as Map)['text'] as String? ?? '').toList()
                  ),
                  builder: (ctx, aiSnap) {
                    return Text(
                      aiSnap.data ?? 'Analyzing reviews...',
                      style: TextStyle(color: Colors.white, fontSize: 11, height: 1.4),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWriteReviewDialog(BuildContext context, HiddenGem gem, GemsProvider gemsProvider, user) {
    double rating = 4.0;
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Review', style: TextStyleHelper.instance.title20BoldOutfit),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => rating = (i + 1).toDouble()),
                  child: Icon(i < rating ? Icons.star : Icons.star_border, color: Color(0xFFFFD700), size: 36),
                )),
              ),
              SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3022),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  ),
                  onPressed: () async {
                    if (textController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await gemsProvider.addReview(
                      gemId: gem.id,
                      userId: user.id,
                      userName: user.fullName,
                      avatarUrl: user.avatarUrl,
                      rating: rating,
                      text: textController.text.trim(),
                    );
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review submitted!'), backgroundColor: Color(0xFF1B3022)));
                  },
                  child: Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditReviewDialog(BuildContext context, String gemId, GemReview review, GemsProvider gemsProvider) {
    double rating = review.rating;
    final textController = TextEditingController(text: review.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Review', style: TextStyleHelper.instance.title20BoldOutfit),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => rating = (i + 1).toDouble()),
                  child: Icon(i < rating ? Icons.star : Icons.star_border, color: Color(0xFFFFD700), size: 36),
                )),
              ),
              SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Update your review...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3022),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await gemsProvider.editReview(gemId, review.id, rating: rating, text: textController.text.trim());
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review updated!')));
                  },
                  child: Text('Update Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeTag(String code) {
    if (code.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3022).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        code,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
      ),
    );
  }

  void _showReportDialog(BuildContext context, HiddenGem gem) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) {
      _showGuestSignUpPrompt(context, 'You need an account to report inaccurate information.');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Inaccurate Info'),
        content: const Text('Is something wrong with this place? Our moderators will verify your report.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<GemsProvider>(context, listen: false).updateGem(gem.id, {'reportCount': FieldValue.increment(1)});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you!')));
            },
            child: const Text('Report', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(GemStatus status) {
    Color color;
    String label;
    switch (status) {
      case GemStatus.approved:
        color = Colors.green;
        label = 'APPROVED';
        break;
      case GemStatus.pending:
        color = Colors.orange;
        label = 'PENDING REVIEW';
        break;
      case GemStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        break;
      case GemStatus.draft:
        color = Colors.grey;
        label = 'DRAFT';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildOwnerActions(BuildContext context, HiddenGem gem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Manage Your Contribution', style: TextStyleHelper.instance.body14BoldInter),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to Edit Screen (Reuse Share Screen with gem data)
                  Navigator.pushNamed(context, AppRoutes.shareHiddenGemScreen, arguments: gem);
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B3022),
                  side: const BorderSide(color: Color(0xFF1B3022)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, gem),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, HiddenGem gem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place?'),
        content: const Text('This action cannot be undone. Are you sure you want to remove this gem from the map?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await Provider.of<GemsProvider>(context, listen: false).deleteGem(gem.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to map/explore
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gem deleted successfully.')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}





