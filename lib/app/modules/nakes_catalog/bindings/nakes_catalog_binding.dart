import 'package:get/get.dart';
import '../controllers/nakes_catalog_controller.dart';

class NakesCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesCatalogController>(() => NakesCatalogController());
  }
}
