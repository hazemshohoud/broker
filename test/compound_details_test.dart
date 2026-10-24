import 'package:flutter_test/flutter_test.dart';
import 'package:broker/features/home/data/models/compound_model.dart';
import 'package:broker/features/home/domain/entities/compound.dart';

void main() {
  group('Compound & CompoundModel Property Details', () {
    test('CompoundModel.fromMap parses all Sak-profile fields correctly', () {
      final map = <String, dynamic>{
        'name': 'كمبوند النخيل',
        'location': 'شرق النيل، بني سويف',
        'developerName': 'سوديك',
        'developerStartPrice': 6500000,
        'resaleStartPrice': 7000000,
        'commission': 162500,
        'propertyTypes': ['شقة', 'فيلا'],
        'phone': '+201012345678',
        'whatsapp': '+201012345678',
        'imageUrl': 'https://example.com/main.jpg',
        'imageUrls': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
        'area': '150 - 320 م²',
        'deliveryDate': '2026',
        'mapUrl': 'https://maps.google.com/?q=29.0,31.0',
        'amenities': {
          'مستشفى': '1 كم',
          'جامعة': '1.5 كم',
          'مدرسة': '800 م',
          'نادي': '2 كم',
          'سوبر ماركت': '500 م',
          'عيادة': '1 كم',
          'صيدلية': '400 م',
          'جيم': '1 كم',
          'كافيه او مطعم': '600 م',
          'مساحات خضراء': 'داخل المشروع',
        },
        'faqs': {
          'لماذا هذا العقار؟': 'موقع مميز جداً وتشطيب فاخر.',
          'معلومات عن المطور': 'سابقة أعمال قوية وموثوقة.',
          'هل تصلح للاستثمار العقاري': 'عائد مرتفع ومضمون.',
          'خدمة إعادة البيع': 'دعم حصري لإعادة البيع.',
        },
        'attachments': [
          {'title': 'بروشور المشروع الكامل (PDF)', 'type': 'pdf', 'size': '5 MB'},
        ],
      };

      final compound = CompoundModel.fromMap('compound-123', map);

      expect(compound.id, equals('compound-123'));
      expect(compound.name, equals('كمبوند النخيل'));
      expect(compound.area, equals('150 - 320 م²'));
      expect(compound.deliveryDate, equals('2026'));
      expect(compound.mapUrl, equals('https://maps.google.com/?q=29.0,31.0'));
      expect(compound.amenities?['مستشفى'], equals('1 كم'));
      expect(compound.amenities?['جامعة'], equals('1.5 كم'));
      expect(compound.faqs?['لماذا هذا العقار؟'], equals('موقع مميز جداً وتشطيب فاخر.'));
      expect(compound.attachments?.first['title'], equals('بروشور المشروع الكامل (PDF)'));
    });

    test('effective getters supply standard Sak-profile defaults when null', () {
      const compound = Compound(
        id: 'c-test',
        name: 'مشروع افتراضي',
        location: 'بني سويف',
        developerName: 'مطور تجريبي',
        developerStartPrice: 5000000,
        commission: 125000,
        propertyTypes: ['شقة'],
        readiness: 'جاهز',
      );

      // Area and Delivery defaults
      expect(compound.effectiveArea, contains('120 م²'));
      expect(compound.effectiveDeliveryDate, equals('استلام فوري'));

      // Amenities default list (10 amenities from user specification image)
      final amenities = compound.effectiveAmenities;
      expect(amenities.length, equals(10));
      expect(amenities.containsKey('مستشفى'), isTrue);
      expect(amenities.containsKey('جامعة'), isTrue);
      expect(amenities.containsKey('مدرسة'), isTrue);
      expect(amenities.containsKey('نادي'), isTrue);
      expect(amenities.containsKey('سوبر ماركت'), isTrue);
      expect(amenities.containsKey('عيادة'), isTrue);
      expect(amenities.containsKey('صيدلية'), isTrue);
      expect(amenities.containsKey('جيم'), isTrue);
      expect(amenities.containsKey('كافيه او مطعم'), isTrue);
      expect(amenities.containsKey('مساحات خضراء'), isTrue);

      // FAQs default list (4 questions from user specification image)
      final faqs = compound.effectiveFaqs;
      expect(faqs.length, equals(4));
      expect(faqs.containsKey('لماذا هذا العقار؟'), isTrue);
      expect(faqs.containsKey('معلومات عن المطور'), isTrue);
      expect(faqs.containsKey('هل تصلح للاستثمار العقاري'), isTrue);
      expect(faqs.containsKey('خدمة إعادة البيع'), isTrue);

      // Attachments defaults
      expect(compound.effectiveAttachments.isNotEmpty, isTrue);
      expect(compound.effectiveAttachments.first['title'], contains('PDF'));
    });

    test('dynamic amenities override defaults and allow adding custom or removing amenities', () {
      // Compound with custom amenities (e.g., added metro station, removed schools/hospitals)
      const compound = Compound(
        id: 'c-custom-amenities',
        name: 'مشروع مميز',
        location: 'بني سويف',
        developerName: 'مطور تجريبي',
        developerStartPrice: 6000000,
        commission: 150000,
        propertyTypes: ['شقة'],
        amenities: {
          'جيم متكامل': 'داخل المشروع',
          'محطة قطار سريعة': '2 كم',
          'هايبر ماركت': '500 م',
        },
      );

      final amenities = compound.effectiveAmenities;
      expect(amenities.length, equals(3));
      expect(amenities['جيم متكامل'], equals('داخل المشروع'));
      expect(amenities['محطة قطار سريعة'], equals('2 كم'));
      expect(amenities['هايبر ماركت'], equals('500 م'));
      expect(amenities.containsKey('مدرسة'), isFalse);
    });
  });
}
