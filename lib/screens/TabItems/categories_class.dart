import 'package:flutter/cupertino.dart';

class Categories {
  final String name;
  final String img;

  Categories({
    required this.name,
    required this.img,
  });
}

List getCategoryData() {
  List<Categories> data = [
    Categories(name: "Dentist", img: "assets/1.png"),
    Categories(name: "Physician", img: "assets/2.png"),
    Categories(name: "Cardiologist", img: "assets/3.png"),
    Categories(name: "Psychiatrists", img: "assets/4.png"),
    Categories(name: "ENT", img: "assets/5.png"),
  ];
  return data;
}

List getNearData() {
  List<Text> data = [
    Text("Medical centre"),
    Text("Dr Vartika Dadheech"),
    Text("Dr Manan Gadwal"),
    Text("Dr Lovegood"),
    Text("Dr Strange"),
  ];
  return data;
}
