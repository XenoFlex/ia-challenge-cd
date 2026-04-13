import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import 'result_page.dart';

class ScenarioPage extends StatefulWidget {
  final List<Scenario> scenarios;
  const ScenarioPage({super.key, required this.scenarios});

  @override
  State<ScenarioPage> createState() => _ScenarioPageState();
}

class _ScenarioPageState extends State<ScenarioPage>
    with SingleTickerProviderStateMixin {
  late List<Scenario> _scenarios;
  int _idx = 0, _score = 0;
  ScenarioType? _selected;
  bool _answered = false;

  late AnimationController _cardCtrl;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _scenarios = List.from(widget.scenarios)..shuffle();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _cardSlide = Tween<Offset>(
            begin: const Offset(0.15, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  void _select(ScenarioType t) {
    if (_answered) return;
    setState(() {
      _selected = t;
      _answered = true;
      if (t == _scenarios[_idx].correctType) _score++;
    });
  }

  void _next() {
    if (_idx < _scenarios.length - 1) {
      setState(() {
        _idx++;
        _selected = null;
        _answered = false;
      });
      _cardCtrl.reset();
      _cardCtrl.forward();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _score,
            total: _scenarios.length,
            mode: 'scenario',
            gameBuilder: () => ScenarioPage(scenarios: widget.scenarios),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_scenarios.isEmpty) return _buildEmpty();
    final s = _scenarios[_idx];
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.modeScenario,
        foregroundColor: Colors.white,
        title: Text('Scénario ${_idx + 1} / ${_scenarios.length}',
            style: const TextStyle(fontSize: 16)),
      ),
      body: Column(children: [
        LinearProgressIndicator(
          value: (_idx + 1) / _scenarios.length,
          backgroundColor: Colors.grey.shade200,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppTheme.modeScenario),
          minHeight: 4,
        ),
        Expanded(
          child: SlideTransition(
            position: _cardSlide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _scenarioCard(s),
                const SizedBox(height: 22),
                if (!_answered) ...[
                  const Text('Cet usage de l\'IA est…',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _choiceBtn(ScenarioType.good, '✅  Bon usage',
                      'Recommandé sans restriction', AppTheme.success),
                  const SizedBox(height: 10),
                  _choiceBtn(ScenarioType.caution, '⚠️  Avec précautions',
                      'Possible mais à valider', AppTheme.caution),
                  const SizedBox(height: 10),
                  _choiceBtn(ScenarioType.forbidden, '❌  Usage interdit',
                      'À proscrire absolument', AppTheme.error),
                ] else ...[
                  _feedback(s),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.modeScenario,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _idx < _scenarios.length - 1
                            ? 'Scénario suivant →'
                            : 'Voir mes résultats →',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty() => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
            backgroundColor: AppTheme.modeScenario,
            foregroundColor: Colors.white,
            title: const Text('Mises en Situation')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🔒', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('Pas assez de scénarios disponibles',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                  textAlign: TextAlign.center),
              SizedBox(height: 8),
              Text('Activez la catégorie "Usages CD" dans les Paramètres ⚙️',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      );

  Widget _scenarioCard(Scenario s) => Container(
        decoration: AppTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.modeScenario.withValues(alpha: 0.1),
                AppTheme.modeScenario.withValues(alpha: 0.04),
              ]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              Text(s.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(s.title,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.modeScenario))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text('Situation',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              Text(s.description,
                  style: const TextStyle(
                      fontSize: 14.5, height: 1.5, color: AppTheme.textPrimary)),
            ]),
          ),
        ]),
      );

  Widget _choiceBtn(ScenarioType t, String label, String sub, Color color) =>
      GestureDetector(
        onTap: () => _select(t),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 15)),
              const SizedBox(height: 2),
              Text(sub,
                  style: TextStyle(
                      color: color.withValues(alpha: 0.65), fontSize: 12)),
            ])),
            Icon(Icons.arrow_forward_ios,
                color: color.withValues(alpha: 0.4), size: 15),
          ]),
        ),
      );

  Widget _feedback(Scenario s) {
    final ok = _selected == s.correctType;
    final color = ok ? AppTheme.success : AppTheme.error;
    final tc = _typeColor(s.correctType);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(ok ? 'Bien évalué !' : 'Pas exactement…',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ]),
        if (!ok) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Text('Bonne réponse : ',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tc.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tc.withValues(alpha: 0.35)),
              ),
              child: Text(_typeLabel(s.correctType),
                  style: TextStyle(
                      color: tc,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ]),
        ],
        const SizedBox(height: 10),
        Text(s.explanation,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
      ]),
    );
  }

  String _typeLabel(ScenarioType t) => switch (t) {
        ScenarioType.good => '✅ Bon usage',
        ScenarioType.caution => '⚠️ Avec précautions',
        ScenarioType.forbidden => '❌ Usage interdit',
      };

  Color _typeColor(ScenarioType t) => switch (t) {
        ScenarioType.good => AppTheme.success,
        ScenarioType.caution => AppTheme.caution,
        ScenarioType.forbidden => AppTheme.error,
      };
}
