import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

class ScanBarcodeController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final RxBool isFlashOn = false.obs;
  final RxBool isScanning = true.obs;

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void toggleFlash() {
    scannerController.toggleTorch();
    isFlashOn.value = !isFlashOn.value;
  }

  void switchCamera() {
    scannerController.switchCamera();
  }

  void onDetect(BarcodeCapture capture) async {
    if (!isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        // Pause pemindaian sementara memproses
        isScanning.value = false;
        scannerController.stop();

        _processScannedData(rawValue);
      }
    }
  }

  void _processScannedData(String data) async {
    if (data.startsWith('GARDA_INVITE:')) {
      final parts = data.split(':');
      if (parts.length >= 3) {
        final ownerUid = parts[1];
        final token = parts
            .sublist(2)
            .join(':'); // Sisa dari string adalah token

        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          final doc = await Get.find<AuthService>()
              .getUserReference(ownerUid)
              .collection('anggota')
              .doc(token)
              .get();

          Get.back(); // Tutup loading

          if (!doc.exists) {
            _showErrorDialog("Undangan tidak ditemukan atau sudah digunakan.");
            return;
          }

          final inviteData = doc.data() as Map<String, dynamic>? ?? {};
          final String ownerName = inviteData['ownerName'] ?? "Pengguna";

          _showConfirmationDialog(ownerName, ownerUid, token);
          return;
        } catch (e) {
          Get.back();
          _showErrorDialog("Terjadi kesalahan saat memeriksa undangan.");
          return;
        }
      }
    }

    _showErrorDialog("Kode barcode tidak valid atau tidak dikenali.");
  }

  void _showConfirmationDialog(
    String ownerName,
    String ownerUid,
    String token,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_add_rounded,
                  color: Colors.green.shade700,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Undangan Grup Ditemukan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Anda diundang oleh $ownerName untuk bergabung ke grup pantauan natriumnya.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Setelah Anda menyetujui, pemilik grup juga harus menerima permintaan Anda.",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        _resumeScanning();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _joinGroup(ownerUid, token);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Gabung",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _joinGroup(String ownerUid, String token) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar("Belum Masuk", "Anda harus masuk untuk bergabung.");
      _resumeScanning();
      return;
    }

    if (currentUser.uid == ownerUid) {
      Get.snackbar("Gagal", "Anda tidak bisa bergabung ke grup Anda sendiri.");
      _resumeScanning();
      return;
    }

    try {
      await Get.find<AuthService>()
          .getUserReference(ownerUid)
          .collection('group_requests')
          .doc(currentUser.uid)
          .set({
            'uid': currentUser.uid,
            'name': currentUser.displayName ?? 'Pengguna',
            'email': currentUser.email,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Hapus token undangan agar hanya bisa dipakai sekali
      await Get.find<AuthService>()
          .getUserReference(ownerUid)
          .collection('anggota')
          .doc(token)
          .delete();

      Get.defaultDialog(
        title: "Permintaan Terkirim",
        middleText:
            "Permintaan bergabung telah dikirim. Menunggu persetujuan pemilik grup.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF2E7D32),
        onConfirm: () {
          Get.back(); // Tutup dialog
          Get.back(); // Tutup halaman scanner
        },
      );
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan", "Gagal mengirim permintaan bergabung.");
      _resumeScanning();
    }
  }

  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: "Peringatan",
      middleText: message,
      textConfirm: "Coba Lagi",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        _resumeScanning();
      },
    );
  }

  void _resumeScanning() {
    isScanning.value = true;
    scannerController.start();
  }
}
