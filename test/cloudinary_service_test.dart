import 'dart:typed_data';
import 'package:broker/core/services/cloudinary_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('CloudinaryService', () {
    test('optimizeUrl injects f_auto,q_auto for Cloudinary URLs', () {
      const original =
          'https://res.cloudinary.com/kb1kx0do/image/upload/v12345/sample.png';
      final optimized = CloudinaryService.optimizeUrl(original);

      expect(
        optimized,
        'https://res.cloudinary.com/kb1kx0do/image/upload/f_auto,q_auto/v12345/sample.png',
      );
    });

    test('optimizeUrl with dimensions injects width, height, and limit', () {
      const original =
          'https://res.cloudinary.com/kb1kx0do/image/upload/v12345/sample.png';
      final optimized = CloudinaryService.optimizeUrl(
        original,
        width: 120,
        height: 120,
      );

      expect(
        optimized,
        'https://res.cloudinary.com/kb1kx0do/image/upload/f_auto,q_auto,w_120,h_120,c_limit/v12345/sample.png',
      );
    });

    test('optimizeUrl leaves non-Cloudinary or already optimized URLs intact', () {
      const nonCloudinary = 'https://example.com/images/house.jpg';
      expect(CloudinaryService.optimizeUrl(nonCloudinary), nonCloudinary);

      const alreadyOptimized =
          'https://res.cloudinary.com/kb1kx0do/image/upload/f_auto,q_auto/v12345/sample.png';
      expect(CloudinaryService.optimizeUrl(alreadyOptimized), alreadyOptimized);
    });

    test('compressImage resizes images with dimensions exceeding maxDimension', () {
      // Create a 2000x1000 dummy image
      final large = img.Image(width: 2000, height: 1000);
      img.fill(large, color: img.ColorRgb8(255, 0, 0));
      final largeBytes = Uint8List.fromList(img.encodeJpg(large));

      final compressed = CloudinaryService.compressImage(
        largeBytes,
        maxDimension: 512,
        quality: 75,
      );

      final decoded = img.decodeImage(compressed);
      expect(decoded, isNotNull);
      expect(decoded!.width, 512);
      expect(decoded.height, 256);
    });

    test('compressImage leaves already small dimension images as-is', () {
      final small = img.Image(width: 200, height: 200);
      img.fill(small, color: img.ColorRgb8(0, 255, 0));
      final smallBytes = Uint8List.fromList(img.encodeJpg(small));

      final result = CloudinaryService.compressImage(smallBytes);
      expect(result.lengthInBytes, smallBytes.lengthInBytes);
    });
  });
}
