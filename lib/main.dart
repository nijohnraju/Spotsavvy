import 'package:firebase_core/firebase_core.dart';//hello
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panigale/custom.dart';
import 'package:panigale/screens/home.dart';
import 'package:panigale/screens/login.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';


var kColorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 135, 220, 66));

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Manrope',
        ).copyWith(
       useMaterial3: true,
       colorScheme: kColorScheme,
       
      ),
      home: Scaffold(
        body: AnimatedSplashScreen(
          
            splash:const ListTile(
              title: Image(
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
            duration: 2000,
            backgroundColor:  whitesavvy,
            nextScreen: const LoginAuth()),
      ),
    );
  }
}

class LoginAuth extends StatelessWidget {
  const LoginAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            } else if (snapshot.hasData) {
              return const MainPage();
            } else {
              return const LoginPage();
            }
          }),
    );
  }
}