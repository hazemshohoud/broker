// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final outDir = Directory('assets/icons');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final files = {
    'nav_home': r'C:\Users\malawy\.gemini\antigravity-ide\brain\e44f3659-8154-4e78-91c8-6c590bb936fa\.user_uploaded\media_1792068732992.png',
    'nav_account': r'C:\Users\malawy\.gemini\antigravity-ide\brain\e44f3659-8154-4e78-91c8-6c590bb936fa\.user_uploaded\media_1792068790457.png',
    'filter_sliders': r'C:\Users\malawy\.gemini\antigravity-ide\brain\e44f3659-8154-4e78-91c8-6c590bb936fa\.user_uploaded\media_1792068817128.png',
  };

  for (final entry in files.entries) {
    final src = img.decodeImage(File(entry.value).readAsBytesSync())!;
    final transparent = img.Image(width: src.width, height: src.height, numChannels: 4);

    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        final lum = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;

        // Background is near 247-255, stroke is ~5-40
        double alpha;
        if (lum >= 235) {
          alpha = 0.0;
        } else if (lum <= 40) {
          alpha = 1.0;
        } else {
          alpha = (235 - lum) / (235 - 40);
        }

        final aInt = (alpha.clamp(0.0, 1.0) * 255).round();
        transparent.setPixelRgba(x, y, 255, 255, 255, aInt);
      }
    }

    // Resize to high-DPI icon 192x192
    final resized = img.copyResize(
      transparent,
      width: 192,
      height: 192,
      interpolation: img.Interpolation.average,
    );

    final outFile = File('assets/icons/${entry.key}.png');
    outFile.writeAsBytesSync(img.encodePng(resized));
    print('Generated ${outFile.path}: 192x192 PNG');
  }
}
