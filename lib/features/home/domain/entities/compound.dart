import 'package:equatable/equatable.dart';

class Compound extends Equatable {
  const Compound({
    required this.id,
    required this.name,
    required this.location,
    required this.developerName,
    required this.developerStartPrice,
    required this.commission,
    required this.propertyTypes,
    this.resaleStartPrice,
    this.phone,
    this.whatsapp,
    this.imageUrl,
    this.imageUrls = const [],
    this.developerLogoUrl,
    this.isProject = false,
    this.projectImageUrl,
    this.region,
    this.district,
    this.readiness,
    this.finishing,
    this.area,
    this.deliveryDate,
    this.mapUrl,
    this.latitude,
    this.longitude,
    this.amenities,
    this.faqs,
    this.attachments,
  });

  final String id;
  final String name;
  final String location;
  final String developerName;
  final double developerStartPrice;
  final double? resaleStartPrice;
  final double commission;
  final List<String> propertyTypes;
  final String? phone;
  final String? whatsapp;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? developerLogoUrl;
  final bool isProject;
  final String? projectImageUrl;

  /// رابط صورة بانر المشروع المخصصة أو الصورة الأولى كخيار احتياطي
  String? get effectiveProjectImageUrl {
    if (projectImageUrl != null && projectImageUrl!.trim().isNotEmpty) {
      return projectImageUrl!.trim();
    }
    return imageUrl;
  }

  /// جميع صور العقار (تستثني صورة بانر المشروع لضمان ظهور صور العقار والوحدات الحقيقية)
  List<String> get allImages {
    final propertyImages = imageUrls
        .where((url) => projectImageUrl == null || url.trim() != projectImageUrl!.trim())
        .toList();
    if (propertyImages.isNotEmpty) return propertyImages;
    if (imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.trim() != projectImageUrl?.trim()) {
      return [imageUrl!.trim()];
    }
    if (imageUrls.isNotEmpty) return imageUrls;
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) return [imageUrl!.trim()];
    if (projectImageUrl != null && projectImageUrl!.trim().isNotEmpty) return [projectImageUrl!.trim()];
    return const [];
  }

  /// المنطقة الرئيسية (مثال: شرق النيل) والحي التابع لها.
  final String? region;
  final String? district;

  /// حالة العقار (جاهز / تحت الإنشاء).
  final String? readiness;

  /// التشطيب (تشطيب كامل / نصف تشطيب / عضم).
  final String? finishing;

  /// المساحة (مثال: 120 م² أو 140 - 320 م²).
  final String? area;

  String get effectiveArea {
    if (area != null && area!.trim().isNotEmpty) return area!.trim();
    return 'تبدأ من 120 م² إلى 350 م²';
  }

  /// تاريخ الاستلام (مثال: فوري أو 2026).
  final String? deliveryDate;

  String get effectiveDeliveryDate {
    if (deliveryDate != null && deliveryDate!.trim().isNotEmpty) {
      return deliveryDate!.trim();
    }
    return readiness == 'جاهز' ? 'استلام فوري' : 'قيد الإنشاء (2026/2027)';
  }

  /// رابط أو إحداثيات خريطة الموقع
  final String? mapUrl;
  final double? latitude;
  final double? longitude;

  /// الخدمات القريبة والمسافات بالكيلومتر
  final Map<String, String>? amenities;

  Map<String, String> get effectiveAmenities {
    if (amenities != null) return amenities!;
    return const {
      'مستشفى': '1 كم',
      'جامعة': '1 كم',
      'مدرسة': '1 كم',
      'نادي': '1 كم',
      'سوبر ماركت': '1 كم',
      'عيادة': '1 كم',
      'صيدلية': '1 كم',
      'جيم': '1 كم',
      'كافيه او مطعم': '1 كم',
      'مساحات خضراء': '1 كم',
    };
  }

  /// الأسئلة والأجوبة الشائعة (Accordion FAQs)
  final Map<String, String>? faqs;

  Map<String, String> get effectiveFaqs {
    if (faqs != null && faqs!.isNotEmpty) return faqs!;
    return {
      'لماذا هذا العقار؟':
          'يتميز مشروع $name بموقع استراتيجي في $location بتصميم معماري فاخر وخدمات عصرية تضمن الراحة والأمان.',
      'معلومات عن المطور':
          'شركة $developerName تُعد من كبرى الشركات الرائدة ذات السمعة العريقة والالتزام التام بالجودة ومواعيد التسليم.',
      'هل تصلح للاستثمار العقاري':
          'نعم، المشروع يُعد فرصة استثمارية واعدة بعائد إيجاري مجزٍ ونمو متسارع في القيمة الرأسمالية للوحدات.',
      'خدمة إعادة البيع':
          'يقدم تطبيق بروكر وشركاؤه دعماً متكاملاً لإعادة بيع أو تأجير وحدتك عبر شبكة واسعة من الوسطاء والعملاء الجادين.',
    };
  }

  /// المرفقات (بروشور، ماستر بلان، ملف أسعار)
  final List<Map<String, String>>? attachments;

  List<Map<String, String>> get effectiveAttachments {
    if (attachments != null && attachments!.isNotEmpty) return attachments!;
    return [
      {
        'title': 'بروشور المشروع الكامل (PDF)',
        'type': 'pdf',
        'size': '4.2 MB',
      },
      {
        'title': 'المخطط العام والماستر بلان (Master Plan)',
        'type': 'image',
        'size': '2.8 MB',
      },
      {
        'title': 'جدول خطط السداد ونظم التقسيط',
        'type': 'doc',
        'size': '1.5 MB',
      },
    ];
  }

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    developerName,
    developerStartPrice,
    resaleStartPrice,
    commission,
    propertyTypes,
    phone,
    whatsapp,
    imageUrl,
    imageUrls,
    developerLogoUrl,
    isProject,
    projectImageUrl,
    region,
    district,
    readiness,
    finishing,
    area,
    deliveryDate,
    mapUrl,
    latitude,
    longitude,
    amenities,
    faqs,
    attachments,
  ];
}
