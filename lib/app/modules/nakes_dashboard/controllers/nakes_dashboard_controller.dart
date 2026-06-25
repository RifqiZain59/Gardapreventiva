import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

class NakesDashboardController extends GetxController {
  final currentIndex = 0.obs;

  final RxString nakesName = 'Tenaga Kesehatan'.obs;
  final RxString photoBase64 = ''.obs;
  final RxInt totalPatients = 0.obs;
  final isLoading = true.obs;

  final RxInt patuhCount = 0.obs;
  final RxInt kurangPatuhCount = 0.obs;
  final RxInt tidakPatuhCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ambil nama dari dokumen Nakes
        final nakesDoc = await Get.find<AuthService>()
            .getUserReference(user.uid)
            .get();
        if (nakesDoc.exists) {
          final data = nakesDoc.data() as Map<String, dynamic>?;
          nakesName.value = data?['name'] ?? 'Tenaga Kesehatan';
          photoBase64.value = data?['photoBase64'] ?? data?['strImageBase64'] ?? '';
        }

        // Hitung total pasien di subcollection mobile/roles/pasien
        final pasienSnapshot = await FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .count()
            .get();
        final total = pasienSnapshot.count ?? 0;
        totalPatients.value = total;

        // Mock data untuk statistik kepatuhan (distribusi dari total pasien)
        if (total > 0) {
          patuhCount.value = (total * 0.6).round();
          kurangPatuhCount.value = (total * 0.25).round();
          tidakPatuhCount.value =
              total - patuhCount.value - kurangPatuhCount.value;
        } else {
          patuhCount.value = 0;
          kurangPatuhCount.value = 0;
          tidakPatuhCount.value = 0;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
