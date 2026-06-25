import 'package:get/get.dart';

import '../controllers/nakes_detail_pasien_garda_controller.dart';

class NakesDetailPasienGardaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesDetailPasienGardaController>(
      () => NakesDetailPasienGardaController(),
    );
  }
}
