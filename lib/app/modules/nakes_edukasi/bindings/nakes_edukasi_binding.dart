import 'package:get/get.dart';
import '../controllers/nakes_edukasi_controller.dart';

class NakesEdukasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesEdukasiController>(() => NakesEdukasiController());
  }
}
