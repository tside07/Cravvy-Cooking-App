/// One cooking instruction step (from `recipes.steps` in Supabase).
class CookingStep {
  const CookingStep({
    required this.number,
    required this.text,
    this.timerMinutes,
  });

  final int number;
  final String text;
  final int? timerMinutes;
}

/// Parses DB step strings into [CookingStep] rows (optional timer from text).
abstract final class RecipeCookingSteps {
  static final _timerPattern = RegExp(
    r'(\d+)\s*(?:'
    r'phút|phut|minute|minutes|min'
    r'|giây|giay|second|seconds|sec'
    r')',
    caseSensitive: false,
  );

  static List<CookingStep> fromStrings(List<String> raw) {
    final lines = raw.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return [
      for (var i = 0; i < lines.length; i++)
        CookingStep(
          number: i + 1,
          text: lines[i],
          timerMinutes: parseTimerMinutes(lines[i]),
        ),
    ];
  }

  /// Returns minutes if step text mentions a duration (e.g. "nấu 20 phút").
  static int? parseTimerMinutes(String text) {
    final match = _timerPattern.firstMatch(text);
    if (match == null) return null;

    final value = int.tryParse(match.group(1)!);
    if (value == null || value <= 0) return null;

    final unit = match.group(0)!.toLowerCase();
    if (unit.contains('giây') ||
        unit.contains('giay') ||
        unit.contains('sec')) {
      return (value / 60).ceil().clamp(1, 180);
    }
    return value.clamp(1, 180);
  }
}
