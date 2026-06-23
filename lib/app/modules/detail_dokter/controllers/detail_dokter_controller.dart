import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailDokterController extends GetxController {
  final isLoading = true.obs;
  final doctorData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      fetchDoctorDetails(args['username'] ?? args['uid']);
    } else {
      isLoading.value = false;
    }
  }

  void fetchDoctorDetails(String? username) async {
    if (username == null) {
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      // Ambil data dari collection website berdasarkan username
      final snapshot = await FirebaseFirestore.instance
          .collection('website')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        doctorData.value = snapshot.docs.first.data();
      } else {
        // Fallback
        final args = Get.arguments;
        if (args != null && args is Map<String, dynamic>) {
           doctorData.value = args;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail dokter');
    } finally {
      isLoading.value = false;
    }
  }
}
