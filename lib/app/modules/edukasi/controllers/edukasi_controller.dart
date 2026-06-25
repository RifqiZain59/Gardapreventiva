import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EdukasiController extends GetxController {
  final isLoading = true.obs;
  final edukasiList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEdukasi();
  }

  void fetchEdukasi() {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collectionGroup('edukasi')
        .snapshots()
        .listen((snapshot) {
      edukasiList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      Get.snackbar('Error', 'Gagal memuat data edukasi: $e');
      isLoading.value = false;
    });
  }
}
