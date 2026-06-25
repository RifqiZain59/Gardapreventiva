import 'package:get/get.dart';

import '../controllers/nakes_tentang_aplikasi_controller.dart';

class NakesTentangAplikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesTentangAplikasiController>(
      () => NakesTentangAplikasiController(),
    );
  }
}
