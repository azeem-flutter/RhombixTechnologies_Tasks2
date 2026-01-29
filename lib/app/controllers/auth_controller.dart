import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/error_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// =====================
  /// AUTH STATE
  /// =====================
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// =====================
  /// SIGN UP FORM
  /// =====================
  final signUpFormKey = GlobalKey<FormState>();
  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpConfirmPasswordController = TextEditingController();

  final RxBool isSignUpLoading = false.obs;
  final RxBool isSignUpPasswordVisible = false.obs;
  final RxBool isSignUpConfirmPasswordVisible = false.obs;

  /// =====================
  /// SIGN IN FORM
  /// =====================
  final signInFormKey = GlobalKey<FormState>();
  final signInEmailController = TextEditingController();
  final signInPasswordController = TextEditingController();

  final RxBool isSignInLoading = false.obs;
  final RxBool isSignInPasswordVisible = false.obs;

  /// =====================
  /// LIFECYCLE
  /// =====================
  @override
  void onInit() {
    super.onInit();

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  /// =====================
  /// UI HELPERS
  /// =====================
  void toggleSignUpPassword() => isSignUpPasswordVisible.toggle();

  void toggleSignUpConfirmPassword() => isSignUpConfirmPasswordVisible.toggle();

  void toggleSignInPassword() => isSignInPasswordVisible.toggle();

  /// =====================
  /// SIGN UP
  /// =====================
  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;
    if (isSignUpLoading.value) return;

    try {
      isSignUpLoading.value = true;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: signUpEmailController.text.trim(),
        password: signUpPasswordController.text.trim(),
      );

      final user = UserModel(
        id: credential.user!.uid,
        name: signUpNameController.text.trim(),
        email: signUpEmailController.text.trim(),
        bio: '',
        profileImage: null,
        favorites: [],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      currentUser.value = user;

      ErrorService.showSuccess('Account created successfully');
      Get.offAllNamed('/home');
      _clearSignUpControllers();
    } catch (e) {
      ErrorService.handleError(e);
    } finally {
      isSignUpLoading.value = false;
    }
  }

  /// =====================
  /// SIGN IN
  /// =====================
  Future<void> signIn() async {
    if (!signInFormKey.currentState!.validate()) return;
    if (isSignInLoading.value) return;

    try {
      isSignInLoading.value = true;

      final credential = await _auth.signInWithEmailAndPassword(
        email: signInEmailController.text.trim(),
        password: signInPasswordController.text.trim(),
      );

      await _loadUserData(credential.user!.uid);

      ErrorService.showSuccess('Signed in successfully');
      Get.offAllNamed('/home');
      _clearSignInControllers();
    } catch (e) {
      ErrorService.handleError(e);
    } finally {
      isSignInLoading.value = false;
    }
  }

  /// =====================
  /// SIGN OUT
  /// =====================
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser.value = null;
    Get.offAllNamed('/signin');
  }

  /// =====================
  /// LOAD USER
  /// =====================
  Future<void> _loadUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('User record not found');
    }

    currentUser.value = UserModel.fromMap(doc.data()!);
  }

  /// =====================
  /// CLEANUP
  /// =====================
  void _clearSignUpControllers() {
    signUpNameController.clear();
    signUpEmailController.clear();
    signUpPasswordController.clear();
    signUpConfirmPasswordController.clear();
  }

  void _clearSignInControllers() {
    signInEmailController.clear();
    signInPasswordController.clear();
  }

  @override
  void onClose() {
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    signInEmailController.dispose();
    signInPasswordController.dispose();
    super.onClose();
  }
}
