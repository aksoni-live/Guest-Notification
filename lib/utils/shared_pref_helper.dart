import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static late SharedPreferences _prefs;

  static Future<void> initPref() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void setUserId(String userId) {
    _prefs.setString("user_id", userId);
  }

  static String getUserId() {
    return _prefs.getString("user_id") ?? 'VPidNGUCDMVUQtBBmhD7';
  }
}
