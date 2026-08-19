import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../models/scan_result.dart';
import 'cloud_snake_service.dart';
import 'snake_database.dart';

class AiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 35),
    receiveTimeout: const Duration(seconds: 35),
  ));

  Future<ScanResult?> scanImage(String base64Image) async {
    const String systemPrompt = '''
You are VenomShield AI, an expert herpetologist specializing in snakes found in Bangladesh and the Indian subcontinent. Your primary job is to accurately identify snake species from photos and determine if they are venomous.

## CRITICAL CLASSIFICATION RULES
- When uncertain between venomous and non-venomous, ALWAYS err on the side of "venomous: true" (safety first).
- Pay close attention to HEAD SHAPE, SCALE PATTERN, BODY SHAPE, and COLORING.
- Do NOT rely solely on color — many venomous and non-venomous snakes share similar colors.

## BANGLADESH VENOMOUS SNAKES REFERENCE (Big Four + others)

1. **গোখরা / Spectacled Cobra (Naja naja)** — venomous: true, danger_level: high
   - Hood with spectacle marking on back
   - Smooth shiny scales, olive-brown to black
   - Round pupils, broad head slightly wider than neck

2. **মনোকলড গোখরা / Monocled Cobra (Naja kaouthia)** — venomous: true, danger_level: high
   - Single O-shaped (monocle) mark on hood back
   - Olive, brown, or grey body

3. **কিং কোবরা / King Cobra (Ophiophagus hannah)** — venomous: true, danger_level: high
   - Very large (3-5m), narrow hood, chevron pattern on neck
   - Olive-green to brown with pale crossbands

4. **শঙ্খিনী / কালকেউটে / Common Krait (Bungarus caeruleus)** — venomous: true, danger_level: high
   - Black/dark blue body with thin white crossbands
   - Triangular cross-section, prominent vertebral ridge
   - Small head barely distinct from neck, smooth glossy scales

5. **পদ্মগোখরা / Banded Krait (Bungarus fasciatus)** — venomous: true, danger_level: high
   - Alternating black and yellow bands of equal width
   - Triangular body cross-section

6. **চন্দ্রবোড়া / Russell's Viper (Daboia russelii)** — venomous: true, danger_level: high
   - Three rows of dark brown/black chain-like oval spots bordered with white
   - Triangular head, VERY distinct from neck
   - Rough keeled scales, stocky body
   - V-shaped marking on head

7. **সবুজ বোড়া / Green Pit Viper (Trimeresurus spp.)** — venomous: true, danger_level: medium
   - Bright green body, triangular head
   - Heat-sensing pit between eye and nostril
   - Prehensile tail, often in trees/bushes

8. **পাহাড়ি বোড়া / Mountain Pit Viper** — venomous: true, danger_level: medium
   - Brown with dark blotches, triangular head

## COMMON NON-VENOMOUS SNAKES IN BANGLADESH

1. **ধামন / Rat Snake (Ptyas mucosa)** — venomous: false, danger_level: low
   - Large (up to 2.5m), olive-brown to yellowish
   - Black cross-bars on front body, smooth scales
   - OFTEN CONFUSED with Cobra but NO hood

2. **অজগর / Indian Rock Python (Python molurus)** — venomous: false, danger_level: low
   - Very large, thick body with brown blotches
   - Heat-sensing pits on upper lip

3. **ঢোড়া সাপ / Checkered Keelback (Fowlea piscator)** — venomous: false, danger_level: low
   - Olive-green with black checkered pattern
   - Found near water, keeled scales

4. **লাউডগা / Common Vine Snake (Ahaetulla nasuta)** — venomous: false, danger_level: low
   - Very thin, bright green, pointed snout
   - Horizontal keyhole-shaped pupil

5. **কালনাগিনী / Common Wolf Snake (Lycodon aulicus)** — venomous: false, danger_level: low
   - Small, dark brown/black with white crossbands
   - OFTEN CONFUSED with Krait — but flatter head, different band pattern

6. **দুধরাজ সাপ / Common Trinket Snake** — venomous: false, danger_level: low
   - Brown with two dark stripes on neck

7. **হেলে সাপ / Dog-faced Water Snake** — venomous: false, danger_level: low
   - Thick body, eyes on top of head, found in water

## KEY VISUAL DISTINCTIONS
- Cobra vs Rat Snake: Cobra has hood + spectacle mark; Rat Snake has NO hood
- Krait vs Wolf Snake: Krait has triangular body cross-section + glossy scales; Wolf Snake has flat head + matte scales
- Russell's Viper vs any python: Viper has chain-like oval spots + rough keeled scales + triangular head

Respond ONLY with a valid JSON object matching this structure:
{
  "status": "identified", "unidentified", or "not_detected",
  "species_bn": "Bangla name",
  "species_en": "English common name (Scientific name)",
  "venomous": true or false,
  "confidence": A realistic, conservative confidence value between 0.0 and 1.0 (calibrate based on visibility of key patterns/features; do not default to 0.95 unless exceptionally clear),
  "danger_level": "high", "medium", or "low",
  "first_aid_bn": ["3-4 first aid steps in Bangla"],
  "first_aid_en": ["3-4 first aid steps in English"],
  "description_bn": "2-3 sentence description in Bangla",
  "description_en": "2-3 sentence description in English"
}

## VALIDATION FLOW AND RULES
- **status: identified**: A snake is clearly visible and its species can be recognized. Provide full details.
- **status: unidentified**: A snake is visible in the image, but the species is blurry, cut off, or unrecognized. Erring on the side of safety, set "venomous" to true, "confidence" to 0.0, "species_bn" to "অজানা প্রজাতি", "species_en" to "Unknown Species", and provide a warning description.
- **status: not_detected**: The image contains no snake at all (e.g. food, human hands/faces, pets, random objects, scenery). Set "status" to "not_detected", "species_bn" to "সাপ শনাক্ত হয়নি", "species_en" to "No Snake Detected", "confidence" to 0.0, "venomous" to false, and explain in description Bn/En why a snake was not found (e.g., "The image shows food/hand/object rather than a snake").

Return ONLY raw JSON. No markdown, no code blocks, no extra text.
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
                  'text': 'Identify this snake from Bangladesh. Look carefully at head shape, body pattern, scale texture, and coloring. Determine species and whether it is venomous.',
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
          'max_tokens': 500,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'].toString().trim();
        // Remove markdown code blocks if any
        final cleanContent = _cleanJsonString(content);
        final Map<String, dynamic> jsonMap = json.decode(cleanContent);
        
        // 1. Lookup detected snake in offline dataset
        final String speciesBn = jsonMap['species_bn'] as String? ?? '';
        final String speciesEn = jsonMap['species_en'] as String? ?? '';
        final bool rawVenomous = jsonMap['venomous'] == true || jsonMap['venomous'] == 1;

        final cachedSpecies = SnakeDatabase.getSpeciesDetails(speciesEn, speciesBn);

        if (cachedSpecies != null) {
          // Snake found in offline dataset: retrieve verified details directly without redundant generation
          jsonMap['venomous'] = cachedSpecies.venomous;
          jsonMap['danger_level'] = cachedSpecies.dangerLevel;
          if (cachedSpecies.descriptionBn.isNotEmpty) {
            jsonMap['description_bn'] = cachedSpecies.descriptionBn;
          }
          if (cachedSpecies.descriptionEn.isNotEmpty) {
            jsonMap['description_en'] = cachedSpecies.descriptionEn;
          }
          if (cachedSpecies.firstAidBn.isNotEmpty) {
            jsonMap['first_aid_bn'] = cachedSpecies.firstAidBn;
          }
          if (cachedSpecies.firstAidEn.isNotEmpty) {
            jsonMap['first_aid_en'] = cachedSpecies.firstAidEn;
          }
        } else {
          // Not yet in dataset: override venomous flag if known, and cache this newly generated snake
          final bool verifiedVenomous = SnakeDatabase.checkVenomous(speciesEn, speciesBn, rawVenomous);
          jsonMap['venomous'] = verifiedVenomous;
          if (!verifiedVenomous) {
            jsonMap['danger_level'] = 'low';
          }

          if (speciesEn.isNotEmpty && speciesEn != 'Unknown Species') {
            final List<String> faBn = (jsonMap['first_aid_bn'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final List<String> faEn = (jsonMap['first_aid_en'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final newSpecies = SnakeSpecies(
              scientificName: speciesEn,
              speciesEn: speciesEn,
              speciesBn: speciesBn,
              englishKeywords: [speciesEn.toLowerCase()],
              banglaKeywords: [speciesBn.toLowerCase()],
              venomous: verifiedVenomous,
              dangerLevel: jsonMap['danger_level'] as String? ?? (verifiedVenomous ? 'high' : 'low'),
              descriptionBn: jsonMap['description_bn'] as String? ?? '',
              descriptionEn: jsonMap['description_en'] as String? ?? '',
              biteEffectsBn: jsonMap['description_bn'] as String? ?? '',
              biteEffectsEn: jsonMap['description_en'] as String? ?? '',
              symptomsBn: '',
              symptomsEn: '',
              progressionBn: '',
              progressionEn: '',
              fatalityBn: '',
              fatalityEn: '',
              firstAidBn: faBn,
              firstAidEn: faEn,
              actionsBn: '',
              actionsEn: '',
              emergencyBn: '',
              emergencyEn: '',
            );
            SnakeDatabase.registerDynamicSpecies(newSpecies);
            CloudSnakeService.pushToSupabase(newSpecies);
          }
        }
        
        return ScanResult.fromJson(jsonMap);
      }
    } catch (e) {
      // ponytail: log error and return null to trigger triage engine fallback
      print('AI Service Error: $e');
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
