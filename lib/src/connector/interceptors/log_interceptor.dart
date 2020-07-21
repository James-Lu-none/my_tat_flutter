import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/config/config.dart';

/**
 * Log 攔截器
 * Created by guoshuyu
 * on 2019/3/23.
 */
class LogsInterceptors extends InterceptorsWrapper {
  static List<Map> sHttpResponses = new List<Map>();
  static List<String> sResponsesHttpUrl = new List<String>();

  static List<Map<String, dynamic>> sHttpRequest =
      new List<Map<String, dynamic>>();
  static List<String> sRequestHttpUrl = new List<String>();

  static List<Map<String, dynamic>> sHttpError =
      new List<Map<String, dynamic>>();
  static List<String> sHttpErrorUrl = new List<String>();

  @override
  onRequest(RequestOptions options) async {
    if (Config.DEBUG) {
      Log.d("請求url：${options.path}");
      Log.d('請求頭: ' + options.headers.toString());
      if (options.data != null) {
        Log.d('請求參數: ' + options.data.toString());
      }
    }
    try {
      addLogic(sRequestHttpUrl, options.path ?? "");
      var data;
      if (options.data is Map) {
        data = options.data;
      } else {
        data = Map<String, dynamic>();
      }
      var map = {
        "header:": {...options.headers},
      };
      if (options.method == "POST") {
        map["data"] = data;
      }
      addLogic(sHttpRequest, map);
    } catch (e) {
      Log.e(e);
    }
    return options;
  }

  @override
  onResponse(Response response) async {
    if (Config.DEBUG) {
      if (response != null) {
        Log.d('返回參數: ' + response.toString());
      }
    }
    if (response.data is Map || response.data is List) {
      try {
        var data = Map<String, dynamic>();
        data["data"] = response.data;
        addLogic(sResponsesHttpUrl, response?.request?.uri?.toString() ?? "");
        addLogic(sHttpResponses, data);
      } catch (e) {
        Log.e(e);
      }
    } else if (response.data is String) {
      try {
        var data = Map<String, dynamic>();
        data["data"] = response.data;
        addLogic(sResponsesHttpUrl, response?.request?.uri.toString() ?? "");
        addLogic(sHttpResponses, data);
      } catch (e) {
        Log.e(e);
      }
    } else if (response.data != null) {
      try {
        String data = response.data.toJson();
        addLogic(sResponsesHttpUrl, response?.request?.uri.toString() ?? "");
        addLogic(sHttpResponses, json.decode(data));
      } catch (e) {
        Log.e(e);
      }
    }
    return response; // continue
  }

  @override
  onError(DioError err) async {
    if (Config.DEBUG) {
      Log.e('請求異常: ' + err.toString());
      Log.e('請求異常信息: ' + (err.response?.toString() ?? ""));
    }
    try {
      addLogic(sHttpErrorUrl, err.request.path ?? "null");
      var errors = Map<String, dynamic>();
      errors["error"] = err.message;
      addLogic(sHttpError, errors);
    } catch (e) {
      Log.e(e);
    }
    return err; // continue;
  }

  static addLogic(List list, data) {
    if (list.length > 20) {
      list.removeAt(0);
    }
    list.add(data);
  }
}
