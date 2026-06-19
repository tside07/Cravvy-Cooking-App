/// Cache key segment for Home featured subset (meal type + optional quick tag).
String buildFeaturedFilterKey(String mealType, String? tag) {
  return '$mealType|${tag ?? ''}';
}
