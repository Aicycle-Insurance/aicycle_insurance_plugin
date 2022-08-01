import 'module_types/common_response.dart';
import 'module_types/options.dart';

abstract class RestfulModule {
  Future<CommonResponse<T>> get<T>(
    String uri, {
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  });

  Future<CommonResponse<T>> post<T>(
    String uri,
    data, {
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  });

  Future<CommonResponse<T>> put<T>(
    String uri, {
    data,
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  });

  Future<CommonResponse<T>> delete<T>(
    String uri, {
    data,
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  });
  Future<CommonResponse<T>> patch<T>(
    String uri,
    data, {
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  });
}
