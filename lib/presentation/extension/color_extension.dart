import 'dart:developer';
import 'dart:ui';

extension ColorExtension on String {
  Color? toColor() {
    try {
      var hexColor = replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      if (hexColor.length == 8) {
        return Color(int.parse("0x$hexColor"));
      }
    } catch (e) {
      log('error toColor: $e');
    }
    return null;
  }
}
