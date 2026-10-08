import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:front/service/apiException.dart';

Future<void> checkApiStatus() async {
  try {
    final response = await http
        .get(Uri.parse('http://localhost:8080/api/alive')) // use a rota real do seu back
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw ApiException('O servidor está com problemas, tente novamente mais tarde');
    }
  } catch (e) {
    throw ApiException('O servidor está offline, tente novamente mais tarde');
  }
}