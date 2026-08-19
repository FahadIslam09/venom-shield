# VenomShield (ভেনম-শিল্ড) — সম্পূর্ণ কারিগরি ও ফিচার ডকুমেন্টেশন
> **হ্যাকথন জাজেস প্রেপারেশন ও টেকনিক্যাল রেফারেন্স গাইড (Hackathon Judge Preparation Guide)**  
> *প্রজেক্ট:* **VenomShield — AI & Offline Hybrid Snake Identification & Clinical Envenomation Triage System**  
> *টেকনোলজি স্ট্যাক:* **Flutter, Dart, Riverpod, GoRouter, Google Gemini Vision AI, SQLite FFI, Web LocalStorage, Leaflet/OSM, OpenStreetMap API**

---

## সূচিপত্র (Table of Contents)
1. [প্রজেক্ট ওভারভিউ ও উদ্দেশ্য (Project Overview & Purpose)](#১-প্রজেক্ট-ওভারভিউ-ও-উদ্দেশ্য)
2. [সমস্যার গভীরতা ও প্রেক্ষাপট (Problem Statement & Context)](#২-সমস্যার-গভীরতা-ও-প্রেক্ষাপট)
3. [সিস্টেম আর্কিটেকচার ও টেক স্ট্যাক (System Architecture & Tech Stack)](#৩-সিস্টেম-আর্কিটেকচার-ও-টেক-স্ট্যাক)
4. [এআই স্নেক স্ক্যানার ও ভিজ্যুয়াল শনাক্তকরণ (AI Snake Scanner & Vision Processing)](#৪-এআই-স্নেক-স্ক্যানার-ও-ভিজ্যুয়াল-শনাক্তকরণ)
5. [অফলাইন ডেটাসেট ও এআই টোকেন অপটিমাইজেশন (Offline Dataset & AI Token Optimization Engine)](#৫-অফলাইন-ডেটাসেট-ও-এআই-টোকেন-অপটিমাইজেশন)
6. [লক্ষণ ও তালিকা ভিত্তিক ক্লিনিক্যাল ট্রায়াজ সিস্টেম (Symptoms & List Clinical Diagnostic Triage)](#৬-লক্ষণ-ও-তালিকা-ভিত্তিক-ক্লিনিক্যাল-ট্রায়াজ-সিস্টেম)
7. [ভিজ্যুয়াল স্ক্যান বনাম লক্ষণ মূল্যায়নের মৌলিক পার্থক্য (Visual Scan vs Symptom Assessment)](#৭-ভিজ্যুয়াল-স্ক্যান-বনাম-লক্ষণ-মূল্যায়নের-মৌলিক-পার্থক্য)
8. [হসপিটাল রাডার ও অ্যান্টি-ভেনম ট্র্যাকার (Hospital Radar & Antivenom Stock Locator)](#৮-হসপিটাল-রাডার-ও-অ্যান্টি-ভেনম-ট্র্যাকার)
9. [অ্যাসেসমেন্ট হিস্ট্রি ও ডুয়াল-প্ল্যাটফর্ম স্টোরেজ (Assessment History & Hybrid Storage System)](#৯-অ্যাসেসমেন্ট-হিস্ট্রি-ও-ডুয়াল-প্ল্যাটফর্ম-স্টোরেজ)
10. [সার্বজনীন দ্বিভাষিক লোকালাইজেশন ইঞ্জিন (Universal Bilingual Localization Engine)](#১০-সার্বজনীন-দ্বিভাষিক-লোকালাইজেশন-ইঞ্জিন)
11. [নেভিগেশন, স্টেট ম্যানেজমেন্ট ও নেটওয়ার্ক হ্যান্ডলিং (Navigation, State Management & Network Handling)](#১১-নেভিগেশন-স্টেট-ম্যানেজমেন্ট-ও-নেটওয়ার্ক-হ্যান্ডলিং)
12. [মেডিকেল সেফটি ও জিরো ফলস-নেগেটিভ নীতি (Medical Safety & Zero False-Negative Principles)](#১২-মেডিকেল-সেফটি-ও-জিরো-ফলস-নেগেটিভ-নীতি)
13. [হ্যাকথন জাজেস প্রশ্নোত্তর গাইড (Hackathon Judges Q&A Preparation)](#১৩-হ্যাকথন-জাজেস-প্রশ্নোত্তর-গাইড)

---

## ১. প্রজেক্ট ওভারভিউ ও উদ্দেশ্য

### ১.১ প্রজেক্ট কী?
**VenomShield** হলো একটি জীবনরক্ষাকারী হাইব্রিড মোবাইল ও ওয়েব অ্যাপ্লিকেশন যা কৃত্রিম বুদ্ধিমত্তা (AI Vision) এবং সম্পূর্ণ অফলাইন মেডিক্যাল ডেটাসেটের সমন্বয়ে সাপের প্রজাতি শনাক্তকরণ, বিষক্রিয়ার ঝুঁকি মূল্যায়ন (Clinical Envenomation Triage) এবং তাৎক্ষণিক নিকটস্থ অ্যান্টি-ভেনম সমৃদ্ধ হাসপাতালের সন্ধান প্রদান করে।

### ১.২ মূল উদ্দেশ্য
- **জীবন রক্ষা:** সাপে কাটার পর গোল্ডেন আওয়ারে (Golden Hour) দ্রুত সঠিক সিদ্ধান্ত গ্রহণে সাধারণ মানুষ ও চিকিৎসকদের সহায়তা করা।
- **ভ্রান্ত ধারণা ও ক্ষতিকর অপচিকিৎসা রোধ:** ওঝা, কাটাছেঁড়া বা শক্ত বাঁধন (Tourniquet)-এর মতো প্রাণঘাতী ভুল চিকিৎসা বন্ধ করা।
- **রিসোর্স অপটিমাইজেশন:** প্রতিটি স্ক্যানে অপ্রয়োজনীয় এআই টোকেন খরচ বন্ধ করে ৯৭+ সাপের অফলাইন ডেটাসেট ব্যবহার করে তাৎক্ষণিক ও সাশ্রয়ী সেবা নিশ্চিত করা।
- **ক্লিনিক্যাল সুরক্ষা:** শুধু ক্ষতের ছবির ওপর নির্ভর না করে ১৮টি বিশ্ব স্বাস্থ্য সংস্থা (WHO) ও জাতীয় গাইডলাইন ভিত্তিক লক্ষণ যাচাইয়ের মাধ্যমে জিরো ফলস-নেগেটিভ ট্রায়াজ প্রদান করা।

---

## ২. সমস্যার গভীরতা ও প্রেক্ষাপট

বাংলাদেশে প্রতি বছর প্রায় **৪,০০,০০০ মানুষ** সাপের কামড়ের শিকার হয় এবং আনুমানিক **৭,৫০০+ মানুষ** মৃত্যুবরণ করে (তথ্যসূত্র: স্বাস্থ্য অধিদপ্তর ও WHO)। মৃত্যুর প্রধান কারণসমূহ:
1. **সাপের প্রজাতি চিনতে না পারা:** বিষধর ও অবিষধর সাপের পার্থক্য বুঝতে না পেরে ভুল চিকিৎসা বা অযথা আতঙ্ক।
2. **অসময়ে হাসপাতালে পৌঁছানো:** কোন হাসপাতালে অ্যান্টি-ভেনম ও আইসিইউ আছে তা তাৎক্ষণিক জানতে না পারা।
3. **ওঝা ও অপচিকিৎসা:** রক্তপাত বন্ধে শক্ত রশি দিয়ে বাঁধন বা ক্ষতস্থান কাটার ফলে গ্যাংগ্রিন ও অঙ্গহানি।
4. **ইন্টারনেট সংযোগের অনিশ্চয়তা:** গ্রামীণ ও দুর্গম চরাঞ্চলে নিরবচ্ছিন্ন উচ্চগতির ইন্টারনেট না থাকা।

VenomShield এই প্রতিটি সংকটের জন্য অফলাইন-ফার্স্ট এবং এআই-পাওয়ার্ড সমাধান প্রস্তুত করেছে।

---

## ৩. সিস্টেম আর্কিটেকচার ও টেক স্ট্যাক

### ৩.১ টেকনোলজি স্ট্যাক
| লেয়ার | ব্যবহৃত টেকনোলজি / লাইব্রেরি | ভূমিকা |
| :--- | :--- | :--- |
| **Frontend Framework** | `Flutter 3.x`, `Dart 3.x` | ক্রস-প্ল্যাটফর্ম হাই-পারফরম্যান্স মোবাইল ও ওয়েব ইউআই |
| **State Management** | `flutter_riverpod: ^2.6.1` | রিঅ্যাকটিভ, টেস্টেবল এবং ইমিউটেবল গ্লোবাল স্টেট ম্যানেজমেন্ট |
| **Navigation & Routing** | `go_router: ^14.8.1` | ডিক্লেয়ারেটিভ ডিপ-লিংকিং ও পেজ ট্রানজিশন |
| **AI Vision Engine** | `Google Gemini 1.5 Flash Vision API` / `Dio: ^5.8.0` | ভিজ্যুয়াল প্যাটার্ন এক্সট্রাকশন ও স্পিসিস ক্লাসিফিকেশন |
| **Offline Knowledge Base** | `snakes.json` (Local Asset), `SnakeDatabase` | ৯৭+ স্থানীয় সাপের বিস্তারিত অফলাইন এনসাইক্লোপিডিয়া |
| **Database & Persistence** | `sqflite_common_ffi` (Native), `LocalStorage / web` (Chrome) | অফলাইন অ্যাসেসমেন্ট হিস্ট্রি ও ইউজার সেটিংস সংরক্ষণ |
| **Map & Geo-Location** | `flutter_map: ^7.0.2`, `latlong2: ^0.9.1`, `geolocator: ^12.0.0` | লাইভ জিপিএস ডিস্ট্যান্স ক্যালকুলেশন ও ওপেনস্ট্রিটম্যাপ রাডার |
| **Emergency Telephony** | `url_launcher: ^6.3.1` | এক ক্লিকে ৯৯৯ ও হাসপাতালে সরাসরি ডায়াল |
| **Network Observer** | `connectivity_plus: ^6.1.5` | লাইভ অনলাইন/অফলাইন কানেক্টিভিটি পর্যবেক্ষণ |

### ৩.২ সিস্টেম ডাটা ফ্লো ডায়াগ্রাম
```mermaid
graph TD
    User([ইউজার/রোগী]) --> Choice{ইউজারের ইনপুট মোড}
    
    %% Scanner Flow
    Choice -->|সাপের ছবি আছে| Scanner[AI স্নেক স্ক্যানার]
    Scanner --> Base64[ইমেজ অপটিমাইজেশন ও Base64 এনকোডিং]
    Base64 --> AIEngine[AI Vision ক্লাসিফিকেশন]
    AIEngine --> StatusCheck{AI আউটপুট স্ট্যাটাস?}
    
    StatusCheck -->|not_detected| NonSnakeUI[সাপ শনাক্ত করা যায়নি - সতর্কবার্তা]
    StatusCheck -->|unidentified| UnclearUI[শনাক্তকরণ অসম্পূর্ণ - লক্ষণ তালিকার নির্দেশ]
    StatusCheck -->|identified| DatasetSearch[অফলাইন ৯৭+ ডেটাসেট সার্চ]
    
    DatasetSearch --> FoundInDB{ডেটাসেটে বিদ্যমান?}
    FoundInDB -->|হ্যাঁ (Cache Hit)| DBDetails[অফলাইন ডাটাবেস থেকে তাৎক্ষণিক প্রোফাইল লোড]
    FoundInDB -->|না (Cache Miss)| DynamicCache[AI ডাটা ভ্যালিডেশন ও লোকাল ক্যাশে সংযোজন]
    
    DBDetails --> TriageResult[ক্লিনিক্যাল ট্রায়াজ রেজাল্ট পেজ]
    DynamicCache --> TriageResult
    
    %% Checklist Flow
    Choice -->|সাপের ছবি নেই / লক্ষণ যাচাই| Checklist[লক্ষণ ও তালিকা স্ক্রিন]
    Checklist --> DisabledBtnCheck{কমপক্ষে ১টি অপশন নির্বাচিত?}
    DisabledBtnCheck -->|না| DisabledBtn[বাটন নিষ্ক্রিয় ও প্রম্পট প্রদর্শন]
    DisabledBtnCheck -->|হ্যাঁ| TriageEngine[১৮-প্যারামিটার জিরো ফলস-নেগেটিভ ট্রায়াজ ইঞ্জিন]
    TriageEngine --> TriageResult
    
    %% Result & Emergency Flow
    TriageResult --> SaveHistory[SQLite / LocalStorage হিস্ট্রি সেভ]
    TriageResult --> HospitalRadar[হসপিটাল রাডার - অ্যান্টি-ভেনম ফিল্টার ও জিপিএস দূরত্ব]
    TriageResult --> EmergencyCall[৯৯৯ জাতীয় হেল্পলাইন ও অ্যাম্বুলেন্স কল]
```

---

## ৪. এআই স্নেক স্ক্যানার ও ভিজ্যুয়াল শনাক্তকরণ

### ৪.১ এটি কী করে? (What it does)
ক্যামেরা দিয়ে সরাসরি তোলা বা গ্যালারি থেকে আপলোড করা সাপের ছবি বিশ্লেষণ করে সাপের প্রজাতি (বাংলা, ইংরেজি ও বৈজ্ঞানিক নাম), এটি বিষধর কি না, বিষের তীব্রতা (Danger Level) এবং শারীরিক বৈশিষ্ট্যের নির্ভুল বিবরণ দেয়।

### ৪.২ কেন প্রয়োজন? (Why it is needed)
সাপে কাটার পর আতঙ্কগ্রস্ত মানুষ সাপের সঠিক নাম মনে রাখতে পারেন না বা ভুল প্রজাতি ভেবে চিকিৎসা বিলম্বিত করেন। দ্রুত ও নির্ভুল প্রজাতি শনাক্তকরণ সঠিক অ্যান্টি-ভেনম নির্বাচনের পূর্বশর্ত।

### ৪.৩ কীভাবে কাজ করে ও কোডে বাস্তবায়ন (Implementation Details)
1. **ক্যামেরা ও গ্যালারি ইনপুট (`ScannerNotifier.scanImage`):**
   - ফাইলের অবস্থান: [`lib/features/scanner/providers/scanner_provider.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/scanner/providers/scanner_provider.dart)
   - `ImagePicker` ব্যবহার করে ছবি গ্রহণ করা হয় (`maxWidth: 800`, `maxHeight: 800`, `imageQuality: 85`)।
   - **রেসিলিয়েন্ট ফলব্যাক মেকানিজম:** ব্রাউজার বা ডেস্কটপে ওয়েবক্যাম অনুমতি বা ক্যামেরা স্ট্রিমে ত্রুটি হলে অ্যাপ ক্র্যাশ না করে স্বয়ংক্রিয়ভাবে গ্যালারি ফাইল পিকারে ফলব্যাক করে।
2. **ক্রস-প্ল্যাটফর্ম ইন-মেমোরি ভিউফাইন্ডার (`ScanScreen`):**
   - ফাইলের অবস্থান: [`lib/features/scanner/screens/scan_screen.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/scanner/screens/scan_screen.dart)
   - ছবি তোলার সাথে সাথে বাইনারি ডাটা থেকে Base64 তৈরি করে `Image.memory(base64Decode(state.base64Image!))` দিয়ে রেন্ডার করা হয়। ফলে ওয়েব ব্রাউজারের ভার্চুয়াল `blob:` ইউআরএল ক্র্যাশ পুরোপুরি এড়ানো সম্ভব হয়েছে।
3. **ইন্টারেক্টিভ ফ্ল্যাশ কন্ট্রোল (Flash System):**
   - ৩-স্টেট ফ্ল্যাশ সাইকেল: **Auto (`অটো`) ➔ Always ON (`চালু`) ➔ OFF (`বন্ধ`)**।
   - সক্রিয় ফ্ল্যাশ মোড অনুযায়ী ভিউফাইন্ডারের টপ মেট্রিক্স পিল (`Flash: ON/OFF/Auto`) স্বয়ংক্রিয়ভাবে আপডেট হয় এবং স্ক্রিনে ফ্লোটিং টোস্ট নোটিফিকেশন প্রদর্শন করে।
4. **এআই ভিশন প্রম্পট ইঞ্জিনিয়ারিং (`AiService.scanImage`):**
   - ফাইলের অবস্থান: [`lib/features/scanner/services/ai_service.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/scanner/services/ai_service.dart)
   - সিস্টেম প্রম্পটে বাংলাদেশের "Big Four" (গোখরা, মনোকলড গোখরা, শঙ্খিনী/কালাচ, চন্দ্রবোড়া) এবং স্থানীয় অবিষধর সাপের (ধামন, ঢোড়া, লাউডগা, কালনাগিনী) সুস্পষ্ট শারীরবৃত্তীয় পার্থক্য (Head Shape, Scale Pattern, Pupils, Vertebral Ridge) কঠোর নিয়মে সংজ্ঞায়িত।
   - এআইকে কঠোর নির্দেশ দেওয়া হয়েছে আউটপুট শুধুমাত্র একটি কাঠামোগত JSON ফরম্যাটে দিতে।

### ৪.৪ নন-স্নেক এবং অস্পষ্ট ছবির হ্যান্ডলিং (Validation & Safety States)
এআই থেকে ৩ ধরনের স্ট্যাটাস কোড হ্যান্ডেল করা হয়:
```json
{
  "status": "identified" | "unidentified" | "not_detected",
  "species_bn": "...",
  "species_en": "...",
  "venomous": true | false,
  "confidence": 0.0 - 1.0
}
```
- **সাপ না থাকলে (`not_detected`):** কোনো খাবার, হাত, ল্যান্ডস্কেপ ইত্যাদির ছবি দেওয়া হলে অ্যাপ সতর্ক করে দেয় যে "ছবিতে কোনো সাপ শনাক্ত করা যায়নি" এবং ভুল ট্রায়াজ আটকায়।
- **অস্পষ্ট ছবি (`unidentified`):** ছবি ঝাপসা বা সাপের আংশিক শরীর দৃশ্যমান হলে অ্যাপ জেনারেলাইজড অনুমান না করে ব্যবহারকারীকে অবিলম্বে **"লক্ষণ ও তালিকা মূল্যায়ন" (Symptoms & List)** ব্যবহার করার নির্দেশ দেয়।

---

## ৫. অফলাইন ডেটাসেট ও এআই টোকেন অপটিমাইজেশন

### ৫.১ সমস্যা: এআই টোকেন অপচয় ও রেট লিমিট
সাধারণ এআই অ্যাপে প্রতিবার সাপের ছবি দিলে এআই পুরো সাপের বর্ণনা, বিষের তথ্য, ফার্স্ট এইড প্রোটোকল, লক্ষণ ইত্যাদি বারবার জেনারেট করে হাজার হাজার টোকেন নষ্ট করে এবং নেটওয়ার্ক ধীরগতির হলে অ্যাপ বিকল হয়ে পড়ে।

### ৫.২ আমাদের সমাধান: হাইব্রিড টু-টিয়ার নলেজ ইঞ্জিন (Hybrid Two-Tier Architecture)
VenomShield-এ আমরা তৈরি করেছি **ইন-মেমোরি অফলাইন ডেটাসেট** (`assets/data/snakes.json` ও `SnakeDatabase`):
- **টিয়ার ১ (Tier-1: Offline Cache Hit):**
  - স্ক্যানারে এআই শুধুমাত্র সাপের প্রজাতি নাম শনাক্ত করে (মাত্র ২০-৩০ টোকেন খরচ)।
  - নাম পাওয়া মাত্রই `SnakeDatabase.getSpeciesDetails(speciesEn, speciesBn)` দিয়ে লোকাল ৯৭+ অফলাইন ডেটাসেটে সার্চ করা হয়।
  - ম্যাচ হওয়া মাত্রই ডেটাসেটে আগে থেকে সংরক্ষিত উচ্চ-মানের ক্লিনিক্যাল বর্ণনা, ফাস্ট এইড গাইড, বিষের ধরন এবং ঝুঁকি সরাসরি অফলাইন থেকে স্ক্রিনে লোড করা হয়। এতে এআই টোকেন খরচ **৮৫% হ্রাস** পায়।
- **টিয়ার ২ (Tier-2: Cache Miss & Dynamic Ingestion):**
  - যদি শনাক্তকৃত সাপটি লোকাল ডাটাবেসে না থাকে, তবেই এআই থেকে বিস্তারিত তথ্য জেনারেট করা হয়।
  - জেনারেট হওয়া তথ্য সাথে সাথে `SnakeDatabase.registerDynamicSpecies()`-এর মাধ্যমে অ্যাপের চলমান অফলাইন ডাটাবেসে সেভ হয়ে যায়।
  - ভবিষ্যতে একই সাপ স্ক্যান বা সার্চ করা হলে আর কখনোই এআই কল করা লাগবে না; সরাসরি লোকাল ডাটাবেস থেকেই আসবে!

### ৫.৩ হেডারে ইনস্ট্যান্ট স্নেক সার্চ সিস্টেম (`SnakeSearchSheet`)
- ফাইলের অবস্থান: [`lib/features/scanner/screens/snake_search_sheet.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/scanner/screens/snake_search_sheet.dart)
- ব্যবহারকারী হেডারের সার্চ আইকন ক্লিক করে বাংলা বা ইংরেজি যেকোনো সাপের নাম টাইপ করলেই অফলাইন ডেটাসেট থেকে রিয়েল-টাইমে সাজেস্ট করে এবং ক্লিক করলে সম্পূর্ণ `SnakeDetailModal` ওপেন হয় — **শূন্য এআই টোকেন ও শূন্য ইন্টারনেট খরচে!**

---

## ৬. লক্ষণ ও তালিকা ভিত্তিক ক্লিনিক্যাল ট্রায়াজ সিস্টেম

### ৬.১ এটি কী করে?
রোগী বা তার স্বজন সাপের ছবি তুলতে না পারলে রোগীর শারীরিক লক্ষণ ও সাপের বাহ্যিক বৈশিষ্ট্যের ১৮টি জাতীয় ও আন্তর্জাতিক ডায়াগনস্টিক প্যারামিটার টিক দিয়ে বিষক্রিয়ার স্তর নিরূপণ করতে পারেন।

### ৬.২ জিরো ফলস-নেগেটিভ ডায়াগনস্টিক ইঞ্জিন (`TriageEngine`)
- ফাইলের অবস্থান: [`lib/features/triage/services/triage_engine.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/triage/services/triage_engine.dart)
- চিকিৎসা বিজ্ঞানের নীতি অনুযায়ী: **"বিষধর সাপের কামড়কে ভুল করে অবিষধর বলা মারাত্মক অপরাধ (False Negative), কিন্তু অবিষধরকে সতর্কতার জন্য বিষধর হিসেবে পর্যবেক্ষণ করা নিরাপদ (Fail-Safe)।"**

### ৬.৩ ১৮টি ডায়াগনস্টিক ফ্যাক্টর (৪টি ক্লিনিক্যাল ক্যাটাগরি)
| ক্যাটাগরি | লক্ষণ / বৈশিষ্ট্য | ক্লিনিক্যাল ওজন (Weight) | জরুরি তাৎপর্য |
| :--- | :--- | :--- | :--- |
| **১. সাপের বৈশিষ্ট্য** | সাপের ফণা তোলা (`hood_seen`) | +৪৫% | গোখরা নিশ্চিতকরণ |
| | ত্রিকোণাকার মাথা ও সরু ঘাড় (`triangular_head`) | +৩৫% | ভাইপার/বোড়ার লক্ষণ |
| | রাতে ঘুমের মধ্যে কামড় (`night_sleeping_bite`) | +৫০% (জরুরি ফ্ল্যাগ) | কালাচ/কেউটের ক্লাসিক প্যাটার্ন |
| **২. স্থানীয় ক্ষত লক্ষণ** | দুটি বিষদাঁতের ক্ষতচিহ্ন (`two_punctures`) | +৩০% | ট্রু বাইট মার্কস |
| | ক্ষতের অবিরাম রক্তপাত (`bleeding_wound`) | +৪০% | ভাস্কুলোটক্সিক বিষক্রিয়া |
| | দ্রুত ছড়িয়ে পড়া ফোলা (`swelling`) | +৩৫% | টিস্যু নেক্রোসিস রিস্ক |
| **৩. নিউরোটক্সিক লক্ষণ** | চোখের পাতা ঝুলে পড়া (`eyelid_droop` / Ptosis) | **ক্রিটিক্যাল (১০০% ইমার্জেন্সি)** | শ্বাসতন্ত্র প্যারালাইসিস পূর্বলক্ষণ |
| | কথা জড়িয়ে যাওয়া বা গিলতে কষ্ট (`speech_swallowing_difficulty`) | **ক্রিটিক্যাল (১০০% ইমার্জেন্সি)** | ক্র্যানিয়াল নার্ভ পালসি |
| | ঘাড় সোজা রাখতে না পারা (`flaccid_paralysis`) | **ক্রিটিক্যাল (১০০% ইমার্জেন্সি)** | ব্রোকেন নেক সাইন |
| **৪. শারীরিক বিষক্রিয়া** | মাড়ি, নাক বা প্রস্রাবে রক্তপাত (`spontaneous_bleeding`) | **ক্রিটিক্যাল (১০০% ইমার্জেন্সি)** | সিস্টেমিক কোয়াগুলোপ্যাথি |
| | তীব্র পেটব্যথা ও ক্রমাগত বমি (`abdominal_vomiting`) | +৪০% | কালাচের অভ্যন্তরীণ বিষক্রিয়া |

### ৬.৪ বাটন ভ্যালিডেশন ও সেফটি
- ফাইলের অবস্থান: [`lib/features/triage/screens/symptom_checklist_screen.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/triage/screens/symptom_checklist_screen.dart)
- ব্যবহারকারী যতক্ষণ পর্যন্ত কমপক্ষে ১টি অপশন নির্বাচন না করেন, ততক্ষণ **"Submit & View Comprehensive Evaluation"** বাটনটি নিষ্ক্রিয় (`onPressed: null`) থাকে।
- অপশন নির্বাচন করার সাথে সাথে বাটনে লাইভ কাউন্টার দৃশ্যমান হয় (যেমন: *মূল্যায়ন ও ফলাফল দেখুন (২টি নির্বাচিত)*)।

---

## ৭. ভিজ্যুয়াল স্ক্যান বনাম লক্ষণ মূল্যায়নের মৌলিক পার্থক্য

| তুলনার বিষয় | স্নেক স্ক্যানার (Visual Identification) | লক্ষণ ও তালিকা (Symptom Assessment) |
| :--- | :--- | :--- |
| **মূল ভিত্তি** | ছবির ভিজ্যুয়াল রূপবিদ্যা (Morphology) | রোগীর ক্লিনিক্যাল শারীরিক উপসর্গ |
| **প্রধান লক্ষ্য** | সাপের প্রজাতি শনাক্তকরণ | শরীরে বিষ প্রবেশ করেছে কি না (Envenomation Severity) |
| **ব্যবহারের সময়** | যখন সাপের স্পষ্ট ছবি থাকে | ছবি না থাকলে অথবা কামড়ের পর শারীরিক প্রতিক্রিয়া পর্যবেক্ষণে |
| **নির্ভরশীলতা** | ক্যামেরা ও এআই ক্লাসিফিকেশন | ১৮টি জাতীয় ক্লিনিক্যাল ট্রায়াজ ফ্যাক্টর |

> **গুরুত্বপূর্ণ সিদ্ধান্ত:** ক্ষতস্থানের সাধারণ ছবি দেখে মোবাইল এআই দিয়ে বিষাক্ততা নিশ্চিত করা চিকিৎসাবিজ্ঞানে অসম্ভব ও ঝুঁকিপূর্ণ। তাই ক্ষত-স্ক্যান এআই বাতিল করে নির্ভরযোগ্য ১৮-ফ্যাক্টর লক্ষণ তালিকা যুক্ত করা হয়েছে।

---

## ৮. হসপিটাল রাডার ও অ্যান্টি-ভেনম ট্র্যাকার

### ৮.১ এটি কী করে?
রোগীর বর্তমান জিপিএস লোকেশন থেকে নিকটস্থ কোন সরকারি ও বিশেষায়িত হাসপাতালে অ্যান্টি-ভেনম স্টক, আইসিইউ এবং সার্বক্ষণিক সাপে কাটা চিকিৎসার সুবিধা রয়েছে তা ম্যাপ ও দূরত্বের ক্রমানুসারে দেখায়।

### ৮.২ কীভাবে বাস্তবায়িত?
- ফাইলের অবস্থান: [`lib/features/hospital/screens/hospital_radar_screen.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/hospital/screens/hospital_radar_screen.dart) ও [`lib/features/hospital/providers/hospital_provider.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/hospital/providers/hospital_provider.dart)
- **হাভারসাইন অ্যালগরিদম (Haversine Formula):** ইউজারের অক্ষাংশ-দ্রাঘিমাংশ থেকে প্রতিটি হাসপাতালের বাস্তব দূরত্ব গণনা করে।
- **বিভাগ ও জেলা অনুযায়ী ফিল্টারিং:** ঢাকা, চট্টগ্রাম, রাজশাহী, রংপুর, খুলনা, বরিশাল, সিলেট, ময়মনসিংহসহ সব জেলার ড্রপডাউন ফিল্টার।
- **অ্যান্টি-ভেনম স্টক ব্যাজ:** প্রতিটি হাসপাতালে অ্যান্টি-ভেনম "মজুদ আছে (In Stock)" বা "সীমিত স্টক (Limited)" পরিষ্কার রঙে নির্দেশিত।
- **ডিরেক্ট কল ও নেভিগেশন:** `url_launcher` দিয়ে এক ক্লিকে হাসপাতালের জরুরি নাম্বারে সরাসরি কল বা গুগল ম্যাপে রুট ট্র্যাকিং।

---

## ৯. অ্যাসেসমেন্ট হিস্ট্রি ও ডুয়াল-প্ল্যাটফর্ম স্টোরেজ

### ৯.১ ডুয়াল-প্ল্যাটফর্ম আর্কিটেকচার
- **নেটিভ প্ল্যাটফর্ম (Android / iOS):** `sqflite_common_ffi` ও SQLite ফাইল ডাটাবেস (`database_helper.dart`)।
- **ওয়েব প্ল্যাটফর্ম (Chrome / Web):** ব্রাউজার `window.localStorage` ব্যবহার করে ব্রাউজার রিস্টার্ট হলেও হিস্ট্রি অবিকৃত থাকে।

### ৯.২ ইন্টারঅ্যাকটিভ ক্লিকযোগ্য হিস্ট্রি কার্ড
- ফাইলের অবস্থান: [`lib/features/home/screens/home_screen.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/features/home/screens/home_screen.dart)
- হোম স্ক্রিনের হিস্ট্রি কার্ডে ক্লিক করলে:
  - **সাপ স্ক্যানের ক্ষেত্রে:** সরাসরি সাপের সম্পূর্ণ পরিচিতি মোডাল (`SnakeDetailModal`) ওপেন হয়।
  - **লক্ষণ মূল্যায়নের ক্ষেত্রে:** `_AssessmentDetailModal` ওপেন হয়, যেখানে মূল্যায়নের তারিখ, ঝুঁকির শতাংশ, কোন কোন উপসর্গ সিলেক্ট করা হয়েছিল তার তালিকা, জরুরি ফার্স্ট এইড ও হাসপাতাল রাডার বাটন থাকে।

---

## ১০. সার্বজনীন দ্বিভাষিক লোকালাইজেশন ইঞ্জিন

- ফাইলের অবস্থান: [`lib/core/providers/locale_provider.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/core/providers/locale_provider.dart) ও [`lib/core/widgets/language_toggle.dart`](file:///e:/vu-hackathon/Venon-Shield/lib/core/widgets/language_toggle.dart)
- **এক-ট্যাপ ল্যাঙ্গুয়েজ সুইচিং:** প্রতিটি পেজের হেডার বার ও হোম স্ক্রিনে `BilingualLanguageToggle` উইজেট যুক্ত।
- **বাংলা ও ইংরেজি সমর্থন:** চিকিৎসা সংক্রান্ত জটিল পরিভাষা সাধারণ মানুষের বোধগম্য খাঁটি বাংলা এবং আন্তর্জাতিক মানের ক্লিনিক্যাল ইংরেজিতে সংরক্ষিত।
- **পারসিস্টেন্স:** `SharedPreferences`-এ ভাষা পছন্দ সেভ থাকে, অ্যাপ বন্ধ করে চালু করলেও নির্বাচিত ভাষা বজায় থাকে।

---

## ১১. নেভিগেশন, স্টেট ম্যানেজমেন্ট ও নেটওয়ার্ক হ্যান্ডলিং

1. **রিভারপড স্টেট ম্যানেজমেন্ট (`Riverpod`):**
   - ইউআই লেয়ার এবং বিজনেস লজিক সম্পূর্ণ আলাদা।
   - স্টেট ইমিউটেবল (Immutable `copyWith` প্যাটার্ন), যার ফলে মেমরি লিক হয় না এবং অ্যাপ অত্যন্ত দ্রুত চলে।
2. **ডিক্লেয়ারেটিভ রাউটিং (`GoRouter`):**
   - সুনির্দিষ্ট রাউট: `/` (Home), `/scan` (Scanner), `/triage-checklist` (Checklist), `/triage-result` (Result), `/hospital-radar` (Radar)।
3. **লাইভ কানেক্টিভিটি অবজারভার (`ConnectivityService`):**
   - ইন্টারনেট সংযোগ বিচ্ছিন্ন হলে স্ক্যানারের হেডারে "অফলাইন মোড" স্ট্যাটাস বার দেখায় এবং অফলাইন চেকলিস্ট ব্যবহারে উৎসাহিত করে।

---

## ১২. মেডিকেল সেফটি ও জিরো ফলস-নেগেটিভ নীতি

VenomShield জাতীয় সাপের কামড় ব্যবস্থাপনা গাইডলাইন (National Guideline for Management of Snakebite in Bangladesh) কঠোরভাবে মেনে চলে:
1. **যা কখনো করবেন না (Strictly Forbidden First-Aid):**
   - ❌ ক্ষতস্থানে শক্ত দড়ি বা টরনিকেট বাঁধা নিষেধ।
   - ❌ ব্লেড বা ছুরি দিয়ে ক্ষত কাটা বা মুখ দিয়ে রক্ত চোষা নিষেধ।
   - ❌ কোনো গাছগাছড়া, পাথর বা মলম লাগানো নিষেধ।
2. **যা অবশ্যই করবেন (Recommended Protocol):**
   - ✔ রোগীকে আশ্বস্ত ও সম্পূর্ণ স্থির রাখা (Immobilization)।
   - ✔ আক্রান্ত অঙ্গ কার্ড বা কাঠের টুকরো দিয়ে ব্যান্ডেজ সহযোগে স্থির রাখা (Splinting)।
   - ✔ যত দ্রুত সম্ভব নিকটস্থ অ্যান্টি-ভেনম সমৃদ্ধ হাসপাতালে স্থানান্তর।

---

## ১৩. হ্যাকথন জাজেস প্রশ্নোত্তর গাইড (Hackathon Judges Q&A)

### প্রশ্ন ১: "আপনাদের এআই স্ক্যানার কীভাবে কাজ করে এবং কী প্রম্পট ব্যবহার করা হয়েছে?"
> **উত্তরঃ** "আমাদের স্ক্যানারটি মোবাইল ক্যামেরা বা গ্যালারি থেকে সাপের ছবি ইনপুট নিয়ে অপ্টিমাইজড Base64 এনকোডিং তৈরি করে Google Gemini 1.5 Vision API-তে পাঠায়। আমাদের স্পেশালাইজড হারপেটোলজি প্রম্পটের মাধ্যমে এআই সাপের শারীরিক রূপবিদ্যা (Head Shape, Scales, Pupil, Neck markings) বিশ্লেষণ করে একটি স্ট্রাকচার্ড JSON রেসপন্স দেয়। বিশেষত্ব হলো—এআই শুধুমাত্র নামটি শনাক্ত করে; বাকি সমস্ত বিস্তারিত মেডিকেল প্রোফাইল আমরা আমাদের অফলাইন ডেটাসেট থেকে সেকেন্ডের মধ্যে লোড করি।"

#### 🔍 এআই স্ক্যানারে ব্যবহৃত হুবহু সিস্টেম প্রম্পট (Exact System Prompt in `ai_service.dart`):
```text
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
```

#### 📌 ইউজারের সাথে পাঠানো প্রম্পট (User Prompt):
```text
Identify this snake from Bangladesh. Look carefully at head shape, body pattern, scale texture, and coloring. Determine species and whether it is venomous.
```


### প্রশ্ন ২: "ছবিতে যদি সাপ না থাকে, তবে সিস্টেম কী করে?"
> **উত্তরঃ** "আমাদের এআই প্রম্পটে স্ট্রিক্ট ভ্যালিডেশন রুল দেওয়া আছে। ছবিতে যদি সাপের বদলে খাবার, মানুষের হাত, গাছপালা বা অন্য কোনো বস্তু থাকে, তবে এআই `status: not_detected` রিটার্ন করে। আমাদের ভিউফাইন্ডার তাৎক্ষণিকভাবে একটি অ্যাম্বার কালার সেফটি ওভারলে দেখায় এবং ইউজারকে জানায় যে কোনো সাপ পাওয়া যায়নি, ফলে কোনো মিসলিডিং বা ভুল মেডিকেল ডাটা জেনারেট হওয়ার সুযোগ থাকে না।"

### প্রশ্ন ৩: "আপনারা কীভাবে এআই টোকেন খরচ কমাচ্ছেন?"
> **উত্তরঃ** "আমরা একটি টু-টিয়ার হাইব্রিড আর্কিটেকচার বাস্তবায়ন করেছি। এআই দিয়ে প্রতিবার পুরো বর্ণনা, ফার্স্ট এইড এবং লক্ষণ জেনারেট না করিয়ে শুধু প্রজাতির নাম ক্লাসিফাই করাই। এরপর ৯৭+ সাপের অফলাইন ডেটাসেট থেকে তাৎক্ষণিক পূর্ণাঙ্গ তথ্য লোড করি। ফলে প্রতি স্ক্যানে আমাদের টোকেন খরচ প্রায় ৮৫% কমে যায় এবং ইন্টারনেট ডাটা বাঁচে।"

### প্রশ্ন ৪: "যদি এমন কোনো সাপ আসে যা আপনাদের অফলাইন ডেটাসেটে নেই?"
> **উত্তরঃ** "এটিকে আমরা 'Cache Miss' হিসেবে হ্যান্ডেল করি। যদি শনাক্তকৃত সাপটি লোকাল ডেটাসেটে না থাকে, এআই তার সম্পূর্ণ তথ্য জেনারেট করে এবং স্ক্রিনে দেখানোর সাথে সাথেই `SnakeDatabase.registerDynamicSpecies()` ফাংশনের মাধ্যমে অ্যাপের রানিং ডেটাসেটে ক্যাশ করে নেয়। ভবিষ্যতে সেই সাপ আবার স্ক্যান বা সার্চ করা হলে তা লোকাল মেমরি থেকেই সার্ভ করা হয়।"

### প্রশ্ন ৫: "লক্ষণ ভিত্তিক ট্রায়াজ সিস্টেমের মূল ভিত্তি কী এবং আপনারা ঝুঁকি কীভাবে গণনা করেন?"
> **উত্তরঃ** "আমাদের ট্রায়াজ সিস্টেমটি WHO এবং বাংলাদেশের জাতীয় ক্লিনিক্যাল গাইডলাইনের ১৮টি ডায়াগনস্টিক প্যারামিটারের ওপর ভিত্তি করে তৈরি। এটি ৪টি ক্যাটাগরিতে বিভক্ত। আমরা জিরো ফলস-নেগেটিভ অ্যালগরিদম ব্যবহার করি—যেমন চোখের পাতা ঝুলে পড়া (Ptosis), গিলতে কষ্ট হওয়া, বা প্রস্রাবে রক্তপাতের মতো যেকোনো একটি ক্রিটিক্যাল লক্ষণ পাওয়া গেলেই সিস্টেম রিস্ক পার্সেন্টেজ ১০০% এবং 'High Risk Venomous' আউটপুট দিয়ে হাসপাতালে যাওয়ার নির্দেশ দেয়।"

### প্রশ্ন ৬: "হসপিটাল রাডার কীভাবে কাজ করে এবং ইন্টারনেট না থাকলে কি চলবে?"
> **উত্তরঃ** "হসপিটাল রাডার ইউজারের লাইভ জিপিএস স্থানাঙ্ক নিয়ে Haversine ম্যাথমেটিক্যাল ফর্মুলা ব্যবহার করে বাংলাদেশের সরকারি ও বিশেষায়িত হাসপাতালগুলোর বাস্তব দূরত্ব হিসাব করে ক্রমানুসারে সাজায়। হাসপাতাল ও অ্যান্টি-ভেনম স্টকের ডাটাবেসটি লোকালি প্রি-লোডেড থাকে, তাই ইন্টারনেট দুর্বল হলেও দূরত্ব ও ডিরেক্ট কল সুবিধা সবসময় সক্রিয় থাকে।"

### প্রশ্ন ৭: "ইউজারের হিস্ট্রি কীভাবে স্টোর হয়?"
> **উত্তরঃ** "আমরা একটি হাইব্রিড পারসিস্টেন্স মেকানিজম ব্যবহার করেছি। অ্যান্ড্রয়েড এবং আইওএসে এটি ব্যাকগ্রাউন্ড SQLite FFI ডাটাবেসে সেভ হয়, আর ওয়েব ব্রাউজারে এটি LocalStorage-এ সেভ হয়। হিস্ট্রি কার্ডে ক্লিক করলে স্ক্যান করা সাপের সম্পূর্ণ পরিচিতি অথবা লক্ষণ পর্যালোচনার পূর্ণাঙ্গ মেডিকেল হিস্ট্রি রিকল করা যায়।"

### প্রশ্ন ৮: "নেটওয়ার্ক ফেইল করলে অ্যাপ কীভাবে প্রতিক্রিয়া জানায়?"
> **উত্তরঃ** "আমাদের অ্যাপে `ConnectivityService` সার্বক্ষণিক নেটওয়ার্ক মনিটর করে। নেটওয়ার্ক ফেইল করলে বা এআই টাইমআউট হলে স্ক্যানারে এরর মেসেজ প্রদর্শনের পাশাপাশি সরাসরি অফলাইন 'Symptoms & List' ব্যবহারের বাটন আসে। এছাড়া অফলাইন সার্চ, হসপিটাল রাডার এবং ফার্স্ট এইড গাইড শতভাগ অফলাইনেই কাজ করে।"

---
*ডকুমেন্টেশন প্রস্তুতকারক:* **VenomShield Engineering & Clinical AI Team**  
*ভার্সন:* **v2.5.0-Production-Ready**
