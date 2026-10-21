import 'package:equatable/equatable.dart';

class OnboardingItem extends Equatable {
  const OnboardingItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.order,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int order;

  /// الشاشات الافتراضية الأربعة في حال لم يقم المسؤول بإضافة صور في قاعدة البيانات بعد
  static const List<OnboardingItem> defaults = [
    OnboardingItem(
      id: 'default_1',
      title: 'أكبر شبكة مشروعات عقارية',
      description: 'تصفح مئات المشروعات الحصرية والكمبوندات بأعلى نسب عمولات في السوق المصري.',
      imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
      order: 1,
    ),
    OnboardingItem(
      id: 'default_2',
      title: 'إدارة ذكية وشاملة لعملائك',
      description: 'سجّل عملاءك واحتياجاتهم وتابع صفقاتك مع إمكانية التواصل الفوري عبر الهاتف والواتساب.',
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      order: 2,
    ),
    OnboardingItem(
      id: 'default_3',
      title: 'سحب فوري لأرباحك وعمولاتك',
      description: 'تابع رصيدك المتاح واسحب أرباحك وعمولاتك مباشرة عبر إنستاباي أو المحفظة الإلكترونية.',
      imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
      order: 3,
    ),
    OnboardingItem(
      id: 'default_4',
      title: 'بوابتك الرقمية للوساطة العقارية',
      description: 'انضم لشبكة وسطاء بروكر المحترفين وابدأ في إتمام الصفقات وتنمية أرباحك من اليوم.',
      imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
      order: 4,
    ),
  ];

  @override
  List<Object?> get props => [id, title, description, imageUrl, order];
}
