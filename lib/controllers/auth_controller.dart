import 'dart:convert';

import 'package:av_master_mobile/constants/base_url.dart';
import 'package:av_master_mobile/dio/api_client.dart';
import 'package:av_master_mobile/screens/portal_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static const baseURL = BASE_URL;
  final apiClient = ApiClient();
  final RxBool isLoading = false.obs;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future login({required String epfNumber, required String password}) async {
    try {
      print("print1");
      isLoading.value = true;
      var data = {'password': password,'email':epfNumber};
      if (epfNumber == null || password == null) {
        print("print2");
        isLoading.value = false;
        return false;
      } else {
        print("print3");

        final response = await apiClient.dio.post('$BASE_URL/login',data: data);
        final Map<String, dynamic> responseBody = response.data;
        print("print4");
        print(responseBody);
        isLoading.value = false;
        if(response.statusCode == 200){
          // await storage.write(key: 'accessToken', value: responseBody.data['ac']);
          // await storage.write(key: 'refreshToken', value: value)
          return true;
        }
      }
    } on DioException catch (e) {
      isLoading.value = false;
      // Check if a response and data exist.
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
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
    }}
  }
}
