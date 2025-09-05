import 'package:av_master_mobile/controllers/auth_controller.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

AuthController authController = Get.put(AuthController());
UserModel? user;

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: ()async{
      // final userJson = await authController.getUserFromStorage();
      // if(userJson!=null){
      //   user =  userJson;
      // }
      final result = await authController.logout();
      if(result ==true){
        Get.offAll(() => Login());
      }


    }, icon: Icon(Icons.logout_outlined));
  }
}
