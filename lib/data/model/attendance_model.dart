class AttendanceModel {
  final bool success;
  final String message;

  const AttendanceModel({required this.success, required this.message});

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}
