import 'package:flutter/material.dart';
import '../utils/question_text.dart';
import '../widgets/speak_button.dart';
import '../app_fonts.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/learning_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/app_button.dart';
import '../widgets/state_dropdown.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});
  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, int> _selectedAnswers = {};

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final filtered = learning.filteredQuestions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Lernen', style: roboto(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
      ),
      body: SafeArea(
        top: false, // AppBar handled top
        bottom: true, // Android Nav-Bar berücksichtigen
        child: filtered.isEmpty
            ? _buildEmptyState(context, learning)
            : Column(
                children: [
                  _buildProgressBar(learning),
                  _buildLanguageBar(learning),
                  _buildFilterBar(learning),
                  _buildQuestionMeta(context, learning, filtered),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildQuestionCard(context, learning, filtered),
                    ),
                  ),
                  _buildNavigation(context, learning, filtered),
                ],
              ),
      ),
    );
  }

  /// Sprachumschalter DE / EN / عربي
  Widget _buildLanguageBar(LearningProvider learning) {
    final langs = [
      {'code': 'de', 'label': 'DE'},
      {'code': 'en', 'label': 'EN'},
      {'code': 'ar', 'label': 'عربي'},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: langs.map((l) {
          final active = learning.viewLanguage == l['code'];
          return Expanded(
            child: GestureDetector(
              onTap: () => learning.setViewLanguage(l['code']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    l['label']!,
                    style: roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : _primary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressBar(LearningProvider learning) {
    final total = learning.totalQuestionCount;
    final learned = learning.learnedCount;
    final progress = total > 0 ? learned / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 6,
                backgroundColor: _surface,
                valueColor: const AlwaysStoppedAnimation<Color>(_primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$learned / $total', style: roboto(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(LearningProvider learning) {
    final showStatePicker = learning.filterCategory == QuestionCategory.bundesland;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          // Suchfeld
          SizedBox(
            height: 36,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => learning.setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'Suchen...',
                hintStyle: roboto(fontSize: 13, color: _textSecondary),
                prefixIcon: const Icon(Icons.search, size: 18, color: _textSecondary),
                border: InputBorder.none, filled: true, fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Kategorie-Chips (tappbar – funktioniert zuverlässig auf Flutter-Web)
          // Hinweis: kein setState(() {}) nötig, weil learning.setCategoryFilter
          // notifyListeners() ruft und context.watch<LearningProvider>() den
          // Rebuild auslöst.
          Row(
            children: [
              _filterChip('Alle', learning.filterCategory == null,
                  () => learning.setCategoryFilter(null)),
              const SizedBox(width: 8),
              _filterChip('Allgemein', learning.filterCategory == QuestionCategory.allgemein,
                  () => learning.setCategoryFilter(QuestionCategory.allgemein)),
              const SizedBox(width: 8),
              _filterChip('Bundesland', learning.filterCategory == QuestionCategory.bundesland,
                  () => learning.setCategoryFilter(QuestionCategory.bundesland)),
            ],
          ),
          // Themen + "Falsche" (horizontal scrollbar, spart Platz)
          if (!showStatePicker) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _smallChip(
                    'Falsche (${learning.wrongCount})',
                    learning.filterWrongOnly,
                    () => learning.setWrongOnly(!learning.filterWrongOnly),
                    icon: Icons.replay,
                  ),
                  for (final t in LearningProvider.topics)
                    _smallChip(
                      t,
                      learning.filterTopic == t,
                      () => learning.setTopicFilter(learning.filterTopic == t ? null : t),
                    ),
                ],
              ),
            ),
          ],
          // Bundesland-Auswahl (echter Dropdown) nur wenn Kategorie Bundesland
          if (showStatePicker) ...[
            const SizedBox(height: 8),
            StateDropdown(
              options: learning.availableStates,
              selected: learning.filterState,
              placeholder: 'Alle Bundesländer',
              leadingIcon: Icons.location_on_outlined,
              onSelected: (s) => learning.setStateFilter(s),
            ),
          ],
        ],
      ),
    );
  }

  /// Kleiner Chip mit eigener Breite (für die scrollbare Themen-Zeile).
  Widget _smallChip(String label, bool active, VoidCallback onTap, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? _primary : _surface,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: active ? Colors.white : _textSecondary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tappbarer Filter-Chip (gleiches Muster wie die funktionierende Sprachleiste).
  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 34,
          decoration: BoxDecoration(
            color: active ? _primary : _surface,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: roboto(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : _textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom-Sheet zur Auswahl eines Bundeslands. (Deprecated — verwendet jetzt StateDropdown.)
  // ignore: unused_element
  void _showStatePickerLegacy(LearningProvider learning) {
    final states = learning.availableStates;
    try {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text('Bundesland wählen',
                      style: roboto(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
                ),
                ListTile(
                  leading: Icon(learning.filterState == null ? Icons.check : null, color: _primary, size: 20),
                  title: Text('Alle Bundesländer', style: roboto(fontSize: 14, color: _textPrimary)),
                  onTap: () { learning.setStateFilter(null); Navigator.pop(ctx); },
                ),
                for (final s in states)
                  ListTile(
                    leading: Icon(learning.filterState == s ? Icons.check : null, color: _primary, size: 20),
                    title: Text(s, style: roboto(fontSize: 14, color: _textPrimary)),
                    onTap: () { learning.setStateFilter(s); Navigator.pop(ctx); },
                  ),
              ],
            ),
          );
        },
      );
    } catch (e, st) {
      debugPrint('LearningScreen: state picker FAILED: $e\n$st');
    }
  }

  Widget _buildQuestionMeta(BuildContext context, LearningProvider learning, List<Question> filtered) {
    if (filtered.isEmpty) return const SizedBox.shrink();
    final q = filtered[learning.currentIndex.clamp(0, filtered.length - 1)];
    final isBookmarked = learning.isBookmarked(q.id);
    final isLearned = learning.isLearned(q.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showJumpDialog(context, learning, filtered.length),
              child: Row(
                children: [
                  Flexible(
                    child: Text('${learning.currentIndex + 1} / ${filtered.length} · ${q.category.displayName}',
                      overflow: TextOverflow.ellipsis,
                      style: roboto(fontSize: 13, fontWeight: FontWeight.w500, color: _textSecondary)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.swap_vert, size: 16, color: _primary),
                  Text(' Springen', style: roboto(fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
                ],
              ),
            ),
          ),
          SpeakButton(
            key: ValueKey('speak_${q.id}_${learning.viewLanguage}'),
            text: formatQuestionForSpeech(q, lang: learning.viewLanguage),
            lang: learning.viewLanguage,
          ),
          GestureDetector(
            onTap: () => copyQuestion(context, q, lang: learning.viewLanguage),
            child: Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 4),
              child: const Icon(Icons.copy_rounded, color: _textTertiary, size: 19)),
          ),
          GestureDetector(
            onTap: () => learning.toggleLearned(q.id),
            child: Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: isLearned ? _success.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: Icon(isLearned ? Icons.check_circle : Icons.check_circle_outline, color: isLearned ? _success : _textTertiary, size: 20)),
          ),
          GestureDetector(
            onTap: () => learning.toggleBookmark(q.id),
            child: Container(width: 32, height: 32,
              decoration: BoxDecoration(color: isBookmarked ? _primary.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? _primary : _textTertiary, size: 20)),
          ),
        ],
      ),
    );
  }

  Future<void> _showJumpDialog(BuildContext context, LearningProvider learning, int total) async {
    final target = await showDialog<int>(
      context: context,
      builder: (ctx) => _JumpDialog(total: total),
    );
    if (target != null) learning.goToQuestion(target);
  }

  Widget _buildQuestionCard(BuildContext context, LearningProvider learning, List<Question> filtered) {
    final q = filtered[learning.currentIndex.clamp(0, filtered.length - 1)];
    final lang = learning.viewLanguage;
    final isRtl = lang == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: QuestionCard(
        questionNumber: learning.currentIndex + 1, totalQuestions: filtered.length,
        questionText: q.questionFor(lang), answers: q.answersFor(lang),
        answerImages: q.answerImages,
        imageAsset: q.image, imageCredit: q.imageCredit,
        selectedAnswer: _selectedAnswers[q.id], correctAnswer: q.correctAnswerIndex,
        showCorrectAnswer: _selectedAnswers.containsKey(q.id), category: q.category.displayName,
        onAnswerSelected: (index) {
          setState(() { _selectedAnswers[q.id] = index; });
          learning.recordAnswer(q.id, index == q.correctAnswerIndex);
        },
      ),
    );
  }

  Widget _buildNavigation(BuildContext context, LearningProvider learning, List<Question> filtered) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _surface, width: 1))),
      child: Row(
        children: [
          Expanded(child: AppButton(label: 'Zurück', isOutlined: true, isSmall: true,
            onPressed: learning.currentIndex > 0 ? learning.previousQuestion : null)),
          const SizedBox(width: 12),
          Expanded(child: AppButton(label: learning.currentIndex < filtered.length - 1 ? 'Weiter' : '🔁 Zufall', isSmall: true,
            onPressed: () {
              if (learning.currentIndex < filtered.length - 1) {
                learning.nextQuestion();
              } else {
                learning.goToRandomQuestion();
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LearningProvider learning) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(learning.filterWrongOnly ? Icons.celebration_outlined : Icons.search_off, size: 56, color: _textTertiary),
          const SizedBox(height: 16),
          Text(learning.filterWrongOnly ? 'Keine falschen Fragen' : 'Keine Fragen gefunden',
              style: roboto(fontSize: 16, fontWeight: FontWeight.w600, color: _textSecondary)),
          const SizedBox(height: 4),
          Text(learning.filterWrongOnly
                  ? 'Falsch beantwortete Fragen aus Tests und Lernmodus landen hier.'
                  : 'Versuche es mit einer anderen Suche',
              textAlign: TextAlign.center,
              style: roboto(fontSize: 13, color: _textTertiary)),
          const SizedBox(height: 24),
          AppButton(label: 'Filter zurücksetzen', isOutlined: true, isSmall: true,
            onPressed: () { learning.clearAllFilters(); _searchController.clear(); setState(() {}); }),
        ],
      ),
    );
  }
}

/// Dialog "Zu Frage springen" -- verwaltet seinen Eingabe-Controller selbst,
/// damit er erst nach dem Ausblenden des Dialogs freigegeben wird.
class _JumpDialog extends StatefulWidget {
  final int total;
  const _JumpDialog({required this.total});

  @override
  State<_JumpDialog> createState() => _JumpDialogState();
}

class _JumpDialogState extends State<_JumpDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_controller.text.trim());
    if (n != null && n >= 1 && n <= widget.total) Navigator.pop(context, n - 1);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Zu Frage springen',
          style: roboto(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: 'Nummer (1 – ${widget.total})'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        TextButton(onPressed: _submit, child: const Text('Springen')),
      ],
    );
  }
}
