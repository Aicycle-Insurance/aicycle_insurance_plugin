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

  Future<Map<String, String>> _getHeaders({
    required String token,
    Map<String, String>? headers,
  }) async {
    var finalHeaders = <String, String>{};

    if (headers != null) finalHeaders = headers;

    if (!(finalHeaders.containsKey('authorization'))) {
      finalHeaders['authorization'] = 'Bearer ' + token;
    }
    return finalHeaders;
  }

  @override
  Future<CommonResponse<T>> delete<T>(
    String uri, {
    data,
    required String token,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    var result = await getConnect.delete<T>(
      uri,
      query: query,
      headers: (await _getHeaders(headers: options?.headers, token: token)),
      contentType: options?.contentType,
    );
    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(
          statusCode: 401, statusMessage: 'Your AiCycle token has expired!');
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
    required String token,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    var result = await getConnect.get<T>(
      uri,
      query: query,
      headers: (await _getHeaders(headers: options?.headers, token: token)),
      contentType: options?.contentType,
    );
    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(
          statusCode: 401, statusMessage: 'Your AiCycle token has expired!');
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
    required String token,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    var result = await getConnect.patch<T>(
      uri,
      data,
      query: query,
      headers: (await _getHeaders(headers: options?.headers, token: token)),
      contentType: options?.contentType,
    );
    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(
          statusCode: 401, statusMessage: 'Your AiCycle token has expired!');
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
    required String token,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    var result = await getConnect.post<T>(
      uri,
      data,
      query: query,
      headers: (await _getHeaders(headers: options?.headers, token: token)),
      contentType: options?.contentType,
    );
    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(
          statusCode: 401, statusMessage: 'Your AiCycle token has expired!');
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
    required String token,
    Map<String, dynamic>? query,
    CommonRequestOptions? options,
  }) async {
    var result = await getConnect.put<T>(
      uri,
      data,
      query: query,
      headers: (await _getHeaders(headers: options?.headers, token: token)),
      contentType: options?.contentType,
    );
    if (result.statusCode == 500) {
      String message = 'Internal Server Error';
      if (result.body is Map) {
        message = json.encode(result.body);
      }
      return CommonResponse(statusCode: 500, statusMessage: message);
    }
    if (result.statusCode == 401) {
      return CommonResponse(
          statusCode: 401, statusMessage: 'Your AiCycle token has expired!');
    }

    return CommonResponse(
      body: result.body,
      headers: result.headers,
      statusCode: result.statusCode,
      statusMessage: result.statusText,
    );
  }
}
