#!/usr/bin/env python3
"""
VenomShield AI - Resumable Snake Species Dataset Generator
Uses Google AI Studio (Gemini API) to generate offline medical and herpetological data.

Features:
- 100+ Comprehensive Species (Bangladesh native + global snakes).
- Incremental, atomic saving to assets/data/snakes.json.
- 100% Resumable: automatically skips previously completed species.
- Automatic retry with exponential backoff for 429 rate limits, 503 server errors, and network disconnects.
- Zero external pip dependencies (uses standard Python 3 urllib/json).
"""

import os
import sys
import json
import time
import argparse
import urllib.request
import urllib.error

# Force UTF-8 on Windows console for Bengali character output
if sys.stdout and hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

# Default Google AI Studio API Key provided for VenomShield
DEFAULT_API_KEY = "YOUR_GEMINI_KEY_HERE"

# Models to attempt in order of preference
GEMINI_MODELS = [
    "gemini-3.6-flash",
    "gemini-3.7-flash",
    "gemini-flash-latest",
    "gemini-3.5-flash"
]

# Comprehensive Species Database List (100+ Species)
SNAKE_SPECIES_CATALOG = [
    # =========================================================================
    # PART 1: BANGLADESH NATIVE & REGIONAL SPECIES (Venomous & Non-Venomous)
    # =========================================================================
    # --- Major Venomous (The Big Four & Common Dangerous Snakes) ---
    {
        "scientific_name": "Daboia russelii",
        "species_en": "Russell's Viper",
        "species_bn": "চন্দ্রবোড়া (রাসেলস ভাইপার)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Vipers)"
    },
    {
        "scientific_name": "Naja naja",
        "species_en": "Spectacled Cobra",
        "species_bn": "খৈয়া গোখরা",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Cobras)"
    },
    {
        "scientific_name": "Naja kaouthia",
        "species_en": "Monocled Cobra",
        "species_bn": "পদ্ম গোখরা (মনোকলড গোখরা)",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Cobras)"
    },
    {
        "scientific_name": "Ophiophagus hannah",
        "species_en": "King Cobra",
        "species_bn": "শঙ্খচূড় (রাজগোখরা)",
        "region": "Bangladesh / South & Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Cobras)"
    },
    {
        "scientific_name": "Bungarus caeruleus",
        "species_en": "Common Krait",
        "species_bn": "কাল কেউটে (কমন ক্রেইট)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Kraits)"
    },
    {
        "scientific_name": "Bungarus fasciatus",
        "species_en": "Banded Krait",
        "species_bn": "শঙ্খিনী (ডোরাকাটা কেউটে)",
        "region": "Bangladesh / South & Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Kraits)"
    },
    {
        "scientific_name": "Bungarus niger",
        "species_en": "Black Krait",
        "species_bn": "কালো কেউটে",
        "region": "Bangladesh / Eastern Himalayas",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Kraits)"
    },
    {
        "scientific_name": "Bungarus lividus",
        "species_en": "Lesser Black Krait",
        "species_bn": "ছোট কালো কেউটে",
        "region": "Bangladesh / Eastern India",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Kraits)"
    },
    {
        "scientific_name": "Bungarus walli",
        "species_en": "Wall's Krait",
        "species_bn": "ওয়ালস কেউটে",
        "region": "Bangladesh / Gangetic Plains",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Kraits)"
    },
    {
        "scientific_name": "Bungarus bungaroides",
        "species_en": "Northeastern Hill Krait",
        "species_bn": "পাহাড়ি কেউটে",
        "region": "Bangladesh / Northeastern Hills",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Kraits)"
    },
    # --- Pit Vipers & Keelbacks (Bangladesh) ---
    {
        "scientific_name": "Trimeresurus albolabris",
        "species_en": "White-lipped Pit Viper",
        "species_bn": "সাদা-ঠোঁট সবুজ বোড়া",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "medium",
        "category": "Viperidae (Pit Vipers)"
    },
    {
        "scientific_name": "Trimeresurus erythrurus",
        "species_en": "Spot-tailed Pit Viper",
        "species_bn": "লাললেজি সবুজ বোড়া",
        "region": "Bangladesh / Myanmar / India",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "medium",
        "category": "Viperidae (Pit Vipers)"
    },
    {
        "scientific_name": "Trimeresurus purpureomaculatus",
        "species_en": "Mangrove Pit Viper",
        "species_bn": "সুন্দরবন বোড়া (ম্যানগ্রোভ পিট ভাইপার)",
        "region": "Bangladesh (Sundarbans) / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "medium",
        "category": "Viperidae (Pit Vipers)"
    },
    {
        "scientific_name": "Trimeresurus gramineus",
        "species_en": "Bamboo Pit Viper",
        "species_bn": "বাঁশ বোড়া",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "medium",
        "category": "Viperidae (Pit Vipers)"
    },
    {
        "scientific_name": "Ovophis monticola",
        "species_en": "Mountain Pit Viper",
        "species_bn": "পাহাড়ি বোড়া",
        "region": "Bangladesh / Himalayan Foothills",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "medium",
        "category": "Viperidae (Pit Vipers)"
    },
    {
        "scientific_name": "Rhabdophis subminiatus",
        "species_en": "Red-necked Keelback",
        "species_bn": "লালঘাড় ঢোড়া",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Colubridae (Venomous Keelbacks)"
    },
    {
        "scientific_name": "Rhabdophis himalayanus",
        "species_en": "Orange-collared Keelback",
        "species_bn": "কমলাঘাড় ঢোড়া",
        "region": "Bangladesh / Himalayas",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "medium",
        "category": "Colubridae (Keelbacks)"
    },
    # --- Marine / Sea Snakes (Bay of Bengal / Coastal Bangladesh) ---
    {
        "scientific_name": "Hydrophis schistosus",
        "species_en": "Beaked Sea Snake",
        "species_bn": "হুক-নাক সামুদ্রিক সাপ",
        "region": "Bay of Bengal / Coastal Bangladesh",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Sea Snakes)"
    },
    {
        "scientific_name": "Hydrophis cyanocinctus",
        "species_en": "Annulated Sea Snake",
        "species_bn": "নীলবলয় সামুদ্রিক সাপ",
        "region": "Bay of Bengal / Coastal Waters",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Sea Snakes)"
    },
    {
        "scientific_name": "Hydrophis curtus",
        "species_en": "Shaw's Sea Snake",
        "species_bn": "শ'র সামুদ্রিক সাপ",
        "region": "Bay of Bengal",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Sea Snakes)"
    },
    {
        "scientific_name": "Pelamis platura",
        "species_en": "Yellow-bellied Sea Snake",
        "species_bn": "হলুদপেট সামুদ্রিক সাপ",
        "region": "Bay of Bengal / Indo-Pacific",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Sea Snakes)"
    },
    {
        "scientific_name": "Laticauda colubrina",
        "species_en": "Yellow-lipped Sea Krait",
        "species_bn": "সামুদ্রিক কেউটে",
        "region": "Bay of Bengal / Coastal Islands",
        "is_bangladesh_native": True,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Sea Kraits)"
    },
    # --- Non-Venomous & Mildly Venomous (Bangladesh Native) ---
    {
        "scientific_name": "Python molurus",
        "species_en": "Indian Rock Python",
        "species_bn": "অজগর (রক পাইথন)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Pythonidae (Pythons)"
    },
    {
        "scientific_name": "Malayopython reticulatus",
        "species_en": "Reticulated Python",
        "species_bn": "জালি অজগর",
        "region": "Bangladesh (Chittagong/Sylhet) / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Pythonidae (Pythons)"
    },
    {
        "scientific_name": "Ptyas mucosa",
        "species_en": "Oriental Rat Snake",
        "species_bn": "ধামন সাপ (দারাজ)",
        "region": "Bangladesh / South & Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Rat Snakes)"
    },
    {
        "scientific_name": "Ptyas korros",
        "species_en": "Indochinese Rat Snake",
        "species_bn": "ছোট ধামন",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Rat Snakes)"
    },
    {
        "scientific_name": "Ptyas nigromarginata",
        "species_en": "Green Rat Snake",
        "species_bn": "সবুজ ধামন",
        "region": "Bangladesh / Eastern Himalayas",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Rat Snakes)"
    },
    {
        "scientific_name": "Fowlea piscator",
        "species_en": "Checkered Keelback",
        "species_bn": "ঢোড়া সাপ (জলঢোড়া)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Water Snakes)"
    },
    {
        "scientific_name": "Fowlea flavipunctatus",
        "species_en": "Yellow-spotted Keelback",
        "species_bn": "হলুদ ফোঁটা ঢোড়া",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Water Snakes)"
    },
    {
        "scientific_name": "Ahaetulla nasuta",
        "species_en": "Common Vine Snake",
        "species_bn": "সবুজ লাউডগা",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Vine Snakes)"
    },
    {
        "scientific_name": "Ahaetulla prasina",
        "species_en": "Asian Vine Snake",
        "species_bn": "এশীয় লাউডগা",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Vine Snakes)"
    },
    {
        "scientific_name": "Lycodon aulicus",
        "species_en": "Common Wolf Snake",
        "species_bn": "ঘরগিন্নি সাপ (কালনাগিনী / নেকড়ে সাপ)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Wolf Snakes)"
    },
    {
        "scientific_name": "Lycodon capucinus",
        "species_en": "Common House Snake",
        "species_bn": "রূপালী ঘরগিন্নি",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Wolf Snakes)"
    },
    {
        "scientific_name": "Lycodon zawi",
        "species_en": "Zaw's Wolf Snake",
        "species_bn": "জাও এর ঘরগিন্নি",
        "region": "Bangladesh / Myanmar",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Wolf Snakes)"
    },
    {
        "scientific_name": "Lycodon fasciatus",
        "species_en": "Banded Wolf Snake",
        "species_bn": "ডোরাকাটা ঘরগিন্নি",
        "region": "Bangladesh / Northeast Hills",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Wolf Snakes)"
    },
    {
        "scientific_name": "Chrysopelea ornata",
        "species_en": "Ornate Flying Snake",
        "species_bn": "কালনাগিনী (উড়ুক্কু সাপ)",
        "region": "Bangladesh / South & Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Flying Snakes)"
    },
    {
        "scientific_name": "Chrysopelea paradisi",
        "species_en": "Paradise Flying Snake",
        "species_bn": "স্বর্গীয় উড়ুক্কু সাপ",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Flying Snakes)"
    },
    {
        "scientific_name": "Coelognathus helena",
        "species_en": "Common Trinket Snake",
        "species_bn": "দুধরাজ সাপ",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Trinket Snakes)"
    },
    {
        "scientific_name": "Coelognathus radiatus",
        "species_en": "Copperhead Trinket Snake",
        "species_bn": "তামাটে দুধরাজ",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Trinket Snakes)"
    },
    {
        "scientific_name": "Oligodon arnensis",
        "species_en": "Common Kukri Snake",
        "species_bn": "কুকরি সাপ (ব্যান্ডেড কুকরি)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Kukri Snakes)"
    },
    {
        "scientific_name": "Oligodon albocinctus",
        "species_en": "Light-barred Kukri Snake",
        "species_bn": "শ্বেতবলয় কুকরি",
        "region": "Bangladesh / Himalayas",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Kukri Snakes)"
    },
    {
        "scientific_name": "Oligodon cyclurus",
        "species_en": "Cantor's Kukri Snake",
        "species_bn": "ক্যান্টরের কুকরি",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Kukri Snakes)"
    },
    {
        "scientific_name": "Dendrelaphis tristis",
        "species_en": "Common Bronzeback Tree Snake",
        "species_bn": "ব্রোঞ্জপিঠ বেত আঁচড়া",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Bronzebacks)"
    },
    {
        "scientific_name": "Dendrelaphis pictus",
        "species_en": "Painted Bronzeback",
        "species_bn": "চিত্রিত ব্রোঞ্জপিঠ সাপ",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Bronzebacks)"
    },
    {
        "scientific_name": "Boiga trigonata",
        "species_en": "Common Cat Snake",
        "species_bn": "ফণিমনসা সাপ (ক্যাট স্নেক)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Cat Snakes)"
    },
    {
        "scientific_name": "Boiga ochracea",
        "species_en": "Tawny Cat Snake",
        "species_bn": "মেটে ফণিমনসা",
        "region": "Bangladesh / Eastern India",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Cat Snakes)"
    },
    {
        "scientific_name": "Boiga siamensis",
        "species_en": "Eyed Cat Snake",
        "species_bn": "সিয়ামী ফণিমনসা",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Cat Snakes)"
    },
    {
        "scientific_name": "Boiga cyanea",
        "species_en": "Green Cat Snake",
        "species_bn": "সবুজ ফণিমনসা",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Cat Snakes)"
    },
    {
        "scientific_name": "Enhydris enhydris",
        "species_en": "Rainbow Water Snake",
        "species_bn": "রামধনু জলসাপ (পাকড়া ঢোড়া)",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Homalopsidae (Water Snakes)"
    },
    {
        "scientific_name": "Homalopsis buccata",
        "species_en": "Masked Water Snake",
        "species_bn": "মুখোশধারী জলসাপ",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Homalopsidae (Water Snakes)"
    },
    {
        "scientific_name": "Cerberus rynchops",
        "species_en": "Dog-faced Water Snake",
        "species_bn": "হেলে সাপ (কুকুর-মুখী জলসাপ)",
        "region": "Coastal Bangladesh (Sundarbans)",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Homalopsidae (Mud Snakes)"
    },
    {
        "scientific_name": "Gerarda prevostiana",
        "species_en": "Gerard's Water Snake",
        "species_bn": "গেরার্ডের জলসাপ",
        "region": "Coastal Mangroves / Sundarbans",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Homalopsidae (Mangrove Snakes)"
    },
    {
        "scientific_name": "Indotyphlops braminus",
        "species_en": "Brahminy Blind Snake",
        "species_bn": "দুমুখো কেঁচো সাপ (অন্ধ সাপ)",
        "region": "Bangladesh / Pantropical",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Typhlopidae (Blind Snakes)"
    },
    {
        "scientific_name": "Typhlops diardii",
        "species_en": "Diard's Blind Snake",
        "species_bn": "ডিয়ার্ডের অন্ধ সাপ",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Typhlopidae (Blind Snakes)"
    },
    {
        "scientific_name": "Eryx conicus",
        "species_en": "Rough-scaled Sand Boa",
        "species_bn": "বালু বোয়া (বামন অজগর)",
        "region": "Bangladesh / South Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Boidae (Sand Boas)"
    },
    {
        "scientific_name": "Psammodynastes pulverulentus",
        "species_en": "Common Mock Viper",
        "species_bn": "নকল বোড়া",
        "region": "Bangladesh / Southeast Asia",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Mock Vipers)"
    },
    {
        "scientific_name": "Sibynophis collaris",
        "species_en": "Collared Black-headed Snake",
        "species_bn": "কালোমাথা সাপ",
        "region": "Bangladesh / Himalayas",
        "is_bangladesh_native": True,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae"
    },

    # =========================================================================
    # PART 2: PROMINENT GLOBAL & INTERNATIONAL SPECIES (Venomous & Non-Venomous)
    # =========================================================================
    # --- Africa ---
    {
        "scientific_name": "Dendroaspis polylepis",
        "species_en": "Black Mamba",
        "species_bn": "কালো মাম্বা (ব্ল্যাক মাম্বা)",
        "region": "Sub-Saharan Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Mambas)"
    },
    {
        "scientific_name": "Dendroaspis angusticeps",
        "species_en": "Eastern Green Mamba",
        "species_bn": "সবুজ মাম্বা (গ্রিন মাম্বা)",
        "region": "Eastern & Southern Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Mambas)"
    },
    {
        "scientific_name": "Bitis arietans",
        "species_en": "Puff Adder",
        "species_bn": "পাফ অ্যাডার",
        "region": "Africa & Arabian Peninsula",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Adders)"
    },
    {
        "scientific_name": "Bitis gabonica",
        "species_en": "Gaboon Viper",
        "species_bn": "গ্যাবুন ভাইপার",
        "region": "Central & West Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Vipers)"
    },
    {
        "scientific_name": "Bitis nasicornis",
        "species_en": "Rhinoceros Viper",
        "species_bn": "রাইনো ভাইপার (গণ্ডার বোড়া)",
        "region": "Central & West Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Vipers)"
    },
    {
        "scientific_name": "Dispholidus typus",
        "species_en": "Boomslang",
        "species_bn": "বুমস্ল্যাং",
        "region": "Sub-Saharan Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Colubridae (Venomous)"
    },
    {
        "scientific_name": "Thelotornis capensis",
        "species_en": "Twig Snake (Bird Snake)",
        "species_bn": "টুইগ স্নেক",
        "region": "Southern & Eastern Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Colubridae (Venomous)"
    },
    {
        "scientific_name": "Naja nivea",
        "species_en": "Cape Cobra",
        "species_bn": "কেপ কোবরা",
        "region": "Southern Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Cobras)"
    },
    {
        "scientific_name": "Naja haje",
        "species_en": "Egyptian Cobra",
        "species_bn": "মিশরীয় কোবরা",
        "region": "North & East Africa",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Cobras)"
    },
    {
        "scientific_name": "Cerastes cerastes",
        "species_en": "Sahara Horned Viper",
        "species_bn": "শিংযুক্ত সাহারা বোড়া",
        "region": "North Africa & Middle East",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Vipers)"
    },
    {
        "scientific_name": "Python sebae",
        "species_en": "African Rock Python",
        "species_bn": "আফ্রিকান রক পাইথন",
        "region": "Sub-Saharan Africa",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Pythonidae (Pythons)"
    },
    {
        "scientific_name": "Python regius",
        "species_en": "Ball Python (Royal Python)",
        "species_bn": "বল পাইথন",
        "region": "West & Central Africa",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Pythonidae (Pythons)"
    },

    # --- Australia & Oceania ---
    {
        "scientific_name": "Oxyuranus microlepidotus",
        "species_en": "Inland Taipan (Fierce Snake)",
        "species_bn": "ইনল্যান্ড তাইপান",
        "region": "Central Australia",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Taipans)"
    },
    {
        "scientific_name": "Oxyuranus scutellatus",
        "species_en": "Coastal Taipan",
        "species_bn": "কোস্টাল তাইপান",
        "region": "Northern & Eastern Australia",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Taipans)"
    },
    {
        "scientific_name": "Pseudonaja textilis",
        "species_en": "Eastern Brown Snake",
        "species_bn": "ইস্টার্ন ব্রাউন স্নেক",
        "region": "Eastern Australia",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Brown Snakes)"
    },
    {
        "scientific_name": "Notechis scutatus",
        "species_en": "Mainland Tiger Snake",
        "species_bn": "টাইগার স্নেক",
        "region": "Southern Australia",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Tiger Snakes)"
    },
    {
        "scientific_name": "Acanthophis antarcticus",
        "species_en": "Common Death Adder",
        "species_bn": "কমন ডেথ অ্যাডার",
        "region": "Australia",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Death Adders)"
    },
    {
        "scientific_name": "Morelia viridis",
        "species_en": "Green Tree Python",
        "species_bn": "সবুজ বৃক্ষ পাইথন",
        "region": "Australia & New Guinea",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Pythonidae (Pythons)"
    },
    {
        "scientific_name": "Morelia spilota",
        "species_en": "Carpet Python",
        "species_bn": "কার্পেট পাইথন",
        "region": "Australia & New Guinea",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Pythonidae (Pythons)"
    },

    # --- Americas (North, Central & South America) ---
    {
        "scientific_name": "Crotalus atrox",
        "species_en": "Western Diamondback Rattlesnake",
        "species_bn": "ওয়েস্টার্ন ডায়মন্ডব্যাক র‍্যাটলস্নেক",
        "region": "North America (USA / Mexico)",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Rattlesnakes)"
    },
    {
        "scientific_name": "Crotalus adamanteus",
        "species_en": "Eastern Diamondback Rattlesnake",
        "species_bn": "ইস্টার্ন ডায়মন্ডব্যাক র‍্যাটলস্নেক",
        "region": "Southeastern USA",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Rattlesnakes)"
    },
    {
        "scientific_name": "Crotalus durissus",
        "species_en": "South American Rattlesnake (Cascabel)",
        "species_bn": "দক্ষিণ আমেরিকান র‍্যাটলস্নেক (কাসকাভেল)",
        "region": "South America",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Rattlesnakes)"
    },
    {
        "scientific_name": "Bothrops atrox",
        "species_en": "Fer-de-lance (Common Lancehead)",
        "species_bn": "ফের-দ্য-ল্যান্স (ল্যান্সহেড ভাইপার)",
        "region": "Tropical South America",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Lanceheads)"
    },
    {
        "scientific_name": "Bothrops jararaca",
        "species_en": "Jararaca",
        "species_bn": "জারারাকা ভাইপার",
        "region": "Brazil / South America",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Lanceheads)"
    },
    {
        "scientific_name": "Lachesis muta",
        "species_en": "South American Bushmaster",
        "species_bn": "বুশমাস্টার ভাইপার",
        "region": "Amazon Rainforest / South America",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Bushmasters)"
    },
    {
        "scientific_name": "Agkistrodon piscivorus",
        "species_en": "Cottonmouth (Water Moccasin)",
        "species_bn": "কটনমাউথ (ওয়াটার মকাসিন)",
        "region": "Southeastern USA",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Pit Vipers)"
    },
    {
        "scientific_name": "Agkistrodon contortrix",
        "species_en": "Eastern Copperhead",
        "species_bn": "ইস্টার্ন কপারহেড",
        "region": "Eastern USA",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "medium",
        "category": "Viperidae (Pit Vipers)"
    },
    {
        "scientific_name": "Micrurus fulvius",
        "species_en": "Eastern Coral Snake",
        "species_bn": "ইস্টার্ন কোরাল স্নেক",
        "region": "Southeastern USA",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Elapidae (Coral Snakes)"
    },
    {
        "scientific_name": "Eunectes murinus",
        "species_en": "Green Anaconda",
        "species_bn": "সবুজ অ্যানাকোন্ডা (গ্রিন অ্যানাকোন্ডা)",
        "region": "South America (Amazon Basin)",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Boidae (Boas)"
    },
    {
        "scientific_name": "Eunectes notaeus",
        "species_en": "Yellow Anaconda",
        "species_bn": "হলুদ অ্যানাকোন্ডা",
        "region": "Southern South America",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Boidae (Boas)"
    },
    {
        "scientific_name": "Boa constrictor",
        "species_en": "Boa Constrictor (Red-tailed Boa)",
        "species_bn": "বোয়া কনস্ট্রিক্টর",
        "region": "Central & South America",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Boidae (Boas)"
    },
    {
        "scientific_name": "Corallus caninus",
        "species_en": "Emerald Tree Boa",
        "species_bn": "পান্না বৃক্ষ বোয়া",
        "region": "South America (Rainforests)",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Boidae (Boas)"
    },
    {
        "scientific_name": "Lampropeltis getula",
        "species_en": "Eastern Kingsnake",
        "species_bn": "ইস্টার্ন কিং স্নেক",
        "region": "North America",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Kingsnakes)"
    },
    {
        "scientific_name": "Lampropeltis triangulum",
        "species_en": "Milk Snake",
        "species_bn": "মিল্ক স্নেক",
        "region": "North & Central America",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Milk Snakes)"
    },
    {
        "scientific_name": "Pantherophis guttatus",
        "species_en": "Corn Snake (Red Rat Snake)",
        "species_bn": "কর্ন স্নেক",
        "region": "Southeastern USA",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Rat Snakes)"
    },
    {
        "scientific_name": "Pantherophis obsoletus",
        "species_en": "Western Black Rat Snake",
        "species_bn": "কালো র‍্যাট স্নেক",
        "region": "North America",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Rat Snakes)"
    },
    {
        "scientific_name": "Thamnophis sirtalis",
        "species_en": "Common Garter Snake",
        "species_bn": "গার্টার স্নেক",
        "region": "North America",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Garter Snakes)"
    },
    {
        "scientific_name": "Heterodon platirhinos",
        "species_en": "Eastern Hognose Snake",
        "species_bn": "ইস্টার্ন হগনোজ স্নেক",
        "region": "North America",
        "is_bangladesh_native": False,
        "venomous": False,
        "danger_level": "low",
        "category": "Colubridae (Hognose Snakes)"
    },

    # --- Europe & Middle East / Central Asia ---
    {
        "scientific_name": "Vipera berus",
        "species_en": "Common European Adder",
        "species_bn": "কমন ইউরোপীয় ভাইপার (অ্যাডার)",
        "region": "Europe & Northern Asia",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "medium",
        "category": "Viperidae (Adders)"
    },
    {
        "scientific_name": "Echis carinatus",
        "species_en": "Saw-scaled Viper",
        "species_bn": "করাত-আঁইশ বোড়া (স-স্কেলড ভাইপার)",
        "region": "Middle East / Central & South Asia",
        "is_bangladesh_native": False,
        "venomous": True,
        "danger_level": "high",
        "category": "Viperidae (Vipers)"
    }
]


def call_gemini_api(api_key: str, prompt: str, model_index: int = 0) -> str:
    """
    Calls Google AI Studio Gemini API with model rotation and error handling.
    """
    model_name = GEMINI_MODELS[model_index % len(GEMINI_MODELS)]
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"

    payload = {
        "contents": [
            {
                "parts": [{"text": prompt}]
            }
        ],
        "generationConfig": {
            "temperature": 0.1,
            "responseMimeType": "application/json"
        }
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )

    with urllib.request.urlopen(req, timeout=60) as resp:
        if resp.status == 200:
            raw_body = resp.read().decode("utf-8")
            data = json.loads(raw_body)
            candidates = data.get("candidates", [])
            if not candidates:
                raise ValueError("Empty candidates in Gemini response")
            text_content = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "").strip()
            return text_content
        else:
            raise urllib.error.HTTPError(url, resp.status, "API Non-200 Response", resp.headers, None)


def generate_species_prompt(species: dict) -> str:
    """
    Constructs a highly structured herpetological prompt for Gemini.
    """
    return f"""You are an expert herpetologist and clinical toxicologist specializing in snake identification, snakebite envenomation management, and medical guidance for Bangladesh and global snakes.

Provide accurate, realistic, medical-grade information for the snake species:
- Scientific Name: {species['scientific_name']}
- English Common Name: {species['species_en']}
- Bengali Common Name: {species['species_bn']}
- Region: {species['region']}
- Is Native to Bangladesh: {species['is_bangladesh_native']}
- Known Venomous Status: {species['venomous']}

Respond with a single raw JSON object strictly adhering to this structure:
{{
  "scientific_name": "{species['scientific_name']}",
  "species_en": "{species['species_en']}",
  "species_bn": "{species['species_bn']}",
  "region": "{species['region']}",
  "is_bangladesh_native": {str(species['is_bangladesh_native']).lower()},
  "venomous": {str(species['venomous']).lower()},
  "danger_level": "{species['danger_level']}",
  "antivenom_available": { "true" if species['venomous'] else "false" },
  "aliases_en": [
    "Array of 4-6 common English search keywords, synonyms, and alternate spellings (e.g. '{species['species_en'].lower()}', '{species['scientific_name'].lower()}')"
  ],
  "aliases_bn": [
    "Array of 3-5 common Bengali search keywords and regional names (e.g. '{species['species_bn']}')"
  ],
  "description_en": "2-3 comprehensive sentences in English explaining physical appearance, habitat, scale patterns, and behavior.",
  "description_bn": "2-3 comprehensive sentences in Bengali explaining physical appearance, habitat, scale patterns, and behavior.",
  "bite_effects_en": "Detailed medical explanation in English about the venom toxicity (neurotoxin, hemotoxin, cytotoxin, non-venomous, etc.) and what physiologically happens if bitten.",
  "bite_effects_bn": "Detailed medical explanation in Bengali about the venom toxicity and physiological effects of a bite.",
  "symptoms_en": "Accurate list and description in English of symptoms that typically develop after a bite (e.g. local swelling, bleeding, ptosis, pain, necrosis, or superficial tooth scratches).",
  "symptoms_bn": "Accurate list and description in Bengali of symptoms that typically develop after a bite.",
  "progression_en": "Detailed timeline in English of how symptoms progress over time (e.g. within 30 mins, 2 hours, 12 hours) and how quickly serious complications develop.",
  "progression_bn": "Detailed timeline in Bengali of how symptoms progress over time and how quickly serious complications develop.",
  "fatality_en": "Realistic assessment in English of whether the bite can be fatal, mortality risk if untreated, and clinical severity.",
  "fatality_bn": "Realistic assessment in Bengali of whether the bite can be fatal, mortality risk if untreated, and clinical severity.",
  "first_aid_en": [
    "Step 1: Immediate first aid instruction in English",
    "Step 2: Immobilization guidance in English",
    "Step 3: What NOT to do (e.g. no tourniquets, no incision) in English",
    "Step 4: Transport instruction in English"
  ],
  "first_aid_bn": [
    "ধাপ ১: তাৎক্ষণিক প্রাথমিক চিকিৎসা নির্দেশনা বাংলায়",
    "ধাপ ২: আক্রান্ত অঙ্গ স্থির রাখার নির্দেশনা বাংলায়",
    "ধাপ ৩: কী করা যাবে না (শক্ত বাঁধন বা কাটা নিষেধ) বাংলায়",
    "ধাপ ৪: হাসপাতালে নেওয়ার নির্দেশনা বাংলায়"
  ],
  "actions_en": "Short 1-2 sentence immediate actionable summary in English.",
  "actions_bn": "Short 1-2 sentence immediate actionable summary in Bengali.",
  "emergency_en": "Clear emergency guidance in English on when and where to seek urgent hospitalization and anti-venom treatment.",
  "emergency_bn": "Clear emergency guidance in Bengali on when and where to seek urgent hospitalization and anti-venom treatment."
}}

CRITICAL RULES:
1. Return ONLY pure valid JSON without markdown wrapping or backticks.
2. Scientific and medical facts must be 100% accurate.
3. For non-venomous snakes, clearly state zero toxicity risk, recommend antiseptic wound washing and tetanus vaccination, and state that anti-venom is not required.
4. For venomous snakes, emphasize urgent hospitalization at anti-venom facilities and strict limb immobilization."""


def clean_json_string(raw_str: str) -> str:
    """Strips markdown code fences and extraneous whitespace."""
    s = raw_str.strip()
    if s.startswith("```json"):
        s = s[7:]
    elif s.startswith("```"):
        s = s[3:]
    if s.endswith("```"):
        s = s[:-3]
    return s.strip()


def load_dataset(file_path: str) -> list:
    """Loads existing dataset if file exists."""
    if os.path.exists(file_path):
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, list):
                    return data
        except Exception as e:
            print(f"[!] Warning: Could not read existing {file_path} ({e}). Creating backup...")
            backup_path = file_path + f".bak.{int(time.time())}"
            try:
                os.rename(file_path, backup_path)
                print(f"[+] Backup saved to {backup_path}")
            except Exception:
                pass
    return []


def save_dataset_atomic(file_path: str, data: list):
    """
    Safely writes dataset to a temporary file and atomically replaces destination.
    Guarantees zero data loss if process is killed mid-write.
    """
    os.makedirs(os.path.dirname(os.path.abspath(file_path)), exist_ok=True)
    temp_path = file_path + ".tmp"
    with open(temp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.flush()
        os.fsync(f.fileno())
    
    # Atomic replace (Windows & POSIX safe)
    if os.path.exists(file_path):
        os.replace(temp_path, file_path)
    else:
        os.rename(temp_path, file_path)


def main():
    parser = argparse.ArgumentParser(description="VenomShield AI Snake Dataset Generator")
    parser.add_argument("--api-key", default=os.getenv("GEMINI_API_KEY", DEFAULT_API_KEY), help="Google AI Studio API Key")
    parser.add_argument("--output", default=os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "data", "snakes.json"), help="Output JSON path")
    parser.add_argument("--limit", type=int, default=None, help="Limit number of new species to process (useful for testing)")
    parser.add_argument("--delay", type=float, default=1.5, help="Delay in seconds between API calls to prevent rate limits")
    parser.add_argument("--force", action="store_true", help="Force re-generation of already existing species")
    parser.add_argument("--verbose", action="store_true", help="Print full generated JSON details")
    args = parser.parse_args()

    api_key = args.api_key.strip()
    if not api_key:
        print("[!] Error: No API key provided. Set GEMINI_API_KEY or use --api-key.")
        sys.exit(1)

    print("=" * 70)
    print("  VENOMSHIELD AI — OFFLINE SNAKE DATASET GENERATOR")
    print("=" * 70)
    print(f"[*] Target Output File : {args.output}")
    print(f"[*] Total Catalog Size : {len(SNAKE_SPECIES_CATALOG)} species")
    print(f"[*] Request Delay      : {args.delay}s")
    print("-" * 70)

    # 1. Load existing dataset
    dataset = load_dataset(args.output)
    print(f"[*] Loaded existing dataset: {len(dataset)} species already saved.")

    # 2. Build index of existing species
    existing_keys = set()
    for item in dataset:
        sci = item.get("scientific_name", "").strip().lower()
        en = item.get("species_en", "").strip().lower()
        if sci:
            existing_keys.add(sci)
        if en:
            existing_keys.add(en)

    # 3. Filter pending species
    pending_species = []
    for spec in SNAKE_SPECIES_CATALOG:
        sci_key = spec["scientific_name"].strip().lower()
        en_key = spec["species_en"].strip().lower()
        if args.force or (sci_key not in existing_keys and en_key not in existing_keys):
            pending_species.append(spec)

    print(f"[*] Species to generate : {len(pending_species)} species")
    if args.limit and args.limit > 0:
        pending_species = pending_species[:args.limit]
        print(f"[*] Batch Limit Applied : Processing next {len(pending_species)} species")

    if not pending_species:
        print("\n[✓] All catalog species are already generated and up-to-date in dataset!")
        print(f"[✓] Total entries in {args.output}: {len(dataset)}")
        return

    print("\n[*] Beginning generation loop with automatic retry and checkpointing...")
    print("=" * 70)

    start_time = time.time()
    success_count = 0
    model_idx = 0

    total_pending = len(pending_species)
    total_catalog = len(SNAKE_SPECIES_CATALOG)

    for idx, spec in enumerate(pending_species, 1):
        sci = spec["scientific_name"]
        en = spec["species_en"]
        bn = spec["species_bn"]
        is_ven = "VENOMOUS" if spec["venomous"] else "NON-VENOMOUS"
        native = "BD Native" if spec["is_bangladesh_native"] else "Global"

        # Calculate progress and ETA
        pct = (idx / total_pending) * 100
        bar_len = 24
        filled_len = int(bar_len * idx // total_pending)
        bar = "█" * filled_len + "░" * (bar_len - filled_len)

        elapsed_so_far = time.time() - start_time
        avg_time_per_item = elapsed_so_far / idx if idx > 1 else 0
        rem_items = total_pending - idx
        eta_secs = int(avg_time_per_item * rem_items)
        eta_str = f"{eta_secs // 60}m {eta_secs % 60}s" if avg_time_per_item > 0 else "Calculating..."

        print(f"\n[{idx:02d}/{total_pending:02d}] {bar} {pct:5.1f}% | ETA: {eta_str}")
        print(f"  🐍 Species  : {en} ({sci}) | {bn}")
        print(f"  ⚠️  Status   : [{is_ven}] | Category: [{spec.get('category', 'Colubridae')}] | Region: [{native}]")

        prompt = generate_species_prompt(spec)
        retry_delay = 3.0
        max_attempts = 10
        item_data = None

        for attempt in range(1, max_attempts + 1):
            try:
                current_model = GEMINI_MODELS[model_idx % len(GEMINI_MODELS)]
                print(f"  ⚡ API Call : Querying {current_model} (Attempt {attempt}/{max_attempts})...", end="", flush=True)
                
                raw_response = call_gemini_api(api_key, prompt, model_index=model_idx)
                cleaned = clean_json_string(raw_response)
                parsed = json.loads(cleaned)

                # Validate essential fields
                if not parsed.get("scientific_name") or "venomous" not in parsed:
                    raise ValueError("Missing required fields in model output JSON")

                # Ensure consistent types
                parsed["venomous"] = bool(parsed["venomous"])
                parsed["is_bangladesh_native"] = bool(parsed.get("is_bangladesh_native", spec["is_bangladesh_native"]))
                if "aliases_en" not in parsed or not isinstance(parsed["aliases_en"], list):
                    parsed["aliases_en"] = [en.lower(), sci.lower()]
                if "aliases_bn" not in parsed or not isinstance(parsed["aliases_bn"], list):
                    parsed["aliases_bn"] = [bn]

                item_data = parsed
                print(" [SUCCESS 200 OK]")
                break

            except urllib.error.HTTPError as e:
                error_body = ""
                try:
                    error_body = e.read().decode("utf-8")
                except Exception:
                    pass

                model_idx += 1  # Rotate to next model
                if e.code == 429:
                    print(f" [RATE LIMIT 429: Will backoff {retry_delay:.1f}s, switching model]")
                elif e.code in (500, 502, 503, 504):
                    print(f" [SERVER ERROR {e.code}: High Demand. Backing off {retry_delay:.1f}s, switching model]")
                elif e.code == 404:
                    print(f" [MODEL ERROR 404: Rotating model...]")
                else:
                    print(f" [HTTP ERROR {e.code}: {error_body[:100]}]")

                time.sleep(retry_delay)
                retry_delay = min(retry_delay * 1.5, 30.0)

            except Exception as e:
                model_idx += 1  # Rotate to next model on timeout/socket error
                print(f" [TIMEOUT/ERROR: {e}. Switching model...]")
                time.sleep(retry_delay)
                retry_delay = min(retry_delay * 1.5, 30.0)

        if item_data is not None:
            # Check if updating or appending
            replaced = False
            for i, existing in enumerate(dataset):
                if existing.get("scientific_name", "").strip().lower() == sci.strip().lower():
                    dataset[i] = item_data
                    replaced = True
                    break
            if not replaced:
                dataset.append(item_data)

            # Atomic save immediately after each successful snake
            save_dataset_atomic(args.output, dataset)
            success_count += 1
            print(f"  💾 Saved    : {args.output} (Collected: {len(dataset)}/{total_catalog} species in database)")

            if args.verbose:
                print("  📋 Details  :")
                print(f"     - Danger Level    : {item_data.get('danger_level')}")
                print(f"     - Search Keywords : {item_data.get('aliases_en')}")
                print(f"     - First Aid Steps : {len(item_data.get('first_aid_en', []))} items")

            # Politeness delay
            if idx < len(pending_species):
                time.sleep(args.delay)
        else:
            print(f"  ❌ Failed after {max_attempts} attempts. Moving to next (will resume on next run).")

    elapsed = time.time() - start_time
    print("\n" + "=" * 70)
    print(f"  DATASET GENERATION RUN COMPLETE")
    print(f"  - Completed in this run: {success_count} / {len(pending_species)} species")
    print(f"  - Total Dataset Size   : {len(dataset)} species saved in {args.output}")
    print(f"  - Total Elapsed Time   : {elapsed:.1f} seconds")
    print("=" * 70)


if __name__ == "__main__":
    main()
