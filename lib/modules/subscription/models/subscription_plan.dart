// Model cho một gói đăng ký (Free / Monthly / Annual)
class SubscriptionPlan {
  final String id;
  final String name;
  final String priceLabel;
  final String priceNote;
  final String? badge;
  final bool highlight;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceLabel,
    required this.priceNote,
    this.badge,
    this.highlight = false,
  });
}
