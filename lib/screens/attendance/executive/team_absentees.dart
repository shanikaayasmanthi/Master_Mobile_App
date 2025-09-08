import 'package:av_master_mobile/controllers/attendance/attendance_controller.dart';
import 'package:av_master_mobile/controllers/attendance/leave_controller.dart';
import 'package:av_master_mobile/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamAbsentees extends StatefulWidget {
  const TeamAbsentees({super.key});

  @override
  State<TeamAbsentees> createState() => _TeamAbsenteesState();
}

LeaveController leaveController = Get.put(LeaveController());
AttendanceController attendanceController = Get.put(AttendanceController());
final userProvider = Get.find<UserProvider>();
RxList absentList = [].obs;
RxBool isAllSelect = false.obs;
RxList selectedList = [].obs;

class _TeamAbsenteesState extends State<TeamAbsentees> {
  Future<void> loadTodayAbsentees(String company) async {
    print(company);
    final fetchedList = await leaveController.loadTodayAbsentees(
      company: company,
    );
    // print(fetchedList);
    if (fetchedList != null) {
      absentList.assignAll(fetchedList);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTodayAbsentees(userProvider.user!.company);
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("Missing Attendance"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        contentPadding: EdgeInsets.zero,
                        value: isAllSelect.value,
                        title: const Text("All"),
                        onChanged: (value) {
                          setState(() {
                            isAllSelect.value = value!;
                            if(value==true){
                              selectedList.assignAll(absentList);
                            }else{
                              selectedList.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () async{
                        print(selectedList);
                        List<String> phoneNumbers =[];
                        selectedList.forEach((item){
                        if (item['office_phonenumber'] != null &&
                            item['office_phonenumber']!.trim().isNotEmpty) {
                          print(item['office_phonenumber']);
                            phoneNumbers.add(item['office_phonenumber']!);
                      }
                        // Check if the personal number is not null AND not empty/whitespace
                        else if (item['personal_phonenumber'] != null &&
                            item['personal_phonenumber']!.trim().isNotEmpty) {
                        phoneNumbers.add(item['personal_phonenumber']!);
                        }
                        });
                        print('Populated phone numbers list: $phoneNumbers');
                        await attendanceController.sendMessage(phoneNumbers: phoneNumbers);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Send MSG",
                        style: TextStyle(color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Obx(()=>Expanded(child: ListView.builder(
                  itemCount: absentList.length,
                  itemBuilder: (context,index){
                    final absentee = absentList[index];
                    return Obx(()=>Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            value: selectedList.any(
                                  (item) => item['epf_number'] == absentee['epf_number'],
                            ),
                            onChanged: (bool? value) {
                              if(value == true){
                                selectedList.add(absentee);
                                if(selectedList.length==absentList.length){
                                  setState(() {
                                    isAllSelect.value = true;
                                  });
                                }
                              }else{
                                selectedList.removeWhere((item)=>item['epf_number']==absentee['epf_number']);
                                isAllSelect.value = false;
                              }
                            },
                            title: Text(absentee['name']),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            print(absentee['office_phonenumber']);
                          },
                          icon: Icon(Icons.message_rounded),
                        ),
                      ],
                    ));
                  }))),
              // Obx((){
              //   return Row(
              //
              //     children: [
              //       Text("Name"),
              //       IconButton(onPressed: (){}, icon: Icon(Icons.message_rounded))
              //     ],
              //   );
              // })
            ],
          ),
        ),
      ),
    );
  }
}
