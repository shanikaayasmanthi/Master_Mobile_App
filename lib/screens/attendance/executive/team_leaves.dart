import 'package:av_master_mobile/controllers/attendance/leave_controller.dart';
import 'package:av_master_mobile/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamLeaves extends StatefulWidget {
  const TeamLeaves({super.key});

  @override
  State<TeamLeaves> createState() => _TeamLeavesState();
}

RxList leaveList = [].obs;

class _TeamLeavesState extends State<TeamLeaves> {

  LeaveController leaveController = Get.put(LeaveController());
  final userProvider = Get.find<UserProvider>();


  Future<void> loadLeaveList(String company)async{
    final fetchedList = await leaveController.loadTodayLeaveList(company: company);
    // print(fetchedList);
    // print(company);
    if (fetchedList != null) {
      leaveList.assignAll(fetchedList);
    }
    // print(leaveList);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadLeaveList(userProvider.user!.company);
  }

  @override
  Widget build(BuildContext context) {
        var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("Today Leave List"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Obx(() {
                if (leaveList.isEmpty) {
                  return Center(
                    child: Text(
                      "No leaves for today.",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 16,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: leaveList.length,
                    itemBuilder: (context, index) {
                      var leaveRecord = leaveList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(leaveRecord['status']=='pending'?Icons.error_outline:Icons.check_circle_outline,
                            color: leaveRecord['status']=='pending'?Color(0xFF01601E):Color(0xFF00C63B),),
                            SizedBox(width: 20),
                            Text(
                              leaveRecord['name'],
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              }))
            ],
          )
        ),
      ),
    );
  }
}
