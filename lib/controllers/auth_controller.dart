import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal() {
    UserRepository.init();
  }

  User get currentUser => UserRepository.currentUser.value;
  ValueNotifier<User> get currentUserNotifier => UserRepository.currentUser;

  bool login(String email, String pass) {
    bool ok = UserRepository.loginUserAccount(email, pass);
    if (ok) notifyListeners();
    return ok;
  }

  User register(String name, String email, String phone, String pass) {
    User user = UserRepository.registerUserAccount(name, email, phone, pass);
    notifyListeners();
    return user;
  }

  void logout() {
    UserRepository.currentUser.value = User(
      id: '',
      email: '',
      name: '',
      avatarUrl: '',
      loyaltyPoints: 0,
      phoneNumber: '',
      coupons: [],
      isVerified: false,
    );
    UserRepository.saveUser();
    notifyListeners();
  }

  void googleSignIn(String email, String name, String avatarUrl) {
    UserRepository.googleSignInAccount(email, name, avatarUrl);
    notifyListeners();
  }

  void verifyEmailCode(String email) {
    UserRepository.markEmailVerified(email);
    notifyListeners();
  }

  bool forgotPassword(String email, String newPass) {
    UserRepository.savePassword(email, newPass);
    notifyListeners();
    return true;
  }

  bool changePassword(String email, String currentPass, String newPass) {
    final curSaved = UserRepository.getPassword(email);
    if (curSaved == currentPass) {
      UserRepository.savePassword(email, newPass);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool isLoggedIn() {
    return currentUser.email.isNotEmpty;
  }
}
