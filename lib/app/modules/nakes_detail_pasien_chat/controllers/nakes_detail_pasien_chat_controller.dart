import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NakesDetailPasienChatController extends GetxController {
  final pasienData = {}.obs;

  late TextEditingController nameController;
  late TextEditingController tekananDarahController;
  late TextEditingController tinggiBadanController;
  late TextEditingController beratBadanController;
  late TextEditingController kondisiKesehatanController;
  late TextEditingController usiaController;
  final catatanList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final data = Get.arguments as Map<String, dynamic>?;
    if (data != null) {
      pasienData.value = data;
      _populateFields(data);
    } else {
      _populateFields({});
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    nameController = TextEditingController(text: data['name'] ?? data['nama'] ?? '');
    tekananDarahController = TextEditingController(text: data['tekanan_darah'] ?? '');
    tinggiBadanController = TextEditingController(text: (data['tinggi_badan'] ?? '').toString());
    beratBadanController = TextEditingController(text: (data['berat_badan'] ?? '').toString());
    kondisiKesehatanController = TextEditingController(text: data['kondisi_kesehatan'] ?? data['kondisi'] ?? '');
    usiaController = TextEditingController(text: (data['age'] ?? data['usia'] ?? '').toString());
    
    dynamic rawCatatan = data['catatan_nakes'];
    if (rawCatatan is List) {
      catatanList.value = List<String>.from(rawCatatan);
    } else if (rawCatatan is String && rawCatatan.isNotEmpty) {
      catatanList.value = [rawCatatan];
    } else {
      catatanList.clear();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    tekananDarahController.dispose();
    tinggiBadanController.dispose();
    beratBadanController.dispose();
    kondisiKesehatanController.dispose();
    usiaController.dispose();
    super.onClose();
  }
}
