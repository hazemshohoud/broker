import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/withdrawal.dart';

extension PayoutMethodTypeX on PayoutMethodType {
  String get label => switch (this) {
    PayoutMethodType.instaPay => 'إنستاباي',
    PayoutMethodType.wallet => 'المحفظة الإلكترونية',
  };

  IconData get icon => switch (this) {
    PayoutMethodType.instaPay => IconsaxPlusLinear.bank,
    PayoutMethodType.wallet => IconsaxPlusLinear.wallet_3,
  };
}

extension CommissionStatusX on CommissionStatus {
  /// (الليبل، اللون) بتاع بادج الحالة.
  (String, Color) get badge => switch (this) {
    CommissionStatus.pending => ('قيد الاعتماد', AppColors.accent),
    CommissionStatus.approved => ('معتمدة', AppColors.success),
  };
}

extension WithdrawalStatusX on WithdrawalStatus {
  (String, Color) get badge => switch (this) {
    WithdrawalStatus.pending => ('قيد التنفيذ', AppColors.accent),
    WithdrawalStatus.completed => ('تم التحويل', AppColors.success),
    WithdrawalStatus.rejected => ('مرفوض', AppColors.favorite),
  };
}
