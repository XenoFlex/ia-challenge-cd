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
  int _currentIndex = 0;
  int _score = 0;
  ScenarioType? _selectedType;
  bool _answered = false;

  late AnimationController _cardController;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _selectType(ScenarioType type) {
    if (_answered) return;
    setState(() {
      _selectedType = type;
      _answered = true;
      if (type == widget.scenarios[_currentIndex].correctType) _score++;
    });
  }

  void _next() {
    if (_currentIndex < widget.scenarios.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedType = null;
        _answered = false;
      });
      _cardController.reset();
      _cardController.forward();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _score,
            total: widget.scenarios.length,
            mode: 'scenario',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = widget.scenarios[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.modeScenario,
        foregroundColor: Colors.white,
        title: Text(
          'Scénario ${_currentIndex + 1} / ${widget.scenarios.length}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.scenarios.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.modeScenario),
            minHeight: 4,
          ),
          Expanded(
            child: SlideTransition(
              position: _cardSlide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildScenarioCard(scenario),
                    const SizedBox(height: 22),
                    if (!_answered) ...[
                      const Text(
                        'Cet usage de l\'IA est…',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildChoiceButton(
                        type: ScenarioType.good,
                        label: '✅  Bon usage',
                        sublabel: 'Recommandé sans restriction',
                        color: AppTheme.success,
                      ),
                      const SizedBox(height: 10),
                      _buildChoiceButton(
                        type: ScenarioType.caution,
                        label: '⚠️  Avec précautions',
                        sublabel: 'Possible mais à valider',
                        color: AppTheme.caution,
                      ),
                      const SizedBox(height: 10),
                      _buildChoiceButton(
                        type: ScenarioType.forbidden,
                        label: '❌  Usage interdit',
                        sublabel: 'À proscrire absolument',
                        color: AppTheme.error,
                      ),
                    ] else ...[
                      _buildFeedback(scenario),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.modeScenario,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentIndex < widget.scenarios.length - 1
                                ? 'Scénario suivant →'
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
        ],
      ),
    );
  }

  Widget _buildScenarioCard(Scenario scenario) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.modeScenario.withOpacity(0.1),
                  AppTheme.modeScenario.withOpacity(0.04),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(scenario.icon,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    scenario.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.modeScenario,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    'Situation',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  scenario.description,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required ScenarioType type,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _selectType(type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(
                        color: color.withOpacity(0.65), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: color.withOpacity(0.4), size: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(Scenario scenario) {
    final isCorrect = _selectedType == scenario.correctType;
    final typeColor = _typeColor(scenario.correctType);
    final color = isCorrect ? AppTheme.success : AppTheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isCorrect ? '✅' : '❌',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Bien évalué !' : 'Pas exactement…',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Bonne réponse : ',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withOpacity(0.35)),
                  ),
                  child: Text(
                    _typeLabel(scenario.correctType),
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            scenario.explanation,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(ScenarioType type) {
    switch (type) {
      case ScenarioType.good:
        return '✅ Bon usage';
      case ScenarioType.caution:
        return '⚠️ Avec précautions';
      case ScenarioType.forbidden:
        return '❌ Usage interdit';
    }
  }

  Color _typeColor(ScenarioType type) {
    switch (type) {
      case ScenarioType.good:
        return AppTheme.success;
      case ScenarioType.caution:
        return AppTheme.caution;
      case ScenarioType.forbidden:
        return AppTheme.error;
    }
  }
}
