import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/triage_provider.dart';

class TriageResultScreen extends ConsumerWidget {
  const TriageResultScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triageState = ref.watch(triageProvider);
    final result = triageState.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('মূল্যায়ন ফলাফল')),
        body: const Center(
          child: Text('কোনো মূল্যায়নের তথ্য পাওয়া যায়নি। অনুগ্রহ করে পুনরায় চেষ্টা করুন।'),
        ),
      );
    }

    final bool isVenomous = result.venomous;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('জরুরি মূল্যায়ন ফলাফল'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            ref.read(triageProvider.notifier).clear();
            context.go('/');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isVenomous
                      ? [AppColors.danger, const Color(0xFFC62828)]
                      : [AppColors.safe, const Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isVenomous ? AppColors.danger : AppColors.safe).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isVenomous ? Icons.warning_rounded : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isVenomous ? 'বিষধর সাপের কামড়ের লক্ষণ!' : 'বিষহীন / ক্ষতিকর নয়',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVenomous ? 'জরুরি চিকিৎসা প্রয়োজন' : 'আতঙ্কিত হবেন না',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Diagnostic Verdict Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'বিশ্লেষণ রিপোর্ট',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: 20),
                    Text(
                      result.reasonBn,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    if (result.matchedSpeciesBn != null && result.matchedSpeciesBn!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.matchedSpeciesEn != null && result.matchedSpeciesEn!.isNotEmpty
                              ? 'শনাক্তকৃত প্রজাতি: ${result.matchedSpeciesBn} (${result.matchedSpeciesEn})'
                              : 'শনাক্তকৃত প্রজাতি: ${result.matchedSpeciesBn}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // First Aid Steps Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'জরুরি প্রাথমিক চিকিৎসা (করনীয়)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: result.firstAidBn.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                color: isVenomous ? AppColors.accent.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isVenomous ? Icons.warning_amber_rounded : Icons.check,
                                size: 14,
                                color: isVenomous ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                result.firstAidBn[index],
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Action Buttons
            ElevatedButton.icon(
              onPressed: () => context.push('/hospital-radar'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('নিকটস্থ অ্যান্টি-ভেনম হাসপাতাল খুঁজুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(54),
              ),
            ),
            
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _makeCall('999'),
              icon: const Icon(Icons.phone_in_talk, color: AppColors.accent),
              label: const Text('৯৯৯ এ কল করুন (জরুরি সাহায্য)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent, width: 1.5),
                minimumSize: const Size.fromHeight(54),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                ref.read(triageProvider.notifier).clear();
                context.go('/');
              },
              child: const Text(
                'হোমে ফিরে যান',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
