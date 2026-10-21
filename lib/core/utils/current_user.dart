import 'package:firebase_auth/firebase_auth.dart';

class CurrentUserHolder {
  static String? activeUid;
  static String? cachedUserName;
  static String? cachedPhotoUrl;
}

extension CurrentUserId on FirebaseAuth {
  /// uid المستخدم الحالي، أو المستخدم النشط، أو مستخدم الاختبار المعتمد.
  String get requireUid {
    final uid = currentUser?.uid;
    return uid ?? CurrentUserHolder.activeUid ?? 'Bhcw0EQI34VL5k6aDe4tWiEzH153';
  }
}
