import 'package:front/session/session.dart';

import '../core/api_client.dart';
import '../models/usuario.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<Usuario> login(String usuario, String senha) async{
      final res = await _api.post('/auth/login', body: {'usuario': usuario, 'senha': senha}) as Map<String, dynamic>;
      final usuarioJson = Usuario.fromJson(res);
      SessionStorage.saveSession(userId: usuarioJson.id);

      return usuarioJson;
      }

  /// "Primeiro acesso": cria o usuário (o back-end grava o usuário em MAIÚSCULAS).
  Future<Usuario> registrar(String usuario, String senha) async => Usuario.fromJson(
        await _api.post('/auth/registro', body: {'usuario': usuario, 'senha': senha})
            as Map<String, dynamic>,
      );

  Future<void> logout() async{
    SessionStorage.clearSession();
    print("logout");
  }
}
