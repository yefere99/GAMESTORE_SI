class AuthService {
  static bool _isAdmin = false;

  static bool get isAdmin => _isAdmin;

  static bool login(String password) {
    if (password == 'admin123') {
      _isAdmin = true;
      return true;
    }
    return false;
  }

  static void logout() {
    _isAdmin = false;
  }
}
