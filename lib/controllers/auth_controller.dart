import 'dart:convert';

import 'package:av_master_mobile/constants/base_url.dart';
import 'package:av_master_mobile/dio/api_client.dart';
import 'package:av_master_mobile/screens/login.dart';
import 'package:av_master_mobile/screens/portal_page.dart';
import 'package:av_master_mobile/user/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../models/user.dart';

class AuthController extends GetxController {
  static const baseURL = BASE_URL;
  final apiClient = ApiClient();
  final RxBool isLoading = false.obs;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onReady() {
    super.onReady();
    // This is the ideal place to check the auth state
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    // Attempt to retrieve the user from secure storage
    final user = await getUserFromStorage();
    final userProvider = Get.find<UserProvider>();
    if (user != null) {
      userProvider.setUser(user);
      print(userProvider.user!.epfNumber);
      // User is logged in, navigate to the home page and remove all other routes
      Get.offAll(() => PortalPage());
    } else {
      // No user found, navigate to the login page
      Get.offAll(() => Login());
    }
  }

  Future login({required String epfNumber, required String password}) async {
    try {
      // print("print1");
      isLoading.value = true;
      var data = {'password': password, 'email': epfNumber};
      if (epfNumber == null || password == null) {
        // print("print2");
        isLoading.value = false;
        return false;
      } else {
        // print("print3");

        final response = await apiClient.dio.post(
          '$BASE_URL/login',
          data: data,
        );
        final Map<String, dynamic> responseBody = response.data;
        // print("print4");
        // print(responseBody);
        isLoading.value = false;
        if (response.statusCode == 200) {
          // print(responseBody['data']['refresh_token']);
          await storage.write(
            key: 'accessToken',
            value: responseBody['data']['access_token'],
          );
          await storage.write(
            key: 'refreshToken',
            value: responseBody['data']['refresh_token'],
          );
          final UserModel user = UserModel.fromJson(
            responseBody['data']['user'],
          );
          final userJson = json.encode(user.toJson());
          await storage.write(key: 'user', value: userJson);

          final userProvider = Get.find<UserProvider>();
          userProvider.setUser(user);
          return true;
        }
      }
    } on DioException catch (e) {
      isLoading.value = false;
      // Check if a response and data exist.
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: ${responseBody}");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          return 'Incorrect credentials';
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

  Future logout() async {
    try {
      final response = await apiClient.dio.post(
        '$BASE_URL/logout',
        // queryParameters: {'epf_number': epfNumber},
      );
      if(response.statusCode==200){
        storage.delete(key: 'user');
        final userProvider = Get.find<UserProvider>();
        userProvider.clearUser();
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseBody = e.response!.data;
        print("DioException occurred with response: ${responseBody}");

        // Handle specific status codes
        if (e.response?.statusCode == 422) {
          // This is a validation error.
          return 'Incorrect credentials';
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

  Future<UserModel?> getUserFromStorage() async {
    final userJson = await storage.read(key: 'user');
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    }
    return null;
  }
}
