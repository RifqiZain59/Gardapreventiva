import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/nakes_dashboard_controller.dart';
import '../../../routes/app_pages.dart';
import '../../nakes_edukasi/views/nakes_edukasi_view.dart';
import '../../nakes_catalog/views/nakes_catalog_view.dart';
import '../../nakes_profile/views/nakes_profile_view.dart';

class NakesDashboardView extends GetView<NakesDashboardController> {
  const NakesDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Obx(
        () => Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              _buildDashboardTab(),
              const NakesEdukasiView(),
              const NakesCatalogView(),
              const NakesProfileView(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF2E7D32),
              unselectedItemColor: Colors.grey.shade400,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.health_and_safety_rounded),
                  label: 'Edukasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Katalog',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [_buildPatientComplianceStats(), _buildGridMenu()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        // Kotak tidak melengkung di bawah sesuai permintaan
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.health_and_safety,
              size: 140,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Halo,',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.nakesName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Selamat Bertugas',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    backgroundImage: controller.photoBase64.value.isNotEmpty
                        ? MemoryImage(const Base64Decoder().convert(controller.photoBase64.value))
                        : null,
                    child: controller.photoBase64.value.isEmpty 
                        ? const Icon(Icons.person, color: Colors.white, size: 32)
                        : null,
                  )),
                ],
              ),
              const SizedBox(height: 32),
              // Kotak Info Total Pasien
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pasien GARDA',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.isLoading.value
                                ? '...'
                                : '${controller.totalPatients.value} Orang',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientComplianceStats() {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.bar_chart_rounded,
              size: 120,
              color: Colors.black.withOpacity(0.03),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final int patuh = controller.patuhCount.value;
                final int kurang = controller.kurangPatuhCount.value;
                final int bahaya = controller.tidakPatuhCount.value;
                final int total = patuh + kurang + bahaya;

                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Visual Grafik Donut
                    SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: CustomPaint(
                                painter: DonutChartPainter(
                                  patuh: patuh,
                                  kurang: kurang,
                                  bahaya: bahaya,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$total',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  'Pasien',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Keterangan Legend
                    _buildLegendItem(
                      color: const Color(0xFF4CAF50),
                      title: 'Patuh (Aman)',
                      count: patuh,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: const Color(0xFFFF9800),
                      title: 'Kurang Patuh (Peringatan)',
                      count: kurang,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: const Color(0xFFF44336),
                      title: 'Tidak Patuh (Bahaya)',
                      count: bahaya,
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required int count,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        Text(
          '$count Pasien',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGridMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Live Chat',
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFF4CAF50),
        'route': Routes.NAKES_CHAT,
      },
      {
        'title': 'Informasi Kesehatan',
        'icon': Icons.medical_information_rounded,
        'color': const Color(0xFFFF9800),
        'route': Routes.NAKES_INFORMASI_KESEHATAN,
      },
      {
        'title': 'Pasien',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF2196F3),
        'route': Routes.NAKES_PASIEN_GARDA,
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuCard(
          title: item['title'],
          iconData: item['icon'],
          color: item['color'],
          onTap: () {
            if (item['route'] != null) {
              Get.toNamed(item['route']);
            } else {
              Get.snackbar(
                'Segera Hadir',
                'Fitur ${item['title']} sedang dalam pengembangan',
                backgroundColor: Colors.white,
                colorText: Colors.black,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData iconData,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(iconData, size: 100, color: color.withOpacity(0.1)),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: color, size: 28),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int patuh;
  final int kurang;
  final int bahaya;

  DonutChartPainter({
    required this.patuh,
    required this.kurang,
    required this.bahaya,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = (patuh + kurang + bahaya).toDouble();
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    if (total == 0) {
      paint.color = Colors.grey.shade200;
      canvas.drawArc(rect, 0, 3.1415926535897932 * 2, false, paint);
      return;
    }

    double startAngle = -3.1415926535897932 / 2; // Start from top
    final double sweepPatuh = (patuh / total) * 2 * 3.1415926535897932;
    final double sweepKurang = (kurang / total) * 2 * 3.1415926535897932;
    final double sweepBahaya = (bahaya / total) * 2 * 3.1415926535897932;

    const double gap = 0.1; // Small gap between segments

    if (patuh > 0) {
      paint.color = const Color(0xFF4CAF50);
      canvas.drawArc(
        rect,
        startAngle,
        sweepPatuh - (total > patuh ? gap : 0),
        false,
        paint,
      );
      startAngle += sweepPatuh;
    }

    if (kurang > 0) {
      paint.color = const Color(0xFFFF9800);
      canvas.drawArc(
        rect,
        startAngle,
        sweepKurang - (total > kurang ? gap : 0),
        false,
        paint,
      );
      startAngle += sweepKurang;
    }

    if (bahaya > 0) {
      paint.color = const Color(0xFFF44336);
      canvas.drawArc(
        rect,
        startAngle,
        sweepBahaya - (total > bahaya ? gap : 0),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
