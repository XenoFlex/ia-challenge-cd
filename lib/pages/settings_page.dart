import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Paramètres'),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: SettingsProvider.instance,
        builder: (context, _) {
          final s = SettingsProvider.instance;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Mon niveau'),
                const SizedBox(height: 4),
                _sub("Adapte les questions à votre maîtrise de l'IA"),
                const SizedBox(height: 14),
                _buildLevelSelector(s),
                const SizedBox(height: 28),
                _label('Mes catégories'),
                const SizedBox(height: 4),
                _sub('Sélectionnez les thèmes à explorer'),
                const SizedBox(height: 14),
                _buildCategoryToggles(s),
                const SizedBox(height: 20),
                _buildNote(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      );

  Widget _sub(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
      );

  Widget _buildLevelSelector(SettingsProvider s) {
    return Row(
      children: Difficulty.values.map((d) {
        final isSelected = s.difficulty == d;
        final isLast = d == Difficulty.advanced;
        return Expanded(
          child: GestureDetector(
            onTap: () => s.setDifficulty(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? d.color : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? d.color : Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: d.color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Text(d.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 6),
                  Text(
                    d.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    d.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryToggles(SettingsProvider s) {
    return Column(
      children: QuizCategory.values.map((cat) {
        final on = s.isCategoryEnabled(cat);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: on ? cat.color.withValues(alpha: 0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: on
                    ? cat.color.withValues(alpha: 0.4)
                    : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: on ? 0.15 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child:
                        Text(cat.emoji, style: const TextStyle(fontSize: 20))),
              ),
              title: Text(
                cat.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: on ? cat.color : AppTheme.textSecondary,
                ),
              ),
              subtitle: Text(
                cat.description,
                style: const TextStyle(
                    fontSize: 11.5, color: AppTheme.textSecondary),
              ),
              trailing: Switch.adaptive(
                value: on,
                onChanged: (_) => s.toggleCategory(cat),
                activeThumbColor: cat.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: const Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Les paramètres s'appliquent à tous les modes. Au moins une catégorie doit rester active.",
              style: TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
