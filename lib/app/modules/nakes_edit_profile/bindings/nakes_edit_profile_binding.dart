import 'package:get/get.dart';

import '../controllers/nakes_edit_profile_controller.dart';

class NakesEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesEditProfileController>(() => NakesEditProfileController());
  }
}
