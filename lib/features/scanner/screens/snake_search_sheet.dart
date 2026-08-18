import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../services/snake_database.dart';

class SnakeSearchSheet extends ConsumerStatefulWidget {
  const SnakeSearchSheet({super.key});

  @override
  ConsumerState<SnakeSearchSheet> createState() => _SnakeSearchSheetState();
}

class _SnakeSearchSheetState extends ConsumerState<SnakeSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all'; // 'all', 'venomous', 'non_venomous', 'native'
  List<SnakeSpecies> _allSpecies = [];
  List<SnakeSpecies> _filteredSpecies = [];

  @override
  void initState() {
    super.initState();
    _allSpecies = SnakeDatabase.getAllSpecies();
    _filteredSpecies = _allSpecies;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSpecies = _allSpecies.where((s) {
        // Filter by category chip
        if (_filter == 'venomous' && !s.venomous) return false;
        if (_filter == 'non_venomous' && s.venomous) return false;
        if (_filter == 'native' && !s.isBangladeshNative) return false;

        if (query.isEmpty) return true;

        // Match English name or scientific name
        if (s.speciesEn.toLowerCase().contains(query) ||
            s.scientificName.toLowerCase().contains(query)) {
          return true;
        }

        // Match Bengali name
        if (s.speciesBn.toLowerCase().contains(query)) {
          return true;
        }

        // Match English aliases
        for (var kw in s.englishKeywords) {
          if (kw.toLowerCase().contains(query)) return true;
        }

        // Match Bengali aliases
        for (var kw in s.banglaKeywords) {
          if (kw.toLowerCase().contains(query)) return true;
        }

        return false;
      }).toList();
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
    });
    _onSearchChanged();
  }

  void _showSnakeDetails(BuildContext context, SnakeSpecies snake, AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SnakeDetailModal(snake: snake, lang: lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      lang.t('সাপের তথ্য অনুসন্ধান', 'Search Snake Database'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: lang.t('সাপের নাম লিখুন (যেমন: গোখরা, রাসেলস ভাইপার, Cobra)...', 'Enter snake name (e.g. Cobra, Viper, Python)...'),
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', lang.t('সকল সাপ', 'All Species (${_allSpecies.length})')),
                const SizedBox(width: 8),
                _buildFilterChip('venomous', lang.t('বিষধর', 'Venomous')),
                const SizedBox(width: 8),
                _buildFilterChip('non_venomous', lang.t('অবিষধর', 'Non-Venomous')),
                const SizedBox(width: 8),
                _buildFilterChip('native', lang.t('বাংলাদেশের সাপ', 'Bangladesh Native')),
              ],
            ),
          ),

          const Divider(height: 16, color: AppColors.outlineVariant),

          // Results List
          Expanded(
            child: _filteredSpecies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.outline),
                        const SizedBox(height: 12),
                        Text(
                          lang.t('কোনো সাপ খুঁজে পাওয়া যায়নি।', 'No snake species found.'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang.t('অন্য কোনো নাম বা বানান দিয়ে অনুসন্ধান করুন।', 'Try searching with another name or spelling.'),
                          style: const TextStyle(fontSize: 12, color: AppColors.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredSpecies.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final snake = _filteredSpecies[index];
                      return _buildSnakeCard(snake, lang);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => _setFilter(key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSnakeCard(SnakeSpecies snake, AppLanguage lang) {
    final isVenomous = snake.venomous;
    final displayName = lang.isBengali ? (snake.speciesBn.isNotEmpty ? snake.speciesBn : snake.speciesEn) : snake.speciesEn;
    final subName = lang.isBengali ? snake.speciesEn : snake.speciesBn;

    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isVenomous ? AppColors.error.withOpacity(0.25) : AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showSnakeDetails(context, snake, lang),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Badge icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isVenomous ? AppColors.errorContainer : AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVenomous ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                  color: isVenomous ? AppColors.error : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Names and taxonomy
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (subName.isNotEmpty && subName != displayName) ...[
                      const SizedBox(height: 2),
                      Text(
                        subName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      snake.scientificName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVenomous ? AppColors.errorContainer : AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isVenomous ? lang.t('বিষধর', 'Venomous') : lang.t('অবিষধর', 'Non-Venomous'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isVenomous ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  if (snake.isBangladeshNative) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lang.t('বাংলাদেশ', 'BD Native'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnakeDetailModal extends StatelessWidget {
  final SnakeSpecies snake;
  final AppLanguage lang;

  const _SnakeDetailModal({required this.snake, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isVenomous = snake.venomous;
    final displayName = lang.isBengali ? (snake.speciesBn.isNotEmpty ? snake.speciesBn : snake.speciesEn) : snake.speciesEn;
    final subName = lang.isBengali ? snake.speciesEn : snake.speciesBn;

    final description = lang.isBengali
        ? (snake.descriptionBn.isNotEmpty ? snake.descriptionBn : snake.descriptionEn)
        : (snake.descriptionEn.isNotEmpty ? snake.descriptionEn : snake.descriptionBn);

    final biteEffects = lang.isBengali
        ? (snake.biteEffectsBn.isNotEmpty ? snake.biteEffectsBn : snake.biteEffectsEn)
        : (snake.biteEffectsEn.isNotEmpty ? snake.biteEffectsEn : snake.biteEffectsBn);

    final symptoms = lang.isBengali
        ? (snake.symptomsBn.isNotEmpty ? snake.symptomsBn : snake.symptomsEn)
        : (snake.symptomsEn.isNotEmpty ? snake.symptomsEn : snake.symptomsBn);

    final progression = lang.isBengali
        ? (snake.progressionBn.isNotEmpty ? snake.progressionBn : snake.progressionEn)
        : (snake.progressionEn.isNotEmpty ? snake.progressionEn : snake.progressionBn);

    final fatality = lang.isBengali
        ? (snake.fatalityBn.isNotEmpty ? snake.fatalityBn : snake.fatalityEn)
        : (snake.fatalityEn.isNotEmpty ? snake.fatalityEn : snake.fatalityBn);

    final actions = lang.isBengali
        ? (snake.actionsBn.isNotEmpty ? snake.actionsBn : snake.actionsEn)
        : (snake.actionsEn.isNotEmpty ? snake.actionsEn : snake.actionsBn);

    final emergency = lang.isBengali
        ? (snake.emergencyBn.isNotEmpty ? snake.emergencyBn : snake.emergencyEn)
        : (snake.emergencyEn.isNotEmpty ? snake.emergencyEn : snake.emergencyBn);

    final firstAidSteps = lang.isBengali
        ? (snake.firstAidBn.isNotEmpty ? snake.firstAidBn : snake.firstAidEn)
        : (snake.firstAidEn.isNotEmpty ? snake.firstAidEn : snake.firstAidBn);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Modal Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (subName.isNotEmpty && subName != displayName)
                        Text(
                          subName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        snake.scientificName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.outlineVariant),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status & Toxicity Badge Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isVenomous ? AppColors.errorContainer.withOpacity(0.2) : AppColors.primaryFixed.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isVenomous ? AppColors.error.withOpacity(0.35) : AppColors.primary.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isVenomous ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: isVenomous ? AppColors.error : AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isVenomous
                                    ? lang.t('বিষধর প্রজাতি (মারাত্মক ঝুঁকি)', 'Venomous Species (High Danger)')
                                    : lang.t('অবিষধর প্রজাতি (নিরাপদ)', 'Non-Venomous Species (Harmless)'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isVenomous ? AppColors.error : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${lang.t("আবাসস্থল", "Region")}: ${snake.region} | ${snake.isBangladeshNative ? lang.t("বাংলাদেশে প্রাপ্ত", "Native to BD") : lang.t("আন্তর্জাতিক", "Global")}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Species Description Card
                  if (description.isNotEmpty) ...[
                    _buildSectionCard(
                      title: lang.t('শারীরিক বিবরণ ও বৈশিষ্ট্য', 'Physical Description & Appearance'),
                      icon: Icons.info_outline,
                      content: description,
                      isVenomous: false,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Bite Effects Card
                  if (biteEffects.isNotEmpty) ...[
                    _buildSectionCard(
                      title: lang.t('বিষক্রিয়া ও কামড়ের প্রভাব', 'Venom Toxicity & Bite Effects'),
                      icon: Icons.science_outlined,
                      content: biteEffects,
                      isVenomous: isVenomous,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Symptoms Card
                  if (symptoms.isNotEmpty) ...[
                    _buildSectionCard(
                      title: lang.t('সম্ভাব্য উপসর্গ ও লক্ষণসমূহ', 'Bite Symptoms'),
                      icon: Icons.healing,
                      content: symptoms,
                      isVenomous: isVenomous,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Progression Card
                  if (progression.isNotEmpty) ...[
                    _buildSectionCard(
                      title: lang.t('সময়ানুযায়ী লক্ষণ বৃদ্ধি', 'Symptom Progression Timeline'),
                      icon: Icons.timeline,
                      content: progression,
                      isVenomous: isVenomous,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Fatality & Severity Card
                  if (fatality.isNotEmpty) ...[
                    _buildSectionCard(
                      title: lang.t('প্রাণহানির ঝুঁকি ও তীব্রতা', 'Fatality & Clinical Severity'),
                      icon: Icons.crisis_alert,
                      content: fatality,
                      isVenomous: isVenomous,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Step-by-Step First Aid Card
                  if (firstAidSteps.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                lang.t('জরুরি প্রাথমিক চিকিৎসা ধাপসমূহ', 'Step-by-Step First Aid'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...firstAidSteps.map((step) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4, right: 8),
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Immediate Action & Emergency Guidance
                  if (actions.isNotEmpty || emergency.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isVenomous ? AppColors.errorContainer.withOpacity(0.12) : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isVenomous ? AppColors.error.withOpacity(0.3) : AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_hospital_outlined,
                                color: isVenomous ? AppColors.error : AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                lang.t('জরুরি করণীয় ও হাসপাতাল নির্দেশনা', 'Immediate Actions & Emergency Hospitalization'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isVenomous ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (actions.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              actions,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                          if (emergency.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              emergency,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isVenomous ? FontWeight.w600 : FontWeight.normal,
                                color: isVenomous ? AppColors.error : AppColors.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    required bool isVenomous,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isVenomous ? AppColors.error : AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isVenomous ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
