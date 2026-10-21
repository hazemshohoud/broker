class ArabicSearchHelper {
  const ArabicSearchHelper._();

  /// إزالة التشكيل وتوحيد الحروف العربية لتسهيل البحث
  static String normalize(String input) {
    var text = input.trim().toLowerCase();

    // إزالة التشكيل وحركات الإعراب
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // إزالة التطويل (ـ)
    text = text.replaceAll('\u0640', '');

    // توحيد الألفات (أ، إ، آ، ٱ -> ا)
    text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // توحيد التاء المربوطة (ة -> ه)
    text = text.replaceAll('ة', 'ه');

    // توحيد الياء والألف المقصورة (ى -> ي)
    text = text.replaceAll('ى', 'ي');

    // إزالة المسافات المتكررة
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text;
  }

  /// التحقق من مطابقة الاستعلام لأي من النصوص المستهدفة
  /// يدعم البحث متعدد الكلمات (Multi-word query)
  static bool matchesQuery({
    required String query,
    required Iterable<String?> targets,
  }) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return true;

    final tokens = normalizedQuery
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.isEmpty) return true;

    final combinedTarget = targets
        .where((t) => t != null && t.trim().isNotEmpty)
        .map((t) => normalize(t!))
        .join(' ');

    // يجب أن تكون كل كلمة في الاستعلام موجودة داخل النصوص المجمعة
    return tokens.every((token) => combinedTarget.contains(token));
  }
}
