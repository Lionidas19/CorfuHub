import 'package:flutter/foundation.dart';
import 'package:corfu_shared/shared.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthNotifier extends ChangeNotifier {
  final AppRepository _repo;

  AuthNotifier(this._repo) {
    _init();
  }

  AuthStatus _status = AuthStatus.unknown;
  UserEntity? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> _init() async {
    try {
      _user = await _repo.getCurrentUser();
      _status =
          _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      await _repo.sendPhoneOtp(phone);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({required String phone, required String token}) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      _user = await _repo.verifyPhoneOtp(phone: phone, token: token);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
    }
  }

  /// DEBUG ONLY: Sign in as a test user without OTP.
  Future<void> debugSignIn(String userId) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      _user = await _repo.debugSignInAsUser(userId);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// DEBUG ONLY: Sign in as a test user by UUID
  Future<bool> debugSignInAsUser(String userId) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      _user = await _repo.debugSignInAsUser(userId);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
    }
  }
}
