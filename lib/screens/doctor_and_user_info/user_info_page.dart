// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_doctor/screens/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';

class UserInfoPage extends StatefulWidget {
  User? user;
  UserInfoPage({Key? key, this.user}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String? address;
  Geoflutterfire geo = Geoflutterfire();
  GeoFirePoint? myLocation;

  Future<void> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
    GetAddressFromLatLong(position);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];

    address =
        "${place.subLocality} ${place.locality} ${place.administrativeArea}";

    myLocation =
        geo.point(latitude: position.latitude, longitude: position.longitude);

    setState(() {});
  }

  Future<void> GetLatLongFromAddress() async {
    List<Location> locations =
        await locationFromAddress(locationController.text);

    List<Placemark> placemarks = await placemarkFromCoordinates(
        locations[0].latitude, locations[0].longitude);
    print(placemarks);
    Placemark place = placemarks[0];

    address =
        "${place.subLocality} ${place.locality} ${place.administrativeArea}";

    myLocation = geo.point(
        latitude: locations[0].latitude, longitude: locations[0].longitude);

    locationController.clear();

    setState(() {});
  }

  addDataToDb() {
    if (widget.user?.uid != null &&
        firstNameController.text != null &&
        firstNameController.text != '' &&
        lastNameController.text != null &&
        lastNameController.text != '') {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user?.uid)
          .collection("information")
          .doc(widget.user?.phoneNumber)
          .set({
        'First Name': firstNameController.text,
        'Last Name': lastNameController.text,
        'Email': emailController.text,
        'Age': ageController.text,
        'doctor': false,
        'Location': myLocation?.data,
      });
      Get.offAll(HomePage(
        user: widget.user,
      ));
    } else {
      print('toast');
      Toast.show("Enter details",
          border: Border.all(color: Colors.red),
          textStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          backgroundColor: Colors.red[100] ?? Colors.red,
          duration: Toast.lengthShort,
          gravity: Toast.bottom);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGeoLocationPosition();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/third.png'), fit: BoxFit.cover)),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.5),
              ),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                keyboardType: TextInputType.name,
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: "First Name",
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                keyboardType: TextInputType.name,
                controller: lastNameController,
                decoration: InputDecoration(
                  hintText: "Last Name",
                  border: InputBorder.none,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email (optional)",
                  border: InputBorder.none,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: ageController,
                decoration: InputDecoration(
                  hintText: "Age (optional)",
                  border: InputBorder.none,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      showCursor: false,
                      // enabled: false,
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: address == null ? "Location" : address,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await GetLatLongFromAddress();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      locationController.clear();
                      await _getGeoLocationPosition();
                    },
                    child: Icon(
                      Icons.location_on,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              minWidth: 200,
              child: Text("Continue"),
              textColor: Colors.white,
              onPressed: () async {
                await addDataToDb();
              },
              color: Colors.cyan,
            )
          ],
        ),
      ),
    );
  }
}
