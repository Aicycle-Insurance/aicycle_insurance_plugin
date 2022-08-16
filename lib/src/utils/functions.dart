import 'package:flutter/material.dart';

String getTitleFromColor(Color color) {
  if (color == Color(0xFFBD10E0)) {
    return 'Vỡ, thủng, rách';
  } else if (color == Color(0xFFA2FF43)) {
    return 'Móp (bẹp)';
  } else if (color == Color(0xFF0B7CFF)) {
    return 'Nứt (rạn)';
  } else if (color == Color(0xFFFFEC05)) {
    return 'Trầy (xước)';
  } else {
    return 'Khác';
  }
}