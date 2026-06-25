import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  void _startSplash() async {
    // Mulai timer 2 detik (sesuai durasi animasi)
    final stopwatch = Stopwatch()..start();

    User? user = FirebaseAuth.instance.currentUser;
    String nextRoute = Routes.ONBOARDING;

    if (user != null && user.emailVerified) {
      // Sesuai permintaan: jika sudah login, ke halaman login dulu (jangan loncat langsung ke utama)
      nextRoute = Routes.LOGIN;
    } else if (user != null && !user.emailVerified) {
      // Jika belum verifikasi email, arahkan ke login agar bisa masuk dan verifikasi
      nextRoute = Routes.LOGIN;
    }

    stopwatch.stop();
    // Jika proses fetch lebih cepat dari 2.5 detik, tunggu sisanya agar animasi selesai
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 2500) {
      await Future.delayed(Duration(milliseconds: 2500 - elapsed));
    }

    Get.offAllNamed(nextRoute);
  }
}
