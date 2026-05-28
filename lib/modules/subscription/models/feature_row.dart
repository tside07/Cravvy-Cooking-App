/// Model cho một hàng trong bảng so sánh tính năng Free vs Premium.
class FeatureRow {
  final String label;
  final String freeVal;
  final String premiumVal;
  final bool freeCheck;
  final bool premiumCheck;

  const FeatureRow({
    required this.label,
    this.freeVal = '',
    this.premiumVal = '',
    this.freeCheck = false,
    this.premiumCheck = false,
  });
}
