import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// أيقونة الهاتف المخصصة لحقول الإدخال بصيغة SVG
class AppPhoneFieldIcon extends StatelessWidget {
  const AppPhoneFieldIcon({
    super.key,
    this.size = 20,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/login_phone_icon.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            color ?? AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

/// أيقونة كلمة المرور المخصصة لحقول الإدخال بصيغة SVG
class AppPasswordFieldIcon extends StatelessWidget {
  const AppPasswordFieldIcon({
    super.key,
    this.size = 20,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/login_password_icon.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            color ?? AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

/// ليبل فوق الحقل — الستايل الموحد لكل فورمات التطبيق.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixWidget ??
                (prefixIcon == null
                    ? null
                    : Icon(prefixIcon, size: 20, color: AppColors.textSecondary)),
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// حقل كلمة المرور بزرار إظهار/إخفاء بدون تقييد لـ 4 أرقام.
class AppPinField extends StatefulWidget {
  const AppPinField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '••••••••',
    this.validator,
    this.textInputAction,
    this.keyboardType = TextInputType.visiblePassword,
    this.prefixWidget,
    this.prefixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final TextInputType keyboardType;
  final Widget? prefixWidget;
  final IconData? prefixIcon;

  @override
  State<AppPinField> createState() => _AppPinFieldState();
}

class _AppPinFieldState extends State<AppPinField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _hidden,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      prefixWidget: widget.prefixWidget ??
          (widget.prefixIcon != null
              ? null
              : const AppPasswordFieldIcon()),
      prefixIcon: widget.prefixIcon,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
