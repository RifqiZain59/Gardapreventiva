import 'package:get/get.dart';

import '../controllers/nakes_detail_pasien_chat_controller.dart';

class NakesDetailPasienChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesDetailPasienChatController>(
      () => NakesDetailPasienChatController(),
    );
  }
}
