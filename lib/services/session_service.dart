import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // Claves usadas para almacenar datos de sesión en SharedPreferences.
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'auth_username';
  static const String _roleKey = 'auth_role';
  static const String _userIdKey = 'auth_user_id';

  // Guarda los datos de sesión (token, id de usuario, nombre y rol).
  Future<void> saveSession({
    required String token,
    required int userId,
    required String username,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey, role);
  }

  // Devuelve el token de sesión almacenado.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Verifica si hay una sesión activa basada en la existencia de un token.
  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Devuelve el nombre de usuario almacenado en la sesión.
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Devuelve el rol almacenado en la sesión.
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Devuelve el id de usuario almacenado en la sesión.
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Elimina todos los datos de sesión guardados en SharedPreferences.
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
  }
}