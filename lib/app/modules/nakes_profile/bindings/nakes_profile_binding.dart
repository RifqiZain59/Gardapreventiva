import 'package:get/get.dart';
import '../controllers/nakes_profile_controller.dart';

class NakesProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesProfileController>(() => NakesProfileController());
  }
}
