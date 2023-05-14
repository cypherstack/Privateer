import 'package:flutter/material.dart';

extension BoxShadowExt on BoxShadow {
  static BoxShadow fromJson(Map<String, dynamic> json) => BoxShadow(
        color: Color(int.parse(json["color"] as String)),
        spreadRadius: json["spread_radius"] as double,
        blurRadius: json["blur_radius"] as double,
      );
}
