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
        primaryColor: const Color(0xFF3366CC), // Primary color
        scaffoldBackgroundColor: const Color(0xFFF7F8FA), // Light background
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          color: Color(0xFF3366CC), // Change app bar color
          elevation: 2, // Slight shadow for app bar
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
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
            elevation: 5, // Add shadow to buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
