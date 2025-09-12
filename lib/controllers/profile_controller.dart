// lib/controllers/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan_pkl_app/pages/auth/login_page.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  // Variabel-variabel yang "observable"
  var user = User(id: 0, name: '', email: '').obs;
  final RxBool isLoading = true.obs;
  final RxBool isUploading = false.obs;
  final RxString token = ''.obs;
  final RxBool hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile(); // Panggil fungsi saat controller dibuat
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading(true);
      token.value = (await _apiService.getToken()) ?? '';
      final fetchedUser = await _apiService.getUserProfile();
      user(fetchedUser);
      hasError(false);
    } catch (e) {
      hasError(true);
      errorMessage(e.toString());
      print(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      isUploading(true);
      try {
        final Map<String, dynamic> result;
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          result = await _apiService.updateUserProfile(fotoBytes: bytes);
        } else {
          result = await _apiService.updateUserProfile(
            fotoFile: File(pickedFile.path),
          );
        }

        // Muat ulang data profil setelah update berhasil
        await fetchUserProfile();
        Get.snackbar('Sukses', result['message']); // Gunakan Get.snackbar
      } catch (e) {
        Get.snackbar('Gagal', 'Gagal memperbarui foto profil: $e');
      } finally {
        isUploading(false);
      }
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Panggil logout di ApiService
      await _apiService.logout();

      // Arahkan user ke halaman login
      Get.to(LoginPage()); // pastikan route /login sudah ada
    } catch (e) {
      Get.snackbar(
        "Logout Gagal",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
