// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_doctor/screens/TabItems/categories_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

late _HomeScreenState _homeScreenState;

class HomeScreen extends StatefulWidget {
  User? user;
  HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() {
    return _homeScreenState = _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  var x;
  bool show = false;

  getData() async {
    x = await FirebaseFirestore.instance.collection('gigs').get().then((value) {
      value.docs.forEach((element) {
        print(element['Age']);
      });
    });
    show = true;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
            padding: EdgeInsets.only(top: 15, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find Your",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Doctor",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white),
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextField(
                            textAlign: TextAlign.start,
                            enabled: false,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search",
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Categories",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  // padding: EdgeInsets.all(10),
                  height: 300,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (context, idx) {
                        var x = getCategoryData()[idx];
                        print(x.name);
                        return Card(
                          color: Colors.white,
                          child: Container(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    x.name,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  child: Image.asset(
                                    x.img,
                                    fit: BoxFit.scaleDown,
                                  ),
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35)),
                            width: 200,
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Near you",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                show
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: 4,
                        itemBuilder: (context, idx) {
                          var y = x[idx];
                          print(y);
                          return Card(
                              color: Colors.white,
                              child: Container(
                                alignment: Alignment.center,
                                height: 80,
                                child: ListTile(
                                  trailing: Icon(Icons.textsms_outlined),
                                  title: y,
                                  leading: CircleAvatar(
                                      radius: 27,
                                      backgroundImage:
                                          AssetImage('assets/header.png')),
                                ),
                              ));
                        })
                    : Center(
                        child: CircularProgressIndicator(
                        color: Colors.cyan,
                        strokeWidth: 1,
                      )),
              ],
            )),
      ),
    );
  }
}
