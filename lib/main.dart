import 'package:find_doctor/screens/homePage.dart';
import 'package:find_doctor/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GetMaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    bool login = false;
    if (FirebaseAuth.instance.currentUser != null) {
      login = true;
    }
    return MaterialApp(
        title: 'Cure It',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: login
            ? HomePage(user: FirebaseAuth.instance.currentUser)
            : LoginPage());
  }
}
