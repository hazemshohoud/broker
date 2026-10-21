abstract final class Validators {
  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  /// الاسم ثلاثي: ثلاث كلمات على الأقل.
  static String? fullName(String? value) {
    if (required(value) != null) return 'الاسم مطلوب';
    final parts = value!.trim().split(RegExp(r'\s+'));
    return parts.length >= 3 ? null : 'اكتب الاسم ثلاثي';
  }

  static String? egyptianPhone(String? value) {
    if (required(value) != null) return 'رقم الهاتف مطلوب';
    return RegExp(r'^01\d{9}$').hasMatch(value!.trim())
        ? null
        : 'رقم الهاتف غير صحيح';
  }

  static String? pin(String? value) {
    if (required(value) != null) return 'كلمة المرور مطلوبة';
    if (value!.trim().length < 4) return 'كلمة المرور يجب ألا تقل عن 4 خانات';
    return null;
  }

  static String? confirmPin(String? value, String pin) {
    if (required(value) != null) return 'تأكيد كلمة المرور مطلوب';
    return value!.trim() == pin ? null : 'كلمة المرور غير متطابقة';
  }
}
