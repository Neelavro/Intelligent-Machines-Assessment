import 'dart:convert';

import 'package:intelligent_machines_assessment/data/model/api_result_model.dart';

class CameraRemoteDatasource {
  Future<ApiResult> uploadImage(String filePath) async {
    await Future.delayed(const Duration(seconds: 2));
    return ApiResult(
      body: jsonEncode({'success': true, 'message': 'Image uploaded successfully'}),
      statusCode: 200,
    );
  }
}
