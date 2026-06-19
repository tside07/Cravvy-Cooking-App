/// A single paragraph of legal text, optionally with a subtitle.
class LegalContent {
  final String? subtitle;
  final String text;

  const LegalContent({
    this.subtitle,
    required this.text,
  });
}
