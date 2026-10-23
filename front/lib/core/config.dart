import 'package:flutter/foundation.dart';

/// Permite trocar a URL sem mexer no código:
///   flutter run --dart-define=API_URL=http://192.168.0.10:8080/api
const _apiUrlDefine = String.fromEnvironment('API_URL');

/// URL base da API Spring Boot (todos os controllers estão sob `/api`).
///
/// - Emulador Android: o "localhost" do PC é acessado por 10.0.2.2
/// - Web / Desktop / iOS Simulator: localhost
/// - Celular físico: use --dart-define com o IP do PC na rede.
String get apiBaseUrl {
  if (_apiUrlDefine.isNotEmpty) return _apiUrlDefine;
  final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  return 'http://${android ? '10.0.2.2' : 'localhost'}:8080/api';
}
