import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_export.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static Widget builder(BuildContext context) {
    return const ChatListScreen();
  }

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _activeTab = 0; // 0: Chats, 1: Broadcasts

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'broadcast_tab') {
        setState(() {
          _activeTab = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: _buildAppBar(context),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 3),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          if (_activeTab == 0) _buildSearchAndFilter(),
          Expanded(
            child: _activeTab == 0
                ? (user == null
                    ? const Center(child: Text('Sign in to view chats'))
                    : StreamBuilder<List<ChatPreview>>(
                        stream: chatProvider.getMyChats(user.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1B3022),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No conversations yet.'));
                          }

                          final chats = snapshot.data!;
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: chats.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Interval(
                                  index * 0.1,
                                  1.0,
                                  curve: Curves.easeOutCubic,
                                ),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 30 * (1 - value)),
                                      child: _buildChatItem(context, chats[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ))
                : _buildBroadcastsStream(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _activeTab == 0 ? 'Conversations' : 'System Broadcasts',
        style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
          fontSize: 24,
          color: const Color(0xFF1B3022),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFECE5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _activeTab == 0 ? const Color(0xFF1B3022) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      '💬 Chats',
                      style: TextStyle(
                        color: _activeTab == 0 ? Colors.white : const Color(0xFF1B3022),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _activeTab == 1 ? const Color(0xFF1B3022) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      '📢 Broadcasts',
                      style: TextStyle(
                        color: _activeTab == 1 ? Colors.white : const Color(0xFF1B3022),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: const Color(0x33C1C9C1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF4D6353), size: 20),
            const SizedBox(width: 12),
            Text(
              'Search chats...',
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: const Color(0xFF4D6353),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastsStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B3022)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No broadcast alerts received yet.'),
          );
        }
        final docs = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final title = data['title'] ?? 'Broadcast';
            final message = data['message'] ?? '';
            final createdAt = data['createdAt'] as Timestamp?;
            final dateStr = createdAt != null
                ? '${createdAt.toDate().day}/${createdAt.toDate().month} ${createdAt.toDate().hour.toString().padLeft(2, '0')}:${createdAt.toDate().minute.toString().padLeft(2, '0')}'
                : '';

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.campaign, color: Color(0xFFE38B29), size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyleHelper.instance.body14BoldInter
                                    .copyWith(color: const Color(0xFF191C1A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: TextStyleHelper.instance.label10MediumInter
                            .copyWith(color: const Color(0xFF4D6353)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      color: const Color(0xFF4D6353),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatItem(BuildContext context, ChatPreview chat) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.chatDetailsScreen,
        arguments: chat,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(chat.userAvatar),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E5641),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.userName,
                        style: TextStyleHelper.instance.body14BoldInter
                            .copyWith(color: const Color(0xFF191C1A)),
                      ),
                      Text(
                        '5m',
                        style: TextStyleHelper.instance.label10MediumInter
                            .copyWith(color: const Color(0xFF4D6353)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      color: chat.unreadCount > 0
                          ? const Color(0xFF191C1A)
                          : const Color(0xFF4D6353),
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4EC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chat.relatedGemName,
                      style: const TextStyle(
                        color: Color(0xFF3E5641),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (chat.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
