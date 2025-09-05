import 'package:av_master_mobile/screens/attendance/technician/home.dart';
import 'package:av_master_mobile/screens/attendance/technician/leaves.dart';
import 'package:av_master_mobile/screens/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TechPageController extends GetxController {

  final RxInt currentPage = 0.obs;

  //for attendance portal
  final List <Widget> attendancePages = [
    const Home(),
    const Leaves(),
    const Profile(),
  ];

  //for other portals
  final List <Widget> pages = [
    const Center(child: Text("404 Not Found"),)
  ];

  void onAttendanceBottomNavTap(int index ){
    if (index == 0) {
      currentPage.value = 1;
    } else if (index == 1) {
      currentPage.value = 2;
    }
  }

  void onAttendanceHomeTap (){
    currentPage.value =0;
  }
  
  
  
}