import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    // _auth.authStateChanges().listen((User? user) {
    //   if (user != null) {
    //     _loadUserData(user.uid);
    //   } else {
    //     currentUser.value = null;
    //   }
    // });
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Sign up with email and password
  // Firebase Auth: Create new user account
  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // TODO: Use FirebaseAuth to create user
      // UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      //   email: emailController.text.trim(),
      //   password: passwordController.text.trim(),
      // );

      // Create user document in Firestore
      // final user = UserModel(
      //   id: userCredential.user!.uid,
      //   name: nameController.text.trim(),
      //   email: emailController.text.trim(),
      //   createdAt: DateTime.now(),
      // );

      // await _firestore.collection('users').doc(user.id).set(user.toMap());
      // currentUser.value = user;

      // Simulate success for demo
      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
      _clearControllers();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  // Firebase Auth: Sign in existing user
  Future<void> signIn() async {
    if (!signInFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // TODO: Use FirebaseAuth to sign in user
      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      //   email: emailController.text.trim(),
      //   password: passwordController.text.trim(),
      // );

      // await _loadUserData(userCredential.user!.uid);

      // Simulate success for demo
      Get.snackbar(
        'Success',
        'Signed in successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
      _clearControllers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid email or password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  // Firebase Auth: Sign out current user
  Future<void> signOut() async {
    try {
      // await _auth.signOut();
      currentUser.value = null;
      Get.offAllNamed('/signin');

      Get.snackbar(
        'Success',
        'Signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load user data from Firestore
  // Future<void> _loadUserData(String uid) async {
  //   try {
  //     final doc = await _firestore.collection('users').doc(uid).get();
  //     if (doc.exists) {
  //       currentUser.value = UserModel.fromMap(doc.data()!);
  //     }
  //   } catch (e) {
  //     print('Error loading user data: $e');
  //   }
  // }

  void _clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
