import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;

  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  late List<Question> _shuffledQuestions;

  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List.from(widget.questions)..shuffle();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _cardController.forward();
    _updateProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressController.animateTo(
      (_currentIndex + 1) / _shuffledQuestions.length,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _shuffledQuestions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _cardController.reset();
      _cardController.forward();
      _updateProgress();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _score,
            total: _shuffledQuestions.length,
            mode: 'quiz',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _shuffledQuestions[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Question ${_currentIndex + 1} / ${_shuffledQuestions.length}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_score pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _progressController,
            builder: (_, __) => LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 4,
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _buildCategoryBadge(question.category),
                      const SizedBox(height: 14),
                      _buildQuestionCard(question),
                      const SizedBox(height: 16),
                      ...List.generate(question.options.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildOptionButton(question, i),
                        );
                      }),
                      if (_answered) ...[
                        const SizedBox(height: 4),
                        _buildExplanation(question),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _currentIndex < _shuffledQuestions.length - 1
                                  ? 'Question suivante →'
                                  : 'Voir mes résultats →',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(QuizCategory category) {
    final label = _categoryLabel(category);
    final color = _categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Text(
        question.question,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildOptionButton(Question question, int index) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFDDE1E7);
    Color textColor = AppTheme.textPrimary;
    Widget? trailing;

    if (_answered) {
      if (index == question.correctIndex) {
        bgColor = AppTheme.success.withOpacity(0.08);
        borderColor = AppTheme.success;
        textColor = AppTheme.success;
        trailing =
            const Icon(Icons.check_circle, color: AppTheme.success, size: 20);
      } else if (index == _selectedAnswer) {
        bgColor = AppTheme.error.withOpacity(0.08);
        borderColor = AppTheme.error;
        textColor = AppTheme.error;
        trailing = const Icon(Icons.cancel, color: AppTheme.error, size: 20);
      }
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  ['A', 'B', 'C', 'D'][index],
                  style: TextStyle(
                    color: _answered ? textColor : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.options[index],
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: _answered && index == question.correctIndex
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(Question question) {
    final isCorrect = _selectedAnswer == question.correctIndex;
    final color = isCorrect ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? '✅' : '❌',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Bonne réponse !' : 'Pas tout à fait…',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.explanation,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(QuizCategory category) {
    switch (category) {
      case QuizCategory.fondamentaux:
        return 'Fondamentaux';
      case QuizCategory.fonctionnement:
        return 'Fonctionnement';
      case QuizCategory.usages:
        return 'Usages CD';
      case QuizCategory.risques:
        return 'Risques & Limites';
    }
  }

  Color _categoryColor(QuizCategory category) {
    switch (category) {
      case QuizCategory.fondamentaux:
        return AppTheme.primary;
      case QuizCategory.fonctionnement:
        return AppTheme.modeScenario;
      case QuizCategory.usages:
        return AppTheme.modeFlash;
      case QuizCategory.risques:
        return AppTheme.error;
    }
  }
}
