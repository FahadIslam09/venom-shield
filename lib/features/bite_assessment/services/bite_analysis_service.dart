import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class BiteAnalysisService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
  ));

  Future<Map<String, dynamic>?> analyzeBiteSite(String base64Image) async {
    const String systemPrompt = '''
You are VenomShield AI, an expert medical triage assistant.
Analyze the user's uploaded image of a snakebite wound (bite site).
Respond ONLY with a valid JSON object matching this schema:
{
  "observations": ["List of observations in Bangla, e.g. ফোলা দেখা গেছে, কামড়ের দাগ দেখা গেছে, লালচে ভাব"],
  "unclear": true or false
}

Rules:
- Identify only visible signs: ফোলা (swelling), লালচে ভাব (redness), টিস্যু পরিবর্তন (tissue change), ক্ষতের ধরন (wound type), কামড়ের দাগ (fang marks), or other visible abnormalities.
- Do NOT make diagnostic statements, and NEVER claim the snake was venomous or non-venomous. Only report visual observations.
- All elements in the "observations" list must be in Bangla language.
- If the image is unclear, blurry, or not a bite site, set "unclear" to true and return an empty observations list.
- Return ONLY raw JSON. No markdown code blocks, no trailing whitespace, no text before or after the JSON.
''';

    try {
      final response = await _dio.post(
        ApiConstants.openRouterUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.openRouterKey}',
            'HTTP-Referer': 'https://venomshield.ai',
            'X-Title': 'VenomShield AI',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'google/gemini-2.5-flash',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Analyze this bite site image. Observe the wound and check for swelling, redness, fang marks, or tissue damage. Respond with observations in Bangla.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                }
              ],
            }
          ],
          'temperature': 0.0,
          'max_tokens': 300,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'].toString().trim();
        final cleanContent = _cleanJsonString(content);
        final Map<String, dynamic> jsonMap = json.decode(cleanContent);
        return jsonMap;
      }
    } catch (e) {
      print('Bite Analysis Service Error: $e');
    }
    return null;
  }

  String _cleanJsonString(String raw) {
    var cleaned = raw;
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
}
