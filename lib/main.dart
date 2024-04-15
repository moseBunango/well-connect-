import 'package:flutter/material.dart';
import 'package:well_connect_app/pages/HomePage.dart';
import 'package:well_connect_app/pages/LandingPage.dart';
import 'package:well_connect_app/pages/AssesmentFormPage.dart';
import 'package:well_connect_app/pages/LoginPage.dart';
import 'package:well_connect_app/pages/OrderHistoryPage.dart';
import 'package:well_connect_app/pages/ProfileDetailsPage.dart';
import 'package:well_connect_app/pages/ProfilePage.dart';
import 'package:well_connect_app/pages/RegisterPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
      routes: {
        '/Register': (context) => RegisterPage(),
        '/LogInPage': (context) => LoginPage(),
        '/ProfilePage':(context) => ProfilePage(),
        '/AssesmentFormPage':(context) => AsssesmentForm(),
        '/HomePage':(context) => HomePage(),
        '/profileDetailsPage':(context)=>ProfileDetailsPage(),
        '/LandingPage':(context)=>LandingPage(),
        '/OrderHistoryPage':(context)=>OrderHistoryPage(),
      },
    );
  }
}
