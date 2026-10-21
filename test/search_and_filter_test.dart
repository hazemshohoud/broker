import 'package:broker/core/utils/arabic_search.dart';
import 'package:broker/features/home/data/models/compound_model.dart';
import 'package:broker/features/home/domain/entities/compound.dart';
import 'package:broker/features/home/domain/entities/compound_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArabicSearchHelper', () {
    test('normalizes Alef, Ta Marbouta, Alef Maksura and removes Tashkeel', () {
      // Alef variants
      expect(ArabicSearchHelper.normalize('أكتوبر'), 'اكتوبر');
      expect(ArabicSearchHelper.normalize('إعمار'), 'اعمار');
      expect(ArabicSearchHelper.normalize('آل نهيان'), 'ال نهيان');

      // Ta Marbouta to Ha
      expect(ArabicSearchHelper.normalize('القاهرة'), 'القاهره');
      expect(ArabicSearchHelper.normalize('شقة'), 'شقه');

      // Alef Maksura to Ya
      expect(ArabicSearchHelper.normalize('مستشفى'), 'مستشفي');

      // Tashkeel removal
      expect(ArabicSearchHelper.normalize('بُرُوكَرٌ'), 'بروكر');
    });

    test('matchesQuery handles multi-token and tolerant Arabic query', () {
      final targets = ['كمبوند وان هايد بارك', 'Hyde Park', 'الحي الأول، شرق النيل', 'شقة فيلا'];

      // Exact match
      expect(ArabicSearchHelper.matchesQuery(query: 'هايد بارك', targets: targets), isTrue);

      // Alef tolerance ('أول' vs 'اول')
      expect(ArabicSearchHelper.matchesQuery(query: 'الحي الاول', targets: targets), isTrue);

      // Property type search ('فيلا' / 'شقه')
      expect(ArabicSearchHelper.matchesQuery(query: 'شقه', targets: targets), isTrue);
      expect(ArabicSearchHelper.matchesQuery(query: 'فيلا', targets: targets), isTrue);

      // Multi-token: name + type
      expect(ArabicSearchHelper.matchesQuery(query: 'هايد فيلا', targets: targets), isTrue);

      // Non-matching query
      expect(ArabicSearchHelper.matchesQuery(query: 'الشيخ زايد', targets: targets), isFalse);
    });
  });

  group('Compound Multi-Images (Up to 5 images)', () {
    test('Compound entity allImages returns list of images or falls back to imageUrl', () {
      const c1 = Compound(
        id: 'c1',
        name: 'كمبوند 1',
        location: 'بني سويف',
        developerName: 'مطور 1',
        developerStartPrice: 5000000,
        commission: 125000,
        propertyTypes: ['شقة'],
        imageUrl: 'https://res.cloudinary.com/demo/image1.jpg',
      );
      expect(c1.allImages, ['https://res.cloudinary.com/demo/image1.jpg']);

      const c2 = Compound(
        id: 'c2',
        name: 'كمبوند 2',
        location: 'بني سويف',
        developerName: 'مطور 2',
        developerStartPrice: 6000000,
        commission: 150000,
        propertyTypes: ['فيلا'],
        imageUrl: 'https://res.cloudinary.com/demo/image1.jpg',
        imageUrls: [
          'https://res.cloudinary.com/demo/image1.jpg',
          'https://res.cloudinary.com/demo/image2.jpg',
          'https://res.cloudinary.com/demo/image3.jpg',
          'https://res.cloudinary.com/demo/image4.jpg',
          'https://res.cloudinary.com/demo/image5.jpg',
        ],
      );
      expect(c2.allImages.length, 5);
      expect(c2.allImages.first, 'https://res.cloudinary.com/demo/image1.jpg');
      expect(c2.allImages.last, 'https://res.cloudinary.com/demo/image5.jpg');
    });

    test('CompoundModel handles both legacy imageUrl and new imageUrls list', () {
      final modelLegacy = CompoundModel.fromMap('c_legacy', {
        'name': 'Legacy Compound',
        'location': 'بني سويف',
        'developerName': 'Dev',
        'developerStartPrice': 3000000,
        'commission': 75000,
        'propertyTypes': ['شقة'],
        'imageUrl': 'https://res.cloudinary.com/demo/legacy.jpg',
      });
      expect(modelLegacy.imageUrls, ['https://res.cloudinary.com/demo/legacy.jpg']);
      expect(modelLegacy.allImages, ['https://res.cloudinary.com/demo/legacy.jpg']);

      final modelMulti = CompoundModel.fromMap('c_multi', {
        'name': 'Multi Image Compound',
        'location': 'بني سويف',
        'developerName': 'Dev',
        'developerStartPrice': 8000000,
        'commission': 200000,
        'propertyTypes': ['فيلا'],
        'imageUrls': [
          'https://res.cloudinary.com/demo/img1.jpg',
          'https://res.cloudinary.com/demo/img2.jpg',
          'https://res.cloudinary.com/demo/img3.jpg',
        ],
      });
      expect(modelMulti.imageUrls.length, 3);
      expect(modelMulti.imageUrl, 'https://res.cloudinary.com/demo/img1.jpg');
    });
  });

  group('CompoundFilter Precision & Trimming', () {
    const compound = Compound(
      id: 'c1',
      name: 'كمبوند النرجس',
      location: 'الحي الثاني',
      developerName: 'النرجس جروب',
      developerStartPrice: 4500000,
      commission: 112500,
      propertyTypes: ['شقة', 'دوبلكس'],
      region: ' شرق النيل ',
      district: ' الحي الثاني ',
      readiness: ' جاهز ',
      finishing: ' تشطيب كامل ',
    );

    test('matches handles surrounding whitespaces in fields correctly', () {
      const filter1 = CompoundFilter(
        region: 'شرق النيل',
        readiness: 'جاهز',
        finishing: 'تشطيب كامل',
      );
      expect(filter1.matches(compound), isTrue);

      const filter2 = CompoundFilter(
        propertyTypes: {'شقة'},
        districts: {'الحي الثاني'},
      );
      expect(filter2.matches(compound), isTrue);
    });

    test('NumRange contains handles floating point numbers with tolerance', () {
      const range = NumRange(4500000, 10000000);
      expect(range.contains(4500000.00001), isTrue);
      expect(range.contains(4499999.99999), isTrue);
      expect(range.contains(4500000), isTrue);
    });
  });

  group('Compound Projects vs Regular Properties', () {
    test('CompoundModel correctly parses isProject and projectImageUrl', () {
      final model = CompoundModel.fromMap('p1', {
        'name': 'مشروع زهرة بني سويف',
        'location': 'شرق النيل',
        'developerName': 'إعمار',
        'developerStartPrice': 3000000,
        'commission': 75000,
        'propertyTypes': ['شقة'],
        'isProject': true,
        'projectImageUrl': 'https://example.com/banner.jpg',
        'imageUrl': 'https://example.com/main.jpg',
      });

      expect(model.isProject, isTrue);
      expect(model.projectImageUrl, 'https://example.com/banner.jpg');
      expect(model.effectiveProjectImageUrl, 'https://example.com/banner.jpg');
    });

    test('effectiveProjectImageUrl falls back to imageUrl when projectImageUrl is empty', () {
      const c = Compound(
        id: 'p2',
        name: 'مشروع بلا بانر',
        location: 'المدينة',
        developerName: 'مطور',
        developerStartPrice: 2000000,
        commission: 50000,
        propertyTypes: ['شقة'],
        isProject: true,
        imageUrl: 'https://example.com/fallback.jpg',
      );

      expect(c.effectiveProjectImageUrl, 'https://example.com/fallback.jpg');
    });
  });
}
