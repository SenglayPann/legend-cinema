import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:legend_cinema/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/auth_services.dart';

class AuthState extends ChangeNotifier {
  UserModel? _currentUser;
  final bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // ───────────────────────────────────────────────────────────────
  // 🔹 Load user from persistent storage on app start
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(userMap);
        print('=======> User loaded from storage: ${_currentUser?.userName}');
        notifyListeners();
      } catch (e) {
        debugPrint('Error decoding saved user: $e');
      }
    }
  }

  // ───────────────────────────────────────────────────────────────
  // 🔹 Save current user to local storage
  Future<void> saveUserToStorage(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userMap = user.toJson();
    await prefs.setString('user', jsonEncode(userMap));
    print('User saved to storage.');
  }

  // ───────────────────────────────────────────────────────────────
  // 🔹 Clear local user (on sign out)
  Future<void> clearUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _currentUser = null;
    notifyListeners();
  }

  // Optional helper
  void setUser(UserModel user) {
    _currentUser = user;
    saveUserToStorage(user);
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────
  // 🔹 Update user profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    DateTime? dob,
  }) async {
    if (_currentUser == null) return;

    // Create updated user object
    final updatedUser = _currentUser!.copyWith(
      firstName: firstName,
      lastName: lastName,
      userName: '$firstName $lastName',
      dateOfBirth: dob != null ? Timestamp.fromDate(dob) : null,
    );

    try {
      // Update in Firestore
      final authService = AuthServices();
      await authService.updateUser(updatedUser);

      // Update local state
      setUser(updatedUser);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
}
