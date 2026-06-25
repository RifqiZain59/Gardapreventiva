import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlternativeFood {
  final String id;
  final String category;
  final String originalFood;
  final double originalSodium;
  final String alternativeFood;
  final double alternativeSodium;
  final String benefit;

  AlternativeFood({
    required this.id,
    required this.category,
    required this.originalFood,
    required this.originalSodium,
    required this.alternativeFood,
    required this.alternativeSodium,
    required this.benefit,
  });

  double get savings => originalSodium - alternativeSodium;
}

class NakesCatalogController extends GetxController {
  final RxString searchQuery = "".obs;
  final RxString selectedCategory = "Semua".obs;

  final RxList<String> categories = <String>["Semua"].obs;

  final RxList<AlternativeFood> allAlternatives = <AlternativeFood>[].obs;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference? _katalogRef;

  @override
  void onInit() {
    super.onInit();
    final user = _auth.currentUser;
    if (user != null) {
      _katalogRef = _firestore
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(user.uid)
          .collection('katalog_makanan');
      _loadRealData();
    }
  }

  void _loadRealData() {
    if (_katalogRef == null) return;
    
    _katalogRef!.snapshots().listen((snapshot) {
      allAlternatives.clear();
      Set<String> uniqueCategories = {"Semua"};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        String altFood = data['makanan_alternatif'] ?? '';
        String origFood = data['makanan_asli'] ?? '';
        double savings =
            double.tryParse(data['hemat_natrium_mg'].toString()) ?? 0;

        String cat = altFood.isNotEmpty ? altFood : 'Lainnya';
        uniqueCategories.add(cat);

        allAlternatives.add(
          AlternativeFood(
            id: doc.id,
            category: cat,
            originalFood: origFood,
            originalSodium: savings,
            alternativeFood: altFood,
            alternativeSodium: 0,
            benefit:
                "Alternatif sehat ini dapat menghemat natrium sebanyak ${savings.toInt()} mg.",
          ),
        );
      }
      categories.assignAll(uniqueCategories.toList());
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = "Semua";
      }
    });
  }

  List<AlternativeFood> get filteredAlternatives {
    return allAlternatives.where((alt) {
      bool matchCategory =
          selectedCategory.value == "Semua" ||
          alt.category == selectedCategory.value;
      bool matchSearch =
          alt.originalFood.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          alt.alternativeFood.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
      return matchCategory && matchSearch;
    }).toList();
  }

  void selectAlternativeForCalculator(AlternativeFood food) {
    Get.snackbar(
      "Dihitung",
      "Memproyeksikan ${food.alternativeFood} ke dalam asupan harian...",
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }

  Future<void> addFood(String asli, String alternatif, double hemat) async {
    if (_katalogRef == null) return;
    
    try {
      await _katalogRef!.add({
        'makanan_asli': asli,
        'makanan_alternatif': alternatif,
        'hemat_natrium_mg': hemat,
      });
      Get.snackbar(
        'Sukses',
        'Data makanan berhasil ditambahkan',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan data: $e',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> updateFood(
    String id,
    String asli,
    String alternatif,
    double hemat,
  ) async {
    if (_katalogRef == null) return;
    
    try {
      await _katalogRef!.doc(id).update({
        'makanan_asli': asli,
        'makanan_alternatif': alternatif,
        'hemat_natrium_mg': hemat,
      });
      Get.snackbar(
        'Sukses',
        'Data makanan berhasil diperbarui',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui data: $e',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> deleteFood(String id) async {
    if (_katalogRef == null) return;
    
    try {
      await _katalogRef!.doc(id).delete();
      Get.snackbar(
        'Sukses',
        'Data makanan berhasil dihapus',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus data: $e',
        backgroundColor: Colors.white,
      );
    }
  }
}
