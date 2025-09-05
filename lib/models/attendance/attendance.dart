// No import from 'package:get/get.dart'; or 'package:flutter/cupertino.dart';
// This is a pure data class.

class AttendanceModel {
  bool isCheckIn;
  DateTime? checkedInTime;
  bool isCheckInApproved;
  bool isCheckOut;
  DateTime? checkedOutTime;
  bool isCheckOutApproved;

  AttendanceModel({
    this.isCheckIn = false,
    this.checkedInTime,
    this.isCheckInApproved = false,
    this.isCheckOut = false,
    this.checkedOutTime,
    this.isCheckOutApproved = false,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final checkInDateTime = json['check_in'] != null
        ? DateTime.parse(json['check_in'])
        : null;

    final checkOutDateTime = json['check_out'] != null
        ? DateTime.parse(json['check_out'])
        : null;

    return AttendanceModel(
      isCheckIn: checkInDateTime != null,
      checkedInTime: checkInDateTime,
      isCheckInApproved: json['check_in_approved_by'] != null,
      isCheckOut: checkOutDateTime != null,
      checkedOutTime: checkOutDateTime,
      isCheckOutApproved: json['check_out_approved_by'] != null,
    );
  }
  AttendanceModel copyWith({
    bool? isCheckIn,
    DateTime? checkedInTime,
    bool? isCheckInApproved,
    bool? isCheckOut,
    DateTime? checkedOutTime,
    bool? isCheckOutApproved,
  }) {
    return AttendanceModel(
      isCheckIn: isCheckIn ?? this.isCheckIn,
      checkedInTime: checkedInTime ?? this.checkedInTime,
      isCheckInApproved: isCheckInApproved ?? this.isCheckInApproved,
      isCheckOut: isCheckOut ?? this.isCheckOut,
      checkedOutTime: checkedOutTime ?? this.checkedOutTime,
      isCheckOutApproved: isCheckOutApproved ?? this.isCheckOutApproved,
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'isCheckIn': isCheckIn,
      'checkedInTime': checkedInTime,
      'isCheckInApproved': isCheckInApproved ,
      'isCheckOut': isCheckOut,
      'checkedOutTime': checkedOutTime,
      'isCheckOutApproved': isCheckOutApproved,
    };
  }


}