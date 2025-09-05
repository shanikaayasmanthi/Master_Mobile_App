import 'package:av_master_mobile/constants/base_url.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio = Dio();
  final String baseURL = BASE_URL;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient(){

    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await storage.read(key: 'accessToken');

        if(accessToken !=null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
          // options.headers['Accept'] = 'application/json';
          // options.headers['Content-Type'] = 'application/json';
        }

        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if(error.response?.statusCode == 401){
          try{
            final newAccessToken = await refreshToken();
            if (newAccessToken != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              return handler.resolve(await dio.fetch(error.requestOptions));
            }

          } on DioException catch(e){
            await storage.delete(key: 'accessToken');
            await storage.delete(key: 'refreshToken');
            return handler.next(e);
          }
        }
        return handler.next(error);
      }
    ),);

  }

  Future<String?> refreshToken()async{
    final refreshToken = await storage.read(key: 'refreshToken');

    if(refreshToken !=null){
      throw DioException(requestOptions: RequestOptions(path: ''));
    }

    try{
      final response = await Dio().post('$baseURL/auth/refresh-token',
        data: {'refresh_token':refreshToken},);
      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await storage.write(key: 'accessToken', value: newAccessToken);
        await storage.write(key: 'refreshToken', value: newRefreshToken);

        return newAccessToken;
      }
    } catch (e) {
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
    }
    return null;
  }
}