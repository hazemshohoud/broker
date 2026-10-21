import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_top_header.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/entities/broker_profile.dart';
import '../cubit/account_cubit.dart';
import 'terms_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountCubit>()..load(),
      child: const AccountView(),
    );
  }
}

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('متأكد إنك عايز تسجّل خروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AccountCubit>().signOut();
    }
  }

  void _openEditPayoutSheet(BuildContext context, BrokerProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<AccountCubit>(),
        child: _EditPayoutSheet(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == AccountStatus.signedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            appBar: const AppTopHeader(),
            body: _buildBody(context, state, profile),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AccountState state,
    BrokerProfile? profile,
  ) {
    if (state.status == AccountStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == AccountStatus.failure || profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'حدث خطأ غير متوقع'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<AccountCubit>().load(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: context.read<AccountCubit>().load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 160),
        children: [
          _ProfileHeaderCard(
            fullName: profile.fullName,
            photoUrl: profile.photoUrl,
            isApproved: profile.isApproved,
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'البيانات الشخصية',
            children: [
              _InfoRow(
                icon: IconsaxPlusLinear.user,
                label: 'الاسم',
                value: profile.fullName,
              ),
              _InfoRow(
                icon: IconsaxPlusLinear.call,
                label: 'رقم الهاتف',
                value: profile.phone,
              ),
              _InfoRow(
                icon: IconsaxPlusLinear.message,
                label: 'رقم الواتساب',
                value: profile.whatsapp,
              ),
              _InfoRow(
                icon: IconsaxPlusLinear.location,
                label: 'المحافظة',
                value: profile.governorate,
              ),
              _InfoRow(
                icon: IconsaxPlusLinear.calendar,
                label: 'تاريخ الميلاد',
                value: Formatters.date(profile.birthDate),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'طرق استلام العمولات',
            action: TextButton.icon(
              onPressed: () => _openEditPayoutSheet(context, profile),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                foregroundColor: AppColors.brandDark,
              ),
              icon: const Icon(IconsaxPlusLinear.edit_2, size: 16),
              label: const Text(
                'تعديل',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
            children: [
              if (profile.instaPayNumber != null && profile.instaPayNumber!.isNotEmpty)
                _InfoRow(
                  icon: IconsaxPlusLinear.bank,
                  label: 'رقم الإنستاباي',
                  value: profile.instaPayNumber!,
                  isLast: profile.walletNumber == null || profile.walletNumber!.isEmpty,
                ),
              if (profile.walletNumber != null && profile.walletNumber!.isNotEmpty)
                _InfoRow(
                  icon: IconsaxPlusLinear.wallet_3,
                  label: 'رقم المحفظة الإلكترونية',
                  value: profile.walletNumber!,
                  isLast: true,
                ),
              if ((profile.instaPayNumber == null || profile.instaPayNumber!.isEmpty) &&
                  (profile.walletNumber == null || profile.walletNumber!.isEmpty))
                _InfoRow(
                  icon: IconsaxPlusLinear.wallet_3,
                  label: 'وسائل الاستلام',
                  value: 'لم تسجل وسيلة استلام (اضغط تعديل لإضافتها)',
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'عام',
            children: [
              _ActionRow(
                icon: IconsaxPlusLinear.document_text,
                label: 'الشروط والأحكام',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TermsPage()),
                ),
              ),
              _ActionRow(
                icon: IconsaxPlusLinear.logout,
                label: 'تسجيل الخروج',
                danger: true,
                isLast: true,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.action,
  });

  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 20, color: AppColors.brand),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = danger ? AppColors.favorite : AppColors.brand;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.borderLight),
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: danger ? AppColors.favorite : null,
                  ),
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.fullName,
    this.photoUrl,
    required this.isApproved,
  });

  final String fullName;
  final String? photoUrl;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brand.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.brand, width: 2),
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl!.isNotEmpty
                  ? Image.network(
                      CloudinaryService.optimizeUrl(
                        photoUrl!,
                        width: 128,
                        height: 128,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackLetter(),
                    )
                  : _fallbackLetter(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    if (isApproved) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        IconsaxPlusBold.verify,
                        color: AppColors.brandDark,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isApproved ? 'وسيط عقاري معتمد' : 'حساب قيد المراجعة',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isApproved ? AppColors.brandDark : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackLetter() {
    return Center(
      child: Text(
        fullName.isNotEmpty ? fullName.characters.first : 'و',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.brandDark,
        ),
      ),
    );
  }
}

class _EditPayoutSheet extends StatefulWidget {
  const _EditPayoutSheet({required this.profile});

  final BrokerProfile profile;

  @override
  State<_EditPayoutSheet> createState() => _EditPayoutSheetState();
}

class _EditPayoutSheetState extends State<_EditPayoutSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _instaPayController;
  late final TextEditingController _walletController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _instaPayController = TextEditingController(text: widget.profile.instaPayNumber ?? '');
    _walletController = TextEditingController(text: widget.profile.walletNumber ?? '');
  }

  @override
  void dispose() {
    _instaPayController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final instaPay = _instaPayController.text.trim();
    final wallet = _walletController.text.trim();

    if (instaPay.isEmpty && wallet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال حساب إنستاباي أو رقم محفظة إلكترونية على الأقل'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await context.read<AccountCubit>().savePayoutDetails(
      instaPayNumber: instaPay.isNotEmpty ? instaPay : null,
      walletNumber: wallet.isNotEmpty ? wallet : null,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(IconsaxPlusBold.tick_circle, color: AppColors.brand, size: 20),
                SizedBox(width: 8),
                Text('تم حفظ بيانات الدفع بنجاح'),
              ],
            ),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final systemBottom = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, (systemBottom > 0 ? systemBottom : 12) + 16 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconsaxPlusBold.wallet_3, color: AppColors.brandDark, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'تعديل طرق استلام العمولات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'يمكنك إدخال حساب انستاباي أو رقم المحفظة الإلكترونية أو كلاهما لتلقي العمولات.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppFormField(
                  label: 'رقم أو عنوان إنستاباي (InstaPay)',
                  controller: _instaPayController,
                  hint: 'مثال: name@instapay أو 01012345678',
                  prefixIcon: IconsaxPlusLinear.bank,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppFormField(
                  label: 'رقم المحفظة الإلكترونية (كاش)',
                  controller: _walletController,
                  hint: '010... / 011... / 012... / 015...',
                  keyboardType: TextInputType.phone,
                  prefixIcon: IconsaxPlusLinear.wallet_3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: 'حفظ التعديلات',
                  loading: _isSaving,
                  onPressed: _save,
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


