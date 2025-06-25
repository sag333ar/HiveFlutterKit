import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';

class ApiService {
  Future<Map<String, dynamic>> handleLogin(LoginModel result) async {
    final url = Uri.parse('${server.domain}/mobile/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "challenge": result.challenge,
        "proof": result.proof,
        "publicKey": result.publicKey,
        "username": result.username,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login API error: ${response.body}');
    }
  }
}
