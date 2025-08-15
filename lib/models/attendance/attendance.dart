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

  // Optional: A 'copyWith' method is useful for creating new instances
  // with updated values, especially when working with Rx<T>
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
}