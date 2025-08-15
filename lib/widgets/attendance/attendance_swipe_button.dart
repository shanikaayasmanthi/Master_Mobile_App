import 'package:av_master_mobile/controllers/attendance/attendance_controller.dart';
import 'package:av_master_mobile/models/attendance/attendance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';


class AttendanceSwipeButton extends StatefulWidget {
  const AttendanceSwipeButton({
    super.key,
    required this.attendanceController,
    this.onActionComplete,
    this.selectedSupervisorIds,
    required this.workingPlace,
    required this.siteNo,
  });


  final AttendanceController attendanceController;
  final AttendanceActionCallback? onActionComplete;
  final List<int>? selectedSupervisorIds;
  final String workingPlace;
  final int siteNo;
  @override
  State<AttendanceSwipeButton> createState() => _AttendanceSwipeButtonState();
}
typedef AttendanceActionCallback =
void Function(AttendanceModel updatedAttendance);

class _AttendanceSwipeButtonState extends State<AttendanceSwipeButton> {
  bool _canSwipe() {
    final bool isCheckedIn =
        widget.attendanceController.attendanceModel.value.isCheckIn;
    final bool isCheckInApproved =
        widget.attendanceController.attendanceModel.value.isCheckInApproved;
    final bool isCheckedOut =
        widget.attendanceController.attendanceModel.value.isCheckOut;

    if (!isCheckedIn && !isCheckedOut) {
      return true;
    } else if (isCheckedIn && isCheckInApproved && !isCheckedOut) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final bool isCheckedIn =
            widget.attendanceController.attendanceModel.value.isCheckIn;
        final bool isCheckInApproved =
            widget.attendanceController.attendanceModel.value.isCheckInApproved;
        final bool isCheckedOut =
            widget.attendanceController.attendanceModel.value.isCheckOut;
        final bool swipable = _canSwipe();

        String buttonText;
        Color thumbIconColor;
        Color activeThumbBgColor;
        Color activeTrackBgColor;
        Color textColor;

        if (swipable) {
          if (!isCheckedIn) {
            buttonText = 'Swipe to Check In';
            thumbIconColor = colorScheme.primary;
            activeThumbBgColor = colorScheme.onPrimary;
            activeTrackBgColor = colorScheme.primary;
            textColor = colorScheme.onPrimary;
          } else {
            buttonText = 'Swipe to Check Out';
            thumbIconColor = Colors.blueAccent;
            activeThumbBgColor = colorScheme.onPrimary;
            activeTrackBgColor = Colors.blueAccent;
            textColor = colorScheme.onPrimary;
          }
        } else {
          if (isCheckedIn && !isCheckInApproved) {
            buttonText = 'Pending Approval';
          } else if (isCheckedOut) {
            buttonText = 'Checked Out';
          } else {
            buttonText = 'Not Available';
          }
          thumbIconColor = Colors.grey.shade400;
          activeThumbBgColor = Colors.grey;
          activeTrackBgColor = Colors.grey.shade300;
          textColor = Colors.grey.shade600;
        }

        return SwipeButton.expand(
          thumb: Icon(Icons.double_arrow_rounded, color: thumbIconColor),
          thumbPadding: const EdgeInsets.all(6),
          height: 58,
          borderRadius: BorderRadius.circular(10),
          activeThumbColor: activeThumbBgColor,
          activeTrackColor: activeTrackBgColor,
          onSwipeEnd: swipable
              ? () {
                  if (!isCheckedIn) {
                    widget.attendanceController.checkIn(supervisorIds: widget.selectedSupervisorIds);
                    if(widget.attendanceController.selectedSupervisorError.value!=''){
                      Get.snackbar("Cannot Check In", "Select al least one supervisor");
                    }
                  } else if (isCheckedIn &&
                      isCheckInApproved &&
                      !isCheckedOut) {

                    print(widget.workingPlace);
                    print(widget.siteNo);
                    widget.attendanceController.checkOut(
                      workingPlace: widget.workingPlace,
                      siteNo: widget.siteNo
                    );
                    if(widget.attendanceController.workingPlaceError.value!=''){
                      Get.snackbar("Cannot Check Out", widget.attendanceController.workingPlaceError.value);
                    }
                  }
                }
              : null,
          child: Text(
            buttonText,
            style: TextStyle(color: textColor, fontSize: 20),
          ),
        );
      }),
    );
  }
}
