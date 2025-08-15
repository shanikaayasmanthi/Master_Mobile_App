import 'package:av_master_mobile/screens/attendance/executive/team_leaves.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamAttendance extends StatefulWidget {
  const TeamAttendance({super.key});

  @override
  State<TeamAttendance> createState() => _TeamAttendanceState();
}

class _TeamAttendanceState extends State<TeamAttendance> {
  final List<Map<String, dynamic>> attendees = [
    {
      'id': 23,
      'name': 'Lakmal Jayasuriya',
      'in_time': '6.30 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 30,
      'name': 'Kamal Wijesiri',
      'in_time': '7.30 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 20,
      'name': 'Ishan Sadaruwan',
      'in_time': '6.45 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 32,
      'name': 'Pubudu Kumara',
      'in_time': '6.50 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 26,
      'name': 'Rashan Sadanima',
      'in_time': '7.30 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 17,
      'name': 'Sadaru Thushan',
      'in_time': '7.30 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 53,
      'name': 'Thushanka Sethmina',
      'in_time': '8.10 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 3,
      'name': 'Themidu Rashmika',
      'in_time': '7.00 am',
      'out_time': '5.00 pm',
    },
    {
      'id': 12,
      'name': 'Kishan Rajapakse',
      'in_time': '6.30 am',
      'out_time': '5.00 pm',
    },
  ];

  RxList<Map<String, dynamic>> selectedAttendees = <Map<String, dynamic>>[].obs;

  String _getTimePeriod(String time) {
    String formattedTime = time.replaceAll('.', ':');
    DateTime arrivalTime = DateTime.now();

    try {
      final parts = formattedTime.split(' ');
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      int hour24 = hour;
      if (parts[1].toLowerCase() == 'pm' && hour != 12) {
        hour24 += 12;
      }
      if (parts[1].toLowerCase() == 'am' && hour == 12) {
        hour24 = 0;
      }

      arrivalTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour24,
        minute,
      );
    } catch (e) {
      return 'invalid';
    }

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
  }

  Color _getColorForTime(String time, int boxIndex) {
    final timePeriod = _getTimePeriod(time);
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
                spacing: 15,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.warning, color: Colors.red),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Color(0xFF0074F9).withOpacity(0.1),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const TeamLeaves()));
                    },
                    icon: Icon(
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
                              if (!selectedAttendees.any(
                                (item) => item['id'] == attendee['id'],
                              )) {
                                final timePeriod = _getTimePeriod(
                                  attendee['in_time'],
                                );
                                selectedAttendees.add({
                                  'id': attendee['id'],
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
                        // You can use selectedAttendees.value here
                        print(selectedAttendees.value);
                        final List<int> idsToRemove = selectedAttendees
                            .map((attendee) => attendee['id'] as int)
                            .toList();

                        setState(() {
                          // Remove attendees from the main list whose IDs are in idsToRemove
                          attendees.removeWhere(
                            (attendee) => idsToRemove.contains(attendee['id']),
                          );

                          // Clear the selected attendees list after removal
                          selectedAttendees.clear();

                          // Uncheck the "All" checkbox if it was selected
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
              SizedBox(height: 15),
              // Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              // child:
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
              // ),
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = attendees[index];
                    final timePeriod = _getTimePeriod(attendee['in_time']);
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
                                title: Text(attendee['name']),
                                value: selectedAttendees.any(
                                  (item) => item['id'] == attendee['id'],
                                ),
                                onChanged: (bool? value) {
                                  if (value == true) {
                                    selectedAttendees.add({
                                      'id': attendee['id'],
                                      'time_period': timePeriod,
                                    });
                                  } else {
                                    selectedAttendees.removeWhere(
                                      (item) => item['id'] == attendee['id'],
                                    );
                                    isAllSelected.value = false;
                                  }
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            Expanded(child: Text(attendee['in_time'])),
                            ...List.generate(
                              3,
                              (boxIndex) => Padding(
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
                                      attendee['in_time'],
                                      boxIndex + 1,
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
