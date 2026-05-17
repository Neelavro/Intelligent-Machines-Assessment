import 'dart:convert';

import 'package:intelligent_machines_assessment/data/model/api_result_model.dart';

class AttendanceDatasource {
  Future<ApiResult> markAttendance({required double lat, required double lon}) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResult(
      body: jsonEncode({'success': true, 'message': 'Attendance recorded'}),
      statusCode: 200,
    );
  }
}
