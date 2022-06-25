// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_doctor/screens/choice_page.dart';
import 'package:find_doctor/screens/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controller = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String? verifiationCode;
  bool showOtp = false;
  bool ShowProgess = false;

  Future getDoc(User? user) async {
    var a = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('information')
        .doc(user?.phoneNumber)
        .get();
    if (a.exists) {
      print("first******* ${user?.uid}");

      print('Exists');
      Get.offAll(() => HomePage(
            user: user,
          ));
    }
    if (!a.exists) {
      print(user?.uid);
      print('Not exists');
      Get.offAll(() => ChoicePage(user: user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/first.png'), fit: BoxFit.cover)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1.5),
                    color: Colors.white.withOpacity(.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  height: 210,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 12),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: TextField(
                                  showCursor: false,
                                  controller: controller,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      hintText: "Phone",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                            MaterialButton(
                              color: Colors.cyan,
                              textColor: Colors.white,
                              child: Text(
                                "Get Otp",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                setState(() {
                                  ShowProgess = true;
                                });

                                await FirebaseAuth.instance.verifyPhoneNumber(
                                  phoneNumber: controller.text.toString(),
                                  verificationCompleted:
                                      (PhoneAuthCredential credential) async {
                                    await FirebaseAuth.instance
                                        .signInWithCredential(credential)
                                        .then((value) {
                                      if (value.user != null) {
                                        getDoc(value.user);
                                      }
                                    });
                                  },
                                  verificationFailed:
                                      (FirebaseAuthException e) {},
                                  codeSent: (String verificationId,
                                      int? resendToken) {
                                    verifiationCode = verificationId;
                                    setState(() {
                                      showOtp = true;
                                    });
                                  },
                                  codeAutoRetrievalTimeout:
                                      (String verificationId) {},
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      showOtp
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(right: 12),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: TextField(
                                        showCursor: false,
                                        controller: otpController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                            hintText: "OTP",
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                                color: Colors.black38,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    color: Colors.cyan,
                                    textColor: Colors.white,
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      await FirebaseAuth.instance
                                          .signInWithCredential(
                                              PhoneAuthProvider.credential(
                                                  verificationId:
                                                      verifiationCode ?? '',
                                                  smsCode: otpController.text))
                                          .then((value) async {
                                        await getDoc(value.user);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                          : ShowProgess
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.cyan,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
