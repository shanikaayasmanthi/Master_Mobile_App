import 'package:av_master_mobile/controllers/auth_controller.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/widgets/portal_card.dart';
import 'package:av_master_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortalPage extends StatefulWidget {
  const PortalPage({super.key});

  @override
  State<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> {

  final AuthController authController = Get.put(AuthController());
  UserModel? user;
  bool isLoading = true;

  final portalDetails = [
    {'name': "Attendance", 'image': 'lib/images/attendance.png','navigate':""},
    // {'name': "Suspense", 'image': "lib/images/suspense.png",'navigate':""},

  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  Future<void> loadUser()async{
    final storedUser = await authController.getUserFromStorage();

    setState(() {
      user = storedUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const CircularProgressIndicator() // Show a loading indicator
            : user != null
            ? Column(
          children: [
            UserCard(user: user as UserModel,),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio:
                  0.9, // Adjust this ratio for card height/width
                ),
                itemCount: portalDetails.length,
                itemBuilder: (context,index){
                  final cardData = portalDetails[index];
                  return PortalCard(portalName: cardData['name']!, image: cardData['image']!,navigate: cardData['navigate']!,);
                },
              ),
            ),

          ],
        ) // Pass the loaded user data
            : const Text('User not found'),
      ),
    );
  }
}
