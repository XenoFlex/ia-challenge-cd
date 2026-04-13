import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import 'result_page.dart';

class OrderPage extends StatefulWidget {
  final List<OrderChallenge> challenges;
  const OrderPage({super.key, required this.challenges});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  late List<OrderChallenge> _challenges;
  int _idx = 0;
  int _score = 0;

  late List<String> _items;
  bool _submitted = false;
  late List<bool> _correct;

  late AnimationController _cardCtrl;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _challenges = List.from(widget.challenges)..shuffle();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _cardSlide = Tween<Offset>(
            begin: const Offset(0.12, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _initChallenge();
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  void _initChallenge() {
    final ch = _challenges[_idx];
    _items = List.from(ch.correctOrder)..shuffle();
    _submitted = false;
    _correct = [];
  }

  void _submit() {
    final ch = _challenges[_idx];
    bool allCorrect = true;
    final c = List.generate(_items.length, (i) {
      final ok = _items[i] == ch.correctOrder[i];
      if (!ok) allCorrect = false;
      return ok;
    });
    setState(() {
      _submitted = true;
      _correct = c;
      if (allCorrect) _score++;
    });
  }

  void _next() {
    if (_idx < _challenges.length - 1) {
      setState(() {
        _idx++;
        _initChallenge();
      });
      _cardCtrl.reset();
      _cardCtrl.forward();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _score,
            total: _challenges.length,
            mode: 'order',
            gameBuilder: () => OrderPage(challenges: widget.challenges),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_challenges.isEmpty) return _buildEmpty();
    final ch = _challenges[_idx];
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.modeOrder,
        foregroundColor: Colors.white,
        title: Text('Étape ${_idx + 1} / ${_challenges.length}',
            style: const TextStyle(fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          LinearProgressIndicator(
            value: (_idx + 1) / _challenges.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.modeOrder),
            minHeight: 4,
          ),
          Expanded(
            child: SlideTransition(
              position: _cardSlide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerCard(ch),
                    const SizedBox(height: 16),
                    if (!_submitted) ...[
                      const Text('Glissez pour réordonner :',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 10),
                      _buildReorderable(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.modeOrder,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Valider mon ordre →',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else ...[
                      const Text('Résultat :',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 10),
                      _buildResult(ch),
                      const SizedBox(height: 16),
                      _buildExplanation(ch),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.modeOrder,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _idx < _challenges.length - 1
                                ? 'Défi suivant →'
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
        ],
      ),
    );
  }

  Widget _headerCard(OrderChallenge ch) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.modeOrder.withValues(alpha: 0.1),
            AppTheme.modeOrder.withValues(alpha: 0.03),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.modeOrder.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('📋', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(ch.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.modeOrder)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(ch.instruction,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary, height: 1.4)),
        ]),
      );

  Widget _buildReorderable() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      onReorder: (oldIdx, newIdx) {
        setState(() {
          if (newIdx > oldIdx) newIdx--;
          final item = _items.removeAt(oldIdx);
          _items.insert(newIdx, item);
        });
      },
      itemBuilder: (_, i) {
        return _draggableItem(_items[i], i, key: ValueKey(_items[i]));
      },
    );
  }

  Widget _draggableItem(String text, int i, {required Key key}) => Container(
        key: key,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE1E7), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.modeOrder.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('${i + 1}',
                  style: const TextStyle(
                      color: AppTheme.modeOrder,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          title: Text(text,
              style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.drag_handle_rounded,
              color: AppTheme.textSecondary, size: 20),
        ),
      );

  Widget _buildResult(OrderChallenge ch) {
    return Column(
      children: List.generate(_items.length, (i) {
        final ok = _correct.isNotEmpty && _correct[i];
        final color = ok ? AppTheme.success : AppTheme.error;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('${i + 1}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_items[i],
                    style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600)),
                if (!ok) ...[
                  const SizedBox(height: 2),
                  Text('Attendu : ${ch.correctOrder[i]}',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic)),
                ],
              ]),
            ),
            Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color, size: 18),
          ]),
        );
      }),
    );
  }

  Widget _buildExplanation(OrderChallenge ch) {
    final allOk = _correct.every((c) => c);
    final color = allOk ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(allOk ? '✅' : '💡', style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(allOk ? 'Parfait !' : 'Voici le bon ordre :',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14)),
            const SizedBox(height: 4),
            Text(ch.explanation,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEmpty() => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
            backgroundColor: AppTheme.modeOrder,
            foregroundColor: Colors.white,
            title: const Text('Ordonne les Étapes')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🔒', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('Pas assez de défis disponibles',
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
