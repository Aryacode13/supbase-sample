import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'contact_page.dart'; // import halaman ContactPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vmwidifukpjdmbnhaiap.supabase.co', // 🔑 ganti dengan URL kamu
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtd2lkaWZ1a3BqZG1ibmhhaWFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczMjc1MjgsImV4cCI6MjA3MjkwMzUyOH0.pAZWMZJf8vpqaIZdcginLgNEclOkzh_pnD-YFD2EBGw', // 🔑 ganti dengan anon key kamu
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase CRUD Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ContactPage(),
    );
  }
}
