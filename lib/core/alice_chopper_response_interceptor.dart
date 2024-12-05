import 'dart:async';
import 'dart:convert';

import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'alice_core.dart';

class AliceChopperInterceptor implements chopper.Interceptor {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates instance of chopper interceptor
  AliceChopperInterceptor(this.aliceCore);

  /// Creates hashcode based on request
  int getRequestHashCode(BaseRequest baseRequest) {
    int hashCodeSum = 0;
    hashCodeSum += baseRequest.url.hashCode;
    hashCodeSum += baseRequest.method.hashCode;
    if (baseRequest.headers.isNotEmpty) {
      baseRequest.headers.forEach((key, value) {
        hashCodeSum += key.hashCode;
        hashCodeSum += value.hashCode;
      });
    }
    if (baseRequest.contentLength != null) {
      hashCodeSum += baseRequest.contentLength.hashCode;
    }

    return hashCodeSum.hashCode;
  }

  /// Handles chopper response and adds data to existing alice http call
  @override
  FutureOr<chopper.Response<BodyType>> intercept<BodyType>(chopper.Chain<BodyType> chain) async {
    try {
      final baseRequest = await chain.request.toBaseRequest();
      final AliceHttpCall call = AliceHttpCall(getRequestHashCode(baseRequest));
      String endpoint = "";
      String server = "";

      final List<String> split = chain.request.url.toString().split("/");
      if (split.length > 2) {
        server = split[1] + split[2];
      }
      if (split.length > 4) {
        endpoint = "/";
        for (int splitIndex = 3; splitIndex < split.length; splitIndex++) {
          // ignore: use_string_buffers
          endpoint += "${split[splitIndex]}/";
        }
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }

      call.method = chain.request.method;
      call.endpoint = endpoint;
      call.server = server;
      call.client = "Chopper";
      if (chain.request.url.toString().contains("https")) {
        call.secure = true;
      }

      final AliceHttpRequest aliceHttpRequest = AliceHttpRequest();

      if (chain.request.body == null) {
        aliceHttpRequest.size = 0;
        aliceHttpRequest.body = "";
      } else {
        aliceHttpRequest.size = utf8.encode(chain.request.body as String).length;
        aliceHttpRequest.body = chain.request.body;
      }
      aliceHttpRequest.time = DateTime.now();
      aliceHttpRequest.headers = chain.request.headers;

      String? contentType = "unknown";
      if (chain.request.headers.containsKey("Content-Type")) {
        contentType = chain.request.headers["Content-Type"];
      }
      aliceHttpRequest.contentType = contentType;
      aliceHttpRequest.queryParameters = chain.request.parameters;

      call.request = aliceHttpRequest;
      call.response = AliceHttpResponse();

      aliceCore.addCall(call);
    } catch (exception) {
      AliceUtils.log(exception.toString());
    }

    final httpResponse = AliceHttpResponse();
    final String buildNumber = (await PackageInfo.fromPlatform()).buildNumber;
    final chopper.Response<BodyType> response = await chain.proceed(
      chopper.applyHeader(chain.request, 'x-app-version', buildNumber),
    );

    httpResponse.status = response.statusCode;
    if (response.body == null) {
      httpResponse.body = "";
      httpResponse.size = 0;
    } else {
      httpResponse.body = response.body;
      httpResponse.size = utf8.encode(response.body.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final Map<String, String> headers = {};
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;

    aliceCore.addResponse(
      httpResponse,
      getRequestHashCode(response.base.request!),
    );
    return response;
  }
}
