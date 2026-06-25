import 'package:get/get.dart';
import '../controllers/nakes_dashboard_controller.dart';
import '../../nakes_edukasi/controllers/nakes_edukasi_controller.dart';
import '../../nakes_catalog/controllers/nakes_catalog_controller.dart';
import '../../nakes_profile/controllers/nakes_profile_controller.dart';

class NakesDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NakesDashboardController>(() => NakesDashboardController());
    Get.lazyPut<NakesEdukasiController>(() => NakesEdukasiController());
    Get.lazyPut<NakesCatalogController>(() => NakesCatalogController());
    Get.lazyPut<NakesProfileController>(() => NakesProfileController());
  }
}
