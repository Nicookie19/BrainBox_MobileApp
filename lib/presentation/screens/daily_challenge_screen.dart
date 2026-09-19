import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/data/repositories/daily_challenge_repository.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class DailyChallengeScreen extends StatefulWidget {
  final DateTime? fixedDate;
  const DailyChallengeScreen({super.key, this.fixedDate});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> with TickerProviderStateMixin {
  late List<ChallengeQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;
  bool _alreadyCompleted = false;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _loadDailyChallenge();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyChallenge() async {
    final today = widget.fixedDate ?? DateTime.now();
    _questions = DailyChallengeRepository.getDailyQuestions(today);
    _alreadyCompleted = DailyChallengeRepository.isCompletedForDate(today);

    if (_alreadyCompleted) {
      _finished = true;
      _score = DailyChallengeRepository.getScoreForDate(today);
    }

    _progressController.forward();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
      );
    }

    if (_alreadyCompleted) {
      return _buildAlreadyCompletedScreen();
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _finished ? () => context.pop() : () => _showExitDialog(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          _finished ? 'Challenge Complete' : 'Daily Challenge',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_finished) ...[
                      _buildQuestionCard(question),
                      const SizedBox(height: 24),
                      _buildAnswerOptions(question),
                      if (_answered) ...[
                        const SizedBox(height: 16),
                        _buildExplanation(question),
                      ],
                    ] else ...[
                      _buildCompletionCard(),
                    ],
                  ],
                ),
              ),
            ),
            if (!_finished) _buildBottomAction(),
            if (_finished) _buildFinishAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyCompletedScreen() {
    final score = DailyChallengeRepository.getScoreForDate(DateTime.now());
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Daily Challenge'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accentSuccess.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded, color: AppColors.accentSuccess, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'Already Completed Today!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You scored $score/5. Come back tomorrow for a new challenge!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Home'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentWarningSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt_rounded, color: AppColors.accentWarning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '50 XP available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentWarning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              final progress = (_currentIndex + (_answered ? 1 : 0)) / _questions.length;
              return LinearProgressIndicator(
                value: progress * _progressController.value,
                minHeight: 8,
                backgroundColor: AppColors.bgTertiary,
                color: AppColors.accentWarning,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ChallengeQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildAnswerOptions(ChallengeQuestion question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isCorrect = index == question.answer;
        final isSelected = index == _selectedAnswer;

        Color borderColor = AppColors.borderDefault;
        Color bgColor = AppColors.bgCard;
        Color textColor = AppColors.textPrimary;
        IconData? trailingIcon;

        if (_answered) {
          if (isCorrect) {
            borderColor = AppColors.accentSuccess;
            bgColor = AppColors.accentSuccessSoft;
            textColor = AppColors.accentSuccess;
            trailingIcon = Icons.check_circle_rounded;
          } else if (isSelected) {
            borderColor = AppColors.accentError;
            bgColor = AppColors.accentErrorSoft;
            textColor = AppColors.accentError;
            trailingIcon = Icons.cancel_rounded;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _answered ? null : () => _selectAnswer(index, isCorrect),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: isCorrect && _answered ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, color: textColor, size: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildExplanation(ChallengeQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedAnswer == question.answer
            ? AppColors.accentSuccessSoft
            : AppColors.accentPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _selectedAnswer == question.answer
              ? AppColors.accentSuccess.withValues(alpha: 0.3)
              : AppColors.accentPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _selectedAnswer == question.answer
                ? Icons.check_circle_rounded
                : Icons.info_rounded,
            color: _selectedAnswer == question.answer
                ? AppColors.accentSuccess
                : AppColors.accentPrimary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question.explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _selectedAnswer == question.answer
                    ? AppColors.accentSuccess
                    : AppColors.accentPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentPrimary, AppColors.accentPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Challenge Complete!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You answered $_score/${_questions.length} questions correctly',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '+50 XP',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale().slideY(begin: 0.3, end: 0);
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: _answered ? _nextQuestion : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentWarning,
            foregroundColor: AppColors.textOnAccent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(_currentIndex == _questions.length - 1 ? 'Finish Challenge' : 'Next Question'),
        ),
      ),
    );
  }

  Widget _buildFinishAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: () async {
            final today = widget.fixedDate ?? DateTime.now();
            await DailyChallengeRepository.markCompletedForDate(today, _score);
            if (!mounted) return;
            context.read<AppProvider>().completeChallenge();
            if (!mounted) return;
            context.pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: AppColors.textOnAccent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Continue Learning'),
        ),
      ),
    );
  }

  void _selectAnswer(int index, bool isCorrect) {
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex == _questions.length - 1) {
      setState(() => _finished = true);
      _progressController.forward();
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _progressController.forward(from: 0);
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Challenge?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.accentError),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

