import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.bgPrimary,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return _FaqItem(faq: faq)
              .animate()
              .fadeIn(delay: (100 + index * 50).ms)
              .slideY(begin: 0.2, end: 0);
        },
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final FaqItem faq;

  const _FaqItem({required this.faq});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.faq.icon,
                      color: AppColors.accentPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.faq.question,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _expanded ? 'Tap to collapse' : 'Tap to expand',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.faq.answer
                    .split('\n')
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          line,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;
  final IconData icon;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}

final List<FaqItem> _faqs = [
  const FaqItem(
    question: 'How does the streak work?',
    answer:
        'Your streak increases by 1 for each consecutive day you complete at least one lesson. If you miss a day, your streak resets to 1. The streak uses your local calendar day, so it\'s based on your timezone.',
    icon: Icons.local_fire_department_rounded,
  ),
  const FaqItem(
    question: 'How do I earn XP?',
    answer:
        'You earn XP by completing lessons (25 XP each) and daily challenges (up to 50 XP). XP determines your level - each level requires more total XP to reach.',
    icon: Icons.bolt_rounded,
  ),
  const FaqItem(
    question: 'Can I use the app offline?',
    answer:
        'Yes! You can download lessons for offline access. Tap the download icon on any lesson to save it. Downloaded lessons appear in the Downloads section of your profile.',
    icon: Icons.download_rounded,
  ),
  const FaqItem(
    question: 'How do bookmarks work?',
    answer:
        'Tap the bookmark icon on any lesson to save it for later. Your bookmarked lessons appear in the "Saved Lessons" section of your profile. You can remove them anytime.',
    icon: Icons.bookmark_rounded,
  ),
  const FaqItem(
    question: 'What are achievements?',
    answer:
        'Achievements are special rewards for reaching milestones like 7-day streaks, completing 10 lessons, or finishing your first course. Unlocked achievements give bonus XP!',
    icon: Icons.emoji_events_rounded,
  ),
  const FaqItem(
    question: 'How do I reset my progress?',
    answer:
        'Go to Settings → Data & Privacy → Reset Progress. This will clear all XP, streaks, completed lessons, and achievements. This action cannot be undone, so you\'ll need to confirm twice.',
    icon: Icons.delete_outline_rounded,
  ),
  const FaqItem(
    question: 'How do daily reminders work?',
    answer:
        'Enable daily reminders in Settings → Notifications. Choose a time that works for you, and you\'ll get a notification each day to complete a lesson. Requires notification permissions.',
    icon: Icons.alarm_rounded,
  ),
  const FaqItem(
    question: 'How do I report a bug or give feedback?',
    answer:
        'We\'d love to hear from you! Email us at support@brainbox.app or use the "Contact Support" option in your profile. Include your device info and a description of the issue.',
    icon: Icons.bug_report_rounded,
  ),
  const FaqItem(
    question: 'Can I change the theme?',
    answer:
        'Yes! Go to Settings → Appearance to choose between Light, Dark, or System theme. Changes apply immediately across the app.',
    icon: Icons.palette_rounded,
  ),
  const FaqItem(
    question: 'What happens if I miss a day?',
    answer:
        'Your streak resets to 1. Your longest streak is preserved. You can always start a new streak the next day!',
    icon: Icons.refresh_rounded,
  ),
];
