import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final65120479/screens/homescreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantipedia',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF202122)),
          titleTextStyle: TextStyle(
            color: Color(0xFF202122),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF202122)),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF202122)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF202122)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF202122)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFC8CCD1),
          thickness: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366CC),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}