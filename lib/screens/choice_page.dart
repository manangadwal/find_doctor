import 'package:find_doctor/screens/doctor_and_user_info/doctor_info_page.dart';
import 'package:find_doctor/screens/doctor_and_user_info/user_info_page.dart';
import 'package:find_doctor/screens/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoicePage extends StatelessWidget {
  final User? user;
  ChoicePage({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/second.png'), fit: BoxFit.cover)),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Are you a doctor?",
                  style: TextStyle(fontSize: 17),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MaterialButton(
                    child: Text(
                      'Click Here',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Get.to(DoctorInfoPage(
                        user: user,
                      ));
                    },
                    color: Colors.cyan,
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a Doctor?",
                  style: TextStyle(fontSize: 17),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MaterialButton(
                    child: Text(
                      "Click Here",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Get.to(UserInfoPage(
                        user: user,
                      ));
                    },
                    color: Colors.cyan,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
