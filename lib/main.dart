import 'package:flutter/material.dart';
import 'package:mini_social_feed/features/auth/presentation/pages/register_page.dart';
import 'package:mini_social_feed/features/posts/presentation/pages/posts_page.dart';
import 'package:mini_social_feed/features/profile/presentation/pages/profile_page.dart';
import 'package:mini_social_feed/features/splash/presentation/pages/splash_page.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),

      home: const SplashPage(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/postes': (context) => const PostsPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
