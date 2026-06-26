import 'package:get/get.dart';

import '../controllers/nakes_detail_pasien_gativa_controller.dart';

class NakesDetailPasienGativaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesDetailPasienGativaController>(
      () => NakesDetailPasienGativaController(),
    );
  }
}
