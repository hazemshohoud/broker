import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/commission.dart';
import '../../domain/entities/withdrawal.dart';

Commission commissionFromFirestore(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  final title = data['title']?.toString() ??
      data['compoundName']?.toString() ??
      data['name']?.toString() ??
      '';
  return Commission(
    id: doc.id,
    title: title,
    details: data['details']?.toString(),
    amount: _numToDouble(data['amount']),
    status: data['status'] == 'approved'
        ? CommissionStatus.approved
        : CommissionStatus.pending,
    createdAt: _date(data['createdAt']),
  );
}

Withdrawal withdrawalFromFirestore(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  return Withdrawal(
    id: doc.id,
    amount: _numToDouble(data['amount']),
    method: PayoutMethod(
      type: methodFromString(data['method']?.toString()),
      number: data['methodNumber']?.toString() ??
          data['phone']?.toString() ??
          '',
    ),
    status: switch (data['status']?.toString()) {
      'completed' => WithdrawalStatus.completed,
      'rejected' => WithdrawalStatus.rejected,
      _ => WithdrawalStatus.pending,
    },
    createdAt: _date(data['createdAt']),
  );
}

/// وسائل الاستلام المسجلة في مستند التسجيل.
List<PayoutMethod> payoutMethodsFromRegistration(Map<String, dynamic>? data) {
  if (data == null) return const [];
  final insta = data['instaPayNumber']?.toString().trim() ?? '';
  final wallet = data['walletNumber']?.toString().trim() ?? '';
  final phone = data['phone']?.toString().trim() ?? '';

  final list = <PayoutMethod>[];
  if (insta.isNotEmpty) {
    list.add(PayoutMethod(type: PayoutMethodType.instaPay, number: insta));
  }
  if (wallet.isNotEmpty) {
    list.add(PayoutMethod(type: PayoutMethodType.wallet, number: wallet));
  } else if (phone.isNotEmpty && list.isEmpty) {
    // المحفظة الافتراضية بنفس رقم الهاتف
    list.add(PayoutMethod(type: PayoutMethodType.wallet, number: phone));
  }
  return list;
}

Map<String, Object?> withdrawalRequestToMap({
  required String brokerId,
  required double amount,
  required PayoutMethod method,
}) => {
  'brokerId': brokerId,
  'amount': amount,
  'method': methodToString(method.type),
  'methodNumber': method.number,
  'status': 'pending',
  'createdAt': FieldValue.serverTimestamp(),
};

/// الـ rules بتشترط القيم دي بالظبط.
String methodToString(PayoutMethodType type) => switch (type) {
  PayoutMethodType.instaPay => 'instapay',
  PayoutMethodType.wallet => 'wallet',
};

PayoutMethodType methodFromString(String? value) =>
    value == 'wallet' ? PayoutMethodType.wallet : PayoutMethodType.instaPay;

double _numToDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

DateTime _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.fromMillisecondsSinceEpoch(0);
}
