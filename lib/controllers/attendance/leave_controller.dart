import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:get/get.dart';

// import '../../models/leave.dart';

class LeaveController extends GetxController{


  // Sample data with a mix of past and future dates
  final allLeaves = <LeaveModel>[
    LeaveModel(
      fromDate: DateTime(2025, 8, 10), // Upcoming
      toDate: DateTime(2025, 8, 12),
      leaveType: 'Annual Leave',
      considerBy: 'Supun Wijesiri',
      status: 'pending',
        requestedFrom: 'Supun Wijesiri'
    ),
    LeaveModel(
      fromDate: DateTime(2025, 7, 25), // Past
      toDate: DateTime(2025, 7, 27),
      leaveType: 'Sick Leave',
      considerBy: 'Ishan Rathnayeka',
      status: 'approved',
        requestedFrom: 'Supun Wijesiri'
    ),
    LeaveModel(
      fromDate: DateTime(2025, 9, 1), // Upcoming
      toDate: DateTime(2025, 9, 5),
      leaveType: 'Casual Leave',
      considerBy: 'Nuwan Prasanna',
      status: 'approved',
        requestedFrom: 'Supun Wijesiri'
    ),
    LeaveModel(
      fromDate: DateTime(2025, 6, 15), // Past
      toDate: DateTime(2025, 6, 15),
      leaveType: 'Annual Leave',
      considerBy: 'Lakmal Jaliya',
      status: 'rejected',
        requestedFrom: 'Supun Wijesiri'
    ),
    LeaveModel(
      fromDate: DateTime(2025, 9, 1), // Past
      toDate: DateTime(2025, 9, 2),
      leaveType: 'Annual Leave',
      considerBy: 'Lakmal Jaliya',
      status: 'pending',
        requestedFrom: 'Supun Wijesiri'
    ),
  ].obs;

  List<LeaveModel> fetchLeaves ({
    required String state,
}){
    if(state == 'Upcoming'){
      return allLeaves.where((leave) =>
          leave.fromDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
    }else{
      return allLeaves.where((leave) =>
      leave.fromDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))).toList();
    }
  }

  List<LeaveModel> fetchLeaveRequests(){
    return [LeaveModel(fromDate: DateTime(2025,09,02), toDate: DateTime(2025,09,02), leaveType: "Medical Leave",name: "Kasun Prabath"),LeaveModel(fromDate: DateTime(2025,08,21), toDate: DateTime(2025,08,23), leaveType: "Annual Leave",name: "ishan Karunanayeka")];
  }
}