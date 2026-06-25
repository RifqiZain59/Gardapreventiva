import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ageController = TextEditingController();

  // Nakes specific
  final strController = TextEditingController();
  final strImageBase64 = ''.obs;

  final selectedRole = 'Pasien'.obs;
  final roles = ['Pasien', 'Tenaga Kesehatan'];

  final selectedCondition = 'Sehat'.obs;

  final List<String> conditions = [
    'Sehat',
    'Hipertensi',
    'Penyakit kardiovaskular',
    'Penyakit jantung koroner',
    'Penyakit ginjal kronis',
    'Stroke',
  ];

  final isPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;
  final isLoading = false.obs;

  void togglePassword() {
    isPasswordObscure.value = !isPasswordObscure.value;
  }

  void toggleConfirmPassword() {
    isConfirmPasswordObscure.value = !isConfirmPasswordObscure.value;
  }

  Future<void> pickStrImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // compress to avoid firestore document size limit (1MB)
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Firestore document limit is 1MB. Ensure base64 string is not too large.
      if (base64Image.length > 800000) {
        Get.snackbar(
          'Gambar Terlalu Besar',
          'Silakan pilih gambar dengan ukuran lebih kecil',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      strImageBase64.value = base64Image;
    }
  }

  double calculateDailyLimit(int age, String condition) {
    if (age >= 5 && age <= 9) {
      switch (condition) {
        case 'Sehat':
          return 1200;
        case 'Hipertensi':
          return 1200;
        case 'Penyakit kardiovaskular':
          return 1000;
        case 'Penyakit jantung koroner':
          return 1000;
        case 'Penyakit ginjal kronis':
          return 800; // 800 - 1000
        case 'Stroke':
          return 0; // -
        default:
          return 1200;
      }
    } else if (age >= 10 && age <= 17) {
      switch (condition) {
        case 'Sehat':
          return 1500;
        case 'Hipertensi':
          return 1200;
        case 'Penyakit kardiovaskular':
          return 1000;
        case 'Penyakit jantung koroner':
          return 1000;
        case 'Penyakit ginjal kronis':
          return 800; // 800 - 1000
        case 'Stroke':
          return 0; // -
        default:
          return 1500;
      }
    } else if (age >= 18 && age <= 59) {
      switch (condition) {
        case 'Sehat':
          return 2000;
        case 'Hipertensi':
          return 1500;
        case 'Penyakit kardiovaskular':
          return 1500;
        case 'Penyakit jantung koroner':
          return 1500;
        case 'Penyakit ginjal kronis':
          return 1500;
        case 'Stroke':
          return 1500;
        default:
          return 2000;
      }
    } else {
      // Lansia 60+
      switch (condition) {
        case 'Sehat':
          return 1200;
        case 'Hipertensi':
          return 1000;
        case 'Penyakit kardiovaskular':
          return 1000; // 1000 - 1200
        case 'Penyakit jantung koroner':
          return 1000; // 1000 - 1200
        case 'Penyakit ginjal kronis':
          return 1000;
        case 'Stroke':
          return 1000;
        default:
          return 1200;
      }
    }
  }

  Future<void> register() async {
    if (selectedRole.value == 'Tenaga Kesehatan') {
      if (strController.text.isEmpty) {
        Get.snackbar(
          'Input Kosong',
          'Harap isi Nomor STR',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }
      if (strImageBase64.value.isEmpty) {
        Get.snackbar(
          'Foto STR',
          'Harap unggah foto bukti STR',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }
    }

    isLoading.value = true;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameController.text.trim());

        int age = int.tryParse(ageController.text) ?? 20;
        double? calculatedLimit;

        if (selectedRole.value == 'Pasien') {
          calculatedLimit = calculateDailyLimit(age, selectedCondition.value);
        }

        // Save to main role collection (no separate profile subcollection)
        Map<String, dynamic> userData = {
          'name': nameController.text.trim(),
          'email': user.email,
          'age': age,
          'role': selectedRole.value,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (selectedRole.value == 'Pasien') {
          userData['kondisi'] = selectedCondition.value;
          userData['dailyLimit'] = calculatedLimit;
        } else {
          userData['strNumber'] = strController.text.trim();
          userData['strImageBase64'] = strImageBase64.value;
        }

        String subCollectionName = selectedRole.value == 'Pasien'
            ? 'pasien'
            : 'tenaga_kesehatan';

        // Save all data to the role document directly
        await FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection(subCollectionName)
            .doc(user.uid)
            .set(userData);

        // Send email verification
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
      }

      isLoading.value = false;
      Get.offAllNamed(Routes.VERIFIKASI_EMAIL);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan saat mendaftar.';
      if (e.code == 'weak-password') {
        message = 'Kata sandi terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email ini sudah terdaftar sebelumnya.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }
      Get.snackbar(
        'Pendaftaran Gagal',
        message,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Pendaftaran Gagal',
        'Terjadi error: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void goToLogin() {
    Get.back();
  }
}
