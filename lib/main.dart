import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/signin.dart';

void main() async {
  // Since Starting Since August 17 2020, you need to initialize firebase app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// 0. Add firebase configs for both IOS and Android
// 1. ADD Stripe secret key. Instructions given in ../functions/index.js
// 2.0 Deploy Firebase functions
// 2/ ADD  Stripe Publishable key in ../screens/shop.dart
// 3. Add a private email to your Firebase project
// 4. run the application in Android or IOS (or Both)
// 5/ use that private email to login
//

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Demo',
      debugShowCheckedModeBanner: false,
      home: SignIn(),
    );
  }
}
