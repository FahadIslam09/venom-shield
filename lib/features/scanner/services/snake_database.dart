class SnakeSpecies {
  final String scientificName;
  final List<String> englishKeywords;
  final List<String> banglaKeywords;
  final bool venomous;

  // Medical information fields
  final String biteEffectsBn;
  final String biteEffectsEn;
  final String symptomsBn;
  final String symptomsEn;
  final String progressionBn;
  final String progressionEn;
  final String fatalityBn;
  final String fatalityEn;
  final String actionsBn;
  final String actionsEn;
  final String emergencyBn;
  final String emergencyEn;

  const SnakeSpecies({
    required this.scientificName,
    required this.englishKeywords,
    required this.banglaKeywords,
    required this.venomous,
    required this.biteEffectsBn,
    required this.biteEffectsEn,
    required this.symptomsBn,
    required this.symptomsEn,
    required this.progressionBn,
    required this.progressionEn,
    required this.fatalityBn,
    required this.fatalityEn,
    required this.actionsBn,
    required this.actionsEn,
    required this.emergencyBn,
    required this.emergencyEn,
  });
}

class SnakeDatabase {
  static const List<SnakeSpecies> _speciesList = [
    // Russell's Viper (Daboia russelii) / চন্দ্রবোড়া
    SnakeSpecies(
      scientificName: 'Daboia russelii',
      englishKeywords: ['russell\'s viper', 'daboia russelii', 'russel', 'viper'],
      banglaKeywords: ['চন্দ্রবোড়া', 'রাসেলস ভাইপার', 'চন্দ্রবোড়া'],
      venomous: true,
      biteEffectsBn: 'চন্দ্রবোড়া অত্যন্ত বিষধর সাপ। এর কামড়ে প্রধানত রক্তক্ষরণজনিত বিষক্রিয়া (Haemotoxin) ঘটে, যা রক্তকণিকা ও রক্তনালী ধ্বংস করে।',
      biteEffectsEn: 'Russell\'s Viper is highly venomous. Its bite primarily causes hemotoxic envenomation, destroying blood cells and causing systemic damage to blood vessels.',
      symptomsBn: 'তীব্র স্থানীয় ব্যথা, কামড়ের স্থান দ্রুত ফুলে যাওয়া, রক্তপাত (মাড়ি, প্রস্রাব বা ক্ষতস্থান দিয়ে), ফোস্কা পড়া এবং টিস্যু নষ্ট হওয়া (Necrosis)।',
      symptomsEn: 'Severe local pain, rapid swelling, active bleeding (from gums, urine, or wound site), blistering, and tissue death (necrosis).',
      progressionBn: 'লক্ষণগুলো খুব দ্রুত ছড়ায়। কয়েক ঘন্টার মধ্যে রক্ত জমাট বাঁধার ক্ষমতা ব্যাহত হয় এবং কিডনি অকেজো হওয়ার মতো জটিলতা দেখা দিতে পারে।',
      progressionEn: 'Symptoms progress rapidly. Coagulopathy (blood clotting failure) and acute kidney injury can develop within a few hours.',
      fatalityBn: 'অত্যন্ত গুরুতর এবং চিকিৎসা না করালে এটি নিশ্চিতভাবে মারাত্মক বা প্রাণঘাতী হতে পারে।',
      fatalityEn: 'Extremely serious. Untreated bites can lead to severe systemic failure and are frequently fatal.',
      actionsBn: 'আক্রান্ত অঙ্গটি নড়াচড়া না করে হৃদপিণ্ডের সমতলের নিচে রাখুন। কোনো রকম শক্ত বাঁধন বা টর্নিকেট দেবেন না।',
      actionsEn: 'Immobilize the bitten limb and keep it below heart level. Avoid tight tourniquets or cutting the wound.',
      emergencyBn: 'কামড় দেওয়ার সাথে সাথে, কোনো লক্ষণ প্রকাশের অপেক্ষা না করেই, অবিলম্বে নিকটস্থ অ্যান্টি-ভেনমযুক্ত হাসপাতালে যেতে হবে।',
      emergencyEn: 'Immediate transport to a hospital stocked with anti-venom is critical; do not wait for symptoms to appear.',
    ),
    // Spectacled Cobra (Naja naja) / গোখরা
    SnakeSpecies(
      scientificName: 'Naja naja',
      englishKeywords: ['spectacled cobra', 'naja naja', 'indian cobra', 'cobra'],
      banglaKeywords: ['গোখরা', 'খৈয়া গোখরা', 'কোবরা'],
      venomous: true,
      biteEffectsBn: 'গোখরা সাপের বিষ মূলত স্নায়ুবিধ্বংসী (Neurotoxin), যা মস্তিস্ক ও স্নায়ুতন্ত্রের কার্যক্ষমতা বন্ধ করে শ্বাসযন্ত্রকে পঙ্গু করে দেয়।',
      biteEffectsEn: 'Cobra venom is primarily neurotoxic, blocking neurotransmission and paralyzing respiratory muscles.',
      symptomsBn: 'কামড়ের স্থানে হালকা জ্বালাপোড়া, চোখের পাতা ভারি হয়ে যাওয়া (Ptosis), গিলতে ও কথা বলতে সমস্যা হওয়া এবং মাংসপেশীর দুর্বলতা।',
      symptomsEn: 'Local burning sensation, drooping eyelids (ptosis), difficulty swallowing or speaking, and generalized muscle weakness.',
      progressionBn: 'লক্ষণগুলো দ্রুত প্রকাশ পায়। স্নায়বিক পঙ্গুত্ব এবং শ্বাসরোধ হওয়া ৩০ মিনিট থেকে ৩ ঘণ্টার মধ্যে ঘটতে পারে।',
      progressionEn: 'Neurotoxic symptoms progress quickly. Respiratory paralysis and asphyxiation can develop between 30 minutes to 3 hours.',
      fatalityBn: 'খুবই মারাত্মক। দ্রুত চিকিৎসা না পেলে ফুসফুস অকেজো হয়ে মৃত্যুর ঝুঁকি অত্যন্ত বেশি থাকে।',
      fatalityEn: 'Highly critical. Without prompt anti-venom treatment, the fatality risk due to respiratory failure is extremely high.',
      actionsBn: 'রোগীকে আশ্বস্ত করুন। আক্রান্ত অঙ্গ স্থির রাখুন। চাপ দিয়ে ক্ষতস্থান বাঁধা (Pressure Immobilization Bandage) উপকারী।',
      actionsEn: 'Reassure the patient and immobilize the limb. A broad pressure bandage is highly recommended for neurotoxic bites.',
      emergencyBn: 'শ্বাসনালী বন্ধ হওয়া রোধ করতে দ্রুততম সময়ে আইসিইউ (ICU) ও অ্যান্টি-ভেনম সুবিধা সম্বলিত হাসপাতালে পৌঁছাতে হবে।',
      emergencyEn: 'Emergency transport to a facility with mechanical ventilation and anti-venom is required immediately.',
    ),
    // Monocled Cobra (Naja kaouthia) / মনোকলড গোখরা
    SnakeSpecies(
      scientificName: 'Naja kaouthia',
      englishKeywords: ['monocled cobra', 'naja kaouthia'],
      banglaKeywords: ['মনোকলড', 'মনোকলড গোখরা'],
      venomous: true,
      biteEffectsBn: 'মনোকলড গোখরা সাপের বিষ মূলত স্নায়ুবিধ্বংসী (Neurotoxin), যা মস্তিস্ক ও স্নায়ুতন্ত্রের কার্যক্ষমতা বন্ধ করে শ্বাসযন্ত্রকে পঙ্গু করে দেয়।',
      biteEffectsEn: 'Monocled Cobra venom is primarily neurotoxic, blocking neurotransmission and paralyzing respiratory muscles.',
      symptomsBn: 'কামড়ের স্থানে হালকা জ্বালাপোড়া, চোখের পাতা ভারি হয়ে যাওয়া (Ptosis), গিলতে ও কথা বলতে সমস্যা হওয়া এবং মাংসপেশীর দুর্বলতা।',
      symptomsEn: 'Local burning sensation, drooping eyelids (ptosis), difficulty swallowing or speaking, and generalized muscle weakness.',
      progressionBn: 'লক্ষণগুলো দ্রুত প্রকাশ পায়। স্নায়বিক পঙ্গুত্ব এবং শ্বাসরোধ হওয়া ৩০ মিনিট থেকে ৩ ঘণ্টার মধ্যে ঘটতে পারে।',
      progressionEn: 'Neurotoxic symptoms progress quickly. Respiratory paralysis and asphyxiation can develop between 30 minutes to 3 hours.',
      fatalityBn: 'খুবই মারাত্মক। দ্রুত চিকিৎসা না পেলে ফুসফুস অকেজো হয়ে মৃত্যুর ঝুঁকি অত্যন্ত বেশি থাকে।',
      fatalityEn: 'Highly critical. Without prompt anti-venom treatment, the fatality risk due to respiratory failure is extremely high.',
      actionsBn: 'রোগীকে আশ্বস্ত করুন। আক্রান্ত অঙ্গ স্থির রাখুন। চাপ দিয়ে ক্ষতস্থান বাঁধা (Pressure Immobilization Bandage) উপকারী।',
      actionsEn: 'Reassure the patient and immobilize the limb. A broad pressure bandage is highly recommended for neurotoxic bites.',
      emergencyBn: 'শ্বাসনালী বন্ধ হওয়া রোধ করতে দ্রুততম সময়ে আইসিইউ (ICU) ও অ্যান্টি-ভেনম সুবিধা সম্বলিত হাসপাতালে পৌঁছাতে হবে।',
      emergencyEn: 'Emergency transport to a facility with mechanical ventilation and anti-venom is required immediately.',
    ),
    // King Cobra (Ophiophagus hannah) / কিং কোবরা
    SnakeSpecies(
      scientificName: 'Ophiophagus hannah',
      englishKeywords: ['king cobra', 'ophiophagus hannah'],
      banglaKeywords: ['কিং কোবরা', 'শঙ্খচূড়'],
      venomous: true,
      biteEffectsBn: 'কিং কোবরা বিশাল পরিমাণ তীব্র নিউরোটক্সিন ও কার্ডিওটক্সিন বিষ প্রয়োগ করে, যা অতি দ্রুত স্নায়ুতন্ত্র ও হৃদযন্ত্র নিষ্ক্রিয় করে।',
      biteEffectsEn: 'King Cobra delivers massive quantities of highly potent neurotoxins and cardiotoxins, rapidly shutting down the nervous system and heart.',
      symptomsBn: 'তীব্র স্থানীয় ব্যথা, ঝিমুনি, পেশীর পঙ্গুত্ব, হৃদস্পন্দন কমে যাওয়া এবং দ্রুত শ্বাসকষ্ট।',
      symptomsEn: 'Severe local pain, drowsiness, paralysis of skeletal muscles, cardiac distress, and rapid breathing failure.',
      progressionBn: 'অত্যন্ত দ্রুত। মাত্র ৩০ মিনিটের মধ্যে কার্ডিও-রেসপিরেটরি ফেইলিউর বা হার্ট অ্যাটাক হতে পারে।',
      progressionEn: 'Extremely rapid progression. Cardio-respiratory arrest can occur in as little as 30 minutes due to massive venom volume.',
      fatalityBn: 'চরম বিপদজনক এবং চিকিৎসা ছাড়া মৃত্যুর সম্ভাবনা প্রায় ১০০%।',
      fatalityEn: 'Critically dangerous. Mortality rate approaches 100% if untreated.',
      actionsBn: 'রোগীকে সম্পূর্ণ স্থির রাখুন। দ্রুততম পরিবহনে নিকটস্থ সদর হাসপাতাল বা মেডিকেল কলেজে নিয়ে যান।',
      actionsEn: 'Keep the patient completely still and rush them to the nearest tertiary care hospital or medical college.',
      emergencyBn: 'এটি সর্বোচ্চ জরুরি অবস্থা। তাৎক্ষণিক অ্যান্টি-ভেনম এবং লাইফ-সাপোর্ট চিকিৎসা অপরিহার্য।',
      emergencyEn: 'This is a medical emergency of the highest order. Immediate anti-venom and respiratory support are mandatory.',
    ),
    // Common Krait (Bungarus caeruleus) / কালকেউটে / কমন ক্রেইট
    SnakeSpecies(
      scientificName: 'Bungarus caeruleus',
      englishKeywords: ['common krait', 'bungarus caeruleus', 'krait'],
      banglaKeywords: ['কালকেউটে', 'কমন ক্রেইট', 'কেউটে'],
      venomous: true,
      biteEffectsBn: 'কালাচ বা কেউটে সাপের বিষ অত্যন্ত শক্তিশালী স্নায়ুবিধ্বংসী (Neurotoxin)। এর কামড় অনেক সময় ব্যথাহীন হয় কিন্তু বিষক্রিয়া চরম মারাত্মক।',
      biteEffectsEn: 'Krait venom is a highly potent pre-synaptic neurotoxin. Bites are often painless or occur during sleep, but envenomation is extremely severe.',
      symptomsBn: 'পেটে তীব্র ব্যথা, গাঁটে ব্যথা, মাংসপেশী অবশ হওয়া, চোখের পাতা পড়ে যাওয়া এবং কথা বলার ক্ষমতা হারিয়ে ফেলা।',
      symptomsEn: 'Severe abdominal cramps, joint pain, muscular paralysis, drooping eyelids, and loss of voice or ability to swallow.',
      progressionBn: 'কামড়ের কয়েক ঘন্টা পর লক্ষণ প্রকাশ পেতে পারে এবং হঠাৎ করে রোগীর শ্বাসকষ্ট শুরু হতে পারে।',
      progressionEn: 'Symptoms may be delayed by several hours, followed by sudden and rapid onset of complete respiratory paralysis.',
      fatalityBn: 'অত্যন্ত মারাত্মক। চিকিৎসা না করালে শ্বাসযন্ত্র সম্পূর্ণ নিষ্ক্রিয় হয়ে নিশ্চিত মৃত্যু ডেকে আনে।',
      fatalityEn: 'Extremely fatal. Induces complete diaphragm failure and death by asphyxiation if untreated.',
      actionsBn: 'রোগীকে ঘুমাতে দেবেন না। শান্ত রাখুন এবং আক্রান্ত অঙ্গ স্প্লিন্ট দিয়ে স্থির করে বাঁধুন।',
      actionsEn: 'Keep the patient awake and calm. Immobilize the bitten limb using splints.',
      emergencyBn: 'ব্যথা বা কামড়ের দাগ না থাকলেও কামড় দেওয়ার সামান্যতম সন্দেহে অতি দ্রুত অ্যান্টি-ভেনমযুক্ত হাসপাতালে যান।',
      emergencyEn: 'Seek emergency hospitalization immediately even if there is no pain or visible puncture mark.',
    ),
    // Banded Krait (Bungarus fasciatus) / পদ্মগোখরা / শঙ্খিনী
    SnakeSpecies(
      scientificName: 'Bungarus fasciatus',
      englishKeywords: ['banded krait', 'bungarus fasciatus'],
      banglaKeywords: ['পদ্মগোখরা', 'শঙ্খিনী'],
      venomous: true,
      biteEffectsBn: 'পদ্মগোখরা বা শঙ্খিনী সাপের বিষ অত্যন্ত শক্তিশালী স্নায়ুবিধ্বংসী (Neurotoxin)। এর কামড় অনেক সময় ব্যথাহীন হয় কিন্তু বিষক্রিয়া চরম মারাত্মক।',
      biteEffectsEn: 'Banded Krait venom is a highly potent neurotoxin. Bites are often painless but envenomation is extremely severe.',
      symptomsBn: 'পেটে তীব্র ব্যথা, গাঁটে ব্যথা, মাংসপেশী অবশ হওয়া, চোখের পাতা পড়ে যাওয়া এবং কথা বলার ক্ষমতা হারিয়ে ফেলা।',
      symptomsEn: 'Severe abdominal cramps, joint pain, muscular paralysis, drooping eyelids, and loss of voice or ability to swallow.',
      progressionBn: 'কামড়ের কয়েক ঘন্টা পর লক্ষণ প্রকাশ পেতে পারে এবং হঠাৎ করে রোগীর শ্বাসকষ্ট শুরু হতে পারে।',
      progressionEn: 'Symptoms may be delayed by several hours, followed by sudden and rapid onset of complete respiratory paralysis.',
      fatalityBn: 'অত্যন্ত মারাত্মক। চিকিৎসা না করালে শ্বাসযন্ত্র সম্পূর্ণ নিষ্ক্রিয় হয়ে নিশ্চিত মৃত্যু ডেকে আনে।',
      fatalityEn: 'Extremely fatal. Induces complete diaphragm failure and death by asphyxiation if untreated.',
      actionsBn: 'রোগীকে ঘুমাতে দেবেন না। শান্ত রাখুন এবং আক্রান্ত অঙ্গ স্প্লিন্ট দিয়ে স্থির করে বাঁধুন।',
      actionsEn: 'Keep the patient awake and calm. Immobilize the bitten limb using splints.',
      emergencyBn: 'ব্যথা বা কামড়ের দাগ না থাকলেও কামড় দেওয়ার সামান্যতম সন্দেহে অতি দ্রুত অ্যান্টি-ভেনমযুক্ত হাসপাতালে যান।',
      emergencyEn: 'Seek emergency hospitalization immediately even if there is no pain or visible puncture mark.',
    ),
    // Green Pit Viper (Trimeresurus spp.) / সবুজ বোড়া
    SnakeSpecies(
      scientificName: 'Trimeresurus',
      englishKeywords: ['green pit viper', 'trimeresurus', 'pit viper'],
      banglaKeywords: ['সবুজ বোড়া', 'সবুজ বোড়া', 'পিট ভাইপার'],
      venomous: true,
      biteEffectsBn: 'সবুজ বোড়া সাপের বিষ মূলত রক্তক্ষরণকারী (Hemotoxin), যা কামড়ের ক্ষতস্থানে তীব্র প্রতিক্রিয়া সৃষ্টি করে।',
      biteEffectsEn: 'Green Pit Viper venom is primarily hemotoxic, causing painful local tissue damage and mild systemic effects.',
      symptomsBn: 'কামড়ের স্থান ফুলে লাল হওয়া, দীর্ঘস্থায়ী জ্বালাপোড়া ও মাঝারি রক্তপাত।',
      symptomsEn: 'Severe local swelling, discoloration, persistent throbbing pain, and localized bleeding.',
      progressionBn: 'ঘন্টার পর ঘন্টা ক্ষতস্থান ফুলে যেতে থাকে এবং সংলগ্ন অংশে তরল জমে কালচে হয়ে যেতে পারে।',
      progressionEn: 'Swelling progresses locally over several hours and may cause localized blistering or bruising.',
      fatalityBn: 'মাঝারি ঝুঁকি। সাধারণত সরাসরি প্রাণঘাতী নয়, তবে টিস্যু বা অঙ্গের ক্ষতি এড়াতে চিকিৎসকের তত্ত্বাবধান প্রয়োজন।',
      fatalityEn: 'Moderate severity. Rarely fatal to humans, but medical evaluation is required to manage tissue damage.',
      actionsBn: 'ক্ষতস্থান নাড়াচাড়া করবেন না। কোনো বরফ বা কেমিক্যাল লাগাবেন না। আক্রান্ত অংশ সাবান-পানি দিয়ে ধুয়ে রাখুন।',
      actionsEn: 'Immobilize the area. Do not apply ice, suction, or traditional remedies. Wash with clean water.',
      emergencyBn: 'অতিরিক্ত ফোলা বা তীব্র ব্যথা প্রতিরোধ এবং ক্ষত পর্যবেক্ষণের জন্য হাসপাতালে ভর্তি হওয়া আবশ্যক।',
      emergencyEn: 'Hospital admission is recommended to monitor swelling and manage potential local complications.',
    ),
    // Mountain Pit Viper (Ovophis monticola) / পাহাড়ি বোড়া
    SnakeSpecies(
      scientificName: 'Ovophis monticola',
      englishKeywords: ['mountain pit viper', 'ovophis monticola'],
      banglaKeywords: ['পাহাড়ি বোড়া', 'পাহাড়ি বোড়া'],
      venomous: true,
      biteEffectsBn: 'পাহাড়ি বোড়া সাপের বিষ মূলত রক্তক্ষরণকারী (Hemotoxin), যা কামড়ের ক্ষতস্থানে তীব্র প্রতিক্রিয়া সৃষ্টি করে।',
      biteEffectsEn: 'Mountain Pit Viper venom is primarily hemotoxic, causing painful local tissue damage and mild systemic effects.',
      symptomsBn: 'কামড়ের স্থান ফুলে লাল হওয়া, দীর্ঘস্থায়ী জ্বালাপোড়া ও মাঝারি রক্তপাত।',
      symptomsEn: 'Severe local swelling, discoloration, persistent throbbing pain, and localized bleeding.',
      progressionBn: 'ঘন্টার পর ঘন্টা ক্ষতস্থান ফুলে যেতে থাকে এবং সংলগ্ন অংশে তরল জমে কালচে হয়ে যেতে পারে।',
      progressionEn: 'Swelling progresses locally over several hours and may cause localized blistering or bruising.',
      fatalityBn: 'মাঝারি ঝুঁকি। সাধারণত সরাসরি প্রাণঘাতী নয়, তবে টিস্যু বা অঙ্গের ক্ষতি এড়াতে চিকিৎসকের তত্ত্বাবধান প্রয়োজন।',
      fatalityEn: 'Moderate severity. Rarely fatal to humans, but medical evaluation is required to manage tissue damage.',
      actionsBn: 'ক্ষতস্থান নাড়াচাড়া করবেন না। কোনো বরফ বা কেমিক্যাল লাগাবেন না। আক্রান্ত অংশ সাবান-পানি দিয়ে ধুয়ে রাখুন।',
      actionsEn: 'Immobilize the area. Do not apply ice, suction, or traditional remedies. Wash with clean water.',
      emergencyBn: 'অতিরিক্ত ফোলা বা তীব্র ব্যথা প্রতিরোধ এবং ক্ষত পর্যবেক্ষণের জন্য হাসপাতালে ভর্তি হওয়া আবশ্যক।',
      emergencyEn: 'Hospital admission is recommended to monitor swelling and manage potential local complications.',
    ),
    // Red-necked Keelback (Rhabdophis subminiatus) / লালঘাড় ঢোড়া
    SnakeSpecies(
      scientificName: 'Rhabdophis subminiatus',
      englishKeywords: ['red-necked keelback', 'rhabdophis subminiatus'],
      banglaKeywords: ['লালঘাড় ঢোড়া', 'লালঘাড়', 'লালঘাড়'],
      venomous: true,
      biteEffectsBn: 'লালঘাড় ঢোড়া সাপের লালাগ্রন্থিতে অত্যন্ত তীব্র বিষ থাকে যা মারাত্মক রক্তক্ষরণ (Hemotoxin) ঘটাতে পারে।',
      biteEffectsEn: 'Red-necked Keelback possesses highly toxic saliva that can cause severe hemorrhagic (hemotoxic) envenomation.',
      symptomsBn: 'ক্ষতস্থান থেকে একটানা রক্তক্ষরণ, মাথাব্যথা, অভ্যন্তরীণ রক্তপাত এবং প্রস্রাবের সাথে রক্ত যাওয়া।',
      symptomsEn: 'Continuous bleeding from the bite wound, headache, internal hemorrhaging, and blood in the urine.',
      progressionBn: 'বিষক্রিয়ার লক্ষণ প্রকাশ পেতে কয়েক ঘন্টা লাগতে পারে, তবে শুরু হওয়ার পর তা দ্রুত কিডনি ও রক্তনালীকে অকেজো করে ফেলে।',
      progressionEn: 'Onset of symptoms can be delayed by several hours, but once started, it rapidly leads to renal failure and severe internal clotting dysfunction.',
      fatalityBn: 'চিকিৎসা না করালে এটি চরম বিপজ্জনক এবং প্রাণঘাতী হতে পারে।',
      fatalityEn: 'Untreated bites can be extremely dangerous and fatal.',
      actionsBn: 'ক্ষতস্থান সাবান ও জল দিয়ে হালকাভাবে ধুয়ে ফেলুন। ক্ষতস্থান কাটার চেষ্টা বা শক্ত বাঁধন দেওয়া নিষেধ।',
      actionsEn: 'Gently wash the wound with soap and water. Do not cut the wound or apply tight tourniquets.',
      emergencyBn: 'রক্তক্ষরণের কোনো লক্ষণ দেখা দেওয়া মাত্র দ্রুত বিশেষায়িত হাসপাতালে গিয়ে চিকিৎসকের পরামর্শ নিন।',
      emergencyEn: 'Seek specialized medical care immediately if any signs of bleeding appear.',
    ),
    
    // Indian Rock Python (Python molurus) / অজগর
    SnakeSpecies(
      scientificName: 'Python molurus',
      englishKeywords: ['indian rock python', 'python molurus', 'python'],
      banglaKeywords: ['অজগর', 'পাইথন', 'রক পাইথন'],
      venomous: false,
      biteEffectsBn: 'অজগর সম্পূর্ণ বিষহীন সাপ। এরা শিকারকে পেঁচিয়ে শ্বাসরোধ করে মারে, কোনো বিষদাঁত বা বিষ গ্রন্থি থাকে না।',
      biteEffectsEn: 'Pythons are entirely non-venomous. They kill prey by constriction and possess no venom glands or fangs.',
      symptomsBn: 'কামড়ে ছোট আঁচড় বা ক্ষত হতে পারে, যাতে সাময়িক ব্যথা ও মৃদু বাহ্যিক রক্তপাত হতে পারে।',
      symptomsEn: 'Bites leave superficial rows of small teeth marks which may bleed slightly and cause minor discomfort.',
      progressionBn: 'ক্ষতস্থানে ব্যাকটেরিয়ার সংক্রমণের সাধারণ ঝুঁকি ছাড়া বিষক্রিয়াজনিত কোনো লক্ষণ প্রকাশ পাবে না।',
      progressionEn: 'No systemic progression occurs. The only risk is secondary bacterial infection of the wound.',
      fatalityBn: 'অবিষধর। এতে কোনো বিষক্রিয়ার বা মৃত্যুর ঝুঁকি নেই।',
      fatalityEn: 'Non-venomous. There is zero risk of envenomation or fatality.',
      actionsBn: 'ক্ষতস্থানটি জীবাণুনাশক সাবান ও পরিষ্কার পানি দিয়ে ভালো করে ধুয়ে নিন। ধনুষ্টঙ্কার (Tetanus) প্রতিষেধক টিকা নিন।',
      actionsEn: 'Wash the wound thoroughly with antiseptic soap and water. Ensure your tetanus vaccination is up to date.',
      emergencyBn: 'জরুরি অ্যান্টি-ভেনম বা বিষক্রিয়ার চিকিৎসার প্রয়োজন নেই। সাধারণ ক্ষত পরিচর্যা করলেই চলবে।',
      emergencyEn: 'Emergency anti-venom treatment is not required. Treat as a standard minor wound.',
    ),
    // Reticulated Python (Malayopython reticulatus) / জালি অজগর
    SnakeSpecies(
      scientificName: 'Malayopython reticulatus',
      englishKeywords: ['reticulated python', 'malayopython reticulatus'],
      banglaKeywords: ['জালি অজগর'],
      venomous: false,
      biteEffectsBn: 'জালি অজগর সম্পূর্ণ অবিষধর সাপ। এরা পেশীবহুল শরীরের চাপে শিকারকে পেঁচিয়ে কাবু করে, কোনো বিষগ্রন্থি বা বিষদাঁত থাকে না।',
      biteEffectsEn: 'Reticulated Python is entirely non-venomous. It uses powerful muscular constriction to overpower prey and has no venom.',
      symptomsBn: 'কামড়ে ছোট সাধারণ দাঁতের আঁচড় বসতে পারে, যাতে মৃদু ব্যথা ও বাহ্যিক রক্তপাত হতে পারে।',
      symptomsEn: 'Bites can leave superficial rows of teeth marks causing minor pain and local bleeding.',
      progressionBn: 'সাধারণ ইনফেকশন ছাড়া অন্য কোনো বিষক্রিয়াজনিত জটিলতা হওয়ার সুযোগ নেই।',
      progressionEn: 'Aside from minor infection risks, no toxic or systemic progression will occur.',
      fatalityBn: 'অবিষধর। এতে কোনো বিষক্রিয়ার ঝুঁকি নেই।',
      fatalityEn: 'Non-venomous. There is no risk of envenomation.',
      actionsBn: 'ক্ষতস্থান সাবান ও হালকা গরম জল দিয়ে পরিষ্কার করে ধুয়ে নিন। সংক্রমণ রোধে অ্যান্টিসেপ্টিক ক্রিম লাগান।',
      actionsEn: 'Wash the wound thoroughly with soap and warm water. Apply antiseptic cream to prevent infection.',
      emergencyBn: 'জরুরি অ্যান্টি-ভেনমের প্রয়োজন নেই। তবে ক্ষত গভীর হলে চিকিৎসকের পরামর্শে ড্রেসিং করান।',
      emergencyEn: 'No emergency anti-venom is needed. Seek local wound care if the bite is deep.',
    ),
    // Oriental Rat Snake (Ptyas mucosa) / ধামন
    SnakeSpecies(
      scientificName: 'Ptyas mucosa',
      englishKeywords: ['oriental rat snake', 'ptyas mucosa', 'rat snake', 'ptyas'],
      banglaKeywords: ['ধামন', 'ধামনা সাপ'],
      venomous: false,
      biteEffectsBn: 'ধামন সম্পূর্ণ বিষহীন সাপ। ফসলের ক্ষতিসাধনকারী ইঁদুর খেয়ে এটি কৃষকের পরম বন্ধু হিসেবে কাজ করে।',
      biteEffectsEn: 'The Rat Snake is entirely non-venomous. It plays a critical role in controlling agricultural rodent pests.',
      symptomsBn: 'কামড়ের ফলে সামান্য আঁচড় হতে পারে, যাতে অতি সামান্য রক্তপাত বা মৃদু ব্যথা অনুভব হতে পারে।',
      symptomsEn: 'Bite causes minor superficial scratches, negligible bleeding, and mild local pain.',
      progressionBn: 'লক্ষণগুলো বাড়ার কোনো সুযোগ নেই। এটি সাধারণ সুঁই ফোটার মতো নিজে থেকেই দ্রুত সেরে যায়।',
      progressionEn: 'No progression. The scratch heals quickly on its own without any systemic symptoms.',
      fatalityBn: 'অবিষধর। এতে বিষক্রিয়া বা প্রাণনাশের কোনো আশঙ্কা নেই।',
      fatalityEn: 'Non-venomous. Absolutely zero risk of death or envenomation.',
      actionsBn: 'ক্ষতস্থান পরিষ্কার সাবান-পানি দিয়ে ধুয়ে নিন এবং রোগীকে আশ্বস্ত করুন যে সাপটি বিষহীন ছিল।',
      actionsEn: 'Wash the area with soap and clean water. Reassure the patient that the snake is harmless.',
      emergencyBn: 'চিকিৎসা বা হাসপাতালের প্রয়োজন নেই। পরিষ্কার ক্ষত পরিচর্যা ও অ্যান্টিসেপ্টিক লাগানোই যথেষ্ট।',
      emergencyEn: 'No hospitalization required. Standard hygiene and local wound care are sufficient.',
    ),
    // Checkered Keelback (Fowlea piscator) / ঢোড়া সাপ
    SnakeSpecies(
      scientificName: 'Fowlea piscator',
      englishKeywords: ['checkered keelback', 'fowlea piscator', 'xenochrophis piscator', 'keelback'],
      banglaKeywords: ['ঢোড়া সাপ', 'ঢোড়া', 'জলঢোড়া', 'জলঢোড়া'],
      venomous: false,
      biteEffectsBn: 'ঢোড়া সাপ বা জলঢোড়া বিষহীন সাপ। এটি সাধারণত ডোবা, পুকুর বা জলাশয়ের আশে পাশে বাস করে ও মাছ খেয়ে জীবনধারণ করে।',
      biteEffectsEn: 'The Checkered Keelback is a non-venomous water snake commonly found in and around wetlands, feeding on fish.',
      symptomsBn: 'কামড়ে ত্বকে সামান্য আঁচড় বা লালচে ভাব দেখা দিতে পারে, যাতে সাময়িক চুলকানি বা সুড়সুড়ি হতে পারে।',
      symptomsEn: 'Bites result in minor scratches or redness, causing temporary itching or mild irritation.',
      progressionBn: 'কোনো বিষক্রিয়া ছড়াবে না। ক্ষতস্থান অতি দ্রুত নিজে নিজেই শুকিয়ে যায়।',
      progressionEn: 'No systemic effects will occur. The minor abrasion heals rapidly.',
      fatalityBn: 'অবিষধর। এতে বিষক্রিয়ার বা মৃত্যুর ঝুঁকি শূন্য।',
      fatalityEn: 'Non-venomous. There is zero risk of toxicity or fatality.',
      actionsBn: 'ক্ষতস্থান সাবান ও পরিষ্কার জল দিয়ে ভালো করে ধুয়ে পরিষ্কার রাখুন।',
      actionsEn: 'Wash the bitten area thoroughly with clean water and mild soap.',
      emergencyBn: 'জরুরি চিকিৎসার প্রয়োজন নেই। এটি সম্পূর্ণ নিরাপদ।',
      emergencyEn: 'No medical treatment or emergency intervention is necessary.',
    ),
    // Common Vine Snake (Ahaetulla nasuta) / লাউডগা
    SnakeSpecies(
      scientificName: 'Ahaetulla nasuta',
      englishKeywords: ['common vine snake', 'ahaetulla nasuta', 'vine snake', 'ahaetulla'],
      banglaKeywords: ['লাউডগা', 'লাউডগা সাপ'],
      venomous: false,
      biteEffectsBn: 'লাউডগা মৃদু বিষধর সাপ (Mildly venomous), যা সাধারণত মানুষের জন্য ক্ষতিকর বা প্রাণঘাতী নয়।',
      biteEffectsEn: 'The Vine Snake is mildly venomous (rear-fanged), but its venom is not dangerous or clinically significant to humans.',
      symptomsBn: 'হালকা চুলকানি, সামান্য ফোলাভাব এবং কামড়ের স্থানে অল্প ঝিনঝিন অনুভূতি।',
      symptomsEn: 'Mild itching, local swelling, and a temporary tingling sensation near the bite.',
      progressionBn: 'লক্ষণগুলো কয়েক ঘণ্টার মধ্যে নিজে থেকেই সেরে যায়। শরীরে কোনো মারাত্মক পরিবর্তন ঘটে না।',
      progressionEn: 'Symptoms are localized and resolve spontaneously within a few hours.',
      fatalityBn: 'কম ঝুঁকি। প্রাণঘাতী হওয়ার কোনো নজির নেই।',
      fatalityEn: 'Low risk. There is no risk of fatality or systemic toxicity.',
      actionsBn: 'ক্ষতস্থান ধুয়ে পরিষ্কার রাখুন। আক্রান্ত অংশ স্থির রাখুন এবং রোগীকে আশ্বস্ত করুন।',
      actionsEn: 'Wash the area with soap and water, keep the limb still, and reassure the patient.',
      emergencyBn: 'সাধারণত জরুরি অ্যান্টি-ভেনম চিকিৎসার প্রয়োজন হয় না। যদি অস্বাভাবিক ফোলা বা অ্যালার্জি দেখা দেয়, চিকিৎসকের পরামর্শ নিন।',
      emergencyEn: 'Anti-venom is not needed. Consult a physician only if unusual swelling or allergic reactions occur.',
    ),
    // Common Wolf Snake (Lycodon aulicus) / কালনাগিনী / ঘরগিন্নি
    SnakeSpecies(
      scientificName: 'Lycodon aulicus',
      englishKeywords: ['common wolf snake', 'lycodon aulicus', 'wolf snake', 'lycodon'],
      banglaKeywords: ['কালনাগিনী', 'ঘরগিন্নি', 'নেকড়ে সাপ', 'নেকড়ে'],
      venomous: false,
      biteEffectsBn: 'কালনাগিনী বা ঘরগিন্নি সম্পূর্ণ বিষহীন সাপ। এটি আমাদের বসতবাড়ির আশেপাশে পোকামাকড় খেয়ে পরিবেশের ভারসাম্য বজায় রাখে।',
      biteEffectsEn: 'The Common Wolf Snake is completely non-venomous and frequently found near houses eating household pests.',
      symptomsBn: 'ছোট আকারের কামড়ের দাগ ও সামান্য জ্বালাপোড়া যা খুব অল্প সময়েই চলে যায়।',
      symptomsEn: 'Tiny bite marks and slight burning sensation that resolves very quickly.',
      progressionBn: 'কোনো বিষ ছড়ানোর ঝুঁকি নেই। লক্ষণগুলো সম্পূর্ণ স্থানীয় এবং নিজে নিজেই মিলিয়ে যায়।',
      progressionEn: 'No risk of toxicity progression. The site returns to normal within minutes.',
      fatalityBn: 'অবিষধর। বিষের কোনো অস্তিত্ব না থাকায় এটি সম্পূর্ণ বিপদমুক্ত।',
      fatalityEn: 'Non-venomous. Completely harmless with zero risk.',
      actionsBn: 'ক্ষতস্থান সাবান ও জল দিয়ে ধুয়ে জীবাণুমুক্ত করুন। রোগীকে আশ্বস্ত করুন।',
      actionsEn: 'Clean the bite area with soap and water. Keep the patient calm and reassured.',
      emergencyBn: 'অ্যান্টি-ভেনম বা হাসপাতালের প্রয়োজন নেই। এটি সাধারণ ক্ষত পরিচর্যাতেই সেরে যাবে।',
      emergencyEn: 'No anti-venom or emergency treatment is required.',
    ),
    // Common Trinket Snake (Coelognathus helena) / দুধরাজ সাপ
    SnakeSpecies(
      scientificName: 'Coelognathus helena',
      englishKeywords: ['common trinket snake', 'coelognathus helena', 'trinket snake'],
      banglaKeywords: ['দুধরাজ সাপ', 'দুধরাজ'],
      venomous: false,
      biteEffectsBn: 'দুধরাজ সম্পূর্ণ বিষহীন সাপ। এদের গায়ের সুন্দর নকশার জন্য এরা সুপরিচিত, কিন্তু এদের কোনো বিষগ্রন্হী থাকে না।',
      biteEffectsEn: 'The Common Trinket Snake is entirely non-venomous and recognized by its beautiful body markings.',
      symptomsBn: 'হালকা কামড় বসলে সামান্য লালচে ভাব হতে পারে, যা খুব দ্রুত নিরাময় হয়ে যায়।',
      symptomsEn: 'Bite may cause slight redness and minor local irritation which heals rapidly.',
      progressionBn: 'কোনো জটিলতা ঘটার সুযোগ নেই।',
      progressionEn: 'No complications or systemic progression.',
      fatalityBn: 'অবিষধর। এতে কোনো বিষক্রিয়ার বা মৃত্যুর ঝুঁকি নেই।',
      fatalityEn: 'Non-venomous. No risk of envenomation or death.',
      actionsBn: 'ক্ষতস্থান সাবান-পানি দিয়ে ধুয়ে রাখুন এবং অ্যান্টিসেপ্টিক ক্রিম লাগান।',
      actionsEn: 'Wash the wound with soap and water, then apply local antiseptic.',
      emergencyBn: 'কোনো প্রকার জরুরি চিকিৎসা বা অ্যান্টি-ভেনমের প্রয়োজন নেই।',
      emergencyEn: 'No emergency medical care or anti-venom required.',
    ),
    // Dog-faced Water Snake (Cerberus rynchops) / হেলে সাপ
    SnakeSpecies(
      scientificName: 'Cerberus rynchops',
      englishKeywords: ['dog-faced water snake', 'cerberus rynchops'],
      banglaKeywords: ['হেলে সাপ', 'হেলে'],
      venomous: false,
      biteEffectsBn: 'হেলে সাপ বা কুকুর-মুখী জলসাপ সম্পূর্ণ বিষহীন সাপ। এরা উপকূলীয় মোহনা ও কাঁদাযুক্ত পানির জলাশয়ে বাস করে।',
      biteEffectsEn: 'The Dog-faced Water Snake is entirely non-venomous, commonly inhabiting coastal mudflats and estuaries.',
      symptomsBn: 'মৃদু আঁচড় ও কামড়ের স্থানে সামান্য অস্বস্তি হতে পারে।',
      symptomsEn: 'Superficial scratches and minor localized discomfort.',
      progressionBn: 'কোনো বিষ ছড়াবে না।',
      progressionEn: 'Zero systemic progression.',
      fatalityBn: 'অবিষধর। এতে বিষক্রিয়া বা মৃত্যুর কোনো ঝুঁকি নেই।',
      fatalityEn: 'Non-venomous. Zero risk of envenomation.',
      actionsBn: 'ক্ষতস্থান পরিষ্কার জল ও সাবান দিয়ে ধুয়ে মুছে নিন।',
      actionsEn: 'Clean the bitten area with clean soap and water.',
      emergencyBn: 'কোনো জরুরি হাসপাতালে ভর্তির প্রয়োজন নেই।',
      emergencyEn: 'No emergency hospitalization is required.',
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

  static SnakeSpecies? getSpeciesDetails(String speciesEn, String speciesBn) {
    final lowerEn = speciesEn.toLowerCase();
    final lowerBn = speciesBn.toLowerCase();

    // 1. Search by scientific/english keywords
    for (var species in _speciesList) {
      for (var kw in species.englishKeywords) {
        if (lowerEn.contains(kw)) {
          return species;
        }
      }
    }

    // 2. Fallback to Bangla keywords search
    for (var species in _speciesList) {
      for (var kw in species.banglaKeywords) {
        if (lowerBn.contains(kw)) {
          return species;
        }
      }
    }

    return null;
  }
}
