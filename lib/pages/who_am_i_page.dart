import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import 'result_page.dart';

class WhoAmIPage extends StatefulWidget {
  final List<WhoAmIRound> rounds;
  const WhoAmIPage({super.key, required this.rounds});

  @override
  State<WhoAmIPage> createState() => _WhoAmIPageState();
}

class _WhoAmIPageState extends State<WhoAmIPage>
    with SingleTickerProviderStateMixin {
  late List<WhoAmIRound> _rounds;
  int _idx = 0;
  int _totalScore = 0;
  int _correctCount = 0;

  int _revealedClues = 1;
  bool _guessed = false;
  bool _wasCorrect = false;
  late List<String> _shuffledAnswers;

  late AnimationController _clueCtrl;
  late Animation<double> _clueFade;

  @override
  void initState() {
    super.initState();
    _rounds = List.from(widget.rounds)..shuffle();
    _clueCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _clueFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _clueCtrl, curve: Curves.easeOut));
    _initRound();
  }

  @override
  void dispose() {
    _clueCtrl.dispose();
    super.dispose();
  }

  void _initRound() {
    final r = _rounds[_idx];
    _revealedClues = 1;
    _guessed = false;
    _wasCorrect = false;
    final answers = [r.answer, ...r.decoys];
    answers.shuffle();
    _shuffledAnswers = answers;
    _clueCtrl.forward(from: 0);
  }

  int get _pointsForCurrentClues => 5 - _revealedClues; // 4,3,2,1,0

  void _revealNextClue() {
    final r = _rounds[_idx];
    if (_revealedClues < r.clues.length) {
      setState(() => _revealedClues++);
      _clueCtrl.forward(from: 0);
    }
  }

  void _guess(String answer) {
    if (_guessed) return;
    final r = _rounds[_idx];
    final correct = answer == r.answer;
    setState(() {
      _guessed = true;
      _wasCorrect = correct;
      if (correct) {
        _totalScore += _pointsForCurrentClues;
        _correctCount++;
      }
    });
  }

  void _next() {
    if (_idx < _rounds.length - 1) {
      setState(() {
        _idx++;
        _initRound();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _correctCount,
            total: _rounds.length,
            mode: 'whoami',
            gameBuilder: () => WhoAmIPage(rounds: widget.rounds),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) return _buildEmpty();
    final r = _rounds[_idx];
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.modeWhoAmI,
        foregroundColor: Colors.white,
        title: Text('Énigme ${_idx + 1} / ${_rounds.length}',
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
                child: Text('$_totalScore pts',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_idx + 1) / _rounds.length,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.modeWhoAmI),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMysteryCard(r),
                  const SizedBox(height: 16),
                  if (!_guessed) ...[
                    _buildPointsIndicator(),
                    const SizedBox(height: 12),
                    _buildRevealButton(r),
                    const SizedBox(height: 20),
                    const Text('Qui suis-je ?',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    ..._shuffledAnswers.map((a) => _answerBtn(a)),
                  ] else ...[
                    _buildFeedback(r),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.modeWhoAmI,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _idx < _rounds.length - 1
                              ? 'Énigme suivante →'
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
        ],
      ),
    );
  }

  Widget _buildMysteryCard(WhoAmIRound r) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.modeWhoAmI.withValues(alpha: 0.12),
            AppTheme.modeWhoAmI.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.modeWhoAmI.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.modeWhoAmI.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(children: [
              const Text('🕵️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Indices',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.modeWhoAmI)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.modeWhoAmI.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$_revealedClues / ${r.clues.length}',
                    style: const TextStyle(
                        color: AppTheme.modeWhoAmI,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_revealedClues, (i) {
                final isLast = i == _revealedClues - 1;
                return FadeTransition(
                  opacity: isLast ? _clueFade : const AlwaysStoppedAnimation(1),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 10, top: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.modeWhoAmI.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: AppTheme.modeWhoAmI,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                        ),
                        Expanded(
                          child: Text(r.clues[i],
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  height: 1.45)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsIndicator() {
    final pts = _pointsForCurrentClues;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: pts >= 3
            ? AppTheme.success.withValues(alpha: 0.1)
            : pts >= 1
                ? AppTheme.caution.withValues(alpha: 0.1)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pts >= 3
              ? AppTheme.success.withValues(alpha: 0.3)
              : pts >= 1
                  ? AppTheme.caution.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('⭐',
            style: TextStyle(fontSize: 16, color: pts > 0 ? null : Colors.grey)),
        const SizedBox(width: 8),
        Text(
          pts > 0
              ? 'Répondez maintenant pour $pts point${pts > 1 ? 's' : ''}'
              : 'Plus de points disponibles',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: pts >= 3
                  ? AppTheme.success
                  : pts >= 1
                      ? AppTheme.caution
                      : AppTheme.textSecondary),
        ),
      ]),
    );
  }

  Widget _buildRevealButton(WhoAmIRound r) {
    final canReveal = _revealedClues < r.clues.length;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canReveal ? _revealNextClue : null,
        icon: Icon(
          canReveal ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          size: 18,
        ),
        label: Text(
          canReveal
              ? 'Révéler l\'indice ${_revealedClues + 1} (−1 pt)'
              : 'Tous les indices révélés',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              canReveal ? AppTheme.modeWhoAmI : AppTheme.textSecondary,
          side: BorderSide(
              color: canReveal
                  ? AppTheme.modeWhoAmI.withValues(alpha: 0.5)
                  : Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _answerBtn(String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _guess(answer),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.modeWhoAmI.withValues(alpha: 0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            const Icon(Icons.help_outline_rounded,
                color: AppTheme.modeWhoAmI, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(answer,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.modeWhoAmI.withValues(alpha: 0.4), size: 14),
          ]),
        ),
      ),
    );
  }

  Widget _buildFeedback(WhoAmIRound r) {
    final color = _wasCorrect ? AppTheme.success : AppTheme.error;
    final pts = _wasCorrect ? _pointsForCurrentClues : 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_wasCorrect ? '✅' : '❌',
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _wasCorrect ? 'Bravo !' : 'Pas tout à fait…',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: color),
              ),
              if (_wasCorrect)
                Text('+$pts point${pts > 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 13,
                        color: color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        if (!_wasCorrect) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Text('Réponse : ',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.35)),
              ),
              child: Text(r.answer,
                  style: const TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ]),
        ],
        const SizedBox(height: 10),
        Text(r.explanation,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
      ]),
    );
  }

  Widget _buildEmpty() => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
            backgroundColor: AppTheme.modeWhoAmI,
            foregroundColor: Colors.white,
            title: const Text('Qui suis-je ?')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🔒', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('Pas assez d\'énigmes disponibles',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                  textAlign: TextAlign.center),
              SizedBox(height: 8),
              Text('Activez plus de catégories dans les Paramètres ⚙️',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      );
}
