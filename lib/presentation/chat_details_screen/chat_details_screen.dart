import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/chat_model.dart';

class ChatDetailsScreen extends StatelessWidget {
  const ChatDetailsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const ChatDetailsScreen();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ModalRoute.of(context)!.settings.arguments as ChatPreview;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, chat),
      body: Column(
        children: [
          _buildGemContext(chat),
          Expanded(child: _buildMessageList()),
          _buildQuickSuggestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatPreview chat) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(chat.userAvatar),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.userName,
                style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Color(0xFF191C1A)),
              ),
              Text(
                'Active Now',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Color(0xFF3E5641)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton(
          icon: Icon(Icons.security, color: Color(0xFF1B3022)),
          itemBuilder: (context) => [
            PopupMenuItem(child: Text('Report User'), value: 'report'),
            PopupMenuItem(child: Text('Block User'), value: 'block'),
          ],
          onSelected: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User $value request sent for moderation (FR5-5)')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGemContext(ChatPreview chat) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF9F7F2),
        border: Border(bottom: BorderSide(color: Color(0x33C1C9C1))),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Color(0xFF3E5641), size: 16),
          SizedBox(width: 8),
          Text(
            'Discussing: ',
            style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Color(0xFF4D6353)),
          ),
          Text(
            chat.relatedGemName,
            style: TextStyleHelper.instance.label10BoldInter.copyWith(color: Color(0xFF1B3022)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        _buildBubble("Hey! I saw you submitted The Secret Jazz Garden.", true),
        _buildBubble("Yes! It's one of my favorite spots in Zamalek.", false),
        _buildBubble("I'm planning to go tonight. Is the entrance easy to find?", true),
        _buildBubble("The entrance is right behind the blue door. Just tell the guard you're there for the 'Tuesday Session'.", false),
        _buildTypingIndicator(),
      ],
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: CustomPaint(
          painter: _BubblePainter(
            color: isMe ? Color(0xFF1B3022) : Color(0xFFF0F4EC),
            isMe: isMe,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: 260),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Color(0xFF191C1A),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (isMe) ...[
                  SizedBox(height: 4),
                  Icon(Icons.done_all, color: Colors.white60, size: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFF0F4EC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedDot(delay: 0),
            SizedBox(width: 4),
            _AnimatedDot(delay: 0.2),
            SizedBox(width: 4),
            _AnimatedDot(delay: 0.4),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final double delay;
  const _AnimatedDot({required this.delay});
  @override
  __AnimatedDotState createState() => __AnimatedDotState();
}

class __AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: Color(0xFF1B3022), shape: BoxShape.circle),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final bool isMe;
  _BubblePainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (isMe) {
      path.addRRect(RRect.fromLTRBAndCorners(0, 0, size.width, size.height, 
        topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), topRight: Radius.circular(20)));
      path.moveTo(size.width, size.height - 10);
      path.lineTo(size.width + 8, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.addRRect(RRect.fromLTRBAndCorners(0, 0, size.width, size.height, 
        topRight: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(20)));
      path.moveTo(0, size.height - 10);
      path.lineTo(-8, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

  Widget _buildQuickSuggestions() {
    final suggestions = ["Entrance fee?", "Best time?", "Safe for solo?", "Hidden menu?"];
    return Container(
      height: 50,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(suggestions[index], style: TextStyle(fontSize: 12, color: Color(0xFF1B3022))),
            backgroundColor: Colors.white,
            side: BorderSide(color: Color(0xFF1B3022).withOpacity(0.2)),
            onPressed: () {},
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x33C1C9C1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFF9F7F2),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ask a local...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF4D6353)),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1B3022),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
