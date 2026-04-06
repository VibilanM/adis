import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _ipKey = 'server_ip';
  static const String _portKey = 'server_port';
  static const String _defaultIp = '192.168.1.100';
  static const String _defaultPort = '8000';

  static ApiService? _instance;
  ApiService._();
  static ApiService get instance => _instance ??= ApiService._();

  Future<String> get baseUrl async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_ipKey) ?? _defaultIp;
    final port = prefs.getString(_portKey) ?? _defaultPort;
    return 'http://$ip:$port';
  }

  Future<void> saveServerConfig(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
    await prefs.setString(_portKey, port);
  }

  Future<Map<String, dynamic>> getServerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ip': prefs.getString(_ipKey) ?? _defaultIp,
      'port': prefs.getString(_portKey) ?? _defaultPort,
    };
  }

  // GET /state
  Future<Map<String, dynamic>?> getState() async {
    try {
      final url = await baseUrl;
      final response = await http
          .get(Uri.parse('$url/state'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Server unreachable — return null, caller handles gracefully
    }
    return null;
  }

  // POST /timer/start
  Future<bool> startTimer(int durationSeconds) async {
    try {
      final url = await baseUrl;
      final response = await http
          .post(
            Uri.parse('$url/timer/start'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'duration': durationSeconds}),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // POST /timer/stop
  Future<bool> stopTimer() async {
    try {
      final url = await baseUrl;
      final response = await http
          .post(Uri.parse('$url/timer/stop'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // POST /task
  Future<bool> addTask(String title, String time) async {
    try {
      final url = await baseUrl;
      final response = await http
          .post(
            Uri.parse('$url/task'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'title': title, 'time': time}),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
