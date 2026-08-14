class SnakeSpecies {
  final String scientificName;
  final List<String> englishKeywords;
  final List<String> banglaKeywords;
  final bool venomous;

  const SnakeSpecies({
    required this.scientificName,
    required this.englishKeywords,
    required this.banglaKeywords,
    required this.venomous,
  });
}

class SnakeDatabase {
  static const List<SnakeSpecies> _speciesList = [
    // Venomous (true)
    SnakeSpecies(
      scientificName: 'Naja naja',
      englishKeywords: ['spectacled cobra', 'naja naja', 'indian cobra', 'cobra'],
      banglaKeywords: ['গোখরা', 'খৈয়া গোখরা', 'কোবরা'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Naja kaouthia',
      englishKeywords: ['monocled cobra', 'naja kaouthia'],
      banglaKeywords: ['মনোকলড', 'মনোকলড গোখরা'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Ophiophagus hannah',
      englishKeywords: ['king cobra', 'ophiophagus hannah'],
      banglaKeywords: ['কিং কোবরা', 'শঙ্খচূড়'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Bungarus caeruleus',
      englishKeywords: ['common krait', 'bungarus caeruleus', 'krait'],
      banglaKeywords: ['কালকেউটে', 'কমন ক্রেইট', 'কেউটে'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Bungarus fasciatus',
      englishKeywords: ['banded krait', 'bungarus fasciatus'],
      banglaKeywords: ['পদ্মগোখরা', 'শঙ্খিনী'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Daboia russelii',
      englishKeywords: ['russell\'s viper', 'daboia russelii', 'russel', 'viper'],
      banglaKeywords: ['চন্দ্রবোড়া', 'রাসেলস ভাইপার', 'চন্দ্রবোড়া'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Trimeresurus',
      englishKeywords: ['green pit viper', 'trimeresurus', 'pit viper'],
      banglaKeywords: ['সবুজ বোড়া', 'সবুজ বোড়া', 'পিট ভাইপার'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Ovophis monticola',
      englishKeywords: ['mountain pit viper', 'ovophis monticola'],
      banglaKeywords: ['পাহাড়ি বোড়া', 'পাহাড়ি বোড়া'],
      venomous: true,
    ),
    SnakeSpecies(
      scientificName: 'Rhabdophis subminiatus',
      englishKeywords: ['red-necked keelback', 'rhabdophis subminiatus'],
      banglaKeywords: ['লালঘাড় ঢোড়া', 'লালঘাড়', 'লালঘাড়'],
      venomous: true,
    ),
    
    // Non-Venomous (false)
    SnakeSpecies(
      scientificName: 'Python molurus',
      englishKeywords: ['indian rock python', 'python molurus', 'python'],
      banglaKeywords: ['অজগর', 'পাইথন', 'রক পাইথন'],
      venomous: false,
    ),
    SnakeSpecies(
      scientificName: 'Malayopython reticulatus',
      englishKeywords: ['reticulated python', 'malayopython reticulatus'],
      banglaKeywords: ['জালি অজগর'],
      venomous: false,
    ),
    SnakeSpecies(
      scientificName: 'Ptyas mucosa',
      englishKeywords: ['oriental rat snake', 'ptyas mucosa', 'rat snake', 'ptyas'],
      banglaKeywords: ['ধামন', 'ধামনা সাপ'],
      venomous: false,
    ),
    SnakeSpecies(
      scientificName: 'Fowlea piscator',
      englishKeywords: ['checkered keelback', 'fowlea piscator', 'xenochrophis piscator', 'keelback'],
      banglaKeywords: ['ঢোড়া সাপ', 'ঢোড়া', 'জলঢোড়া', 'জলঢোড়া'],
      venomous: false,
    ),
    SnakeSpecies(
      scientificName: 'Ahaetulla nasuta',
      englishKeywords: ['common vine snake', 'ahaetulla nasuta', 'vine snake', 'ahaetulla'],
      banglaKeywords: ['লাউডগা', 'লাউডগা সাপ'],
      venomous: false,
    ),
    SnakeSpecies(
      scientificName: 'Lycodon aulicus',
      englishKeywords: ['common wolf snake', 'lycodon aulicus', 'wolf snake', 'lycodon'],
      banglaKeywords: ['কালনাগিনী', 'ঘরগিন্নি', 'নেকড়ে সাপ', 'নেকড়ে'],
      venomous: false,
    ),
    SnakeSpecies(
      scientificName: 'Coelognathus helena',
      englishKeywords: ['common trinket snake', 'coelognathus helena', 'trinket snake'],
      banglaKeywords: ['দুধরাজ সাপ', 'দুধরাজ'],
      venomous: false,
    ),
    SnakeSpecies(
      scientificName: 'Cerberus rynchops',
      englishKeywords: ['dog-faced water snake', 'cerberus rynchops'],
      banglaKeywords: ['হেলে সাপ', 'হেলে'],
      venomous: false,
    ),
  ];

  static bool checkVenomous(String speciesEn, String speciesBn, bool defaultVal) {
    final lowerEn = speciesEn.toLowerCase();
    final lowerBn = speciesBn.toLowerCase();

    // 1. First search by scientific/english keywords
    for (var species in _speciesList) {
      for (var kw in species.englishKeywords) {
        if (lowerEn.contains(kw)) {
          return species.venomous;
        }
      }
    }

    // 2. Fallback to Bangla keywords search
    for (var species in _speciesList) {
      for (var kw in species.banglaKeywords) {
        if (lowerBn.contains(kw)) {
          return species.venomous;
        }
      }
    }

    return defaultVal;
  }
}
