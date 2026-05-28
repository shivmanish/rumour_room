import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../error/exceptions.dart';
import '../codecs.dart';
import '../network_config.dart';
import 'rest_client.dart';

class DioRestClient implements RestClient {
  DioRestClient({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? '',
                connectTimeout: NetworkConfig.connectTimeout,
                receiveTimeout: NetworkConfig.receiveTimeout,
                sendTimeout: NetworkConfig.sendTimeout,
                responseType: ResponseType.json,
                headers: NetworkConfig.commonHeaders,
              ),
            ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  final Dio _dio;

  @override
  Future<T?> read<T>(String path, Decoder<T> decoder) async {
    final json = await _request('GET', path);
    return json == null ? null : decoder(json);
  }

  @override
  Future<void> set<T>(String path, T value, Encoder<T> encoder) async {
    await _request('PUT', path, data: encoder(value));
  }

  @override
  Future<String> add<T>(String collectionPath, T value, Encoder<T> encoder) async {
    final json = await _request('POST', collectionPath, data: encoder(value));
    final id = json?['id'];
    if (id is String) return id;
    throw ServerException('POST $collectionPath did not return an `id` field.');
  }

  @override
  Future<void> update<T>(String path, T value, Encoder<T> encoder) async {
    await _request('PATCH', path, data: encoder(value));
  }

  @override
  Future<void> delete(String path) async {
    await _request('DELETE', path);
  }

  @override
  Future<T?> readWithQuery<T>(
    String path,
    Decoder<T> decoder, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final json = await _request(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    return json == null ? null : decoder(json);
  }

  @override
  Future<List<T>> readList<T>(
    String path,
    Decoder<T> decoder, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? rootKey,
  }) async {
    final response = await _rawRequest(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    final raw = response.data;
    final list = rootKey != null && raw is Map<String, dynamic>
        ? raw[rootKey]
        : raw;
    if (list is! List) {
      throw ServerException(
        'GET $path did not return a list${rootKey != null ? ' at "$rootKey"' : ''}.',
      );
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(decoder)
        .toList(growable: false);
  }

  Future<JsonMap?> _request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final response = await _rawRequest(
      method,
      path,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );
    final body = response.data;
    if (body == null) return null;
    if (body is Map<String, dynamic>) return body;
    throw ServerException(
      '$method $path returned a non-object body (${body.runtimeType}).',
    );
  }

  Future<Response<dynamic>> _rawRequest(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(e.message ?? 'Network timeout.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          return AuthException(
            e.message ?? 'Unauthorized.',
            code: status?.toString(),
          );
        }
        if (status == 404) {
          return NotFoundException(e.message ?? 'Resource not found.');
        }
        return ServerException(
          e.message ?? 'Request failed.',
          statusCode: status,
          body: e.response?.data,
        );
    }
  }
}
