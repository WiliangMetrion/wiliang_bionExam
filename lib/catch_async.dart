import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CatchAsync {
  static Future<dynamic> run({
    String? status,
    required Future<dynamic> Function() future,
  }) async {
    EasyLoading.show(status: status);
    try {
      await future();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Fluttertoast.showToast(msg: e.toString());
    }
    EasyLoading.dismiss();
  }
}
