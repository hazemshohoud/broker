import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_form_field.dart';

const defaultGovernorate = 'بني سويف';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.whatsappController,
    required this.pinController,
    required this.pinConfirmController,
    required this.birthDate,
    required this.onBirthDateChanged,
    required this.photo,
    required this.onPhotoChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController pinController;
  final TextEditingController pinConfirmController;
  final DateTime? birthDate;
  final ValueChanged<DateTime> onBirthDateChanged;
  final XFile? photo;
  final ValueChanged<XFile?> onPhotoChanged;

  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18),
    );
    if (picked != null) onBirthDateChanged(picked);
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 80,
    );
    if (picked != null) onPhotoChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                InkWell(
                  onTap: _pickPhoto,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.chipBackground,
                      border: Border.all(color: AppColors.border),
                      image: photo == null
                          ? null
                          : DecorationImage(
                              image: FileImage(File(photo!.path)),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: photo == null
                        ? const Icon(
                            Icons.add_a_photo_outlined,
                            size: 30,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'صورة (اختياري)',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'الاسم ثلاثي',
            hint: 'مثال: أحمد محمد علي',
            controller: nameController,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: Validators.fullName,
          ),
          _gap,
          FormField<DateTime>(
            initialValue: birthDate,
            validator: (_) => birthDate == null ? 'تاريخ الميلاد مطلوب' : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFormField(
                  label: 'تاريخ الميلاد',
                  hint: 'اليوم / الشهر / السنة',
                  readOnly: true,
                  onTap: () => _pickBirthDate(context),
                  prefixIcon: Icons.cake_outlined,
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  controller: TextEditingController(
                    text: birthDate == null
                        ? ''
                        : DateFormat('dd/MM/yyyy').format(birthDate!),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 12),
                    child: Text(
                      field.errorText!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _gap,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المحافظة',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: defaultGovernorate,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: defaultGovernorate,
                    child: Text(defaultGovernorate),
                  ),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
          _gap,
          AppFormField(
            label: 'رقم الهاتف',
            hint: '01xxxxxxxxx',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            prefixWidget: const AppPhoneFieldIcon(),
            textInputAction: TextInputAction.next,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: Validators.egyptianPhone,
          ),
          _gap,
          AppFormField(
            label: 'رقم الواتساب',
            hint: '01xxxxxxxxx',
            controller: whatsappController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.chat_outlined,
            textInputAction: TextInputAction.next,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: Validators.egyptianPhone,
          ),
          _gap,
          AppPinField(
            label: 'كلمة المرور',
            controller: pinController,
            textInputAction: TextInputAction.next,
            validator: Validators.pin,
          ),
          _gap,
          AppPinField(
            label: 'إعادة كلمة المرور',
            controller: pinConfirmController,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                Validators.confirmPin(value, pinController.text.trim()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

const _gap = SizedBox(height: 14);
