/// يبني بيانات اعتماد Firebase Auth من رقم الهاتف والـ PIN.
/// Firebase Auth يشترط إيميل وباسورد ≥6 أحرف، فبنشتقهم من رقم
/// الهاتف والـ PIN (4 أرقام) — المستخدم لسه بيدخل 4 أرقام فقط.
abstract final class AuthCredentials {
  static const _emailDomain = 'broker.app';
  static const _passwordSuffix = '#b';

  static String emailForPhone(String phone) => '${phone.trim()}@$_emailDomain';

  static String passwordForPin(String pin) {
    final clean = pin.trim();
    if (clean.length < 6) {
      return '$clean$_passwordSuffix';
    }
    return clean;
  }
}
