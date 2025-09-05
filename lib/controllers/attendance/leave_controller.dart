import 'package:av_master_mobile/constants/base_url.dart';
import 'package:av_master_mobile/dio/api_client.dart';
import 'package:av_master_mobile/models/attendance/leave.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

// import '../../models/leave.dart';

class LeaveController extends GetxController {

  final apiClient = ApiClient();
  // Sample data with a mix of past and future dates
  final allLeaves = <LeaveModel>[
    // LeaveModel(
    //   fromDate: DateTime(2025, 8, 10), // Upcoming
    //   toDate: DateTime(2025, 8, 12),
    //   leaveType: 'Annual Leaves',
    //   considerBy: 'Supun Wijesiri',
    //   status: 'approved',
    //   requestedFrom: 'Supun Wijesiri',
    // ),
    // LeaveModel(
    //   fromDate: DateTime(2025, 7, 25), // Past
    //   toDate: DateTime(2025, 7, 27),
    //   leaveType: 'Sick Leaves',
    //   considerBy: 'Ishan Rathnayeka',
    //   status: 'approved',
    //   requestedFrom: 'Supun Wijesiri',
    // ),
    // LeaveModel(
    //   fromDate: DateTime(2025, 9, 1), // Upcoming
    //   toDate: DateTime(2025, 9, 5),
    //   leaveType: 'Casual Leaves',
    //   considerBy: 'Nuwan Prasanna',
    //   status: 'approved',
    //   requestedFrom: 'Supun Wijesiri',
    // ),
    // LeaveModel(
    //   fromDate: DateTime(2025, 6, 15), // Past
    //   toDate: DateTime(2025, 6, 15),
    //   leaveType: 'Annual Leaves',
    //   considerBy: 'Lakmal Jaliya',
    //   status: 'rejected',
    //   requestedFrom: 'Supun Wijesiri',
    // ),
    // LeaveModel(
    //   fromDate: DateTime(2025, 9, 1), // Past
    //   toDate: DateTime(2025, 9, 2),
    //   leaveType: 'Annual Leaves',
    //   // considerBy: '',
    //   status: 'pending',
    //   requestedFrom: 'Rajitha mihiranga',
    // ),
  ].obs;

  Future<List<LeaveModel>> fetchLeaves({required String state,required String epfNumber}) async{
    try{
      final response = await apiClient.dio.get('$BASE_URL/my-leaves',queryParameters: {
        'epf_number':epfNumber,
        'state':state
      });

      if(response.statusCode==200){
        final Map<String,dynamic> responseBody = response.data as Map<String,dynamic>;
        final List<dynamic> leavesData = responseBody['data']['leaves'];

        // Map each item in the list to a LeaveModel
        final List<LeaveModel> leaves = leavesData.map((leaveJson) => LeaveModel.fromJson(leaveJson)).toList();

        return leaves;
      }
      return [];
    }on DioException catch(e){
      // Handle the error here
      print('Dio Error: ${e.response?.statusCode} - ${e.message}');
      return [];
    }
    // return null;
    // return allLeaves;
    // if (state == 'Upcoming') {
    //   final response = apiClient.dio.get('$BASE_URL/my-leaves',queryParameters: {
    //     'epf_number':epfNumber,
    //     'state':state
    //   });
    //   print(response);
    //   return allLeaves
    //       .where(
    //         (leave) => leave.fromDate.isAfter(
    //           DateTime.now().subtract(const Duration(days: 1)),
    //         ),
    //       )
    //       .toList();
    // } else {
    //   final response = apiClient.dio.get('$BASE_URL/my-leaves',queryParameters: {
    //     'epf_number':epfNumber,
    //     'state':state
    //   });
    //   print(response);
    //   return allLeaves
    //       .where(
    //         (leave) => leave.fromDate.isBefore(
    //           DateTime.now().subtract(const Duration(days: 1)),
    //         ),
    //       )
    //       .toList();
    // }
  }



  Future <List<LeaveModel>> fetchLeaveRequests({ required String epfNumber}) async{

    // print(epfNumber);
    try{
      final response = await apiClient.dio.get('$BASE_URL/get-leave-requests',queryParameters: {
        'epf_number':epfNumber
      });

      if(response.statusCode==200){
        final Map<String,dynamic> responseBody = response.data as Map<String,dynamic>;
        // print(responseBody);
        // print(responseBody['data']['leave_requests']);
        final List<dynamic>fetchedLeaveRequests =  responseBody['data']['leave_requests'];
        final List<LeaveModel> leaveRequests = fetchedLeaveRequests.map((json) {
          return LeaveModel.fromJson(json);
        }).toList();
        print(fetchedLeaveRequests);
        return  leaveRequests;
      }

      return [];
      // return [
      //   LeaveModel(
      //     fromDate: DateTime(2025, 09, 02),
      //     toDate: DateTime(2025, 09, 02),
      //     leaveType: "Medical Leave",
      //     name: "Kasun Prabath",
      //   ),
      //   LeaveModel(
      //     fromDate: DateTime(2025, 08, 21),
      //     toDate: DateTime(2025, 08, 23),
      //     leaveType: "Annual Leave",
      //     name: "ishan Karunanayeka",
      //   ),
      // ];
    }on DioException catch(e){
      print("Error occured");
      return [];
    }
  }

  Future loadNumberOfLeaves({required String epfNumber})async{
    try{
      final response = await apiClient.dio.get('$BASE_URL/get-number-of-leaves',queryParameters: {'epf_number':epfNumber});
      // print(response);
      if(response.statusCode==200){
      final Map<String, dynamic> responseBody =
      response.data as Map<String, dynamic>;

      final numberOfLeaveDays = responseBody['data']['number_of_leaves'];
      return numberOfLeaveDays;
      }
      return null;
    }on DioException catch (e){
      print("Error occured");
      print(e?.response);
      return null;
    }
  }

  Future loadLeaveTypes()async{
    try{
      final response = await apiClient.dio.get('$BASE_URL/get-leave-types');
      print(response.toString());
      final Map<String,dynamic> responseBody = response.data as Map<String, dynamic>;
      final leaveTypes = responseBody['data']['leave_types'];
      print(leaveTypes.toString());
      return leaveTypes;
    }on DioException catch (e){
      print("Error occured");
      return null;
    }
  }

  Future applyLeave({
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    required String requestFrom,
    String? reason
})async{

    try{
      var data= {
        'from_date':fromDate,
        "to_date":toDate,
        "leave_type":leaveType,
        "request_from":requestFrom,
        "reason":reason
      };
      final response = await apiClient.dio.post('$BASE_URL/apply-leave');
      print(response);
    }on DioException catch(e){
      print("Error occured");
      return null;
    }
  }

  Future loadLeaveSummery({required String epfNumber})async{
    try{
      final response = await apiClient.dio.get('$BASE_URL/leave-summery',queryParameters: {'epf_number':epfNumber});
      if(response.statusCode==200){
        final Map<String,dynamic> responseBody = response.data as Map<String, dynamic>;
        final leaveSummery = responseBody['data'];
        print(leaveSummery);
        return leaveSummery;
      }
      return null;
    }on DioException catch(e){
      print("Error occured with leave summery");
      return null;
    }
  }

  Future considerLeaveRequest({
    required String epfNumber,
    required String leaveId,
    required String action
})async{
    try{
      var data = {
        'consider_by':epfNumber,
        'leave_id':leaveId,
        'action':action,
      };
      print(data);
      final response = await apiClient.dio.post('$BASE_URL/consider-leave-request',data:data );
      // print(response);
      if(response.statusCode==200){
        return true;
      }
      return false;
    }on DioException catch (e){
      print("Error occured with considering leave");
      return false;
    }
  }

  Future loadTodayLeaveList({required String company})async{
    try{
      print(company);
      final response = await apiClient.dio.get('$BASE_URL/today-leave-list',queryParameters: {'company':company});
      // print(response);
      if(response.statusCode==200){
        final Map<String,dynamic> responseBody = response.data as Map<String, dynamic>;
        final leaveList = responseBody['data']['leave_list'];
        // print(leaveList);
        return leaveList;
      }
      return [];
    }on DioException catch(e){
      print("Error occured with loading leave list");
      return [];
    }
  }

  Future loadTodayAbsentees({required String company})async{
    try{
      final response = await apiClient.dio.get('$BASE_URL/get-today-absentees',queryParameters: {'company':company});
      if(response.statusCode==200){
        final Map<String,dynamic> responseBody = response.data as Map<String, dynamic>;
        final absentList = responseBody['data']['absent_list'];
        // print(absentList);
        return absentList;
      }
      return [];
    }on DioException catch(e){
      print("Error occured with loading leave list");
      return [];
    }
  }
}
