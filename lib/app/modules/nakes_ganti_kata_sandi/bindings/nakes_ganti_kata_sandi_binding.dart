import 'package:get/get.dart';
import '../controllers/nakes_ganti_kata_sandi_controller.dart';

class NakesGantiKataSandiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesGantiKataSandiController>(
      () => NakesGantiKataSandiController(),
    );
  }
}
