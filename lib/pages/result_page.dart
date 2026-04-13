import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final String mode; // 'quiz' | 'scenario' | 'flash'
  final int? timeUsed;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.mode,
    this.timeUsed,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreProgress;
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreProgress = Tween<double>(begin: 0, end: _percentage).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _badgeScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    _scoreController.forward();
    Future.delayed(
        const Duration(milliseconds: 900), _badgeController.forward);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  double get _percentage =>
      widget.total > 0 ? widget.score / widget.total : 0;

  _BadgeInfo get _badge {
    if (_percentage >= 0.9) {
      return _BadgeInfo('🏆', 'Expert IA',
          'Maîtrise excellente !', AppTheme.accent);
    } else if (_percentage >= 0.7) {
      return _BadgeInfo('⭐', 'Praticien IA',
          'Très bonne connaissance', AppTheme.primaryLight);
    } else if (_percentage >= 0.4) {
      return _BadgeInfo('🌱', 'Explorateur IA',
          'Bonne base, continuez !', AppTheme.modeFlash);
    } else {
      return _BadgeInfo('📚', 'Débutant IA',
          'La formation va vous aider !', AppTheme.modeScenario);
    }
  }

  Color get _scoreColor {
    if (_percentage >= 0.7) return AppTheme.success;
    if (_percentage >= 0.4) return AppTheme.caution;
    return AppTheme.error;
  }

  String get _modeLabel {
    switch (widget.mode) {
      case 'quiz':
        return 'Quiz Connaissances';
      case 'scenario':
        return 'Mise en Situation';
      case 'flash':
        return 'Flash Quiz';
      default:
        return '';
    }
  }

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
                        const Text(
                          'Résultats',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _modeLabel,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Animated score circle
                        AnimatedBuilder(
                          animation: _scoreProgress,
                          builder: (_, __) {
                            final displayed =
                                (_scoreProgress.value * widget.total)
                                    .round();
                            return CustomPaint(
                              painter: _CirclePainter(
                                progress: _scoreProgress.value,
                                color: _scoreColor,
                              ),
                              child: SizedBox(
                                width: 164,
                                height: 164,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$displayed',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 44,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '/ ${widget.total}',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.65),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        // Badge
                        ScaleTransition(
                          scale: _badgeScale,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: badge.color.withOpacity(0.4)),
                            ),
                            child: Column(
                              children: [
                                Text(badge.icon,
                                    style:
                                        const TextStyle(fontSize: 44)),
                                const SizedBox(height: 8),
                                Text(
                                  badge.title,
                                  style: TextStyle(
                                    color: badge.color,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  badge.subtitle,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.75),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.timeUsed != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '⏱  ${widget.timeUsed}s utilisées sur 60s',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🏠  Retour au menu',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
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
      if (_percentage < 0.5) {
        tips = [
          '⚠️  Vigilance sur les données personnelles et nominatives',
          '📋  Revoyez les règles d\'usage IA de votre collectivité',
        ];
      } else if (_percentage < 0.8) {
        tips = [
          '👍  Bon sens des responsabilités !',
          '🔍  Affinez votre jugement sur les cas limites',
        ];
      } else {
        tips = [
          '✅  Excellent sens des bonnes pratiques IA !',
          '🏛️  Vous maîtrisez les enjeux du cadre institutionnel',
        ];
      }
    } else {
      if (_percentage < 0.5) {
        tips = [
          '💡  Revoyez les fondamentaux : tokens, LLM, hallucinations',
          '📖  La formation détaille tous ces concepts en profondeur',
        ];
      } else if (_percentage < 0.8) {
        tips = [
          '👍  Bonne base ! Approfondissez les risques et les limites',
          '🎯  Relisez les slides sur les usages spécifiques au CD',
        ];
      } else {
        tips = [
          '🚀  Excellente maîtrise des concepts IA !',
          '💼  Vous êtes prêt(e) à intégrer l\'IA dans votre quotidien',
        ];
      }
    }

    return tips.map((msg) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            msg,
            style:
                TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 13),
          ),
        ),
      );
    }).toList();
  }
}

class _BadgeInfo {
  final String icon;
  final String title;
  final String subtitle;
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

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    // Progress arc
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
