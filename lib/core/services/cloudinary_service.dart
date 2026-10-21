import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CloudinaryService {
  CloudinaryService({
    http.Client? client,
    this.cloudName = 'kb1kx0do',
    this.uploadPreset = 'pd5xbzdr',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String cloudName;
  final String uploadPreset;

  /// ضغط الصورة قبل الرفع لتقليل حجمها وسرعة رفعها وتوفير المساحة
  static Uint8List compressImage(
    Uint8List bytes, {
    int maxDimension = 1024,
    int quality = 80,
  }) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      final needsResize =
          decoded.width > maxDimension || decoded.height > maxDimension;
      final isLargeSize = bytes.lengthInBytes > 200 * 1024;

      // لو الأبعاد صغيرة والحجم خفيف بالفعل، مفيش داعي لإعادة الضغط
      if (!needsResize && !isLargeSize) {
        return bytes;
      }

      img.Image processed = decoded;
      if (needsResize) {
        processed = img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? maxDimension : null,
          height: decoded.height > decoded.width ? maxDimension : null,
        );
      }

      final encoded = img.encodeJpg(processed, quality: quality);
      return Uint8List.fromList(encoded);
    } catch (_) {
      return bytes;
    }
  }

  /// يرفع صورة محلية إلى Cloudinary بعد التأكد من ضغطها ويرجع الـ Secure URL الدائم
  Future<String?> uploadImage(
    String filePath, {
    String? folder,
    int maxDimension = 1024,
    int quality = 80,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final rawBytes = await file.readAsBytes();
      final compressedBytes = compressImage(
        rawBytes,
        maxDimension: maxDimension,
        quality: quality,
      );

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset;

      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          compressedBytes,
          filename: 'upload.jpg',
        ),
      );

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['secure_url'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// يضيف تحسينات تلقائية للروابط لضغط الصورة وتقليل استهلاك الباندويث عند العرض
  static String optimizeUrl(String url, {int? width, int? height}) {
    if (!url.contains('res.cloudinary.com') || !url.contains('/upload/')) {
      return url;
    }
    if (url.contains('/f_auto')) return url;

    final transformations = <String>['f_auto', 'q_auto'];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (width != null || height != null) transformations.add('c_limit');

    final transformPart = '${transformations.join(',')}/';
    return url.replaceFirst('/upload/', '/upload/$transformPart');
  }
}
