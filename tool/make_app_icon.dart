// Builds square, padded launcher-icon sources from the brand logo.
// Usage: dart run tool/make_app_icon.dart && dart run flutter_launcher_icons
//
// The logo PNG has an opaque (black) background, so the icon background is
// filled with the logo's own corner color to blend seamlessly.
//
// - assets/branding/icon_full.png       full-bleed icon (iOS / legacy Android)
// - assets/branding/icon_foreground.png logo inside the adaptive safe zone
//                                        (Android 8+ crops the outer ~1/3)
import 'dart:io';

import 'package:image/image.dart' as img;

const _size = 1024;

void main() {
  final logo = img.decodePng(
    File('assets/branding/logo_full.png').readAsBytesSync(),
  )!;
  final corner = logo.getPixel(0, 0);
  final background = img.ColorRgba8(
    corner.r.toInt(),
    corner.g.toInt(),
    corner.b.toInt(),
    255,
  );
  stdout.writeln(
    'source ${logo.width}x${logo.height}, background '
    'rgb(${background.r}, ${background.g}, ${background.b})',
  );

  _write('assets/branding/icon_full.png', _compose(logo, 0.8, background));
  _write(
    'assets/branding/icon_foreground.png',
    _compose(logo, 0.6, background),
  );
}

/// Centers [logo] on a square canvas filled with [background], scaled so its
/// longest side is [fraction] of the canvas.
img.Image _compose(img.Image logo, double fraction, img.Color background) {
  final canvas = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(canvas, color: background);
  final scale =
      _size * fraction / (logo.width > logo.height ? logo.width : logo.height);
  final resized = img.copyResize(
    logo,
    width: (logo.width * scale).round(),
    height: (logo.height * scale).round(),
    interpolation: img.Interpolation.average,
  );
  return img.compositeImage(
    canvas,
    resized,
    dstX: (_size - resized.width) ~/ 2,
    dstY: (_size - resized.height) ~/ 2,
  );
}

void _write(String path, img.Image image) {
  File(path).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote $path');
}
