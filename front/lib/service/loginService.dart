import 'dart:convert';
import 'dart:io';

import 'package:front/service/apiException.dart';
import 'package:http/http.dart' as http;

Future<String?> sendLoginRequest(String username, String password) async {
  final url = Uri.parse('http://localhost:8080/api/auth/login');
  try{
      Map<String, String> payload = {
        'usuario': username.toUpperCase(),
        'senha': password,
      };

       final response = await http.post(
          headers: {'Content-Type': 'application/json'},
          url,
          body: jsonEncode(payload),
        );

  if (response.statusCode == 200) {
    print('Logado');
    return response.statusCode.toString();
  } else {
    print('Credenciais inválidas');
    return response.statusCode.toString();
  }
  } catch (e) {
    throw ApiException('Não foi possível conectar à API: $e');
  }
}