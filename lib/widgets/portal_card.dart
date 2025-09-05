import 'package:av_master_mobile/controllers/auth_controller.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/screens/attendance/executive/exe_layout.dart';
import 'package:av_master_mobile/screens/attendance/technician/tech_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortalCard extends StatefulWidget {
  const PortalCard({
    super.key,
    required this.portalName,
    required this.image,
    required this.navigate
  });

  final String portalName;
  final String image;
  final String navigate;
  @override
  State<PortalCard> createState() => _PortalCardState();
}


class _PortalCardState extends State<PortalCard> {

  UserModel? user;
  bool isLoading = true;
  final AuthController authController = Get.put(AuthController());

  Future<void> loadUser()async{
    final storedUser = await authController.getUserFromStorage();
    setState(() {
      user = storedUser;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return isLoading
        ? const CircularProgressIndicator() // Show a loading indicator
        : user != null
        ? Container(
      child: Column(
        children: [
          InkWell(
            onTap: (){
              if(user?.userType=='technician'){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TechLayout(portalName: widget.portalName,)));
              } else if(user?.userType=='executive'|| user?.userType=='top_management'){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ExeLayout(portalName: widget.portalName,)));
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width*0.15,
              height: MediaQuery.of(context).size.width*0.15,
              decoration: BoxDecoration(
                  color:Color(0xE4EFE0FF),
                  borderRadius: BorderRadius.circular(5.0)
              ),
              child: Image.asset(widget.image,),
            ),
          ),
          Text(widget.portalName,
            style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 15
            ),)
        ],
      ),
    ) // Pass the loaded user data
        : const Text('User not found');
  }
}
