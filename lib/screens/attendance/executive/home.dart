import 'dart:convert';

import 'package:av_master_mobile/controllers/attendance/attendance_controller.dart';
import 'package:av_master_mobile/controllers/attendance/leave_controller.dart';
import 'package:av_master_mobile/controllers/auth_controller.dart';
import 'package:av_master_mobile/models/attendance/attendance.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/screens/attendance/executive/leaves.dart';
import 'package:av_master_mobile/screens/attendance/executive/team_attendance.dart';
import 'package:av_master_mobile/widgets/attendance/attendance_data_card.dart';
import 'package:av_master_mobile/widgets/attendance/attendance_swipe_button.dart';
import 'package:av_master_mobile/widgets/attendance/date_card.dart';
import 'package:av_master_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/attendance/leave_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {

  // final user = UserModel(name: "Nuwan Prasanna", company: "IOT Solutions", designation: "Software Engineer");
  late DateTime today;
  late List<DateTime> daysInMonth;
  List<String> requestedSupervisors = [];
  final RxString _siteNo = ''.obs;
  final TextEditingController _siteNoController = TextEditingController();
  final RxString selectedWorkingPlace = 'Select'.obs;
  final List<String> workingPlaces = ['Select','Office - Colombo', 'Office - Matara', 'Site'];

  final AttendanceController attendanceController = Get.put(AttendanceController());
  final LeaveController leaveController = Get.put(LeaveController());
  final AuthController authController = Get.put(AuthController());
  final FlutterSecureStorage storage = FlutterSecureStorage();
  int? numberOFWorkingDays;
  int? numberOfLeavesDays;


  AttendanceModel? lastCallbackAttendanceData;
  AttendanceModel? todayAttendance;
  UserModel? user;
  bool isLoading = true;
  bool canMarkAttendance = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    today = DateTime.now();
    daysInMonth = getDaysInMonth(today);
    loadUserAndCheckInStatus();
  }

  Future loadNumberOfWorkingDays()async{
    final fetchedWorkingDays = await attendanceController.getWorkingDays(epfNumber: user!.epfNumber);
    setState(() {
      numberOFWorkingDays=fetchedWorkingDays;
    });
  }

  Future loadNumberOfLeaves()async{
    final fetchedLeaveDays = await leaveController.loadNumberOfLeaves(epfNumber: user!.epfNumber);
    setState(() {
      numberOfLeavesDays = fetchedLeaveDays;
      print(numberOfLeavesDays);
    });
  }

  Future<void> loadTodayAttendance()async{
   final fetchedAttendanceData =  await attendanceController.loadTodayAttendance(epf_number: user!.epfNumber);
  todayAttendance = fetchedAttendanceData;
  final supervisorEpf = await attendanceController.getSupervisorForExe(epfNumber: user!.epfNumber);
  if(supervisorEpf!=null){
    setState(() {
      requestedSupervisors.assign(supervisorEpf);
      // print(requestedSupervisors.toString());
    });
  }


    // lastCallbackAttendanceData = await attendanceController.getTodayAttendanceFromStorage();
    // if(lastCallbackAttendanceData==null){
    //   final allKeys = await storage.readAll();
    //   for (final key in allKeys.keys) {
    //     if (key.contains('attendance')) {
    //       await storage.delete(key: key);
    //       print('Deleted key: $key');
    //     }
    //   }
    //   final today = DateTime.now();
    //   final Rx<AttendanceModel> attendanceModel = AttendanceModel().obs;
    //   final attendanceJson = json.encode(attendanceModel.toJson());
    //   await storage.write(key: 'attendance_${today.year}-${today.month}-${today.day}', value:attendanceJson);
    //   lastCallbackAttendanceData = attendanceModel.value;
    // }
    // print(lastCallbackAttendanceData?.isCheckIn);
    }

  Future<void> loadUserAndCheckInStatus() async {
    // First, load the user
    final storedUser = await authController.getUserFromStorage();
    setState(() {
      user = storedUser;
      isLoading = false;
    });

    // Only proceed to check attendance status if a user was loaded
    if (user != null) {
      final result = await attendanceController.checkCanMarkAttendance(epfNumber: user!.epfNumber);
      if(result==true){
        setState(() {
          canMarkAttendance = true;
          // print(canMarkAttendance);
          loadTodayAttendance();
          loadNumberOfWorkingDays();
          loadNumberOfLeaves();
        });
      }else{
        setState(() {
          canMarkAttendance = false;
          // print(canMarkAttendance);
        });
      }

    } else {
      // Handle the case where the user is not found
      print('User not found, cannot check attendance status.');
      setState(() {
        canMarkAttendance = false;
      });
    }
  }

  List<DateTime> getDaysInMonth(DateTime date) {
    var firstDayOfMonth = DateTime(date.year, date.month, 1);
    var lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    return List<DateTime>.generate(
      lastDayOfMonth.day,
          (i) => firstDayOfMonth.add(Duration(days: i)),
    );
  }

  @override
  Widget build(BuildContext context) {

    //DateFormat to format the day in week
    final dayOfWeekFormatter = DateFormat('E');
    // DateFormat to format the date
    final dayOfMonthFormatter = DateFormat('d');

    var colorScheme = Theme.of(context).colorScheme;
    return isLoading
        ? const CircularProgressIndicator() // Show a loading indicator
        : user != null
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserCard(user: user!),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // <-- You must specify the scroll direction here!
            itemCount: daysInMonth.length,
            itemBuilder: (context, index) {
              final day = daysInMonth[index];
              final isToday = day.day == today.day && day.month == today.month && day.year == today.year;
              final dateOfMonth = dayOfMonthFormatter.format(day);
              final dayOfWeek = dayOfWeekFormatter.format(day);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: DateCard(
                  date:dateOfMonth ,
                  day: dayOfWeek,
                  bgColor: isToday?colorScheme.primary:colorScheme.secondary,
                  dateColor: isToday?colorScheme.onPrimary:colorScheme.onSecondary,
                ),
              );
            },
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical:10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today Attendance",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const TeamAttendance()));
                  }, child: Text("Team"))
                ],
              ),
              SizedBox(height: 10,),
              canMarkAttendance?Column(
                children: [
                  Obx((){
                    final attendance = attendanceController.attendanceModel.value;
                    if(!attendance.isCheckOut && attendance.isCheckIn){
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Working Place",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Working Place Dropdown
                          Obx(() => DropdownButtonFormField<String>(
                            value: selectedWorkingPlace.value,
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                            dropdownColor: colorScheme.surface,
                            decoration: InputDecoration(
                            ),
                            items:  workingPlaces.map((String place) {
                              return DropdownMenuItem<String>(
                                value: place,
                                child: Text(place),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                selectedWorkingPlace.value = newValue.toString();
                                print(selectedWorkingPlace.value);
                                _siteNoController.text='';
                              }
                            },
                          )),
                          const SizedBox(height: 10),
                          // Conditionally show Site Number field if 'Site' is selected
                          Obx(() {
                            if (selectedWorkingPlace.value == 'Site') {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Enter Site Number",
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _siteNoController,
                                    style: TextStyle(color: colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: "e.g. 1029",
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: colorScheme.primary, width: 2),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value){
                                      _siteNo.value = value;
                                    },
                                  ),
                                  SizedBox(height: 10,),
                                ],
                              );
                            }
                            return const SizedBox.shrink(); // Hide the widget
                          }),
                        ],
                      );
                    }else{
                      return SizedBox.shrink();
                    }
                  }),
                  Obx(()=>AttendanceSwipeButton(selectedSupervisorIds:requestedSupervisors,attendanceController: attendanceController, workingPlace: selectedWorkingPlace.value, siteNo: int.tryParse(_siteNo.value)??0)),
                  SizedBox(height: 15,),
                  Column(
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(() {
                            final attendance =
                                attendanceController.attendanceModel.value;
                            String timeText = attendance.checkedInTime != null
                                ? "${attendance.checkedInTime!.hour.toString().padLeft(2, '0')}:${attendance.checkedInTime!.minute.toString().padLeft(2, '0')} ${attendance.checkedInTime!.hour >= 12 ? 'PM' : 'AM'}"
                                : "Not Yet";
                            dynamic subDescriptionText = attendance.isCheckIn
                                ? (attendance.isCheckInApproved
                                ? "Approved"
                                : "Pending")
                                : null;
                            Color subDescriptionColor = attendance.isCheckIn
                                ? (attendance.isCheckInApproved
                                ? Colors.green
                                : Colors.orange)
                                : Colors.red;
                            String dynamicCheckInDescription;
                            Color dynamicCheckInDescriptionColor;
                            if (!attendance.isCheckIn) {
                              dynamicCheckInDescription = "Check-in before 9:00 AM";
                              dynamicCheckInDescriptionColor = Colors.red;
                            } else if (attendance.checkedInTime != null) {
                              final checkInHour = attendance.checkedInTime!.hour;
                              final checkInMinute = attendance.checkedInTime!.minute;
                              // Define 8:30 AM threshold for 'On-time'
                              if (checkInHour < 8 || (checkInHour == 8 && checkInMinute <= 30)) {
                                dynamicCheckInDescription = "On-time";
                                dynamicCheckInDescriptionColor = colorScheme.onTertiary;
                              } else {
                                dynamicCheckInDescription = "Late";
                                dynamicCheckInDescriptionColor = Colors.red;
                              }
                            } else {
                              dynamicCheckInDescription = "Start Working"; // Fallback
                              dynamicCheckInDescriptionColor = colorScheme.onTertiary;
                            }

                            return AttendanceDataCard(
                              title: "Check In",
                              icon: Icons.input_rounded,
                              time: timeText,
                              subDescription: subDescriptionText,
                              description: dynamicCheckInDescription,
                              subDescriptionColor: subDescriptionColor, // Pass custom color
                              descriptionColor: dynamicCheckInDescriptionColor,
                            );
                          }),
                          Obx(() {
                            final attendance =
                                attendanceController.attendanceModel.value;
                            String timeText = attendance.checkedOutTime != null
                                ? "${attendance.checkedOutTime!.hour.toString().padLeft(2, '0')}:${attendance.checkedOutTime!.minute.toString().padLeft(2, '0')} ${attendance.checkedOutTime!.hour >= 12 ? 'PM' : 'AM'}"
                                : "Not Yet";
                            dynamic subDescriptionText = attendance.isCheckOut
                                ? (attendance.isCheckOutApproved
                                ? "Approved"
                                : "Pending")
                                : null;
                            Color subDescriptionColor = attendance.isCheckOut
                                ? (attendance.isCheckOutApproved
                                ? Colors.green
                                : Colors.orange)
                                : Colors.red;

                            return AttendanceDataCard(
                              title: "Check Out",
                              icon: Icons.output_rounded,
                              time: timeText,
                              subDescription: subDescriptionText,
                              description: "Go Home",
                              subDescriptionColor: subDescriptionColor, // Pass custom color
                            );
                          }),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AttendanceDataCard(
                            title: "Total Leaves",
                            icon: Icons.calendar_today_rounded,
                            time: numberOfLeavesDays??0,
                            description: "This month",
                          ),
                          AttendanceDataCard(
                            title: "Total Days",
                            icon: Icons.calendar_month_rounded,
                            time: numberOFWorkingDays??0,
                            description: "Working Days",
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ],
              ):Center(child: Text("Leave Date"),)
              // SizedBox(height: 10,),

            ],
          ),
        )
      ],
    ) // Pass the loaded user data
        : const Text('User not found');
  }
}
