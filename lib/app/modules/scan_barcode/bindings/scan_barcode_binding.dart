import 'package:get/get.dart';
import '../controllers/scan_barcode_controller.dart';

class ScanBarcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanBarcodeController>(() => ScanBarcodeController());
  }
}
