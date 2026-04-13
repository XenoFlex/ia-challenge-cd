import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import 'result_page.dart';

class FlashPage extends StatefulWidget {
  final List<FlashQuestion> questions;
  const FlashPage({super.key, required this.questions});

  @override
  State<FlashPage> createState() => _FlashPageState();
}

class _FlashPageState extends State<FlashPage> with TickerProviderStateMixin {
  static const int _totalSeconds = 60;
  int _remaining = _totalSeconds;
  int _idx = 0, _score = 0, _answered = 0;
  bool? _lastCorrect;
  bool _ended = false;
  Timer? _timer;
  late List<FlashQuestion> _questions;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackFade;
  late AnimationController _questionCtrl;
  late Animation<Offset> _questionSlide;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.questions)..shuffle();

    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
          ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _feedbackCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _feedbackFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _feedbackCtrl, curve: Curves.easeOut));

    _questionCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _questionSlide = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _questionCtrl, curve: Curves.easeOut));
    _questionCtrl.forward();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_remaining <= 0) { t.cancel(); _endGame(); }
      else { setState(() => _remaining--); }
    });
  }

  void _answer(bool answer) {
    if (_idx >= _questions.length || _ended) return;
    final ok = answer == _questions[_idx].isTrue;
    setState(() {
      _answered++;
      if (ok) _score++;
      _lastCorrect = ok;
    });
    _feedbackCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() { _idx++; _lastCorrect = null; });
      _questionCtrl.reset();
      _questionCtrl.forward();
      if (_idx >= _questions.length) _endGame();
    });
  }

  void _endGame() {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _score,
            total: _answered,
            mode: 'flash',
            timeUsed: _totalSeconds - _remaining,
            gameBuilder: () => FlashPage(questions: widget.questions),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _feedbackCtrl.dispose();
    _questionCtrl.dispose();
    super.dispose();
  }

  Color get _timerColor {
    if (_remaining <= 10) return AppTheme.error;
    if (_remaining <= 20) return AppTheme.caution;
    return AppTheme.modeFlash;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2137),
      body: SafeArea(
        child: Column(children: [
          _buildTopBar(),
          Expanded(
            child: _idx < _questions.length
                ? _buildQuestion()
                : const Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text('⏳', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('Calcul des résultats…',
                          style: TextStyle(color: Colors.white70, fontSize: 18)),
                    ])),
          ),
        ]),
      ),
    );
  }

  Widget _buildTopBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          GestureDetector(
            onTap: () { _timer?.cancel(); Navigator.pop(context); },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _remaining / _totalSeconds,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ScaleTransition(
            scale: _remaining <= 10
                ? _pulseAnim
                : const AlwaysStoppedAnimation(1.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _timerColor.withValues(alpha: 0.5)),
              ),
              child: Text('$_remaining s',
                  style: TextStyle(
                      color: _timerColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ]),
      );

  Widget _buildQuestion() {
    final q = _questions[_idx];
    return Column(children: [
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _badge('✅  $_score correct', AppTheme.success),
          const SizedBox(width: 10),
          _badge('📝  ${_questions.length - _idx} restantes', Colors.white70),
        ]),
      ),
      const SizedBox(height: 20),
      Expanded(
        child: Stack(alignment: Alignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SlideTransition(
              position: _questionSlide,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('VRAI  ou  FAUX ?',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Text(q.statement,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.45)),
                ]),
              ),
            ),
          ),
          if (_lastCorrect != null)
            FadeTransition(
              opacity: _feedbackFade,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 16),
                decoration: BoxDecoration(
                  color: (_lastCorrect!
                          ? AppTheme.success
                          : AppTheme.error)
                      .withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _lastCorrect! ? '✅  CORRECT !' : '❌  FAUX !',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Row(children: [
          Expanded(child: _answerBtn(true)),
          const SizedBox(width: 12),
          Expanded(child: _answerBtn(false)),
        ]),
      ),
    ]);
  }

  Widget _answerBtn(bool isTrue) {
    final color = isTrue ? AppTheme.success : AppTheme.error;
    final label = isTrue ? '✅  VRAI' : '❌  FAUX';
    return GestureDetector(
      onTap: () => _answer(isTrue),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      );
}
