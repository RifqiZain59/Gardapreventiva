import 'package:get/get.dart';

import '../controllers/nakes_bantuan_faq_controller.dart';

class NakesBantuanFaqBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesBantuanFaqController>(
      () => NakesBantuanFaqController(),
    );
  }
}
