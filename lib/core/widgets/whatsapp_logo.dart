import 'package:flutter/material.dart';

/// شعار واتساب المفرغ بالخط الأخضر (بدون دائرة خلفية خضراء مصمتة)
class WhatsAppLogo extends StatelessWidget {
  const WhatsAppLogo({
    super.key,
    this.size = 24,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/whatsapp_outline.png',
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
    );
  }
}
