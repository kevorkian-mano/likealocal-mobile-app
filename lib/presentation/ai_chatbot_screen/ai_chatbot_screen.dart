import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/gems_provider.dart';
import '../../core/services/ai_service.dart';
import '../../core/models/hidden_gem_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  _AIChatbotScreenState createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isAi': true,
      'text':
          'Hi! I\'m Localie, your AI travel assistant. Ask me anything about hidden gems in Cairo!',
    },
  ];
  bool _isTyping = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_50,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: appTheme.midnightPine.withOpacity(0.1),
              child: Icon(
                Icons.auto_awesome,
                color: appTheme.midnightPine,
                size: 20,
              ),
            ),
            SizedBox(width: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Localie AI',
                  style: TextStyleHelper.instance.title16SemiBoldInter,
                ),
                Text(
                  'Online',
                  style: TextStyleHelper.instance.label10MediumInter.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _sendMessage('Surprise me! (FR6-4)'),
            child: Text(
              'Surprise Me',
              style: TextStyle(
                color: appTheme.midnightPine,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20.h),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessage(msg);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isAi = msg['isAi'] ?? false;
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: isAi
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isAi ? Colors.white : appTheme.midnightPine,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.h),
                topRight: Radius.circular(20.h),
                bottomLeft: Radius.circular(isAi ? 0 : 20.h),
                bottomRight: Radius.circular(isAi ? 20.h : 0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              msg['text'],
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: isAi ? Colors.black87 : Colors.white,
              ),
            ),
          ),
          if (msg['suggestedGems'] != null) ...[
            SizedBox(height: 12.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (msg['suggestedGems'] as List<HiddenGem>)
                    .map((gem) => _buildGemCard(gem))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGemCard(HiddenGem gem) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.placeDetailsScreen,
        arguments: gem,
      ),
      child: Container(
        width: 200.h,
        margin: EdgeInsets.only(right: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
              child: Image.network(
                gem.imageUrl,
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gem.name,
                    style: TextStyleHelper.instance.body12BoldInter,
                  ),
                  Text(
                    gem.category,
                    style: TextStyleHelper.instance.label10MediumInter.copyWith(
                      color: Colors.grey,
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

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12.h),
        margin: EdgeInsets.only(bottom: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.h),
        ),
        child: SizedBox(
          width: 30.h,
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(appTheme.midnightPine),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.h, 12.h, 20.h, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask about budget, vibes, or spots...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            onPressed: _listen,
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : appTheme.midnightPine,
            ),
          ),
          IconButton(
            onPressed: () => _sendMessage(_controller.text),
            icon: Icon(Icons.send, color: appTheme.midnightPine),
          ),
        ],
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'isAi': false, 'text': text});
      _isTyping = true;
    });
    _controller.clear();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final gemsProvider = Provider.of<GemsProvider>(context, listen: false);

    // FR6-5: Pass user context (vibes, budget indirectly via preferences)
    final response = await AIService.chatWithAI(
      userMessage: text,
      userVibes: userProvider.user?.selectedVibes ?? [],
      interactionHistory: userProvider.user?.interactionHistory ?? [],
      availableGems: gemsProvider.approvedGems.map((g) => g.toMap()).toList(),
    );

    // Fetch actual Gem objects for suggested IDs
    final List<HiddenGem> suggestedGems = [];
    for (var id in (response['suggestedGemIds'] as List)) {
      try {
        final gem = gemsProvider.gems.firstWhere((g) => g.id == id);
        suggestedGems.add(gem);
      } catch (_) {}
    }

    setState(() {
      _isTyping = false;
      _messages.add({
        'isAi': true,
        'text': response['text'],
        'suggestedGems': suggestedGems.isEmpty ? null : suggestedGems,
      });
    });
  }
}
