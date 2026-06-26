import 'package:get/get.dart';

import '../controllers/nakes_pasien_gativa_controller.dart';

class NakesPasienGativaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesPasienGativaController>(
      () => NakesPasienGativaController(),
    );
  }
}
