import 'package:shared_preferences/shared_preferences.dart';

class AttendanceLocalDatasource {
  static const _latKey = 'office_lat';
  static const _lonKey = 'office_lon';

  Future<void> saveOfficeLocation(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lonKey, lon);
  }

  Future<Map<String, double>?> getOfficeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lon = prefs.getDouble(_lonKey);
    if (lat == null || lon == null) return null;
    return {'lat': lat, 'lon': lon};
  }
}
