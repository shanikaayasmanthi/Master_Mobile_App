import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/widgets/portal_card.dart';
import 'package:av_master_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';

class PortalPage extends StatefulWidget {
  const PortalPage({super.key});

  @override
  State<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> {
  final portalDetails = [
    {'name': "Attendance", 'image': 'lib/images/attendance.png','navigate':""},
    // {'name': "Suspense", 'image': "lib/images/suspense.png",'navigate':""},

  ];

  final user = UserModel(name: "Shanika Ayasmanthi", company: "Alta Vision", designation: "Software Engineer");

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
        child: Column(
          children: [
            UserCard(user: user,),
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
        ),
      ),
    );
  }
}
