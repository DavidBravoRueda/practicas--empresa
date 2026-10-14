
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFB8F500);
const Color backgroundColor = Color(0xFFF5F6F7);
const Color textColor = Color(0xFF202124);

final ValueNotifier<Map<String, int>> cart =
    ValueNotifier<Map<String, int>>({});

final ValueNotifier<bool> isLoggedIn =
    ValueNotifier<bool>(false);

final ValueNotifier<Map<String, dynamic>?> currentUser =
    ValueNotifier<Map<String, dynamic>?>(null);
