import 'package:av_master_mobile/controllers/attendance/attendance_controller.dart';
import 'package:av_master_mobile/models/attendance/attendance_request.dart';
import 'package:av_master_mobile/screens/attendance/executive/team_absentees.dart';
import 'package:av_master_mobile/screens/attendance/executive/team_leaves.dart';
import 'package:av_master_mobile/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TeamAttendance extends StatefulWidget {
  const TeamAttendance({super.key});

  @override
  State<TeamAttendance> createState() => _TeamAttendanceState();
}

class _TeamAttendanceState extends State<TeamAttendance> {
  // Correctly type the RxList to hold AttendanceRequest objects
  RxList<AttendanceRequest> attendees = RxList<AttendanceRequest>();
  RxList<AttendanceRequest> exeAttendees = RxList<AttendanceRequest>();
  RxString tecType = ''.obs;
  RxString exeType = ''.obs;
  RxInt noOfPeriods = 0.obs;

  RxList<AttendanceRequest> selectedAttendees = <AttendanceRequest>[].obs;
  RxList<AttendanceRequest> selectedexeAttendees = <AttendanceRequest>[].obs;
  AttendanceController attendanceController = Get.put(AttendanceController());
  final userProvider = Get.find<UserProvider>();

  // Use a nullable parameter `String?`
  String _getTimePeriodForCheckIn(String? time) {
    if (time == null || time.isEmpty) {
      return 'invalid';
    }

    try {
      // 1. Use DateFormat to parse the string.
      // This is much more reliable than manual string splitting.
      final DateTime arrivalTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).parse(time);

      final morningCutoff = DateTime(
        arrivalTime.year,
        arrivalTime.month,
        arrivalTime.day,
        6,
        45,
      );
      final earlyCutoff = DateTime(
        arrivalTime.year,
        arrivalTime.month,
        arrivalTime.day,
        7,
        0,
      );
      final regularCutoff = DateTime(
        arrivalTime.year,
        arrivalTime.month,
        arrivalTime.day,
        8,
        0,
      );

      // 2. The rest of the logic remains the same.
      if (arrivalTime.isBefore(morningCutoff)) {
        return '1';
      } else if (arrivalTime.isAfter(morningCutoff) &&
          arrivalTime.isBefore(earlyCutoff)) {
        return '2';
      } else if (arrivalTime.isAfter(earlyCutoff) &&
          arrivalTime.isBefore(regularCutoff)) {
        return '3';
      } else if (arrivalTime.isAfter(regularCutoff)) {
        return '4';
      }

      return '2';
    } catch (e) {
      // Return 'invalid' on any parsing error.
      print('Parsing error in _getTimePeriod: $e');
      return 'invalid';
    }
  }

  String _getTimePeriodForCheckOut(String? time) {
    if (time == null || time.isEmpty) {
      return 'invalid';
    }

    try {
      final DateTime departureTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).parse(time);

      final regularCutoff = DateTime(
        departureTime.year,
        departureTime.month,
        departureTime.day,
        17,
        0,
      ); // 5:00 PM
      final lateCutoff = DateTime(
        departureTime.year,
        departureTime.month,
        departureTime.day,
        18,
        30,
      ); // 6:30 PM

      if (departureTime.isAfter(lateCutoff)) {
        return '1';
      } else if (departureTime.isAfter(regularCutoff)) {
        return '2';
      }

      return 'invalid'; // Or handle cases before 5:00 PM as needed
    } catch (e) {
      print('Parsing error in _getTimePeriodForCheckOut: $e');
      return 'invalid';
    }
  }

  // Color _getColorForTime(String? time, int boxIndex, String? selectedPeriod) {
  //   final timePeriod = _getTimePeriod(time);
  //   final boxPeriod = (boxIndex + 1).toString();
  //
  //   // Prioritize the user's selected period
  //   if (selectedPeriod == boxPeriod) {
  //     return Colors.blue;
  //   }
  //   if (boxIndex == 1) {
  //     return timePeriod == '1' ? Colors.green : Colors.white;
  //   } else if (boxIndex == 2) {
  //     return timePeriod == '2' ? Colors.green : Colors.white;
  //   } else if (boxIndex == 3) {
  //     if (timePeriod == '3') {
  //       return Colors.green;
  //     } else if (timePeriod == '4') {
  //       return Colors.red;
  //     }
  //     return Colors.white;
  //   }
  //   return Colors.white;
  // }

  RxBool isAllTecSelected = false.obs;
  RxBool isAllExeSelected = false.obs;

  Future<void> loadTodayAttendance(String company, String epfNumber) async {
    final fetchedData = await attendanceController.loadTodayAttendanceList(
      company: company,
      epfNumber: epfNumber,
    );
    print(fetchedData);
    if (fetchedData != null) {
      setState(() {
        tecType.value = fetchedData['tech_list_type'];
        var listData;
        if (tecType.value == 'check_in') {
          noOfPeriods.value = 3;
          listData = fetchedData['tech_list'];
          attendees.assignAll(
            listData.map<AttendanceRequest>((item) {
              final attendee = AttendanceRequest.fromJsonForCheckIn(item);
              attendee.selectedTimePeriod = _getTimePeriodForCheckIn(
                attendee.time,
              ); // Call _getTimePeriod here
              return attendee;
            }).toList(),
          );
        } else {
          noOfPeriods.value = 2;
          listData = fetchedData['tech_list'];
          attendees.assignAll(
            listData.map<AttendanceRequest>((item) {
              final attendee = AttendanceRequest.fromJsonForCheckOut(item);
              attendee.selectedTimePeriod = _getTimePeriodForCheckOut(
                attendee.time,
              ); // Call _getTimePeriod here
              return attendee;
            }).toList(),
          );
        }

        exeType.value = fetchedData['exe_list_type'];
        var exeListData;
        if (tecType.value == 'check_in') {
          // noOfPeriods.value = 3;
          exeListData = fetchedData['exe_list'];
          exeAttendees.assignAll(
            exeListData.map<AttendanceRequest>((item) {
              final attendee = AttendanceRequest.fromJsonForCheckIn(item);
              attendee.selectedTimePeriod = _getTimePeriodForCheckIn(
                attendee.time,
              ); // Call _getTimePeriod here
              return attendee;
            }).toList(),
          );
        } else {
          // noOfPeriods.value = 2;
          exeListData = fetchedData['exe_list'];
          exeAttendees.assignAll(
            exeListData.map<AttendanceRequest>((item) {
              final attendee = AttendanceRequest.fromJsonForCheckOut(item);
              attendee.selectedTimePeriod = _getTimePeriodForCheckOut(
                attendee.time,
              ); // Call _getTimePeriod here
              return attendee;
            }).toList(),
          );
        }

        // Map the list of maps to a list of AttendanceRequest objects
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // This loop is no longer necessary as you'll handle it inside the ListView.builder.
    // The `attendees` list is initially empty.
    // for (var attendee in attendees) {
    //   attendee.controller = TextEditingController(text: attendee.time ?? '');
    // }
    loadTodayAttendance(
      userProvider.user!.company,
      userProvider.user!.epfNumber,
    );
  }

  @override
  void dispose() {
    for (var attendee in attendees) {
      attendee.controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Mark Attendance")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TeamAbsentees(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning, color: Colors.red),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0074F9).withOpacity(0.1),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TeamLeaves(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF0074F9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Text("Technicians",style: TextStyle(
                fontSize: 19,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold
              )),
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
                        title: const Text("All"),
                        value: isAllTecSelected.value,
                        onChanged: (value) {
                          isAllTecSelected.value = value!;
                          if (isAllTecSelected.value) {
                            // Assign all attendees to the selectedAttendees list
                            selectedAttendees.assignAll(attendees);
                          } else {
                            selectedAttendees.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{

                        if(selectedAttendees.isNotEmpty){
                          if(tecType.value=='check_in'){
                           final result = await attendanceController.approveCheckIn(epfNumber: userProvider.user!.epfNumber, attendanceRequests: selectedAttendees);
                           if(result == true){
                             await loadTodayAttendance(userProvider.user!.company, userProvider.user!.epfNumber);
                           }else{
                             Get.snackbar("Error on approving!", "Please try again");
                           }
                          }else{
                            final result = await attendanceController.approveCheckOut(epfNumber: userProvider.user!.epfNumber, attendanceRequests: selectedAttendees);
                            if(result == true){
                              await loadTodayAttendance(userProvider.user!.company, userProvider.user!.epfNumber);
                            }else{
                              Get.snackbar("Error on approving!", "Please try again");
                            }
                          }
                        }else{
                          Get.snackbar("Select to approve", '');
                        }
                        // print(selectedAttendees.length);
                        // final List<int> idsToRemove = selectedAttendees
                        //     .map((attendee) => attendee.id!) // Use the 'id' property of the object
                        //     .toList();
                        //
                        // setState(() {
                        //   attendees.removeWhere((attendee) => idsToRemove.contains(attendee.id));
                        //   selectedAttendees.clear();
                        //   isAllSelected.value = false;
                        // });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Approve",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Obx(
              //   () => Row(
              //     children: [
              //       Expanded(
              //         flex: 3,
              //         child: Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 50),
              //           child: Text(
              //             "Name",
              //             style: TextStyle(
              //               color: colorScheme.onSurface,
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         child: Text(
              //           type.value=='check_in'?'In Time':'Out Time',
              //           style: TextStyle(
              //             color: colorScheme.onSurface,
              //             fontSize: 18,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ),
              //       type.value=='check_out'?Expanded(flex:2,child: Text("Working Place",style: TextStyle(
              //         color: colorScheme.onSurface,
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //       ),)):SizedBox.shrink(),
              //       type.value=='check_out'?Expanded(flex:2,child: Text("Site No",style: TextStyle(
              //         color: colorScheme.onSurface,
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //       ),)):SizedBox.shrink(),
              //       ...List.generate(
              //         noOfPeriods.value,
              //         (boxIndex) => Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 6.0),
              //           child: Text(
              //             '${boxIndex + 1}',
              //             style: TextStyle(
              //               color: colorScheme.onSurface,
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Obx(()=>attendees.isEmpty?Text(
                'No technicians to mark today.',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                )):
              Expanded(
              child: ListView.builder(
              itemCount: attendees.length,
                itemBuilder: (context, index) {
                  final attendee = attendees[index];

                  // Use a controller specific to each attendee to manage state
                  // This is crucial to prevent the time from reverting
                  final TextEditingController textEditingController =
                  TextEditingController(text: attendee.time);
                  final TextEditingController siteNoController =
                  TextEditingController(text: attendee.siteNo ?? '');

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    child: Obx(
                          () => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicWidth(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CheckboxListTile(
                                  title: Text(attendee.name ?? ''),
                                  value: selectedAttendees.any(
                                        (item) => item.id == attendee.id,
                                  ),
                                  onChanged: (bool? value) {
                                    if (value == true) {
                                      // Add the entire attendee object to the selected list
                                      selectedAttendees.add(attendee);
                                      if (selectedAttendees.length ==
                                          attendees.length) {
                                        isAllTecSelected.value = true;
                                      }
                                    } else {
                                      // Remove the attendee object based on its ID
                                      selectedAttendees.removeWhere(
                                            (item) => item.id == attendee.id,
                                      );
                                      isAllTecSelected.value = false;
                                    }
                                  },
                                  controlAffinity:
                                  ListTileControlAffinity.leading,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    // Format the time string before setting the controller's text
                                    text: attendee.time != null
                                        ? DateFormat('h:mm a').format(
                                      DateFormat(
                                        'yyyy-MM-dd HH:mm:ss',
                                      ).parse(attendee.time),
                                    )
                                        : '',
                                  ),
                                  decoration:  InputDecoration(
                                    labelText: tecType.value=='check_in'?'In Time':'Out Time',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (newTime) {
                                    try {
                                      // 1. Parse the original time string to get the full DateTime object (including the correct date)
                                      final DateTime originalDateTime = DateFormat(
                                        'yyyy-MM-dd HH:mm:ss',
                                      ).parse(attendee.time);

                                      // 2. Parse the new time from the text field
                                      final DateTime parsedTime = DateFormat('h:mm a').parse(newTime);

                                      // 3. Create a new DateTime by combining the original date with the new time
                                      final DateTime updatedDateTime = DateTime(
                                        originalDateTime.year,
                                        originalDateTime.month,
                                        originalDateTime.day,
                                        parsedTime.hour,
                                        parsedTime.minute,
                                        parsedTime.second,
                                      );

                                      // 4. Update the attendee's time with the correctly formatted new DateTime
                                      attendee.time = DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedDateTime);

                                      if (tecType.value == 'check_in') {
                                        attendee.selectedTimePeriod = _getTimePeriodForCheckIn(attendee.time);
                                      } else {
                                        attendee.selectedTimePeriod = _getTimePeriodForCheckOut(attendee.time);
                                      }

                                      attendees.refresh();
                                    } catch (e) {
                                      print('Invalid time format during onChanged: $e');
                                      // You can add a snackbar or other UI feedback here for the user.
                                    }
                                  },

                                  onSubmitted: (newTime) {
                                    // When the user submits the time, re-format it if needed
                                    // and trigger a rebuild to update the UI
                                    try {
                                      final DateTime parsedTime = DateFormat(
                                        'h:mm a',
                                      ).parse(newTime);
                                      attendee.time = newTime;
                                      attendees.refresh();
                                    } catch (e) {
                                      // Handle parsing errors (e.g., if the user enters invalid time)
                                      print('Invalid time format: $newTime');
                                      // Revert the text to the last valid time
                                      textEditingController.text = attendee.time;
                                    }
                                  },
                                ),
                              ),
                              if (tecType.value == 'check_out') ...[
                                SizedBox(width: 10,),
                                Expanded(
                                  flex:2,
                                  child: DropdownButtonFormField<String>(
                                    isDense: true,
                                    decoration: const InputDecoration(
                                      labelText: "Working place",
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                    value: attendee.workingPlace,
                                    items: ['Office - Colombo', 'Office - Matara', 'Site']
                                        .map((String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(value),
                                      ),
                                    ))
                                        .toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        attendee.workingPlace = newValue;
                                        if (!selectedAttendees.any(
                                              (item) => item.id == attendee.id,
                                        )) {
                                          selectedAttendees.add(attendee);
                                        } else {
                                          final itemIndex = selectedAttendees.indexWhere(
                                                (item) => item.id == attendee.id,
                                          );
                                          if (itemIndex != -1) {
                                            selectedAttendees[itemIndex].workingPlace =
                                                attendee.workingPlace;
                                          }
                                        }
                                        attendees.refresh();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  flex:2,
                                  child: TextField(
                                    controller: siteNoController,
                                    decoration: const InputDecoration(
                                      labelText: "Site No",
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                    onChanged: (newSiteNo) {
                                      attendee.siteNo = newSiteNo;
                                      if (!selectedAttendees.any(
                                            (item) => item.id == attendee.id,
                                      )) {
                                        selectedAttendees.add(attendee);
                                      } else {
                                        final itemIndex = selectedAttendees.indexWhere(
                                              (item) => item.id == attendee.id,
                                        );
                                        if (itemIndex != -1) {
                                          selectedAttendees[itemIndex].siteNo =
                                              attendee.siteNo;
                                        }
                                      }
                                      attendees.refresh();
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                              ],
                              ...List.generate(
                                noOfPeriods.value,

                                    (boxIndex) => Padding(
                                  // Use padding for consistent spacing
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0.0,
                                    vertical: 0.0,
                                  ), // Adjust the value here
                                  child: Column(
                                    spacing:0,
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Checkbox(
                                          value:
                                          attendee.selectedTimePeriod ==
                                              (boxIndex + 1).toString(),
                                          onChanged: (bool? newValue) {
                                            if (newValue == true) {
                                              attendee.selectedTimePeriod =
                                                  (boxIndex + 1).toString();
                                              if (!selectedAttendees.any(
                                                    (item) => item.id == attendee.id,
                                              )) {
                                                selectedAttendees.add(attendee);
                                              } else {
                                                final itemIndex = selectedAttendees
                                                    .indexWhere(
                                                      (item) =>
                                                  item.id == attendee.id,
                                                );
                                                if (itemIndex != -1) {
                                                  selectedAttendees[itemIndex]
                                                      .selectedTimePeriod =
                                                      attendee.selectedTimePeriod;
                                                }
                                              }
                                            }
                                            attendees.refresh();
                                          },
                                          checkColor: Colors.white,
                                          activeColor: Colors.blue,
                                          visualDensity: VisualDensity(
                                            horizontal: -4.0,
                                            vertical: -4.0,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${boxIndex + 1}', // Add a title here
                                        style: TextStyle(fontSize: 12), // Adjust font size as needed
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              )
              ),

          SizedBox(height: 10,),
          Text("Executives",style: TextStyle(
              fontSize: 19,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.bold
          )),
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
                    title: const Text("All"),
                    value: isAllExeSelected.value,
                    onChanged: (value) {
                      isAllExeSelected.value = value!;
                      if (isAllExeSelected.value) {
                        // Assign all attendees to the selectedAttendees list
                        selectedexeAttendees.assignAll(exeAttendees);
                      } else {
                        selectedexeAttendees.clear();
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async{

                    if(selectedexeAttendees.isNotEmpty){
                      if(exeType.value=='check_in'){
                        final result = await attendanceController.approveCheckIn(epfNumber: userProvider.user!.epfNumber, attendanceRequests: selectedexeAttendees);
                        if(result == true){
                          await loadTodayAttendance(userProvider.user!.company, userProvider.user!.epfNumber);
                        }else{
                          Get.snackbar("Error on approving!", "Please try again");
                        }
                      }else{
                        final result = await attendanceController.approveCheckOut(epfNumber: userProvider.user!.epfNumber, attendanceRequests: selectedexeAttendees);
                        if(result == true){
                          await loadTodayAttendance(userProvider.user!.company, userProvider.user!.epfNumber);
                        }else{
                          Get.snackbar("Error on approving!", "Please try again");
                        }
                      }
                    }else{
                      Get.snackbar("Select to approve", '');
                    }
                    // print(selectedAttendees.length);
                    // final List<int> idsToRemove = selectedAttendees
                    //     .map((attendee) => attendee.id!) // Use the 'id' property of the object
                    //     .toList();
                    //
                    // setState(() {
                    //   attendees.removeWhere((attendee) => idsToRemove.contains(attendee.id));
                    //   selectedAttendees.clear();
                    //   isAllSelected.value = false;
                    // });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Approve",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Obx(
          //   () => Row(
          //     children: [
          //       Expanded(
          //         flex: 3,
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 50),
          //           child: Text(
          //             "Name",
          //             style: TextStyle(
          //               color: colorScheme.onSurface,
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: Text(
          //           type.value=='check_in'?'In Time':'Out Time',
          //           style: TextStyle(
          //             color: colorScheme.onSurface,
          //             fontSize: 18,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //       type.value=='check_out'?Expanded(flex:2,child: Text("Working Place",style: TextStyle(
          //         color: colorScheme.onSurface,
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),)):SizedBox.shrink(),
          //       type.value=='check_out'?Expanded(flex:2,child: Text("Site No",style: TextStyle(
          //         color: colorScheme.onSurface,
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),)):SizedBox.shrink(),
          //       ...List.generate(
          //         noOfPeriods.value,
          //         (boxIndex) => Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 6.0),
          //           child: Text(
          //             '${boxIndex + 1}',
          //             style: TextStyle(
          //               color: colorScheme.onSurface,
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Obx(()=>exeAttendees.isEmpty?Text(
              'No executives to mark today.',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface.withOpacity(0.6),
              )):
          Expanded(
            child: ListView.builder(
              itemCount: exeAttendees.length,
              itemBuilder: (context, index) {
                final attendee = exeAttendees[index];

                // Use a controller specific to each attendee to manage state
                // This is crucial to prevent the time from reverting
                final TextEditingController textEditingController =
                TextEditingController(text: attendee.time);
                final TextEditingController siteNoController =
                TextEditingController(text: attendee.siteNo ?? '');

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: Obx(
                        () => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IntrinsicWidth(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CheckboxListTile(
                                title: Text(attendee.name ?? ''),
                                value: selectedexeAttendees.any(
                                      (item) => item.id == attendee.id,
                                ),
                                onChanged: (bool? value) {
                                  if (value == true) {
                                    // Add the entire attendee object to the selected list
                                    selectedexeAttendees.add(attendee);
                                    if (selectedexeAttendees.length ==
                                        exeAttendees.length) {
                                      isAllExeSelected.value = true;
                                    }
                                  } else {
                                    // Remove the attendee object based on its ID
                                    selectedexeAttendees.removeWhere(
                                          (item) => item.id == attendee.id,
                                    );
                                    isAllExeSelected.value = false;
                                  }
                                },
                                controlAffinity:
                                ListTileControlAffinity.leading,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  // Format the time string before setting the controller's text
                                  text: attendee.time != null
                                      ? DateFormat('h:mm a').format(
                                    DateFormat(
                                      'yyyy-MM-dd HH:mm:ss',
                                    ).parse(attendee.time),
                                  )
                                      : '',
                                ),
                                decoration:  InputDecoration(
                                  labelText: exeType.value=='check_in'?'In Time':'Out Time',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (newTime) {
                                  try {
                                    // 1. Parse the original time string to get the full DateTime object (including the correct date)
                                    final DateTime originalDateTime = DateFormat(
                                      'yyyy-MM-dd HH:mm:ss',
                                    ).parse(attendee.time);

                                    // 2. Parse the new time from the text field
                                    final DateTime parsedTime = DateFormat('h:mm a').parse(newTime);

                                    // 3. Create a new DateTime by combining the original date with the new time
                                    final DateTime updatedDateTime = DateTime(
                                      originalDateTime.year,
                                      originalDateTime.month,
                                      originalDateTime.day,
                                      parsedTime.hour,
                                      parsedTime.minute,
                                      parsedTime.second,
                                    );

                                    // 4. Update the attendee's time with the correctly formatted new DateTime
                                    attendee.time = DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedDateTime);

                                    if (exeType.value == 'check_in') {
                                      attendee.selectedTimePeriod = _getTimePeriodForCheckIn(attendee.time);
                                    } else {
                                      attendee.selectedTimePeriod = _getTimePeriodForCheckOut(attendee.time);
                                    }

                                    exeAttendees.refresh();
                                  } catch (e) {
                                    print('Invalid time format during onChanged: $e');
                                    // You can add a snackbar or other UI feedback here for the user.
                                  }
                                },

                                onSubmitted: (newTime) {
                                  // When the user submits the time, re-format it if needed
                                  // and trigger a rebuild to update the UI
                                  try {
                                    final DateTime parsedTime = DateFormat(
                                      'h:mm a',
                                    ).parse(newTime);
                                    attendee.time = newTime;
                                    exeAttendees.refresh();
                                  } catch (e) {
                                    // Handle parsing errors (e.g., if the user enters invalid time)
                                    print('Invalid time format: $newTime');
                                    // Revert the text to the last valid time
                                    textEditingController.text = attendee.time;
                                  }
                                },
                              ),
                            ),
                            if (exeType.value == 'check_out') ...[
                              SizedBox(width: 10,),
                              Expanded(
                                flex:2,
                                child: DropdownButtonFormField<String>(
                                  isDense: true,
                                  decoration: const InputDecoration(
                                    labelText: "Working place",
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  value: attendee.workingPlace,
                                  items: ['Office - Colombo', 'Office - Matara', 'Site']
                                      .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(value),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      attendee.workingPlace = newValue;
                                      if (!selectedexeAttendees.any(
                                            (item) => item.id == attendee.id,
                                      )) {
                                        selectedexeAttendees.add(attendee);
                                      } else {
                                        final itemIndex = selectedexeAttendees.indexWhere(
                                              (item) => item.id == attendee.id,
                                        );
                                        if (itemIndex != -1) {
                                          selectedexeAttendees[itemIndex].workingPlace =
                                              attendee.workingPlace;
                                        }
                                      }
                                      exeAttendees.refresh();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                flex:2,
                                child: TextField(
                                  controller: siteNoController,
                                  decoration: const InputDecoration(
                                    labelText: "Site No",
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (newSiteNo) {
                                    attendee.siteNo = newSiteNo;
                                    if (!selectedexeAttendees.any(
                                          (item) => item.id == attendee.id,
                                    )) {
                                      selectedexeAttendees.add(attendee);
                                    } else {
                                      final itemIndex = selectedexeAttendees.indexWhere(
                                            (item) => item.id == attendee.id,
                                      );
                                      if (itemIndex != -1) {
                                        selectedexeAttendees[itemIndex].siteNo =
                                            attendee.siteNo;
                                      }
                                    }
                                    exeAttendees.refresh();
                                  },
                                ),
                              ),
                              SizedBox(width: 10,),
                            ],
                            // ...List.generate(
                            //   noOfPeriods.value,
                            //
                            //       (boxIndex) => Padding(
                            //     // Use padding for consistent spacing
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 0.0,
                            //       vertical: 0.0,
                            //     ), // Adjust the value here
                            //     child: Column(
                            //       spacing:0,
                            //       children: [
                            //         Transform.scale(
                            //           scale: 0.7,
                            //           child: Checkbox(
                            //             value:
                            //             attendee.selectedTimePeriod ==
                            //                 (boxIndex + 1).toString(),
                            //             onChanged: (bool? newValue) {
                            //               if (newValue == true) {
                            //                 attendee.selectedTimePeriod =
                            //                     (boxIndex + 1).toString();
                            //                 if (!selectedAttendees.any(
                            //                       (item) => item.id == attendee.id,
                            //                 )) {
                            //                   selectedAttendees.add(attendee);
                            //                 } else {
                            //                   final itemIndex = selectedAttendees
                            //                       .indexWhere(
                            //                         (item) =>
                            //                     item.id == attendee.id,
                            //                   );
                            //                   if (itemIndex != -1) {
                            //                     selectedAttendees[itemIndex]
                            //                         .selectedTimePeriod =
                            //                         attendee.selectedTimePeriod;
                            //                   }
                            //                 }
                            //               }
                            //               attendees.refresh();
                            //             },
                            //             checkColor: Colors.white,
                            //             activeColor: Colors.blue,
                            //             visualDensity: VisualDensity(
                            //               horizontal: -4.0,
                            //               vertical: -4.0,
                            //             ),
                            //           ),
                            //         ),
                            //         Text(
                            //           '${boxIndex + 1}', // Add a title here
                            //           style: TextStyle(fontSize: 12), // Adjust font size as needed
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
          )
            ],
          ),
        ),
      ),
    );
  }
}
