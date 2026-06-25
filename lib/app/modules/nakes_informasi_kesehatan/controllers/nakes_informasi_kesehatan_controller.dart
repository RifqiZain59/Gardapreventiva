import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InformasiData {
  final String id;
  final String tanggal;
  final String alamat;
  final String keterangan;
  final String gambarBase64;

  InformasiData({
    required this.id,
    required this.tanggal,
    required this.alamat,
    required this.keterangan,
    required this.gambarBase64,
  });
}

class NakesInformasiKesehatanController extends GetxController {
  final isLoading = true.obs;
  final infoList = <InformasiData>[].obs;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _fetchInformasi();
  }

  void _fetchInformasi() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _firestore
        .collection('mobile')
        .doc('roles')
        .collection('tenaga_kesehatan')
        .doc(user.uid)
        .collection('informasi_kesehatan')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            infoList.assignAll(
              snapshot.docs.map((doc) {
                final data = doc.data();
                return InformasiData(
                  id: doc.id,
                  tanggal: data['tanggal'] ?? '',
                  alamat: data['alamat'] ?? '',
                  keterangan: data['keterangan'] ?? '',
                  gambarBase64: data['gambarBase64'] ?? '',
                );
              }).toList(),
            );
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
          },
        );
  }

  Future<void> addInformasi(
    String tanggal,
    String alamat,
    String keterangan,
    String gambarBase64,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(user.uid)
          .collection('informasi_kesehatan')
          .add({
            'tanggal': tanggal,
            'alamat': alamat,
            'keterangan': keterangan,
            'gambarBase64': gambarBase64,
            'createdAt': FieldValue.serverTimestamp(),
          });
      Get.snackbar(
        'Sukses',
        'Informasi berhasil ditambahkan',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan informasi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateInformasi(
    String id,
    String tanggal,
    String alamat,
    String keterangan,
    String gambarBase64,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(user.uid)
          .collection('informasi_kesehatan')
          .doc(id)
          .update({
            'tanggal': tanggal,
            'alamat': alamat,
            'keterangan': keterangan,
            'gambarBase64': gambarBase64,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      Get.snackbar(
        'Sukses',
        'Informasi berhasil diperbarui',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui informasi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteInformasi(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(user.uid)
          .collection('informasi_kesehatan')
          .doc(id)
          .delete();
      Get.snackbar(
        'Sukses',
        'Informasi berhasil dihapus',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus informasi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
