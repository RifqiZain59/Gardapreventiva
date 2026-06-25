import 'package:get/get.dart';
import '../controllers/nakes_chat_controller.dart';

class NakesChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesChatController>(() => NakesChatController());
  }
}
