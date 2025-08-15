import 'package:av_master_mobile/controllers/attendance/leave_controller.dart';
import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:av_master_mobile/screens/attendance/apply_leave.dart';
import 'package:av_master_mobile/widgets/attendance/leave_card.dart';
import 'package:av_master_mobile/widgets/attendance/leave_detail_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Leaves extends StatefulWidget {
  const Leaves({super.key});

  @override
  State<Leaves> createState() => _LeavesState();
}

final RxString currentState = 'Upcoming'.obs;
List<LeaveModel> leaves = <LeaveModel>[].obs;

LeaveController leaveController = Get.put(LeaveController());

class _LeavesState extends State<Leaves> {
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
              LeaveCard(leaveType: "Leave Balance",leaveCount: 04,color: Color(0xFF0074F9),),
              LeaveCard(leaveType: "Approved Leaves",leaveCount: 02,color: Color(0xFF00C63B),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 15,
            children: [
              LeaveCard(leaveType: "Pending Leaves",leaveCount: 01,color: Color(0xFF01601E),),
              LeaveCard(leaveType: "Rejected Leaves",leaveCount: 01,color: Color(0xFFF90004),),
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
            }, onValueChanged: (String value){
          setState(() {
            currentState.value = value;
            // leaves = leaveController.fetchLeaves(state: value);
          });
        }),
      ),
      // Obx(()=>Text(),
      // ),
      SizedBox(height: 15,),
      SizedBox(height: 900,
      child: Obx(() {
        leaves = leaveController.fetchLeaves(state: currentState.value);
        return ListView.builder(
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              return Padding(padding: EdgeInsets.only(bottom: 10),child: LeaveDetailCard(leave: leaves[index],),);
            });
      }),)
    ],),);
  }
}
