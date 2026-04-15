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

// ─── Game mode descriptor ─────────────────────────────────────────
class _Mode {
  final String icon;
  final String title;
  final String description;
  final String tag;
  final Color color;
  final Widget Function(SettingsProvider) pageBuilder;
  final int Function(SettingsProvider) availableCount;
  final int minRequired;

  const _Mode({
    required this.icon,
    required this.title,
    required this.description,
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

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;

  static final List<_Mode> _modes = [
    _Mode(
      icon: '🧠', title: 'Quiz QCM',
      description: 'Questions à choix multiples sur tous les concepts',
      tag: '~5 min', color: AppTheme.modeQuiz,
      pageBuilder: (s) => QuizPage(questions: QuizData.getQuestions(s)),
      availableCount: (s) => QuizData.getQuestions(s).length,
      minRequired: 5,
    ),
    _Mode(
      icon: '🎭', title: 'Mises en Situation',
      description: 'Évaluez des cas concrets du conseil départemental',
      tag: '~4 min', color: AppTheme.modeScenario,
      pageBuilder: (s) => ScenarioPage(scenarios: QuizData.getScenarios(s)),
      availableCount: (s) => QuizData.getScenarios(s).length,
      minRequired: 3,
    ),
    _Mode(
      icon: '⚡', title: 'Flash Quiz',
      description: 'Vrai ou Faux — 60 secondes chrono',
      tag: '60 sec', color: AppTheme.modeFlash,
      pageBuilder: (s) => FlashPage(questions: QuizData.getFlashQuestions(s)),
      availableCount: (s) => QuizData.getFlashQuestions(s).length,
      minRequired: 5,
    ),
    _Mode(
      icon: '🔗', title: 'Associe les Paires',
      description: 'Reliez les termes à leurs définitions',
      tag: '~1 min', color: AppTheme.modeMatch,
      pageBuilder: (s) => MatchPage(sets: QuizData.getMatchSets(s)),
      availableCount: (s) => QuizData.getMatchSets(s).length,
      minRequired: 1,
    ),
    /*_Mode(
      icon: '📋', title: 'Ordonne les Étapes',
      description: 'Remettez les séquences dans le bon ordre',
      tag: '~4 min', color: AppTheme.modeOrder,
      pageBuilder: (s) => OrderPage(challenges: QuizData.getOrderChallenges(s)),
      availableCount: (s) => QuizData.getOrderChallenges(s).length,
      minRequired: 1,
    ),*/
    _Mode(
      icon: '🕵️', title: 'Qui suis-je ?',
      description: 'Devinez le concept à partir d\'indices progressifs',
      tag: '~3 min', color: AppTheme.modeWhoAmI,
      pageBuilder: (s) => WhoAmIPage(rounds: QuizData.getWhoAmIRounds(s)),
      availableCount: (s) => QuizData.getWhoAmIRounds(s).length,
      minRequired: 1,
    ),
    _Mode(
      icon: '🦊', title: 'FOX LAB',
      description: 'Comprendre l\'IA Générative, Workflow et Agentique',
      tag: '~5 min', color: AppTheme.modeFox,
      pageBuilder: (s) => const FoxAIPedagogyGamePage(),
      availableCount: (s) => QuizData.getWhoAmIRounds(s).length,
      minRequired: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _fadeAnims = List.generate(
      6,
      (i) => Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(0.05 * i, 0.45 + 0.05 * i, curve: Curves.easeOut),
      )),
    );
    _slideAnims = List.generate(
      6,
      (i) => Tween<Offset>(
              begin: const Offset(0, 0.25), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(0.05 * i, 0.45 + 0.05 * i, curve: Curves.easeOut),
      )),
    );
    _ctrl.forward();
    SettingsProvider.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    SettingsProvider.instance.removeListener(_onSettingsChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  void _launch(_Mode mode) {
    final s = SettingsProvider.instance;
    if (!mode.isUnlocked(s)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Activez plus de catégories dans les paramètres ⚙️'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => mode.pageBuilder(s)));
  }

  @override
  Widget build(BuildContext context) {
    final s = SettingsProvider.instance;
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(s),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  _buildCategoryChips(s),
                  const SizedBox(height: 20),
                  Row(children: [
                    const Expanded(
                      child: Text('6 modes de jeu',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                    ),
                    Text('${s.difficulty.emoji} ${s.difficulty.label}',
                        style: TextStyle(
                            fontSize: 13,
                            color: s.difficulty.color,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: List.generate(6, (i) {
                      return FadeTransition(
                        opacity: _fadeAnims[i],
                        child: SlideTransition(
                          position: _slideAnims[i],
                          child: _buildModeCard(_modes[i], s),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Formation conçue par Jean-Baptiste Milon — ONEPOINT',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              AppTheme.textSecondary.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  /*
                  ElevatedButton(onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FoxAIPedagogyGamePage()),
                    ), 
                  child: RichText(text: const TextSpan(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: "🦊 FOX LAB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.white)),
                      TextSpan(text: "\nComprendre l'IA Générative, Workflow et Agentique", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white))

                    ],
                  )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 1, 68),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
                  ),
                  )*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SettingsProvider s) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsPage())),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: s.difficulty.color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: s.difficulty.color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${s.difficulty.emoji}  ${s.difficulty.label}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: 300,
              height: 122,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                  child: Image.asset('assets/images/onepointlogo.png', fit: BoxFit.contain)),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.4)),
              ),
              child: const Text(
                'Formation IA Générative — Conseil Départemental',
                style: TextStyle(
                    color: Colors.white, fontSize: 11.5, letterSpacing: 0.3),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(SettingsProvider s) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: QuizCategory.values.map((cat) {
          final on = s.isCategoryEnabled(cat);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage())),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: on
                      ? cat.color.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: on
                        ? cat.color.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${cat.emoji}  ${cat.label}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: on ? cat.color : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeCard(_Mode mode, SettingsProvider s) {
    final unlocked = mode.isUnlocked(s);
    final count = mode.availableCount(s);
    return GestureDetector(
      onTap: () => _launch(mode),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: unlocked
                ? [mode.color, Color.lerp(mode.color, Colors.black, 0.25)!]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (unlocked ? mode.color : Colors.grey)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -10,
              bottom: -10,
              child: Text(
                mode.icon,
                style: TextStyle(
                    fontSize: 72,
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.icon,
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    mode.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          mode.tag,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (unlocked)
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16)
                      else
                        Icon(Icons.lock_rounded,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 16),
                    ],
                  ),
                ],
              ),
            ),
            if (!unlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        '$count / ${mode.minRequired} requis',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
