import 'dart:convert';

import 'package:get/get.dart';

class Req extends GetConnect {
  Future<dynamic> getData(
    String url, {
    Map<String, dynamic>? query,
    String? contentType,
    Map<String, String>? headers,
    Function(dynamic)? decoder,
  }) async {
    Response response = await get(
      url,
      query: query,
      contentType: contentType,
      headers: headers,
      decoder: decoder,
    );

    List<dynamic> result = jsonDecode(response.body);
    return result;
  }
}
