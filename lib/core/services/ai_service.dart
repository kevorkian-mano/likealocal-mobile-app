import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String get _openaiKey => dotenv.get('OPENAI_API_KEY', fallback: '');
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> _callOpenAI(String prompt, {bool isJson = false}) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(_baseUrl));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_openaiKey');

      final body = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are Localie, the smart AI assistant for the LikeALocal app. ${isJson ? "Respond only in valid JSON format." : ""}'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
      };

      if (isJson) {
        body['response_format'] = {'type': 'json_object'};
      }

      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode != 200) {
        debugPrint('OpenAI Error: $responseBody');
        throw Exception('OpenAI API returned ${response.statusCode}');
      }

      final data = jsonDecode(responseBody);
      return data['choices'][0]['message']['content'];
    } finally {
      client.close();
    }
  }

  // FR4-3: Suggest category and tags from an uploaded image
  static Future<Map<String, dynamic>> suggestTagsAndCategory(File imageFile) async {
    try {
      // Simulation of image analysis with metadata or just returning defaults
      // Standard GPT-3.5 doesn't take images. GPT-4-o does but requires base64.
      return {
        'category': 'Sightseeing',
        'tags': ['Authentic', 'Local', 'Vibe']
      };
    } catch (e) {
      debugPrint('AI Image Error: $e');
      throw Exception('Failed to analyze image via AI');
    }
  }

  // FR3-10: Generate an AI summary of user reviews for a gem
  static Future<String> summarizeReviews(List<String> reviewTexts) async {
    if (reviewTexts.isEmpty) return 'No reviews yet. Be the first to share your experience!';
    try {
      final joined = reviewTexts.take(20).join('\n---\n');
      final prompt = 'Summarize these reviews for a local spot in 2-3 sentences. Highlighting the vibe and what locals love.\n\nReviews:\n$joined';
      return await _callOpenAI(prompt);
    } catch (e) {
      debugPrint('AI Summary Error: $e');
      return 'Failed to generate summary.';
    }
  }

  // FR5-6: Suggest smart replies for SuperUsers in chat context
  static Future<List<String>> suggestChatReplies(String lastMessage, String gemName) async {
    try {
      final prompt = 'A visitor asked about "$gemName": "$lastMessage". Suggest 3 short, friendly reply options (max 10 words each). Return as a JSON array of strings under the key "replies".';
      final response = await _callOpenAI(prompt, isJson: true);
      final data = jsonDecode(response);
      return List<String>.from(data['replies'] ?? []);
    } catch (e) {
      debugPrint('AI Reply Error: $e');
      return ['Great question!', 'I recommend visiting early.', 'Yes, it is very nice.'];
    }
  }

  // FR10-4: AI-Powered Personal Itineraries
  static Future<String> generateItinerary(List<String> vibes, List<String> gemNames) async {
    try {
      final vibesStr = vibes.join(', ');
      final gemsStr = gemNames.join(', ');
      final prompt = 'Create a personalized daily itinerary based on my vibes: $vibesStr. Use some of these nearby hidden gems: $gemsStr. Provide a title, morning, afternoon, and evening activity. Keep it concise and inspiring.';
      return await _callOpenAI(prompt);
    } catch (e) {
      debugPrint('AI Itinerary Error: $e');
      return 'Failed to generate itinerary. Please try again later.';
    }
  }

  // FR6-2, FR6-3, FR6-4: AI Chatbot & Recommendations
  static Future<Map<String, dynamic>> chatWithAI({
    required String userMessage,
    required List<String> userVibes,
    required List<Map<String, dynamic>> interactionHistory,
    required List<Map<String, dynamic>> availableGems,
    List<String>? history,
  }) async {
    try {
      final gemData = availableGems.map((g) => '${g['name']} (Vibe: ${g['vibe']}, Category: ${g['category']}, ID: ${g['id']})').join('\n');
      final interactionStr = interactionHistory.map((i) => '${i['category']} (${i['vibe']})').join(', ');
      
      final prompt = '''
        You are "Localie", the AI Smart Assistant for LikeALocal.
        User Vibes: ${userVibes.join(', ')}
        Recent User Interests: $interactionStr
        Available Gems nearby:
        $gemData
        
        User Message: "$userMessage"
        
        Instruction: Respond naturally. Recommend gems that match their past interests. 
        Return your response in JSON format with keys "text" (your response) and "suggestedGemIds" (array of IDs).
      ''';

      final response = await _callOpenAI(prompt, isJson: true);
      return jsonDecode(response);
    } catch (e) {
      debugPrint('AI Chat Error: $e');
      return {
        'text': 'Sorry, I encountered an error connecting to my brain.',
        'suggestedGemIds': []
      };
    }
  }
}
