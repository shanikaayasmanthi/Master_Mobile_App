import 'package:flutter/cupertino.dart';

class AttendanceRequest {
  final int id;
  final String name;
  late  String time;
  TextEditingController? controller;
  String? selectedTimePeriod;
  late String? workingPlace;
  late String? siteNo;

  AttendanceRequest({
    required this.id,
    required this.name,
    required this.time,
    this.controller,
    this.selectedTimePeriod,
    this.workingPlace,
    this.siteNo,
  });

  factory AttendanceRequest.fromJsonForCheckIn(Map<String, dynamic> json) {
    return AttendanceRequest(
      id: json['attendance_id'],
      name: json['name'] as String,
      time: json['time'] as String,
      controller: TextEditingController(text: json['time']),
      selectedTimePeriod: null,
    );
  }
  factory AttendanceRequest.fromJsonForCheckOut(Map<String, dynamic> json) {
    return AttendanceRequest(
      id: json['attendance_id'],
      name: json['name'] as String,
      time: json['time'] as String,
      controller: TextEditingController(text: json['time']),
      selectedTimePeriod: null,
      workingPlace: json['working_place'],
      siteNo: json['site_no']??''
    );
  }

  Map<String, dynamic> toJsonCheckIn() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'morning_allowance': selectedTimePeriod??null,
    };
  }

  Map<String, dynamic> toJsonCheckOut() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'evening_allowance': selectedTimePeriod??null,
      'working_place':workingPlace,
      'site_no':siteNo??''
    };
  }
}