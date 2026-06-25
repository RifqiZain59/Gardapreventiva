import 'package:get/get.dart';
import '../controllers/catatan_nakes_controller.dart';

class CatatanNakesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatatanNakesController>(
      () => CatatanNakesController(),
    );
  }
}
