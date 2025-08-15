import 'dart:convert';

import 'package:av_master_mobile/models/attendance/attendance.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController{

  final Rx<AttendanceModel> attendanceModel = AttendanceModel().obs;
  final storage = FlutterSecureStorage();

  final RxString selectedSupervisorError = ''.obs;
  final Rx workingPlaceError = ''.obs;


  //check in function
 void checkIn({ List<dynamic>?supervisorIds}) {

   selectedSupervisorError.value ="";
   if (supervisorIds == null || supervisorIds.isEmpty) {
     selectedSupervisorError.value = "Select at least one supervisor";
     // Get.snackbar("Cannot Check In", selectedSupervisorError.value); // Show the snackbar here
   } else {
     // If the list is valid, proceed with the check-in logic
     attendanceModel.update((val) {
       val?.isCheckIn = true;
       val?.checkedInTime = DateTime.now();
     });

     Future.delayed(const Duration(seconds: 5), () {
       attendanceModel.update((val) {
         val?.isCheckInApproved = true;
       });
     });
   }


  }

  void checkOut({
    required String workingPlace,
    int? siteNo
}){

   // print(workingPlace);
   // print(siteNo);
   workingPlaceError.value='';

   if(workingPlace =="Select"){
     workingPlaceError.value="Please Enter the place you Worked";
     // Get.snackbar("Cannot Check Out", workingPlaceError.value);
   }else{
     if(workingPlace == "Site"){
       if(siteNo== 0){
         workingPlaceError.value="Enter Correct Site";
         return;
         // Get.snackbar("Cannot Check Out", workingPlaceError.value);
       }else{
         attendanceModel.update((val){
           val?.isCheckOut = true;
           val?.checkedOutTime = DateTime.now();
         });

         Future.delayed(const Duration(seconds: 3),(){
           attendanceModel.update((val){
             val?.isCheckOutApproved = true;
           });
         });
       }
     }
     if(workingPlace !="Site"){
       attendanceModel.update((val){
         val?.isCheckOut = true;
         val?.checkedOutTime = DateTime.now();
       });

       Future.delayed(const Duration(seconds: 3),(){
         attendanceModel.update((val){
           val?.isCheckOutApproved = true;
         });
       });
     }

   }

  }
}