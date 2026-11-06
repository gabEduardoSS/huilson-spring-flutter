import 'package:get_storage/get_storage.dart';

class SessionStorage{
  static final _storage = GetStorage();

  static const String _userIdKey = "user_id";

  static void saveSession({
    required int userId
  }){
    _storage.write(_userIdKey, userId);
  }

  static int? get userId => _storage.read(_userIdKey);

  static void clearSession(){
    _storage.remove(_userIdKey);
  }
}