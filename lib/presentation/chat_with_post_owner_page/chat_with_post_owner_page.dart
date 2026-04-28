import 'package:flutter/material.dart';

class ChatWithPostOwnerPage extends StatelessWidget {
  const ChatWithPostOwnerPage({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChatWithPostOwnerPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF2),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://placehold.co/47x47/png'),
            ),
            SizedBox(width: 12),
            Text(
              'Amr Mohamedi',
              style: TextStyle(
                color: Color(0xFF191C1A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFD8E7D5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                _buildMyMessage('Can you tell me the phone \nnumber of crismon resturant!', '10:26 AM • Read'),
                SizedBox(height: 8),
                _buildMyMessage('and there location also, thank you!!', '10:26 AM • Read'),
                SizedBox(height: 16),
                _buildOtherMessage('+20 127 505 5555', '10:30 AM'),
                SizedBox(height: 8),
                _buildOtherMessage('16 Kamal El Tawil St, Zamalek, Cairo \n(inside Riverside Complex)', '10:30 AM'),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: Color(0xFF546353), shape: BoxShape.circle)),
                    SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: Color(0xFF546353), shape: BoxShape.circle)),
                    SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: Color(0xFF546353), shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMyMessage(String text, String timeInfo) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF1B3022),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          SizedBox(height: 4),
          Text(
            timeInfo,
            style: TextStyle(color: Color(0xFF727971), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFD8E7D5),
              border: Border.all(color: Color(0x4CC2C8BD)),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: Color(0xFF111F12), fontSize: 14),
            ),
          ),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(color: Color(0xFF727971), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.add_circle_outline, color: Colors.grey, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFF1F4ED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Message Amr...',
                style: TextStyle(color: Color(0xFF424940)),
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
