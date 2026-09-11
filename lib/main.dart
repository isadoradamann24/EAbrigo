
import 'package:flutter/material.dart';

import 'screens/cidades_screen.dart';

void main() {
  runApp(const EAbrigoApp());
}

class EAbrigoApp extends StatelessWidget {
  const EAbrigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'E-Abrigo',

      theme: ThemeData(
        useMaterial3: true,

        // Fundo padrão do aplicativo
        scaffoldBackgroundColor: Colors.white,

        // Cor principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE2E8FF),
        ),

        // Estilo dos textos
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),

        // Estilo padrão dos botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE2E8FF),
            foregroundColor: Colors.black,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),

            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),

            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),

        // Estilo padrão dos OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFE2E8FF),
            foregroundColor: Colors.black,

            side: const BorderSide(
              color: Colors.black,
              width: 1,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),

            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),

            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),

      home: const CidadesScreen(),
    );
  }
}

