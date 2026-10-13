import 'package:flutter/material.dart';

import 'app_state.dart';
import 'home_page.dart';

class TecnoStoreApp extends StatelessWidget {
  const TecnoStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TecnoStore',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: textColor,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}
