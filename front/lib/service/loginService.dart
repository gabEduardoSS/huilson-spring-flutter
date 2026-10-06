import 'dart:convert';

import 'package:http/http.dart' as http;

Future sendLoginRequest(String username, String password) async {
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
    // Login successful
    print('Logado');
  } else {
    print(response.statusCode);
    print('Credenciais inválidas');
  }
  } catch (e) {
    print('Erro: $e');
  }
 
}