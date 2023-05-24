// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$PostsService extends PostsService {
  _$PostsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = PostsService;

  @override
  Future<Response<dynamic>> getPost(String id) {
    final $url = 'https://jsonplaceholder.typicode.com/posts/$id';
    final uri = Uri.parse($url);
    final $request = Request('GET', uri, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postPost(String? body) {
    final $url = 'https://jsonplaceholder.typicode.com/posts/';
    final uri = Uri.parse($url);
    final $body = body;
    final $request = Request('POST', uri, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> putPost(String id, String? body) {
    final $url = 'https://jsonplaceholder.typicode.com/posts/$id';
    final uri = Uri.parse($url);
    final $body = body;
    final $request = Request('PUT', uri, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}
