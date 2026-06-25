import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class KatalogController extends GetxController {
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchKatalogData();
  }

  void _fetchKatalogData() {
    FirebaseFirestore.instance
        .collectionGroup('katalog_makanan')
        .snapshots()
        .listen(
          (snapshot) {
            items.clear();
            for (var doc in snapshot.docs) {
              final data = doc.data();
              items.add({
                'id': doc.id,
                'makanan_asli': data['makanan_asli'] ?? '',
                'makanan_alternatif': data['makanan_alternatif'] ?? '',
                'hemat_natrium_mg':
                    double.tryParse(
                      data['hemat_natrium_mg']?.toString() ?? '0',
                    ) ??
                    0,
              });
            }
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            print("Error fetching katalog: $e");
          },
        );
  }
}
