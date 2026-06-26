import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class NakesPasienGativaController extends GetxController {
  final isLoading = true.obs;
  final pasienList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPasien();
  }

  void fetchPasien() {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .snapshots()
        .listen((snapshot) {
      pasienList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      Get.snackbar('Error', 'Gagal memuat data pasien: $e');
      isLoading.value = false;
    });
  }
}

