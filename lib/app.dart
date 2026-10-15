import 'package:flutter/material.dart';

import 'app_state.dart';
import 'home_page.dart';

class TecnoStoreApp extends StatelessWidget {
  const TecnoStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ).copyWith(
          primary: primaryColor,
          onPrimary: whiteColor,
          secondary: selectionColor,
          onSecondary: whiteColor,
          error: errorColor,
          onError: whiteColor,
          surface: whiteColor,
          onSurface: textColor,
          outline: borderColor,
          outlineVariant: borderColor,
        ),
        dividerColor: borderColor,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: secondaryTextColor),
          hintStyle: const TextStyle(color: secondaryTextColor),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: selectionColor, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: errorColor),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: errorColor, width: 2),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: selectionColor,
          selectionColor: selectionColor.withValues(alpha: 0.2),
          selectionHandleColor: selectionColor,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: selectionColor,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}
