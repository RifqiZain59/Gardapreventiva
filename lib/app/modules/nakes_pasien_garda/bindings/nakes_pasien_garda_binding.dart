import 'package:get/get.dart';

import '../controllers/nakes_pasien_garda_controller.dart';

class NakesPasienGardaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesPasienGardaController>(
      () => NakesPasienGardaController(),
    );
  }
}
