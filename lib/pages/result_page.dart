import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final String mode;
  final int? timeUsed;
  final Widget Function()? gameBuilder;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.mode,
    this.timeUsed,
    this.gameBuilder,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with TickerProviderStateMixin {
  late AnimationController _scoreCtrl;
  late Animation<double> _scoreAnim;
  late AnimationController _badgeCtrl;
  late Animation<double> _badgeAnim;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300));
    _scoreAnim = Tween<double>(begin: 0, end: _pct).animate(
        CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic));

    _badgeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _badgeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut));

    _scoreCtrl.forward();
    Future.delayed(const Duration(milliseconds: 900), _badgeCtrl.forward);
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  double get _pct => widget.total > 0 ? widget.score / widget.total : 0;

  _BadgeInfo get _badge {
    if (_pct >= 0.9) return _BadgeInfo('🏆', 'Expert IA', 'Maîtrise excellente !', AppTheme.accent);
    if (_pct >= 0.7) return _BadgeInfo('⭐', 'Praticien IA', 'Très bonne connaissance', AppTheme.primaryLight);
    if (_pct >= 0.4) return _BadgeInfo('🌱', 'Explorateur IA', 'Bonne base, continuez !', AppTheme.modeFlash);
    return _BadgeInfo('📚', 'Débutant IA', 'La formation va vous aider !', AppTheme.modeScenario);
  }

  Color get _scoreColor {
    if (_pct >= 0.7) return AppTheme.success;
    if (_pct >= 0.4) return AppTheme.caution;
    return AppTheme.error;
  }

  String get _modeLabel => switch (widget.mode) {
        'quiz' => 'Quiz Connaissances',
        'scenario' => 'Mise en Situation',
        'flash' => 'Flash Quiz',
        'match' => 'Associe les Paires',
        'order' => 'Ordonne les Étapes',
        'whoami' => 'Qui suis-je ?',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      children: [
                        Text(
                          'Résultats',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _modeLabel,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        AnimatedBuilder(
                          animation: _scoreAnim,
                          builder: (_, __) {
                            final displayed =
                                (_scoreAnim.value * widget.total).round();
                            return CustomPaint(
                              painter: _CirclePainter(
                                  progress: _scoreAnim.value,
                                  color: _scoreColor),
                              child: SizedBox(
                                width: 164,
                                height: 164,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('$displayed',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 44,
                                              fontWeight: FontWeight.bold)),
                                      Text('/ ${widget.total}',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.65),
                                              fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        ScaleTransition(
                          scale: _badgeAnim,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: badge.color.withValues(alpha: 0.4)),
                            ),
                            child: Column(children: [
                              Text(badge.icon,
                                  style: const TextStyle(fontSize: 44)),
                              const SizedBox(height: 8),
                              Text(badge.title,
                                  style: TextStyle(
                                      color: badge.color,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(badge.subtitle,
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                      fontSize: 14)),
                            ]),
                          ),
                        ),
                        if (widget.timeUsed != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '⏱  ${widget.timeUsed}s utilisées sur 60s',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ..._buildInsights(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    if (widget.gameBuilder != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => widget.gameBuilder!()),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('🔄  Rejouer',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(
                            context, (r) => r.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('🏠  Menu principal',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInsights() {
    final List<String> tips;
    if (widget.mode == 'scenario') {
      tips = _pct < 0.5
          ? ['⚠️  Attention aux données personnelles et nominatives', '📋  Revoyez les règles d\'usage IA de votre collectivité']
          : _pct < 0.8
              ? ['👍  Bon sens des responsabilités !', '🔍  Affinez votre jugement sur les cas limites']
              : ['✅  Excellent sens des bonnes pratiques IA !', '🏛️  Vous maîtrisez les enjeux institutionnels'];
    } else if (widget.mode == 'match') {
      tips = _pct < 0.6
          ? ['💡  Revoyez le vocabulaire clé de l\'IA', '📖  La formation détaille tous ces termes']
          : ['🎯  Bonne maîtrise du vocabulaire IA !', '🚀  Vous êtes prêt(e) à utiliser les bons termes'];
    } else if (widget.mode == 'order') {
      tips = _pct < 0.6
          ? ['💡  Revoyez les processus et chronologies', '📖  La formation détaille ces workflows']
          : ['🎯  Bonne compréhension des étapes !', '🚀  Vous maîtrisez les processus IA'];
    } else if (widget.mode == 'whoami') {
      tips = _pct < 0.5
          ? ['💡  Approfondissez les concepts fondamentaux', '📖  La formation couvre tous ces termes']
          : ['🎯  Bonne intuition sur les concepts IA !', '🚀  Vous reconnaissez les notions clés'];
    } else {
      tips = _pct < 0.5
          ? ['💡  Revoyez les fondamentaux : tokens, LLM, hallucinations', '📖  La formation détaille ces concepts']
          : _pct < 0.8
              ? ['👍  Bonne base ! Approfondissez les risques et limites', '🎯  Relisez les slides sur les usages CD']
              : ['🚀  Excellente maîtrise des concepts IA !', '💼  Vous êtes prêt(e) à intégrer l\'IA au quotidien'];
    }
    return tips.map((msg) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(msg,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13)),
          ),
        )).toList();
  }
}

class _BadgeInfo {
  final String icon, title, subtitle;
  final Color color;
  _BadgeInfo(this.icon, this.title, this.subtitle, this.color);
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  _CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    canvas.drawCircle(center, radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.progress != progress;
}
