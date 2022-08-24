import 'dart:convert';

import '../modules/module_types/options.dart';
import '../modules/module_types/common_response.dart';
import '../modules/resful_module.dart';
// import 'package:flutter/foundation.dart';s
import 'package:get/get.dart';

class RestfulModuleImpl implements RestfulModule {
  final GetConnect getConnect = GetConnect(
    timeout: const Duration(seconds: 120),
    maxRedirects: 3,
  );

  Map<String, String> _getHeaders({
    String token,
    Map<String, String> headers,
  }) {
    var finalHeaders = Map<String, String>();

    if (headers != null) finalHeaders = headers;

    if (!(finalHeaders.containsKey('authorization'))) {
      finalHeaders['authorization'] = 'Bearer ' + token;
    }
    print(finalHeaders);
    return finalHeaders;
  }

  @override
  Future<CommonResponse<T>> delete<T>(
    String uri, {
    data,
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  }) async {
    Map<String, String> header;
    if (options == null || options.headers == null) {
      header = (_getHeaders(token: token));
    } else {
      header = (_getHeaders(headers: options.headers, token: token));
    }
    Response<T> result;
    if (query == null) {
      result = await getConnect.delete<T>(
        uri,
        headers: header, // remove header null
        // contentType: options?.contentType, remove contentType
      );
    } else {
      result = await getConnect.delete<T>(
        uri,
        query: query,
        headers: header, // remove header null
        // contentType: options?.contentType, remove contentType
      );
    }

    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(statusCode: 401, statusMessage: '401 Unauthorized');
    }
    return CommonResponse(
      body: result.body,
      headers: result.headers,
      statusCode: result.statusCode,
      statusMessage: result.statusText,
    );
  }

  @override
  Future<CommonResponse<T>> get<T>(
    String uri, {
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  }) async {
    Map<String, String> header;
    if (options == null || options.headers == null) {
      header = (_getHeaders(token: token));
    } else {
      header = (_getHeaders(headers: options.headers, token: token));
    }
    Response<T> result;
    if (query == null) {
      result = await getConnect.get<T>(
        uri,
        headers: header, //remove header null
        // contentType: options.contentType, remove contentType null
      );
    } else {
      result = await getConnect.get<T>(
        uri,
        query: query,
        headers: header, //remove header null
        // contentType: options.contentType, remove contentType null
      );
    }

    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(statusCode: 401, statusMessage: '401 Unauthorized');
    }

    return CommonResponse(
      body: result.body,
      headers: result.headers,
      statusCode: result.statusCode,
      statusMessage: result.statusText,
    );
  }

  @override
  Future<CommonResponse<T>> patch<T>(
    String uri,
    data, {
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  }) async {
    Map<String, String> header;
    if (options == null || options.headers == null) {
      header = (_getHeaders(token: token));
    } else {
      header = (_getHeaders(headers: options.headers, token: token));
    }
    Response<T> result;
    if (query == null) {
      result = await getConnect.patch<T>(
        uri,
        data,
        headers: header,
        // contentType: options.contentType,
      );
    } else {
      result = await getConnect.patch<T>(
        uri,
        data,
        query: query,
        headers: header,
        // contentType: options.contentType,
      );
    }

    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(statusCode: 401, statusMessage: '401 Unauthorized');
    }
    return CommonResponse(
      body: result.body,
      headers: result.headers,
      statusCode: result.statusCode,
      statusMessage: result.statusText,
    );
  }

  @override
  Future<CommonResponse<T>> post<T>(
    String uri,
    data, {
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  }) async {
    print("running post");
    Map<String, String> header;
    if (options == null || options.headers == null) {
      header = (_getHeaders(token: token));
    } else {
      header = (_getHeaders(headers: options.headers, token: token));
    }

    Response<T> result;
    if (query == null) {
      result = await getConnect.post<T>(
        uri,
        data,
        headers: header,
        // contentType: ,
      );
    } else {
      result = await getConnect.post<T>(
        uri,
        data,
        query: query,
        headers: header,
        // contentType: ,
      );
    }

    print(result);
    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(statusCode: 401, statusMessage: '401 Unauthorized');
    }
    return CommonResponse(
      body: result.body,
      headers: result.headers,
      statusCode: result.statusCode,
      statusMessage: result.statusText,
    );
  }

  @override
  Future<CommonResponse<T>> put<T>(
    String uri, {
    data,
    String token,
    Map<String, dynamic> query,
    CommonRequestOptions options,
  }) async {
    Map<String, String> header = {};
    if (options == null || options.headers == null) {
      header = (_getHeaders(token: token));
    } else {
      header = (_getHeaders(headers: options.headers, token: token));
    }
    Response<T> result;
    if (query == null) {
      result = await getConnect.put<T>(
        uri,
        data,
        headers: header,
        // contentType: options.contentType,
      );
    } else {
      result = await getConnect.put<T>(
        uri,
        data,
        query: query,
        headers: header,
        // contentType: options.contentType,
      );
    }

    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(statusCode: 401, statusMessage: '401 Unauthorized');
    }

    return CommonResponse(
      body: result.body,
      headers: result.headers,
      statusCode: result.statusCode,
      statusMessage: result.statusText,
    );
  }
}
