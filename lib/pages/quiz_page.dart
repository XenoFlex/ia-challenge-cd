import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import '../utils/settings_provider.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  late List<Question> _questions;
  int _idx = 0, _score = 0;
  int? _selected;
  bool _answered = false;

  late AnimationController _progressCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.questions)..shuffle();
    if (_questions.length > 12) _questions = _questions.sublist(0, 12);

    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _cardFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardSlide = Tween<Offset>(
            begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _cardCtrl.forward();
    _updateProgress();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressCtrl.animateTo((_idx + 1) / _questions.length,
        duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
  }

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      if (i == _questions[_idx].correctIndex) _score++;
    });
  }

  void _next() {
    if (_idx < _questions.length - 1) {
      setState(() {
        _idx++;
        _selected = null;
        _answered = false;
      });
      _cardCtrl.reset();
      _cardCtrl.forward();
      _updateProgress();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _score,
            total: _questions.length,
            mode: 'quiz',
            gameBuilder: () => QuizPage(questions: widget.questions),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return _buildEmpty();
    final q = _questions[_idx];
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.modeQuiz,
        foregroundColor: Colors.white,
        title: Text('Question ${_idx + 1} / ${_questions.length}',
            style: const TextStyle(fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('$_score pts',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _progressCtrl,
            builder: (_, __) => LinearProgressIndicator(
              value: _progressCtrl.value,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.accent),
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
                      _categoryBadge(q.category),
                      const SizedBox(height: 14),
                      _questionCard(q),
                      const SizedBox(height: 14),
                      ...List.generate(q.options.length,
                          (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _optionBtn(q, i),
                              )),
                      if (_answered) ...[
                        const SizedBox(height: 4),
                        _explanation(q),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.modeQuiz,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _idx < _questions.length - 1
                                  ? 'Question suivante →'
                                  : 'Voir mes résultats →',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildEmpty() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
          backgroundColor: AppTheme.modeQuiz, foregroundColor: Colors.white,
          title: const Text('Quiz QCM')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🔒', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Pas assez de questions disponibles',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
                'Activez plus de catégories ou augmentez le niveau dans les Paramètres ⚙️',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  Widget _categoryBadge(QuizCategory cat) {
    final color = _catColor(cat);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(_catLabel(cat),
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _questionCard(Question q) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration,
        child: Text(q.question,
            style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                height: 1.45)),
      );

  Widget _optionBtn(Question q, int i) {
    Color bg = Colors.white;
    Color border = const Color(0xFFDDE1E7);
    Color txt = AppTheme.textPrimary;
    Widget? trailing;

    if (_answered) {
      if (i == q.correctIndex) {
        bg = AppTheme.success.withValues(alpha: 0.08);
        border = AppTheme.success;
        txt = AppTheme.success;
        trailing = const Icon(Icons.check_circle, color: AppTheme.success, size: 20);
      } else if (i == _selected) {
        bg = AppTheme.error.withValues(alpha: 0.08);
        border = AppTheme.error;
        txt = AppTheme.error;
        trailing = const Icon(Icons.cancel, color: AppTheme.error, size: 20);
      }
    }

    return GestureDetector(
      onTap: () => _select(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: border.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Center(
                child: Text(['A', 'B', 'C', 'D'][i],
                    style: TextStyle(
                        color: _answered ? txt : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(q.options[i],
                  style: TextStyle(
                      color: txt,
                      fontSize: 14,
                      fontWeight: _answered && i == q.correctIndex
                          ? FontWeight.w600
                          : FontWeight.normal))),
          if (trailing != null) trailing,
        ]),
      ),
    );
  }

  Widget _explanation(Question q) {
    final ok = _selected == q.correctIndex;
    final color = ok ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ok ? 'Bonne réponse !' : 'Pas tout à fait…',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(q.explanation,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
        ])),
      ]),
    );
  }

  String _catLabel(QuizCategory c) => switch (c) {
        QuizCategory.iaGenerative => 'IA Générative',
        QuizCategory.iaAgentique => 'IA Agentique',
        QuizCategory.workflowIA => 'Workflows IA',
        QuizCategory.risquesEthique => 'Risques & Éthique',
        QuizCategory.usagesCD => 'Usages CD',
      };

  Color _catColor(QuizCategory c) => switch (c) {
        QuizCategory.iaGenerative => AppTheme.modeQuiz,
        QuizCategory.iaAgentique => AppTheme.modeScenario,
        QuizCategory.workflowIA => AppTheme.modeFlash,
        QuizCategory.risquesEthique => AppTheme.error,
        QuizCategory.usagesCD => AppTheme.modeMatch,
      };
}
