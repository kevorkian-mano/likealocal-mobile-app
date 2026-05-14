import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static Widget builder(BuildContext context) {
    return const ChatListScreen();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(0xFFF9F7F2),
      appBar: _buildAppBar(context),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 3),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: user == null
                ? Center(child: Text('Sign in to view chats'))
                : StreamBuilder<List<ChatPreview>>(
                    stream: chatProvider.getMyChats(user.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1B3022),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No conversations yet.'));
                      }

                      final chats = snapshot.data!;
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: chats.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 600),
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
                  ),
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
        icon: Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Conversations',
        style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
          fontSize: 24,
          color: Color(0xFF1B3022),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: Color(0x33C1C9C1)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Color(0xFF4D6353), size: 20),
            SizedBox(width: 12),
            Text(
              'Search chats...',
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: Color(0xFF4D6353),
              ),
            ),
          ],
        ),
      ),
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: Offset(0, 4),
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
                      color: Color(0xFF3E5641),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
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
                        chat.userName,
                        style: TextStyleHelper.instance.body14BoldInter
                            .copyWith(color: Color(0xFF191C1A)),
                      ),
                      Text(
                        '5m',
                        style: TextStyleHelper.instance.label10MediumInter
                            .copyWith(color: Color(0xFF4D6353)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyleHelper.instance.body14MediumInter.copyWith(
                      color: chat.unreadCount > 0
                          ? Color(0xFF191C1A)
                          : Color(0xFF4D6353),
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F4EC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chat.relatedGemName,
                      style: TextStyle(
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
                margin: EdgeInsets.only(left: 12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1B3022),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: TextStyle(
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
