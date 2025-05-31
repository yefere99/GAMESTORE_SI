import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home_view.dart';
import 'services/cart_service.dart'; // Asegúrate que la ruta es correcta

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamestore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(),
        ),
      ),
      home: const HomeView(), // ✅ Página de inicio
    );
  }
}
