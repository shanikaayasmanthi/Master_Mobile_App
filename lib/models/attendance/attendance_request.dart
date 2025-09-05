import 'package:flutter/cupertino.dart';

class AttendanceRequest {
  final int id;
  final String name;
  late  String time;
  TextEditingController? controller;
  String? selectedTimePeriod;

  AttendanceRequest({
    required this.id,
    required this.name,
    required this.time,
    this.controller,
    this.selectedTimePeriod,
  });

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceRequest(
      id: json['attendance_id'],
      name: json['name'] as String,
      time: json['time'] as String,
      controller: TextEditingController(text: json['time']),
    );
  }
}