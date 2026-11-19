import 'package:get_storage/get_storage.dart';

class SessionStorage{
  static final _storage = GetStorage();

  static const String _userIdKey = "user_id";
  static const String _userName = "user_name";
  static const String _userToken = "user_token";
  static const String _userTokenExpiration = "user_token_expiration";

  static void saveSession({
    required int userId,
    required String token,
    required String usuario,
    required int expiraEm

  }){
    _storage.write(_userIdKey, userId);
    _storage.write(_userName, usuario);
    _storage.write(_userToken, token);
    _storage.write(_userTokenExpiration, expiraEm);
  }

  static int? get userId => _storage.read(_userIdKey);
  static String? get token => _storage.read(_userToken);
  static String? get nome => _storage.read(_userName);

  static void clearSession(){
    _storage.remove(_userIdKey);
    _storage.remove(_userName);
    _storage.remove(_userToken);
    _storage.remove(_userTokenExpiration);
  }
}