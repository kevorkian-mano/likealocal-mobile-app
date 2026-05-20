import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String get _googleApiKey => dotenv.get('GOOGLE_API_KEY', fallback: '');

  // ── Google Generative AI (Gemini) via REST API ────────────────────────────
  static Future<String> _callGoogleAI(String prompt) async {
    debugPrint('🤖 Simulated Google Gemini AI (Offline Mode) with prompt: $prompt');
    
    // Simulate a small delay for realistic UX
    await Future.delayed(const Duration(milliseconds: 500));

    final lowerPrompt = prompt.toLowerCase();
    if (lowerPrompt.contains('summarize these reviews') || lowerPrompt.contains('summarize')) {
      return 'Simulated Local AI Summary: This place is highly rated by locals for its peaceful atmosphere, excellent service, and authentic vibe. Visitors love to spend quiet time here!';
    } else if (lowerPrompt.contains('suggest 3 short, friendly reply options') || lowerPrompt.contains('suggest 3')) {
      return '1. I would love to help you with that!\n2. Yes, it is open today and highly recommended!\n3. I can guide you there if you need directions.';
    } else if (lowerPrompt.contains('personalized daily itinerary') || lowerPrompt.contains('itinerary')) {
      return '# Day Itinerary by Localie\n\n- **Morning:** Start with a cup of fresh brew at the nearest local café.\n- **Afternoon:** Visit the recommended hidden gem to soak in the local history and culture.\n- **Evening:** Enjoy a relaxing stroll around the scenic view spots.';
    } else {
      return 'Hi! I am Localie, your local smart AI assistant. I am currently running in simulated offline mode. Let me know how I can help you find or enjoy the best local places!';
    }
  }



  // FR4-3: Suggest category and tags from an uploaded image
  static Future<Map<String, dynamic>> suggestTagsAndCategory(
    File imageFile,
  ) async {
    try {
      // Simulation of image analysis with metadata or just returning defaults
      // Standard GPT-3.5 doesn't take images. GPT-4-o does but requires base64.
      return {
        'category': 'Cultural Sites',
        'tags': ['Authentic', 'Local', 'Vibe'],
      };
    } catch (e) {
      debugPrint('AI Image Error: $e');
      throw Exception('Failed to analyze image via AI');
    }
  }

  // FR3-10: Generate an AI summary of user reviews for a gem
  static Future<String> summarizeReviews(List<String> reviewTexts) async {
    if (reviewTexts.isEmpty)
      return 'No reviews yet. Be the first to share your experience!';
    try {
      final joined = reviewTexts.take(20).join('\n---\n');
      final prompt =
          'Summarize these reviews for a local spot in 2-3 sentences. Highlight the vibe and what locals love.\n\nReviews:\n$joined';
      return await _callGoogleAI(prompt);
    } catch (e) {
      debugPrint('❌ AI Summary Error: $e');
      return 'Error summarizing reviews: ${e.toString()}';
    }
  }

  // FR5-6: Suggest smart replies for SuperUsers in chat context
  static Future<List<String>> suggestChatReplies(
    String lastMessage,
    String gemName,
  ) async {
    try {
      final prompt =
          'A visitor asked about "$gemName": "$lastMessage". Suggest 3 short, friendly reply options (max 10 words each). Format as a simple numbered list.';
      final response = await _callGoogleAI(prompt);
      
      // Parse the response to extract the three suggestions
      final lines = response.split('\n').where((line) => line.trim().isNotEmpty).toList();
      final suggestions = <String>[];
      
      for (final line in lines) {
        final cleaned = line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
        if (cleaned.isNotEmpty) {
          suggestions.add(cleaned);
        }
      }
      
      // Ensure we return exactly 3 suggestions
      while (suggestions.length < 3) {
        suggestions.add('Great question!');
      }
      
      return suggestions.take(3).toList();
    } catch (e) {
      debugPrint('❌ AI Reply Error: $e');
      return [
        'Great question!',
        'I recommend visiting early.',
        'Yes, it is very nice.',
      ];
    }
  }

  // FR10-4: AI-Powered Personal Itineraries
  static Future<String> generateItinerary(
    List<String> vibes,
    List<String> gemNames,
  ) async {
    try {
      final vibesStr = vibes.join(', ');
      final gemsStr = gemNames.join(', ');
      final prompt =
          'Create a personalized daily itinerary based on my vibes: $vibesStr. Use some of these nearby hidden gems: $gemsStr. Provide a title, morning, afternoon, and evening activity. Keep it concise and inspiring.';
      return await _callGoogleAI(prompt);
    } catch (e) {
      debugPrint('❌ AI Itinerary Error: $e');
      return 'Error generating itinerary: ${e.toString()}';
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
      final gemData = availableGems
          .map(
            (g) =>
                '${g['name']} (Vibe: ${g['vibe']}, Category: ${g['category']}, ID: ${g['id']})',
          )
          .join('\n');
      final interactionStr = interactionHistory
          .map((i) => '${i['category']} (${i['vibe']})')
          .join(', ');

      final prompt =
          '''You are "Localie", the AI Smart Assistant for LikeALocal.
User Vibes: ${userVibes.join(', ')}
Recent User Interests: $interactionStr
Available Gems nearby:
$gemData

User Message: "$userMessage"

Instruction: Respond naturally and conversationally. Recommend gems that match their past interests. 
Be helpful, friendly, and concise. Keep responses under 150 words.
When recommending gems, mention the gem names and IDs so we can track engagement.''';

      final responseText = await _callGoogleAI(prompt);
      
      // Parse suggested gem IDs from the response
      final suggestedGemIds = <String>[];
      for (final gem in availableGems) {
        if (responseText.contains(gem['id'] as String)) {
          suggestedGemIds.add(gem['id'] as String);
        }
      }

      return {
        'text': responseText,
        'suggestedGemIds': suggestedGemIds,
      };
    } catch (e) {
      debugPrint('❌ AI Chat Error: $e\n$e');
      final errorMsg = 'Error: ${e.toString()}. Please check your internet connection and API key.';
      return {
        'text': errorMsg,
        'suggestedGemIds': [],
      };
    }
  }
}
