import 'dart:convert';

import 'package:av_master_mobile/constants/base_url.dart';
import 'package:av_master_mobile/controllers/auth_controller.dart';
import 'package:av_master_mobile/dio/api_client.dart';
import 'package:av_master_mobile/models/attendance/attendance.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:av_master_mobile/user/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final Rx<AttendanceModel> attendanceModel = AttendanceModel().obs;
  final storage = FlutterSecureStorage();
  final apiClient = ApiClient();

  final RxString selectedSupervisorError = ''.obs;
  final Rx workingPlaceError = ''.obs;

  Future loadTodayAttendance({required String epf_number}) async {
    try {
      print('called');
      final response = await apiClient.dio.get(
        '$BASE_URL/get-my-today-attendance',
        queryParameters: {'epf_number': epf_number},
      );
      if (response.statusCode == 200) {
        // print(response);
        final Map<String, dynamic> responseBody =
            response.data as Map<String, dynamic>;
        final Map<String, dynamic> attendanceJson =
            responseBody['data']['today_attendance'];
        final AttendanceModel todayAttendanceModel = AttendanceModel.fromJson(
          attendanceJson,
        );
        attendanceModel.value = todayAttendanceModel;
        return todayAttendanceModel;
      }
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: $responseBody");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          print('Incorrect EPF Number');
          return null;
        } else if (e.response?.statusCode == 401) {
          // This is an unauthorized error.
          print(responseBody['message'] ?? 'Unauthorized');
          return null;
        } else if (e.response?.statusCode == 500) {
          // This is a server error, use the message from the response.
          print(responseBody['message'] ?? 'Internal Server Error');
          return null;
        }
        // Return the general message from the error response.
        print(responseBody['message'] ?? 'An error occurred');
        return null;
      } else {
        // Handle cases where the response data is null (e.g., server crash, no network)
        print("DioException occurred with null response data: ${e.message}");
        print('Check your internet connection or try again later.');
        return null;
      }
    }
  }

  Future getSupervisors({required String company}) async {
    print("api called");
    try {
      final response = await apiClient.dio.get(
        '$BASE_URL/get-supervisors',
        queryParameters: {'company': company},
      );
      // print(response.data);
      final Map<String, dynamic> responseBody =
          response.data as Map<String, dynamic>;
      // print(responseBody);

      // Access the supervisors list and other data
      final supervisors = responseBody['data']['supervisors'];
      // print(supervisors);
      return supervisors;
    } on DioException catch (e) {
      // print(e);
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: ${responseBody}");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          print('Incorrect EPF Number');
          return null;
        } else if (e.response?.statusCode == 401) {
          // This is an unauthorized error.
          print(responseBody['message'] ?? 'Unauthorized');
          return null;
        } else if (e.response?.statusCode == 500) {
          // This is a server error, use the message from the response.
          print(responseBody['message'] ?? 'Internal Server Error');
          return null;
        }
        // Return the general message from the error response.
        print(responseBody['message'] ?? 'An error occurred');
        return null;
      } else {
        // Handle cases where the response data is null (e.g., server crash, no network)
        print("DioException occurred with null response data: ${e.message}");
        print('Check your internet connection or try again later.');
        return null;
      }
    }
  }

  Future getSupervisorForExe({required String epfNumber}) async {
    try {
      final response = await apiClient.dio.get(
        '$BASE_URL/get-supervisor',
        queryParameters: {'epf_number': epfNumber},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody =
            response.data as Map<String, dynamic>;
        // print(responseBody);
        return responseBody['data']['supervisor'];
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: ${responseBody}");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          print('Incorrect EPF Number');
          return null;
        } else if (e.response?.statusCode == 401) {
          // This is an unauthorized error.
          print(responseBody['message'] ?? 'Unauthorized');
          return null;
        } else if (e.response?.statusCode == 500) {
          // This is a server error, use the message from the response.
          print(responseBody['message'] ?? 'Internal Server Error');
          return null;
        }
        // Return the general message from the error response.
        print(responseBody['message'] ?? 'An error occurred');
        return null;
      } else {
        // Handle cases where the response data is null (e.g., server crash, no network)
        print("DioException occurred with null response data: ${e.message}");
        print('Check your internet connection or try again later.');
        return null;
      }
    }
  }

  //check in function
  Future checkIn({List<dynamic>? supervisorIds}) async {
    try {
      AuthController authController = Get.put(AuthController());
      final UserModel? user =
          await authController.getUserFromStorage() as UserModel;
      final userProvider = Get.find<UserProvider>();
      selectedSupervisorError.value = "";
      if ((supervisorIds == null || supervisorIds.isEmpty) &&
          (userProvider.user!.userType == 'technician')) {
        selectedSupervisorError.value = "Select at least one supervisor";
        // Get.snackbar("Cannot Check In", selectedSupervisorError.value); // Show the snackbar here
      } else {
        final checkInTime = DateTime.now();

        if (user != null) {
          var data = {
            'epf_number': user.epfNumber,
            'check_in_time': checkInTime.toIso8601String(),
            'request_from': supervisorIds ?? [],
          };
          // print(data.toString());

          final response = await apiClient.dio.post(
            '$BASE_URL/check-in',
            data: data,
          );
          // print(response);
          if (response.statusCode == 200) {
            await loadTodayAttendance(epf_number: user.epfNumber);
            return true;
          }
          return false;
          // If the list is valid, proceed with the check-in logic
          // attendanceModel.update((val) {
          //   val?.isCheckIn = true;
          //   val?.checkedInTime = DateTime.now();
          // });

          // Future.delayed(const Duration(seconds: 5), () {
          //   attendanceModel.update((val) {
          //     val?.isCheckInApproved = true;
          //   });
          // });
        }
      }
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: ${responseBody}");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          print('Incorrect EPF Number');
          return null;
        } else if (e.response?.statusCode == 401) {
          // This is an unauthorized error.
          print(responseBody['message'] ?? 'Unauthorized');
          return null;
        } else if (e.response?.statusCode == 500) {
          // This is a server error, use the message from the response.
          print(responseBody['message'] ?? 'Internal Server Error');
          return null;
        }
        // Return the general message from the error response.
        print(responseBody['message'] ?? 'An error occurred');
        return null;
      } else {
        // Handle cases where the response data is null (e.g., server crash, no network)
        print("DioException occurred with null response data: ${e.message}");
        print('Check your internet connection or try again later.');
        return null;
      }
    }
  }

  Future checkOut({required String workingPlace, int? siteNo}) async {
    // print(workingPlace);
    // print(siteNo);
    workingPlaceError.value = '';

    if (workingPlace == "Select") {
      workingPlaceError.value = "Please Enter the place you Worked";
      // Get.snackbar("Cannot Check Out", workingPlaceError.value);
    } else {
      if (workingPlace == "Site") {
        if (siteNo == 0) {
          workingPlaceError.value = "Enter Correct Site";
          return false;
          // Get.snackbar("Cannot Check Out", workingPlaceError.value);
        } else {
          //where should api called
          final checkOutTime = DateTime.now();
          AuthController authController = Get.put(AuthController());
          final UserModel? user =
              await authController.getUserFromStorage() as UserModel;
          if (user != null) {
            var data = {
              'epf_number': user.epfNumber,
              'check_out_time': checkOutTime.toIso8601String(),
              'working_place': workingPlace,
              'site_number': siteNo ?? 0,
            };
            final response = await apiClient.dio.post(
              '$BASE_URL/check-out',
              data: data,
            );
            if (response.statusCode == 200) {
              await loadTodayAttendance(epf_number: user.epfNumber);
            }
          }
          // attendanceModel.update((val) {
          //   val?.isCheckOut = true;
          //   val?.checkedOutTime = DateTime.now();
          // });
          //
          // Future.delayed(const Duration(seconds: 3), () {
          //   attendanceModel.update((val) {
          //     val?.isCheckOutApproved = true;
          //   });
          // });
        }
      }
      if (workingPlace != "Site") {
        final checkOutTime = DateTime.now();
        AuthController authController = Get.put(AuthController());
        final UserModel? user =
            await authController.getUserFromStorage() as UserModel;
        if (user != null) {
          var data = {
            'epf_number': user.epfNumber,
            'check_out_time': checkOutTime.toIso8601String(),
            'working_place': workingPlace,
          };
          final response = await apiClient.dio.post(
            '$BASE_URL/check-out',
            data: data,
          );
          if (response.statusCode == 200) {
            await loadTodayAttendance(epf_number: user.epfNumber);
          }
        }
        // attendanceModel.update((val) {
        //   val?.isCheckOut = true;
        //   val?.checkedOutTime = DateTime.now();
        // });

        // Future.delayed(const Duration(seconds: 3), () {
        //   attendanceModel.update((val) {
        //     val?.isCheckOutApproved = true;
        //   });
        // });
      }
    }
  }

  Future checkCanMarkAttendance({required String epfNumber}) async {
    try {
      var data = {'epf_number': epfNumber};
      final response = await apiClient.dio.get(
        '$BASE_URL/check_is_today_leave',
        queryParameters: {'epf_number': epfNumber},
      );
      if (response.statusCode == 200) {
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: ${responseBody}");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          return 'Incorrect EPF Number';
        } else if (e.response?.statusCode == 401) {
          // This is an unauthorized error.
          return responseBody['message'] ?? 'Unauthorized';
        } else if (e.response?.statusCode == 500) {
          // This is a server error, use the message from the response.
          return responseBody['message'] ?? 'Internal Server Error';
        }
        // Return the general message from the error response.
        return responseBody['message'] ?? 'An error occurred';
      } else {
        // Handle cases where the response data is null (e.g., server crash, no network)
        print("DioException occurred with null response data: ${e.message}");
        return 'Check your internet connection or try again later.';
      }
    }
  }

  // Future<AttendanceModel?> getTodayAttendanceFromStorage() async {
  //   final today = DateTime.now();
  //   final attendanceJson = await storage.read(
  //     key: 'attendance_${today.year}-${today.month}-${today.day}',
  //   );
  //   if (attendanceJson != null) {
  //     final Map<String, dynamic> attendanceMap = jsonDecode(attendanceJson);
  //     return AttendanceModel.fromJson(attendanceMap);
  //   }
  //   return null;
  // }

  Future getWorkingDays({required String epfNumber}) async {
    try {
      final response = await apiClient.dio.get(
        '$BASE_URL/get-working-days',
        queryParameters: {'epf_number': epfNumber},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody =
            response.data as Map<String, dynamic>;

        final numberOfWorkingDays =
            responseBody['data']['number_of_working_days'];
        return numberOfWorkingDays;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: ${responseBody}");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          return 'Incorrect EPF Number';
        } else if (e.response?.statusCode == 401) {
          // This is an unauthorized error.
          return responseBody['message'] ?? 'Unauthorized';
        } else if (e.response?.statusCode == 500) {
          // This is a server error, use the message from the response.
          return responseBody['message'] ?? 'Internal Server Error';
        }
        // Return the general message from the error response.
        return responseBody['message'] ?? 'An error occurred';
      } else {
        // Handle cases where the response data is null (e.g., server crash, no network)
        print("DioException occurred with null response data: ${e.message}");
        return 'Check your internet connection or try again later.';
      }
    }
  }

  Future loadTodayAttendanceList({
    required String company,
    required String epfNumber,
  }) async {
    print('called');
    try {
      final response = await apiClient.dio.get(
        '$BASE_URL/get-today-attendance-approval-list',
        queryParameters: {'company': company, 'epf_number': epfNumber},
      );
      // print(response);
      if(response.statusCode==200){
        final Map<String, dynamic> responseBody =
        response.data as Map<String, dynamic>;
        return responseBody['data'];
      }
    } on DioException catch (e) {

    }
  }
}
