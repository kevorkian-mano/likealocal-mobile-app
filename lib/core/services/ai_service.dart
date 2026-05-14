import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static const String _apiKey =
      'YOUR_GEMINI_API_KEY'; // Replace with real key or use environment variable

  // FR4-3: Suggest category and tags from an uploaded image
  static Future<Map<String, dynamic>> suggestTagsAndCategory(
    File imageFile,
  ) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY')
      throw Exception('Gemini API key not configured.');
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final imageBytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart(
            'Analyze this image and suggest: 1. A primary category for this place (e.g., Food, Sightseeing, Nightlife, Shopping, Nature). 2. Three descriptive tags (e.g., Cozy, Vibe, Historic). Return as JSON: {"category": "...", "tags": ["...", "...", "..."]}',
          ),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];
      final response = await model.generateContent(content);
      debugPrint('AI Image Analysis: ${response.text}');
      // Real app would parse JSON here.
      return {
        'category': 'Analyzed',
        'tags': ['AI', 'Generated', 'Tags'],
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
    if (_apiKey == 'YOUR_GEMINI_API_KEY')
      return 'AI summary unavailable (API key not configured).';
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final joined = reviewTexts.take(20).join('\n---\n');
      final content = [
        Content.text(
          'You are a review summarizer for a local travel app. Summarize these reviews in 2-3 sentences, highlighting the most common themes, best features, and any concerns. Keep it friendly and honest.\n\nReviews:\n$joined',
        ),
      ];
      final response = await model.generateContent(content);
      return response.text ?? 'Failed to generate summary.';
    } catch (e) {
      debugPrint('AI Summary Error: $e');
      return 'Failed to generate summary.';
    }
  }

  // FR5-6: Suggest smart replies for SuperUsers in chat context
  static Future<List<String>> suggestChatReplies(
    String lastMessage,
    String gemName,
  ) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') return [];
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final content = [
        Content.text(
          'You are a local expert for "$gemName". A visitor asked: "$lastMessage". Suggest 3 short, helpful, friendly reply options (max 10 words each). Return as a JSON array of strings.',
        ),
      ];
      final response = await model.generateContent(content);
      debugPrint('AI Reply Suggestions: ${response.text}');
      // Real app would parse JSON array
      return [
        'Great question!',
        'I recommend visiting early.',
        'Yes, it is very nice.',
      ];
    } catch (e) {
      debugPrint('AI Reply Error: $e');
      return [];
    }
  }

  // FR10-4: AI-Powered Personal Itineraries
  static Future<String> generateItinerary(
    List<String> vibes,
    List<String> gemNames,
  ) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY')
      return 'Upgrade to Premium to unlock AI Itineraries! (Demo Mode)';
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final vibesStr = vibes.join(', ');
      final gemsStr = gemNames.join(', ');
      final content = [
        Content.text(
          'Create a personalized daily itinerary based on my vibes: $vibesStr. Use some of these nearby hidden gems: $gemsStr. Provide a title, morning, afternoon, and evening activity. Keep it concise and inspiring.',
        ),
      ];
      final response = await model.generateContent(content);
      return response.text ?? 'Failed to generate itinerary.';
    } catch (e) {
      debugPrint('AI Itinerary Error: $e');
      return 'Failed to generate itinerary.';
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
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return {
        'text':
            'I am ready to help, but your API key is not configured! In demo mode, I suggest visiting any of our high-rated spots.',
        'suggestedGemIds': [
          availableGems.isNotEmpty ? availableGems.first['id'] : null,
        ].whereType<String>().toList(),
      };
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
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
          '''
        You are "Localie", the AI Smart Assistant for LikeALocal.
        User Vibes: ${userVibes.join(', ')}
        Recent User Interactions (Learned Style): $interactionStr
        Available Gems nearby:
        $gemData
        
        User Message: "$userMessage"
        
        Instruction: Respond naturally. Use the Learned Style to prioritize gems that match their past interests. If they ask for "Surprise Me", pick something slightly different from their usual style but within their vibes.
        Return your response in JSON format:
        {
          "text": "Your friendly response here...",
          "suggestedGemIds": ["id1", "id2"]
        }
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      // In a real app, parse JSON. For demo, we'll simulate parsing.
      debugPrint('AI Chat Response: ${response.text}');

      return {
        'text': response.text ?? 'I\'m not sure how to respond to that.',
        'suggestedGemIds': availableGems
            .take(2)
            .map((g) => g['id'] as String)
            .toList(),
      };
    } catch (e) {
      debugPrint('AI Chat Error: $e');
      return {
        'text': 'Sorry, I encountered an error connecting to my brain.',
        'suggestedGemIds': [],
      };
    }
  }
}
