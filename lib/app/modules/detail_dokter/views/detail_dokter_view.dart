import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_dokter_controller.dart';

class DetailDokterView extends GetView<DetailDokterController> {
  const DetailDokterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna background modern
      appBar: AppBar(
        title: const Text('Detail Konsultan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Watermark Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: const Icon(
                Icons.medical_services_rounded,
                size: 250,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
            }

            final data = controller.doctorData;
            if (data.isEmpty) {
              return const Center(
                child: Text(
                  "Detail dokter tidak ditemukan", 
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04), 
                          blurRadius: 20, 
                          offset: const Offset(0, 5)
                        )
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.medical_information_rounded, size: 50, color: Color(0xFF2E7D32)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nama Dokter
                        Text(
                          data['username'] ?? 'Nama Dokter',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF1E293B)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // Badge Spesialisasi/Garda
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 16),
                              SizedBox(width: 6),
                              Text(
                                "Konsultan Resmi Garda", 
                                style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // List Info
                        _buildInfoRow(Icons.work_history_rounded, "Spesialisasi", data['spesialisasi'] ?? 'Ahli Gizi & Pola Makan'),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
                        
                        _buildInfoRow(Icons.school_rounded, "Lulusan", data['lulusan'] ?? 'Fakultas Kedokteran Terkemuka'),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
                        
                        _buildInfoRow(Icons.star_rounded, "Pengalaman", "${data['pengalaman'] ?? '5'} Tahun Praktik"),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
                        
                        _buildInfoRow(Icons.people_alt_rounded, "Total Pasien", "${data['total_pasien'] ?? '100+'} Pasien Terbantu"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Slate 100
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value, 
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        )
      ],
    );
  }
}
