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
  RxString type = ''.obs;

  RxList<Map<String, dynamic>> selectedAttendees = <Map<String, dynamic>>[].obs;
  AttendanceController attendanceController = Get.put(AttendanceController());
  final userProvider = Get.find<UserProvider>();

  // Use a nullable parameter `String?`
  String _getTimePeriod(String? time) {
    if (time == null || time.isEmpty) {
      return 'invalid';
    }

    try {
      // 1. Use DateFormat to parse the string.
      // This is much more reliable than manual string splitting.
      final DateTime arrivalTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(time);

      final morningCutoff = DateTime(arrivalTime.year, arrivalTime.month, arrivalTime.day, 6, 45);
      final earlyCutoff = DateTime(arrivalTime.year, arrivalTime.month, arrivalTime.day, 7, 0);
      final regularCutoff = DateTime(arrivalTime.year, arrivalTime.month, arrivalTime.day, 8, 0);

      // 2. The rest of the logic remains the same.
      if (arrivalTime.isBefore(morningCutoff)) {
        return '1';
      } else if (arrivalTime.isAfter(morningCutoff) && arrivalTime.isBefore(earlyCutoff)) {
        return '2';
      } else if (arrivalTime.isAfter(earlyCutoff) && arrivalTime.isBefore(regularCutoff)) {
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

  Color _getColorForTime(String? time, int boxIndex, String? selectedPeriod) {
    final timePeriod = _getTimePeriod(time);
    final boxPeriod = (boxIndex + 1).toString();

    // Prioritize the user's selected period
    if (selectedPeriod == boxPeriod) {
      return Colors.blue;
    }
    if (boxIndex == 1) {
      return timePeriod == '1' ? Colors.green : Colors.white;
    } else if (boxIndex == 2) {
      return timePeriod == '2' ? Colors.green : Colors.white;
    } else if (boxIndex == 3) {
      if (timePeriod == '3') {
        return Colors.green;
      } else if (timePeriod == '4') {
        return Colors.red;
      }
      return Colors.white;
    }
    return Colors.white;
  }

  RxBool isAllSelected = false.obs;

  Future<void> loadTodayAttendance(String company, String epfNumber) async {
    final fetchedData = await attendanceController.loadTodayAttendanceList(
        company: company, epfNumber: epfNumber);
    print(fetchedData);
    if (fetchedData != null) {
      setState(() {
        type.value = fetchedData['list_type'];
        var listData;
        if (type.value == 'check_in') {
          listData = fetchedData['check_in_list'];
        } else {
          listData = fetchedData['check_out_list'];
        }

        // Map the list of maps to a list of AttendanceRequest objects
        attendees.assignAll(listData.map<AttendanceRequest>((item) => AttendanceRequest.fromJson(item)).toList());
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
    loadTodayAttendance(userProvider.user!.company, userProvider.user!.epfNumber);
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TeamAbsentees()));
                    },
                    icon: const Icon(Icons.warning, color: Colors.red),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0074F9).withOpacity(0.1),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TeamLeaves()));
                    },
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF0074F9),
                    ),
                  ),
                ],
              ),
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
                        value: isAllSelected.value,
                        onChanged: (value) {
                          isAllSelected.value = value!;
                          if (isAllSelected.value) {
                            for (var attendee in attendees) {
                              if (!selectedAttendees.any((item) => item['id'] == attendee.id)) {
                                final timePeriod = _getTimePeriod(attendee.time);
                                selectedAttendees.add({
                                  'id': attendee.id,
                                  'time_period': timePeriod,
                                });
                              }
                            }
                          } else {
                            selectedAttendees.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final List<int> idsToRemove = selectedAttendees
                            .map((attendee) => attendee['id'] as int)
                            .toList();

                        setState(() {
                          attendees.removeWhere((attendee) => idsToRemove.contains(attendee.id));
                          selectedAttendees.clear();
                          isAllSelected.value = false;
                        });
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
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        "Name",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "In Time",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...List.generate(
                    3,
                        (boxIndex) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        '${boxIndex + 1}',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = attendees[index];

                    // Use a controller specific to each attendee to manage state
                    // This is crucial to prevent the time from reverting
                    final TextEditingController textEditingController = TextEditingController(text: attendee.time);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0,
                      ),
                      child: Obx(
                            () => Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CheckboxListTile(
                                title: Text(attendee.name ?? ''),
                                value: selectedAttendees.any(
                                      (item) => item['id'] == attendee.id,
                                ),
                                onChanged: (bool? value) {
                                  if (value == true) {
                                    selectedAttendees.add({
                                      'id': attendee.id,
                                      'time_period': _getTimePeriod(textEditingController.text),
                                    });
                                    if(selectedAttendees.length==attendees.length){
                                      setState(() {
                                        isAllSelect.value = true;
                                      });
                                    }
                                  } else {
                                    selectedAttendees.removeWhere(
                                            (item) => item['id'] == attendee.id);
                                    isAllSelected.value = false;
                                  }
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  // Format the time string before setting the controller's text
                                  text: attendee.time != null
                                      ? DateFormat('h:mm a')
                                      .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(attendee.time!))
                                      : '',
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                onChanged: (newTime) {
                                  try {
                                    // Parse the new time in the expected user input format
                                    final DateTime parsedTime = DateFormat('h:mm a').parse(newTime);
                                    // Store the time in the original API format
                                    attendee.time = DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedTime);
                                  } catch (e) {
                                    // Handle parsing errors gracefully
                                    print('Invalid time format during onChanged: $e');
                                    // Optionally, you can revert the text field's value here
                                  }
                                },

                                onSubmitted: (newTime) {
                                  // When the user submits the time, re-format it if needed
                                  // and trigger a rebuild to update the UI
                                  try {
                                    final DateTime parsedTime = DateFormat('h:mm a').parse(newTime);
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
                            ...List.generate(
                              3,
                                  (boxIndex) => GestureDetector(
                                    onTap: () {
                                      // Update the selectedTimePeriod in the model.
                                      // This allows the user to tap and select a period
                                      // even if the checkbox isn't checked yet.
                                      attendee.selectedTimePeriod = (boxIndex + 1).toString();

                                      // Also, make sure the attendee is added to the selection list.
                                      // This ensures the approve button works for single selections.
                                      if (!selectedAttendees.any((item) => item['id'] == attendee.id)) {
                                        selectedAttendees.add({
                                          'id': attendee.id,
                                          'time_period': attendee.selectedTimePeriod,
                                        });
                                      } else {
                                        // If already selected, update the time_period
                                        final itemIndex = selectedAttendees.indexWhere((item) => item['id'] == attendee.id);
                                        if (itemIndex != -1) {
                                          selectedAttendees[itemIndex]['time_period'] = attendee.selectedTimePeriod;
                                        }
                                      }
                                      attendees.refresh(); // Trigger a rebuild
                                    },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      color: _getColorForTime(
                                        attendee.time, // This is the formatted string (e.g., "7:46 AM")
                                        boxIndex,
                                        attendee.selectedTimePeriod,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}