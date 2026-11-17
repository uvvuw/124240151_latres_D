import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/session_service.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('cart');
  await NotificationService().init();
  final username = await SessionService.getUsername();
  runApp(MyApp(loggedIn: username != null && username.isNotEmpty));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: loggedIn ? const MainPage() : const LoginPage(),
    );
  }
}
