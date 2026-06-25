import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/nakes_profile_controller.dart';

class NakesProfileView extends GetView<NakesProfileController> {
  const NakesProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NakesProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Profil Tenaga Kesehatan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -40,
                    top: -20,
                    child: Icon(
                      Icons.medical_information,
                      size: 160,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Column(
                    children: [
                      Obx(() => CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white24,
                        backgroundImage: controller.photoBase64.value.isNotEmpty
                            ? MemoryImage(const Base64Decoder().convert(controller.photoBase64.value))
                            : null,
                        child: controller.photoBase64.value.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 64)
                            : null,
                      )),
                      const SizedBox(height: 16),
                      Obx(
                        () => Text(
                          controller.nakesName.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          controller.nakesEmail.value,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileOption(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profil',
                      subtitle: 'Ubah data diri dan informasi dasar',
                      color: const Color(0xFF2196F3),
                      onTap: () => Get.toNamed(Routes.NAKES_EDIT_PROFILE),
                    ),
                    _buildProfileOption(
                      icon: Icons.security_rounded,
                      title: 'Ganti Kata Sandi',
                      subtitle: 'Perbarui kata sandi Anda',
                      color: const Color(0xFFFF9800),
                      onTap: () => Get.toNamed(Routes.NAKES_GANTI_KATA_SANDI),
                    ),
                    _buildProfileOption(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Informasi versi & detail aplikasi',
                      color: const Color(0xFF9C27B0),
                      onTap: () => Get.toNamed(Routes.NAKES_TENTANG_APLIKASI),
                    ),
                    _buildProfileOption(
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan/FAQ',
                      subtitle: 'Panduan penggunaan aplikasi',
                      color: const Color(0xFF00BCD4),
                      onTap: () => Get.toNamed(Routes.NAKES_BANTUAN_FAQ),
                    ),
                    _buildProfileOption(
                      icon: Icons.logout_rounded,
                      title: 'Keluar',
                      subtitle: 'Akhiri sesi Anda',
                      color: const Color(0xFFF44336),
                      onTap: () {
                        controller.logout();
                      },
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
              indent: 72,
              endIndent: 20,
            ),
        ],
      ),
    );
  }
}
