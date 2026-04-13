import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/quiz_data.dart';
import 'result_page.dart';

class MatchPage extends StatefulWidget {
  final List<MatchSet> sets;
  const MatchPage({super.key, required this.sets});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> with SingleTickerProviderStateMixin {
  late List<MatchSet> _sets;
  int _setIdx = 0;
  int _score = 0;

  // Per-round state
  late List<int> _termOrder;
  late List<int> _defOrder;
  int? _selectedTermIdx; // index into _termOrder
  Set<int> _matched = {};
  Set<int> _errorTermIdx = {};
  Set<int> _errorDefIdx = {};

  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.sets)..shuffle();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _initRound();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _initRound() {
    final n = _sets[_setIdx].pairs.length;
    _termOrder = List.generate(n, (i) => i)..shuffle();
    _defOrder = List.generate(n, (i) => i)..shuffle();
    _selectedTermIdx = null;
    _matched = {};
    _errorTermIdx = {};
    _errorDefIdx = {};
  }

  void _tapTerm(int listIdx) {
    final pairIdx = _termOrder[listIdx];
    if (_matched.contains(pairIdx)) return;
    setState(() {
      _selectedTermIdx = listIdx;
      _errorTermIdx = {};
      _errorDefIdx = {};
    });
  }

  void _tapDef(int listIdx) {
    if (_selectedTermIdx == null) return;
    final termPairIdx = _termOrder[_selectedTermIdx!];
    final defPairIdx = _defOrder[listIdx];

    if (termPairIdx == defPairIdx) {
      // Correct match
      setState(() {
        _matched.add(termPairIdx);
        _selectedTermIdx = null;
        _errorTermIdx = {};
        _errorDefIdx = {};
      });
      if (_matched.length == _sets[_setIdx].pairs.length) {
        _score++;
        Future.delayed(const Duration(milliseconds: 600), _nextSet);
      }
    } else {
      // Wrong
      setState(() {
        _errorTermIdx = {_selectedTermIdx!};
        _errorDefIdx = {listIdx};
      });
      _shakeCtrl.forward(from: 0).then((_) {
        if (!mounted) return;
        setState(() {
          _errorTermIdx = {};
          _errorDefIdx = {};
          _selectedTermIdx = null;
        });
      });
    }
  }

  void _nextSet() {
    if (_setIdx < _sets.length - 1) {
      setState(() {
        _setIdx++;
        _initRound();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: _score,
            total: _sets.length,
            mode: 'match',
            gameBuilder: () => MatchPage(sets: widget.sets),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sets.isEmpty) return _buildEmpty();
    final set = _sets[_setIdx];
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.modeMatch,
        foregroundColor: Colors.white,
        title: Text('Paire ${_setIdx + 1} / ${_sets.length}',
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
            value: (_setIdx + 1) / _sets.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.modeMatch),
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(set.title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('Associez chaque terme à sa définition',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                _buildProgress(set),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTermsColumn(set)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDefsColumn(set)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(MatchSet set) {
    return Row(
      children: List.generate(set.pairs.length, (i) {
        final matched = _matched.contains(i);
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: matched
                  ? AppTheme.success
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTermsColumn(MatchSet set) {
    return Column(
      children: List.generate(_termOrder.length, (listIdx) {
        final pairIdx = _termOrder[listIdx];
        final pair = set.pairs[pairIdx];
        final isMatched = _matched.contains(pairIdx);
        final isSelected = _selectedTermIdx == listIdx;
        final isError = _errorTermIdx.contains(listIdx);

        Color bg, border;
        if (isMatched) {
          bg = AppTheme.success.withValues(alpha: 0.12);
          border = AppTheme.success;
        } else if (isError) {
          bg = AppTheme.error.withValues(alpha: 0.12);
          border = AppTheme.error;
        } else if (isSelected) {
          bg = AppTheme.modeMatch.withValues(alpha: 0.15);
          border = AppTheme.modeMatch;
        } else {
          bg = Colors.white;
          border = const Color(0xFFDDE1E7);
        }

        return GestureDetector(
          onTap: isMatched ? null : () => _tapTerm(listIdx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.5),
              boxShadow: isSelected
                  ? [BoxShadow(
                      color: AppTheme.modeMatch.withValues(alpha: 0.2),
                      blurRadius: 8, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Row(children: [
              Expanded(
                child: Text(pair.term,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isMatched
                            ? AppTheme.success
                            : isSelected
                                ? AppTheme.modeMatch
                                : AppTheme.textPrimary)),
              ),
              if (isMatched)
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 16),
              if (isSelected)
                Icon(Icons.arrow_forward_rounded,
                    color: AppTheme.modeMatch, size: 16),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildDefsColumn(MatchSet set) {
    return Column(
      children: List.generate(_defOrder.length, (listIdx) {
        final pairIdx = _defOrder[listIdx];
        final pair = set.pairs[pairIdx];
        final isMatched = _matched.contains(pairIdx);
        final isError = _errorDefIdx.contains(listIdx);
        final canTap = _selectedTermIdx != null && !isMatched;

        Color bg, border;
        if (isMatched) {
          bg = AppTheme.success.withValues(alpha: 0.12);
          border = AppTheme.success;
        } else if (isError) {
          bg = AppTheme.error.withValues(alpha: 0.12);
          border = AppTheme.error;
        } else if (canTap) {
          bg = Colors.white;
          border = AppTheme.modeMatch.withValues(alpha: 0.4);
        } else {
          bg = Colors.white;
          border = const Color(0xFFDDE1E7);
        }

        return GestureDetector(
          onTap: (isMatched || _selectedTermIdx == null)
              ? null
              : () => _tapDef(listIdx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(children: [
              if (isMatched)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_circle_rounded,
                      color: AppTheme.success, size: 16),
                ),
              Expanded(
                child: Text(pair.definition,
                    style: TextStyle(
                        fontSize: 12,
                        color: isMatched
                            ? AppTheme.success
                            : AppTheme.textPrimary,
                        height: 1.4)),
              ),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildEmpty() => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
            backgroundColor: AppTheme.modeMatch,
            foregroundColor: Colors.white,
            title: const Text('Associe les Paires')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🔒', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('Pas assez de paires disponibles',
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
