import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_doctor/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:toast/toast.dart';

class AccountSettingScreen extends StatefulWidget {
  User? user;

  AccountSettingScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  final List<String> items = [
    'Dentist',
    'Physician',
    'Cardiologist',
    'Psychiatrists',
    'ENT'
  ];
  bool showContainer = false;
  String? selectedValue;
  DocumentSnapshot? a;
  TextEditingController locationController = TextEditingController();
  final geo = Geoflutterfire();
  GeoFirePoint? myLocation;
  String? address;

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

  Future getData() async {
    a = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user?.uid)
        .collection('information')
        .doc(widget.user?.phoneNumber)
        .get();

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    _getGeoLocationPosition();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    bool doctor = a?.get('doctor') ?? false;
    var name = doctor ? 'Dr. ' : '';
    name += a?.get('First Name') ?? '';
    name += ' ';
    name += a?.get('Last Name') ?? '';
    var email = a?.get('Email') ?? '';
    var age = a?.get('Age') ?? '';
    var phone = widget.user?.phoneNumber;

    addDataToDb() {
      if (widget.user?.uid != null && selectedValue != null) {
        FirebaseFirestore.instance.collection('gigs').add({
          'Name': name,
          'Age': age,
          'Specialization': selectedValue,
          'Location': myLocation?.data,
          'Phone': phone
        });
      } else {
        print('toast');
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(20),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Logout of your Account "),
                      InkWell(
                        onTap: () async {
                          showAnimatedDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return ClassicGeneralDialogWidget(
                                contentText: 'Confirm Logout?',
                                onPositiveClick: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Get.offAll(() => LoginPage());
                                },
                                onNegativeClick: () {
                                  Get.back();
                                },
                              );
                            },
                            animationType: DialogTransitionType.rotate,
                            curve: Curves.fastOutSlowIn,
                            duration: Duration(milliseconds: 300),
                          );
                        },
                        child: Icon(
                          Icons.logout_rounded,
                          size: 30,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Account Details"),
                      SizedBox(height: 20),
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 35,
                        backgroundImage: doctor
                            ? NetworkImage(
                                'https://cdn.pixabay.com/photo/2021/11/20/03/17/doctor-6810751__340.png')
                            : NetworkImage(
                                'https://cdn-icons-png.flaticon.com/512/21/21104.png'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Name : ${name}"),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Email : ${email}"),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Age : ${age}"),
                    ],
                  ),
                ),
                doctor
                    ? Container(
                        color: Colors.white,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(20),
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Create your Gig "),
                            InkWell(
                              onTap: () {
                                if (showContainer == true) {
                                  showContainer = false;
                                } else {
                                  showContainer = true;
                                }
                                setState(() {});
                              },
                              child: showContainer
                                  ? Icon(
                                      Icons.cancel,
                                      size: 30,
                                      color: Colors.black,
                                    )
                                  : Icon(
                                      Icons.add_circle_rounded,
                                      size: 30,
                                      color: Colors.black,
                                    ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                showContainer
                    ? Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(15),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Text('Specialization '),
                                  Container(
                                    margin: EdgeInsets.only(left: 15),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2(
                                        items: items
                                            .map(
                                              (e) => DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(
                                                  e,
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        value: selectedValue,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedValue = value as String;
                                          });
                                        },
                                        buttonHeight: 40,
                                        buttonWidth: 140,
                                        itemHeight: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Location"),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 15),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            showCursor: false,
                                            // enabled: false,
                                            controller: locationController,
                                            decoration: InputDecoration(
                                                hintText: address == null
                                                    ? "Location"
                                                    : address,
                                                border: InputBorder.none,
                                                hintStyle:
                                                    TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.grey[100]),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await GetLatLongFromAddress();
                                    setState(() {});
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
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                            MaterialButton(
                              elevation: 2,
                              color: Colors.cyan,
                              onPressed: () {
                                addDataToDb();
                                setState(() {
                                  showContainer = false;
                                });
                                Toast.show("Done",
                                    border: Border.all(color: Colors.green),
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    backgroundColor: Colors.greenAccent,
                                    duration: Toast.lengthShort,
                                    gravity: Toast.bottom);
                              },
                              minWidth: MediaQuery.of(context).size.width,
                              child: Text('Submit'),
                              textColor: Colors.white,
                            )
                          ],
                        ),
                      )
                    : Container(),
              ],
            )),
      ),
    );
  }
}
