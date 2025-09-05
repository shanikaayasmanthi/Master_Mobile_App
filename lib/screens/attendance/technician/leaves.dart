import 'package:av_master_mobile/controllers/attendance/leave_controller.dart';
import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/screens/attendance/apply_leave.dart';
import 'package:av_master_mobile/widgets/attendance/leave_card.dart';
import 'package:av_master_mobile/widgets/attendance/leave_detail_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../profile.dart';

class Leaves extends StatefulWidget {
  const Leaves({super.key});

  @override
  State<Leaves> createState() => _LeavesState();
}

final RxString currentState = 'Upcoming'.obs;
List<LeaveModel> leaves = <LeaveModel>[].obs;
UserModel? user;
Map<String,dynamic>? leaveSummery;

LeaveController leaveController = Get.put(LeaveController());


class _LeavesState extends State<Leaves> {

  Future loadUser()async{
    final fetchedUser = await authController.getUserFromStorage();
    if(fetchedUser!=null){
      setState(() {
        user =fetchedUser;
      });
      await loadLeaveSummery();
      final List<LeaveModel> fetchedLeaveList = await leaveController.fetchLeaves(
        state: currentState.value,
        epfNumber: user!.epfNumber,
      );
      setState(() {
        leaves = fetchedLeaveList;
      });
    }
  }

  Future fetchLeaves()async{
    final List<LeaveModel> fetchedLeaveList = await leaveController.fetchLeaves(
      state: currentState.value,
      epfNumber: user!.epfNumber,
    );
    setState(() {
      leaves = fetchedLeaveList;
    });
  }
  Future loadLeaveSummery()async{
    final fetchedLeaveSummery = await leaveController.loadLeaveSummery(epfNumber: user!.epfNumber);
    if(fetchedLeaveSummery!=null){
      setState(() {
        leaveSummery = fetchedLeaveSummery;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
    child: Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("All Leaves",
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),),
          InkWell(child: Icon(Icons.add_box_outlined,color: colorScheme.onSurface,),
          onTap: (){
            print('tapped');
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ApplyLeave()));
          },),

        ],
      ),
      SizedBox(height: 20,),
      Column(
        spacing: 15,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 15,
            children: [
              LeaveCard(leaveType: "Leave Balance",leaveCount: leaveSummery?['leave_balance']??0,color: Color(0xFF0074F9),),
              LeaveCard(leaveType: "Approved Leaves",leaveCount: leaveSummery?['accepted_leaves']??0,color: Color(0xFF00C63B),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 15,
            children: [
              LeaveCard(leaveType: "Pending Leaves",leaveCount: leaveSummery?['pending_leaves']??0,color: Color(0xFF01601E),),
              LeaveCard(leaveType: "Rejected Leaves",leaveCount: leaveSummery?['rejected_leaves']??0,color: Color(0xFFF90004),),
            ],
          )
        ],
      ),
      SizedBox(height: 25,),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CupertinoSegmentedControl(
            borderColor: Colors.transparent,
            padding: EdgeInsets.all(0),
            children: {
              'Upcoming':SizedBox(
                width:MediaQuery.of(context).size.width*0.35,
                height:MediaQuery.of(context).size.width*0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: currentState.value == 'Upcoming'? colorScheme.primary:colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Upcoming",style: TextStyle(
                          color: currentState.value == 'Upcoming'? Colors.white :colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                ),
              ),
              'Past':SizedBox(
                width:MediaQuery.of(context).size.width*0.35,
                height:MediaQuery.of(context).size.width*0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: currentState.value == 'Past'? colorScheme.primary:colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Past",style: TextStyle(
                          color: currentState.value == 'Past'? Colors.white:colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                ),
              ),
            }, onValueChanged: (String value)async{
          setState(() {
            currentState.value = value;
            // leaves = leaveController.fetchLeaves(state: value);
          });
          await fetchLeaves();
        }),
      ),
      // Obx(()=>Text(),
      // ),
      SizedBox(height: 15,),
      SizedBox(height: leaves.isEmpty?50:900,
      child: Obx(() {
        if (leaves.isEmpty) {
          return Center(
            child: Text(
              "No leaves to display.",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        } else {
          // If not empty, display the ListView
          return ListView.builder(
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LeaveDetailCard(leave: leaves[index]),
              );
            },
          );
        }
      }),)
    ],),);
  }
}
