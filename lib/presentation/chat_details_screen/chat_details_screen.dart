import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_export.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/ai_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key});

  static Widget builder(BuildContext context) {
    return const ChatDetailsScreen();
  }

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _aiSuggestions = [];
  bool _loadingAi = false;
  late ChatPreview _chat;
  late String _currentUserId;
  late ChatProvider _chatProvider;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _speechText = '';
  bool _speechInitialized = false;

  Future<bool> _initSpeech() async {
    if (_speechInitialized) return true;
    try {
      bool available = await _speech.initialize(
        onError: (val) {
          print('Speech initialization/runtime error: $val');
          setState(() {
            _isListening = false;
          });
          if (val.errorMsg.contains('permission')) {
            _showError('Microphone or speech permission is denied.');
          } else {
            _showError('Speech recognition error: ${val.errorMsg}');
          }
        },
        onStatus: (val) {
          print('Speech status: $val');
          if (val == 'notListening' || val == 'done') {
            if (_isListening) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
      );
      _speechInitialized = available;
      return available;
    } catch (e) {
      print('Speech init exception: $e');
      _showError('Could not initialize speech recognition.');
      return false;
    }
  }

  void _startListening() async {
    if (_isListening) return;

    bool available = await _initSpeech();
    if (available) {
      HapticFeedback.lightImpact();

      setState(() {
        _isListening = true;
        _speechText = '';
      });

      await _speech.listen(
        onResult: (val) {
          setState(() {
            _speechText = val.recognizedWords;
            if (val.recognizedWords.isNotEmpty) {
              _messageController.text = val.recognizedWords;
              _messageController.selection = TextSelection.fromPosition(
                TextPosition(offset: _messageController.text.length),
              );
            }
          });
        },
      );
    } else {
      _showError('Speech recognition is not available on this device.');
    }
  }

  void _stopListening() async {
    if (!_isListening) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isListening = false;
    });

    await _speech.stop();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chat = ModalRoute.of(context)!.settings.arguments as ChatPreview;
    _currentUserId =
        Provider.of<UserProvider>(context, listen: false).user?.id ?? '';
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.activeChatId = _chat.id;
  }

  @override
  void dispose() {
    _speech.stop();
    _chatProvider.activeChatId = null;
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messageController.clear();
    try {
      await Provider.of<ChatProvider>(
        context,
        listen: false,
      ).sendMessage(_chat.id, _currentUserId, text.trim());
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0, // ListView is reversed, so 0 is the bottom
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message.')));
    }
  }

  // FR5-6: Load AI suggestions for SuperUser
  Future<void> _loadAiSuggestions(String gemName, String lastMsg) async {
    if (lastMsg.isEmpty) return;
    setState(() => _loadingAi = true);
    final suggestions = await AIService.suggestChatReplies(lastMsg, gemName);
    if (mounted)
      setState(() {
        _aiSuggestions = suggestions;
        _loadingAi = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final chat = ModalRoute.of(context)!.settings.arguments as ChatPreview;
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    final isSuperUser = currentUser?.isSuperUser == true;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, chat, currentUser),
      body: Column(
        children: [
          _buildGemContext(chat),
          Expanded(
            child: _buildMessageList(
              chat.id,
              currentUser?.id ?? '',
              isSuperUser,
              chat.relatedGemName,
            ),
          ),
          if (_isListening) _buildRecordingOverlay(),
          if (isSuperUser) _buildQuickSuggestions(chat.relatedGemName),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ChatPreview chat,
    currentUser,
  ) {
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
            backgroundImage: CachedNetworkImageProvider(chat.userAvatar),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.userName,
                style: TextStyleHelper.instance.body14BoldInter.copyWith(
                  color: Color(0xFF191C1A),
                ),
              ),
              Text(
                'Active Now',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(
                  color: Color(0xFF3E5641),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Color(0xFF1B3022)),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'report', child: Text('Report User')),
            // FR5-5: Block user
            PopupMenuItem(
              value: 'block',
              child: Text('Block User', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) async {
            if (value == 'block') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Block User?'),
                  content: Text(
                    'You won\'t be able to message them and they won\'t be able to start new chats with you.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Block',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true && currentUser != null) {
                await Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).blockUser(chat.targetUserId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('User blocked.')));
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report submitted for moderation (FR5-5)'),
                ),
              );
            }
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
            style: TextStyleHelper.instance.label10MediumInter.copyWith(
              color: Color(0xFF4D6353),
            ),
          ),
          Text(
            chat.relatedGemName,
            style: TextStyleHelper.instance.label10BoldInter.copyWith(
              color: Color(0xFF1B3022),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    String chatId,
    String userId,
    bool isSuperUser,
    String gemName,
  ) {
    return StreamBuilder<List<ChatMessage>>(
      stream: Provider.of<ChatProvider>(
        context,
        listen: false,
      ).getMessages(chatId, userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF1B3022)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('Say hi! 👋', style: TextStyle(color: Colors.grey)),
          );
        }

        final messages = snapshot.data!;

        // Load AI suggestions if last message is from other user and we haven't loaded yet
        if (isSuperUser &&
            messages.isNotEmpty &&
            !messages.first.isMe &&
            _aiSuggestions.isEmpty &&
            !_loadingAi) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _loadAiSuggestions(gemName, messages.first.text),
          );
        } else if (messages.isNotEmpty &&
            messages.first.isMe &&
            _aiSuggestions.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _aiSuggestions.clear()),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(20),
          reverse: true, // Messages are ordered descending from Firestore
          itemCount: messages.length,
          itemBuilder: (context, index) =>
              _buildBubble(messages[index].text, messages[index].isMe),
        );
      },
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF1B3022) : Color(0xFFF0F4EC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isMe ? Radius.circular(20) : Radius.circular(4),
            bottomRight: isMe ? Radius.circular(4) : Radius.circular(20),
          ),
        ),
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
    );
  }

  // FR5-6: AI quick suggestions (SuperUser only)
  Widget _buildQuickSuggestions(String gemName) {
    final suggestions = _aiSuggestions.isNotEmpty
        ? _aiSuggestions
        : ["Entrance fee?", "Best time?", "Safe for solo?", "Hidden menu?"];

    return SizedBox(
      height: 50,
      child: _loadingAi
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1B3022),
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => SizedBox(width: 10),
              itemBuilder: (context, index) => ActionChip(
                avatar: index < _aiSuggestions.length
                    ? Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Color(0xFF1B3022),
                      )
                    : null,
                label: Text(
                  suggestions[index],
                  style: TextStyle(fontSize: 12, color: Color(0xFF1B3022)),
                ),
                backgroundColor: index < _aiSuggestions.length
                    ? Color(0xFFE8F2E9)
                    : Colors.white,
                side: BorderSide(color: Color(0xFF1B3022).withOpacity(0.2)),
                onPressed: () {
                  _messageController.text = suggestions[index];
                  _sendMessage(suggestions[index]);
                },
              ),
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
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask a local...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF4D6353)),
                  suffixIcon: GestureDetector(
                    onTapDown: (_) => _startListening(),
                    onTapUp: (_) => _stopListening(),
                    onTapCancel: () => _stopListening(),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hold the microphone icon to speak.'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      color: Colors.transparent,
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.redAccent : const Color(0xFF1B3022),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1B3022),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2E9), // Pine Sand Accent
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B3022).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const PulsingRecordIndicator(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Listening...',
                  style: TextStyleHelper.instance.label10BoldInter.copyWith(
                    color: const Color(0xFF1B3022),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _speechText.isEmpty ? 'Speak now...' : _speechText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleHelper.instance.label10MediumInter.copyWith(
                    color: const Color(0xFF3E5641),
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Release to stop',
            style: TextStyleHelper.instance.label10MediumInter.copyWith(
              color: const Color(0xFF4D6353),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class PulsingRecordIndicator extends StatefulWidget {
  const PulsingRecordIndicator({super.key});

  @override
  State<PulsingRecordIndicator> createState() => _PulsingRecordIndicatorState();
}

class _PulsingRecordIndicatorState extends State<PulsingRecordIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.4 * _animation.value),
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
          ),
        );
      },
    );
  }
}
