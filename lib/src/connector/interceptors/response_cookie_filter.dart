// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// A cookie filter that can assist in excluding certain cookies from the response.
@immutable
@protected
@sealed
class ResponseCookieFilter extends Interceptor {
  /// The filtering adopts the blacklist mechanism,
  /// and the cookie name or part of the name that needs to be removed is passed in
  /// through [blockedCookieNamePatterns].
  ResponseCookieFilter({@required List<RegExp> blockedCookieNamePatterns})
      : _blockedCookieNamePatterns = blockedCookieNamePatterns;

  final List<RegExp> _blockedCookieNamePatterns;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final _clearedResponse = _removeCookiesFrom(response);
      handler.next(_clearedResponse);
    } on Exception catch (e, _stackTrace) {
      final err = DioError(requestOptions: response.requestOptions, error: e)..stackTrace = _stackTrace;
      handler.reject(err, true);
    }
  }

  Response _removeCookiesFrom(Response response) {
    final cookies = response.headers[HttpHeaders.setCookieHeader]
        ?.where((cookie) => _blockedCookieNamePatterns.every((pattern) => !pattern.hasMatch(cookie)))
        ?.toList();

    if (cookies != null) response.headers.set(HttpHeaders.setCookieHeader, cookies);
    return response;
  }
}