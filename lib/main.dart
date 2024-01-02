import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:kam/features/app/splash_screen/splash_screen.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/create_event_page.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/edit_event_page.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/home_page.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/userList.dart';
import 'package:kam/features/user_auth/presentation/pages/home_page.dart';
import 'package:kam/features/user_auth/presentation/pages/login_page.dart';
import 'package:kam/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:kam/features/user_auth/presentation/pages/profile_page.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/user_profile.dart';

//import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kam?',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(148, 6, 31, 1.0),
          // ···
          brightness: Brightness.dark,
        ),
      ),
      routes: {
        '/': (context) => SplashScreen(
              // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
              child: LoginPage(),
            ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/homeAdmin': (context) => AdminHomePage(),
        '/profilesAdmin': (context) => userList(),
        '/createEventAdmin': (context) => CreateEventPage(),
      },
    );
  }
}
