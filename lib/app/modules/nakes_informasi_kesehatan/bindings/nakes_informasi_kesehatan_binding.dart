import 'package:get/get.dart';
import '../controllers/nakes_informasi_kesehatan_controller.dart';

class NakesInformasiKesehatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesInformasiKesehatanController>(
      () => NakesInformasiKesehatanController(),
    );
  }
}
