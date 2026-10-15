
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF5466C9);
const Color textColor = Color(0xFF263244);
const Color secondaryTextColor = Color(0xFF647085);
const Color backgroundColor = Color(0xFFF6F7F9);
const Color whiteColor = Color(0xFFFFFFFF);
const Color borderColor = Color(0xFFDCE2EB);
const Color selectionColor = Color(0xFF6477D9);
const Color successColor = Color(0xFF257C63);
const Color errorColor = Color(0xFFB42318);

final ValueNotifier<Map<String, int>> cart =
    ValueNotifier<Map<String, int>>({});

final ValueNotifier<bool> isLoggedIn =
    ValueNotifier<bool>(false);

final ValueNotifier<Map<String, dynamic>?> currentUser =
    ValueNotifier<Map<String, dynamic>?>(null);
