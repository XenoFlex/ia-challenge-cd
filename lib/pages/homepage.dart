import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/foxgame.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import '../utils/settings_provider.dart';
import 'quiz_page.dart';
import 'scenario_page.dart';
import 'flash_page.dart';
import 'match_page.dart';
import 'who_am_i_page.dart';
import 'settings_page.dart';

// ─── Mode descriptor ──────────────────────────────────────────────
class _Mode {
  final String icon;
  final String title;
  final String tag;
  final Color color;
  final Widget Function(SettingsProvider) pageBuilder;
  final int Function(SettingsProvider) availableCount;
  final int minRequired;

  const _Mode({
    required this.icon,
    required this.title,
    required this.tag,
    required this.color,
    required this.pageBuilder,
    required this.availableCount,
    required this.minRequired,
  });
  bool isUnlocked(SettingsProvider s) => availableCount(s) >= minRequired;
}

// ─── Homepage ─────────────────────────────────────────────────────
class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _starsCtrl;
  late AnimationController _entranceCtrl;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;

  static const double _cardH   = 68.0;
  static const double _cardGap = 10.0;
  static const double _colH    = 5 * _cardH + 4 * _cardGap; // 380px

  static const List<_Mode> _modes = [
    _Mode(icon: '🧠', title: 'Quiz QCM',          tag: '~5 min', color: AppTheme.modeQuiz,    pageBuilder: _pQuiz,    availableCount: _cQuiz,    minRequired: 5),
    _Mode(icon: '🎭', title: 'Mises en Situation', tag: '~4 min', color: AppTheme.modeScenario,pageBuilder: _pScenario,availableCount: _cScenario,minRequired: 3),
    _Mode(icon: '⚡', title: 'Flash Quiz',          tag: '60 sec', color: AppTheme.modeFlash,  pageBuilder: _pFlash,  availableCount: _cFlash,  minRequired: 5),
    _Mode(icon: '🔗', title: 'Associe les Paires', tag: '~2 min', color: AppTheme.modeMatch,   pageBuilder: _pMatch,  availableCount: _cMatch,  minRequired: 1),
    _Mode(icon: '🕵️', title: 'Qui suis-je ?',     tag: '~3 min', color: AppTheme.modeWhoAmI, pageBuilder: _pWhoAmI, availableCount: _cWhoAmI, minRequired: 1),
  ];

  static Widget _pQuiz    (SettingsProvider s) => QuizPage    (questions: QuizData.getQuestions    (s));
  static Widget _pScenario(SettingsProvider s) => ScenarioPage(scenarios: QuizData.getScenarios    (s));
  static Widget _pFlash   (SettingsProvider s) => FlashPage   (questions: QuizData.getFlashQuestions(s));
  static Widget _pMatch   (SettingsProvider s) => MatchPage   (sets:      QuizData.getMatchSets    (s));
  static Widget _pWhoAmI  (SettingsProvider s) => WhoAmIPage  (rounds:    QuizData.getWhoAmIRounds (s));
  static int _cQuiz    (SettingsProvider s) => QuizData.getQuestions    (s).length;
  static int _cScenario(SettingsProvider s) => QuizData.getScenarios    (s).length;
  static int _cFlash   (SettingsProvider s) => QuizData.getFlashQuestions(s).length;
  static int _cMatch   (SettingsProvider s) => QuizData.getMatchSets    (s).length;
  static int _cWhoAmI  (SettingsProvider s) => QuizData.getWhoAmIRounds (s).length;

  @override
  void initState() {
    super.initState();
    // Durée choisie pour que les 3 multiplicateurs entiers (1, 2, 3)
    // bouclent proprement sans saut visible.
    _waveCtrl = AnimationController(
        duration: const Duration(seconds: 6), vsync: this)
      ..repeat();
    _starsCtrl = AnimationController(
        duration: const Duration(seconds: 4), vsync: this)
      ..repeat();
    _entranceCtrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);

    _fadeAnims = List.generate(5, (i) =>
      Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(0.08 * i, 0.55 + 0.08 * i, curve: Curves.easeOut),
      )));
    _slideAnims = List.generate(5, (i) =>
      Tween<Offset>(begin: const Offset(-0.35, 0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(0.08 * i, 0.55 + 0.08 * i, curve: Curves.easeOutCubic),
      )));

    _entranceCtrl.forward();
    SettingsProvider.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    SettingsProvider.instance.removeListener(_rebuild);
    _waveCtrl.dispose();
    _starsCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _launch(_Mode mode) {
    final s = SettingsProvider.instance;
    if (!mode.isUnlocked(s)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Activez plus de catégories dans les paramètres ⚙️'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => mode.pageBuilder(s)));
  }

  // ─── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = SettingsProvider.instance;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ① Header compact + wave top
          _buildHeader(s),

          // ② Zone centrale : chips + centrage vertical des cartes
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: _buildCategoryChips(s),
                ),
                // ← centrage vertical des 5 modes + Fox Lab
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Colonne gauche : 5 modes ──────────────
                          Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Différents quiz pour valider les acquis',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.55),
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 7),
                                _buildModesColumn(s),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ── Colonne droite : Fox Lab ───────────────
                          Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comprendre les différents types d\'IA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.55),
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 7),
                                SizedBox(
                                    height: _colH, child: _buildFoxLabCard()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ③ Wave bas + footer sombre
          _buildBottomWave(),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────
  Widget _buildHeader(SettingsProvider s) {
    return AnimatedBuilder(
      animation: _waveCtrl,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF060F2E), Color(0xFF0F2460), Color(0xFF1B3A6B)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Row(children: [
                _iconBtn(Icons.settings_rounded, () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()))),
                const SizedBox(width: 12),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Image.asset('assets/images/onepointlogo.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsPage())),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: s.difficulty.color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: s.difficulty.color.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                        '${s.difficulty.emoji} ${s.difficulty.label}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
            // Vague de transition header → fond clair
            SizedBox(
              height: 44,
              width: double.infinity,
              child: CustomPaint(
                painter: _WavePainter(_waveCtrl.value, AppTheme.background),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );

  // ─── Category chips ───────────────────────────────────────────────
  Widget _buildCategoryChips(SettingsProvider s) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: QuizCategory.values.map((cat) {
          final on = s.isCategoryEnabled(cat);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage())),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: on ? cat.color.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: on
                        ? cat.color.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text('${cat.emoji} ${cat.label}',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: on ? cat.color : AppTheme.textSecondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Left: 5 stacked mode cards ───────────────────────────────────
  Widget _buildModesColumn(SettingsProvider s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final mode = _modes[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i < 4 ? _cardGap : 0),
          child: SizedBox(
            height: _cardH,
            child: FadeTransition(
              opacity: _fadeAnims[i],
              child: SlideTransition(
                position: _slideAnims[i],
                child: _buildModeCard(mode, s),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildModeCard(_Mode mode, SettingsProvider s) {
    final unlocked = mode.isUnlocked(s);
    return GestureDetector(
      onTap: () => _launch(mode),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: unlocked
                ? [mode.color, Color.lerp(mode.color, Colors.black, 0.3)!]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (unlocked ? mode.color : Colors.grey)
                  .withValues(alpha: unlocked ? 0.25 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(children: [
          Positioned(
            right: 6, top: 0, bottom: 0,
            child: Center(
              child: Text(mode.icon,
                  style: TextStyle(
                      fontSize: 44,
                      color: Colors.white.withValues(alpha: 0.07))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Text(mode.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mode.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(mode.tag,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                unlocked
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.lock_rounded,
                color: Colors.white.withValues(alpha: 0.65),
                size: 13,
              ),
            ]),
          ),
          if (!unlocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
        ]),
      ),
    );
  }

  // ─── Right: Fox Lab with animated stars ───────────────────────────
  Widget _buildFoxLabCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FoxAIPedagogyGamePage())),
      child: AnimatedBuilder(
        animation: _starsCtrl,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF03001A),
                Color(0xFF08023A),
                Color(0xFF130870),
              ],
              stops: [0, 0.5, 1],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.modeFox.withValues(alpha: 0.32),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(children: [
              Positioned.fill(
                child: CustomPaint(painter: _StarsPainter(_starsCtrl.value)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: Colors.amber, size: 10),
                        SizedBox(width: 4),
                        Text('INTERACTIF',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    const Text('🦊', style: TextStyle(fontSize: 34)),
                    const SizedBox(height: 6),
                    const Text('FOX',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            height: 1.1)),
                    Text('LAB',
                        style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            height: 1.1)),
                    const Spacer(),
                    Text(
                      'IA Générative\nWorkflows &\nAgentique',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Jouer',
                                style: TextStyle(
                                    color: AppTheme.modeFox,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5)),
                            const SizedBox(width: 5),
                            Icon(Icons.play_arrow_rounded,
                                color: AppTheme.modeFox, size: 15),
                          ]),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text('~5 min',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 9.5)),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ─── Bottom wave + footer ─────────────────────────────────────────
  Widget _buildBottomWave() {
    return AnimatedBuilder(
      animation: _waveCtrl,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF060F2E), Color(0xFF0F2460)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 44,
              width: double.infinity,
              child: CustomPaint(
                painter:
                    _WaveBottomPainter(_waveCtrl.value, AppTheme.background),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
              child: Text(
                'Formation conçue par Jean-Baptiste Milon — ONEPOINT',
                style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.4)),
                textAlign: TextAlign.center,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Top Wave Painter ─────────────────────────────────────────────
// Remplit du bas de la courbe jusqu'au bas du canvas avec fill.
// Multiplicateurs entiers (1, 2, 3) → boucle parfaitement sans saut.
class _WavePainter extends CustomPainter {
  final double t;
  final Color fill;
  const _WavePainter(this.t, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    _wave(canvas, size, t * 1, 18, 0.22, 0.28);
    _wave(canvas, size, t * 2, 13, 0.44, 0.52);
    _wave(canvas, size, t * 3, 10, 0.68, 1.0);
  }

  void _wave(Canvas canvas, Size size, double t, double amp, double yFrac,
      double opacity) {
    final path = Path();
    final y0 = size.height * yFrac;
    path.moveTo(0, y0);
    for (double x = 0; x <= size.width; x += 3) {
      final y =
          y0 + math.sin(x / size.width * math.pi * 2.8 + t * math.pi * 2) * amp;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = fill.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.t != t;
}

// ─── Bottom Wave Painter ──────────────────────────────────────────
// Même logique mais remplit du haut du canvas jusqu'à la courbe
// (crée une vague montante sur fond sombre).
class _WaveBottomPainter extends CustomPainter {
  final double t;
  final Color fill;
  const _WaveBottomPainter(this.t, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    _wave(canvas, size, t * 1, 10, 0.78, 0.28);
    _wave(canvas, size, t * 2, 13, 0.52, 0.52);
    _wave(canvas, size, t * 3, 18, 0.28, 1.0);
  }

  void _wave(Canvas canvas, Size size, double t, double amp, double yFrac,
      double opacity) {
    final path = Path();
    final y0 = size.height * yFrac;
    path.moveTo(0, y0);
    for (double x = 0; x <= size.width; x += 3) {
      final y =
          y0 + math.sin(x / size.width * math.pi * 2.8 + t * math.pi * 2) * amp;
      path.lineTo(x, y);
    }
    // Remplissage vers le HAUT (inverse du top wave)
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, Paint()..color = fill.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(_WaveBottomPainter old) => old.t != t;
}

// ─── Stars Painter ────────────────────────────────────────────────
class _StarData {
  final double x, y, r, phase;
  const _StarData(this.x, this.y, this.r, this.phase);
}

class _StarsPainter extends CustomPainter {
  final double t;
  static final List<_StarData> _stars = _generate();
  _StarsPainter(this.t);

  static List<_StarData> _generate() {
    final rng = math.Random(42);
    return List.generate(60, (_) => _StarData(
          rng.nextDouble(),
          rng.nextDouble(),
          0.6 + rng.nextDouble() * 2.2,
          rng.nextDouble() * math.pi * 2,
        ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final blink = (math.sin(t * math.pi * 2 + s.phase) + 1) / 2;
      final opacity = 0.08 + blink * 0.72;
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.t != t;
}
