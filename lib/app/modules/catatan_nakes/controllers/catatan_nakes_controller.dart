import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CatatanNakesController extends GetxController {
  final isLoading = true.obs;
  final catatanNakes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCatatan();
  }

  Future<void> fetchCatatan() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .doc(user.uid)
            .get();

        catatanNakes.clear();
        if (docSnapshot.exists) {
          final data = docSnapshot.data() ?? {};
          if (data['catatan_nakes'] != null) {
            final catatanData = data['catatan_nakes'];
            if (catatanData is List) {
              for (var item in catatanData) {
                if (item != null && item.toString().isNotEmpty) {
                  catatanNakes.add(item.toString());
                }
              }
            } else if (catatanData is String && catatanData.isNotEmpty) {
              catatanNakes.add(catatanData);
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat catatan medis');
    } finally {
      isLoading.value = false;
    }
  }
}
