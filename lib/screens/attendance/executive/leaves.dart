import 'package:av_master_mobile/controllers/attendance/leave_controller.dart';
import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/screens/attendance/apply_leave.dart';
import 'package:av_master_mobile/screens/profile.dart';
import 'package:av_master_mobile/widgets/attendance/leave_card.dart';
import 'package:av_master_mobile/widgets/attendance/leave_detail_card.dart';
import 'package:av_master_mobile/widgets/attendance/leave_request_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Leaves extends StatefulWidget {
  const Leaves({super.key});

  @override
  State<Leaves> createState() => _LeavesState();
}

final RxString currentState = 'Upcoming'.obs;
LeaveController leaveController = Get.put(LeaveController());
List<LeaveModel> leaves = <LeaveModel>[].obs;
List<LeaveModel> leaveRequests = <LeaveModel>[].obs;
TextEditingController filterFromDate = TextEditingController();
final List <RxString> filterName = <RxString>[].obs;
UserModel? user;
Map<String,dynamic>? leaveSummery;


class _LeavesState extends State<Leaves> {

  final leaveTypeList = {'Medical Leave','Annual Leave','Casual Leave'};
  final RxMap<String, bool> checkedLeaveTypes = <String, bool>{}.obs;

  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(
        DateTime.now().year + 5,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy.MM.dd').format(picked);
      controller.text = formattedDate;
    }
  }

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

  Future loadLeaveRequests()async{
    final fetchedLeaveRequests = await leaveController.fetchLeaveRequests(epfNumber: user!.epfNumber);
    if(fetchedLeaveRequests.isNotEmpty){
      setState(() {
        leaveRequests.clear(); // Clear the old list
        leaveRequests.addAll(fetchedLeaveRequests);
        leaveRequests = fetchedLeaveRequests;
      });
    }else{
      leaveRequests.clear();
    }
  }

  Future reLoadLeaveRequests()async{
    await loadLeaveRequests();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the map with all leave types set to false
    for (var leaveType in leaveTypeList) {
      checkedLeaveTypes[leaveType] = false;
    }
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "All Leaves",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                spacing: 7,
                children: [
                  //apply a leave
                  InkWell(
                    child: Icon(
                      Icons.add_box_outlined,
                      color: colorScheme.onSurface,
                    ),
                    onTap: () {
                      print('tapped');
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ApplyLeave()),
                      );
                    },
                  ),
                  //filter leave requests
                  currentState.value == "Team"
                      ? InkWell(
                          child: Icon(
                            Icons.display_settings_rounded,
                            color: colorScheme.onSurface,
                          ),
                          onTap: () {
                            print('Filter');
                            showModalBottomSheet(context: context, builder: (BuildContext context){
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Container(
                                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Filter"),
                                          // SizedBox(height: 10,),
                                          Text("Date From"),
                                          GestureDetector(
                                            child: AbsorbPointer(
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                    hintText: "Filter from",
                                                  suffixIcon: Icon(Icons.calendar_month_rounded)
                                                ),
                                                controller: filterFromDate,
                                                keyboardType: TextInputType.datetime,
                                              ),
                                            ),
                                            onTap:(){ selectDate(context,filterFromDate);},
                                          ),
                                          SizedBox(height: 10,),
                                          Text("Leave Type"),
                                          Expanded(
                                            child: Obx(() {
                                              return ListView(
                                                shrinkWrap: true,
                                                children: leaveTypeList.map((leaveType) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 0.0), // Adjust this value to control spacing
                                                    child: CheckboxListTile(
                                                      title: Text(leaveType),
                                                      controlAffinity: ListTileControlAffinity.leading,
                                                      dense: true,
                                                      visualDensity: VisualDensity.compact,
                                                      materialTapTargetSize:
                                                      MaterialTapTargetSize.shrinkWrap,
                                                      contentPadding: EdgeInsets.zero,
                                                      value: checkedLeaveTypes[leaveType] ?? false,
                                                      onChanged: (bool? newValue) {
                                                        checkedLeaveTypes[leaveType] = newValue!;
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            }),
                                          ),
                                          // Obx((){
                                          //   filterName =
                                          //   return DropdownButtonFormField<String>(
                                          //       value: leaveRequests.isNotEmpty ? leaveRequests.first.name:null,
                                          //       items:leaveRequests.map((request){
                                          //         return DropdownMenuItem<String>(child: Text( request.name!));
                                          //       }).toList() , onChanged: (value){
                                          //     filterName.value = value.toString();
                                          //   });
                                          // })

                                        ],
                                      )
                                      ),
                                ),
                              );
                            });
                          },
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          //leave summery
          Column(
            spacing: 15,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  LeaveCard(
                    leaveType: "Leave Balance",
                    leaveCount: leaveSummery?['leave_balance']??0,
                    color: Color(0xFF0074F9),
                  ),
                  LeaveCard(
                    leaveType: "Approved Leaves",
                    leaveCount: leaveSummery?['accepted_leaves']??0,
                    color: Color(0xFF00C63B),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  LeaveCard(
                    leaveType: "Pending Leaves",
                    leaveCount: leaveSummery?['pending_leaves']??0,
                    color: Color(0xFF01601E),
                  ),
                  LeaveCard(
                    leaveType: "Rejected Leaves",
                    leaveCount: leaveSummery?['rejected_leaves']??0,
                    color: Color(0xFFF90004),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          //segmentController
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(10),
            child: CupertinoSegmentedControl(
              borderColor: Colors.transparent,
              padding: EdgeInsets.all(0),
              children: {
                'Upcoming': SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: currentState.value == 'Upcoming'
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Upcoming",
                          style: TextStyle(
                            color: currentState.value == 'Upcoming'
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                'Past': SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: currentState.value == 'Past'
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Past",
                          style: TextStyle(
                            color: currentState.value == 'Past'
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                'Team': SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: currentState.value == 'Team'
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Team",
                          style: TextStyle(
                            color: currentState.value == 'Team'
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              },
              onValueChanged: (String value)async {
                setState(() {
                  currentState.value = value;
                  // leaves = leaveController.fetchLeaves(state: value);
                });
                if(value!='Team'){
                  await fetchLeaves();
                }else{
                  await loadLeaveRequests();
                }
              },
            ),
          ),

          SizedBox(height: 15),
          //my leaves or leave requests
          SizedBox(
            height: leaves.isEmpty&&currentState.value!='Team'?50:leaveRequests.isEmpty&&currentState.value=='Team'?50:900,
            child: Obx(() {
              // leaves =  leaveController.fetchLeaves(state: currentState.value,epfNumber: user!.epfNumber);
              if (currentState.value == "Team") {//leave requests
                if(leaveRequests.isEmpty){
                  return Center(
                    child: Text(
                      "No leave requests to display.",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }else{
                  return ListView.builder(
                      itemCount: leaveRequests.length,
                      itemBuilder: (context,index){
                        return Padding(padding: EdgeInsets.only(bottom: 10),
                          child: LeaveRequestCard(leaveRequest: leaveRequests[index],onActionComplete: reLoadLeaveRequests,),);
                      });
                }
              } else {//my leaves
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
              }
            }),
          ),
        ],
      ),
    );
  }
}
