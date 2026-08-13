import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/bite_assessment_provider.dart';

class BiteAssessmentResultScreen extends ConsumerWidget {
  const BiteAssessmentResultScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(biteAssessmentProvider);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ঝুঁকি মূল্যায়ন ফলাফল')),
        body: const Center(
          child: Text('কোনো মূল্যায়নের তথ্য পাওয়া যায়নি। অনুগ্রহ করে পুনরায় চেষ্টা করুন।'),
        ),
      );
    }

    // Determine colors based on risk level
    Color riskColor;
    Color bgGradientStart;
    Color bgGradientEnd;
    bool isUrgent = result.riskLevel == 'উচ্চ ঝুঁকি' || result.riskLevel == 'অত্যন্ত উচ্চ ঝুঁকি';

    switch (result.riskLevel) {
      case 'অত্যন্ত উচ্চ ঝুঁকি':
        riskColor = const Color(0xFFB71C1C);
        bgGradientStart = const Color(0xFFD32F2F);
        bgGradientEnd = const Color(0xFF880E4F);
        break;
      case 'উচ্চ ঝুঁকি':
        riskColor = AppColors.accent;
        bgGradientStart = AppColors.accent;
        bgGradientEnd = const Color(0xFFC62828);
        break;
      case 'মাঝারি ঝুঁকি':
        riskColor = AppColors.warning;
        bgGradientStart = AppColors.warning;
        bgGradientEnd = const Color(0xFFE65100);
        break;
      default:
        riskColor = AppColors.safe;
        bgGradientStart = AppColors.safe;
        bgGradientEnd = const Color(0xFF1B5E20);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ঝুঁকি মূল্যায়ন ফলাফল'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            ref.read(biteAssessmentProvider.notifier).clear();
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
                  colors: [bgGradientStart, bgGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: riskColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isUrgent ? Icons.warning_rounded : Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${result.riskPercentage.toStringAsFixed(0)}% — ${result.riskLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.riskDescription,
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

            // Urgent Banner Alert
            if (isUrgent) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  border: Border.all(color: const Color(0xFFEF9A9A), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFC62828), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'অবিলম্বে চিকিৎসা নিন',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Diagnostic Reasons/Observations
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'লক্ষণ ও পর্যবেক্ষণ রিপোর্ট',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: 20),
                    if (result.observedReasons.isEmpty)
                      const Text(
                        'কোনো লক্ষণ চিহ্নিত করা হয়নি।',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: result.observedReasons.length,
                        separatorBuilder: (context, idx) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  result.observedReasons[index],
                                  style: const TextStyle(
                                    fontSize: 13,
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
            const SizedBox(height: 16),

            // Safety Protocols & Restrictions (নিষেধসমূহ)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'জরুরি নির্দেশনা ও সুরক্ষাবিধি',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: result.warningMessages.length,
                      separatorBuilder: (context, idx) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final msg = result.warningMessages[index];
                        final isAlert = msg.contains('ওঝা') || msg.contains('কেটে') || msg.contains('বাঁধুন');
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isAlert ? Icons.cancel_outlined : Icons.check_circle_outline,
                              size: 16,
                              color: isAlert ? AppColors.accent : AppColors.safe,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                msg,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isAlert ? AppColors.accent : AppColors.textPrimary,
                                  fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
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

            // Emergency Action Buttons
            ElevatedButton.icon(
              onPressed: () => context.push('/hospital-radar'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('নিকটস্থ অ্যান্টি-ভেনম হাসপাতাল খুঁজুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                ref.read(biteAssessmentProvider.notifier).clear();
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
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
