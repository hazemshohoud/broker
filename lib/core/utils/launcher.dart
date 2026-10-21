import 'package:url_launcher/url_launcher.dart';

abstract final class Launcher {
  static Future<bool> call(String phone) =>
      launchUrl(Uri(scheme: 'tel', path: phone));

  /// بيفتح محادثة واتساب مع الرقم — بيحوّل 01xxxxxxxxx للصيغة الدولية +20.
  static Future<bool> whatsapp(String phone, [String? text]) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '2$digits';
    final query = text != null ? '?text=${Uri.encodeComponent(text)}' : '';
    return launchUrl(
      Uri.parse('https://wa.me/$digits$query'),
      mode: LaunchMode.externalApplication,
    );
  }

  /// يفتح أي رابط خارجي (مثل خرائط Google أو روابط الويب)
  static Future<bool> url(String urlString) =>
      launchUrl(Uri.parse(urlString), mode: LaunchMode.externalApplication);
}
