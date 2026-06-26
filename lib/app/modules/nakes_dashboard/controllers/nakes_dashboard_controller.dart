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
            .get();
        
        final total = pasienSnapshot.docs.length;
        totalPatients.value = total;

        int patuh = 0;
        int kurangPatuh = 0;
        int tidakPatuh = 0;

        for (var doc in pasienSnapshot.docs) {
          final data = doc.data();
          double limit = (data['dailyLimit'] ?? 2000.0).toDouble();
          if (limit == 0) limit = 2000.0;
          double natrium = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0.0).toDouble();
          
          double ratio = natrium / limit;
          
          if (ratio < 0.6) {
            patuh++;
          } else if (ratio < 0.9) {
            kurangPatuh++;
          } else {
            tidakPatuh++;
          }
        }

        patuhCount.value = patuh;
        kurangPatuhCount.value = kurangPatuh;
        tidakPatuhCount.value = tidakPatuh;
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
