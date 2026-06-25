import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna background modern yang sangat soft

      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: Obx(() {
        if (controller.selectedDoctor.value == null) {
          // TAMPILAN DAFTAR DOKTER (List Mode)
          return _buildDoctorList();
        } else {
          // TAMPILAN RUANG OBROLAN (Chat Mode)
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Watermark Background
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: 0.04,
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: 250,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ListView.builder(
                        shrinkWrap: true,
                        reverse: true, // Auto-scroll ke bawah
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        return _ChatBubble(
                          id: msg.id,
                          text: msg.text,
                          isUser: msg.isUser,
                          senderName: msg.senderName,
                          senderRole: msg.senderRole,
                          time: msg.time,
                        );
                      },
                    ),
                  ),
                ),
                  // Input Area
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        )
                      ]
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9), // Abu-abu terang untuk input
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: TextField(
                                  controller: textController,
                                  maxLines: 4,
                                  minLines: 1,
                                  textInputAction: TextInputAction.send,
                                  decoration: const InputDecoration(
                                    hintText: "Ketik pesan Anda...",
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                                  ),
                                  onSubmitted: (val) {
                                    controller.sendMessage(val);
                                    textController.clear();
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              if (textController.text.trim().isNotEmpty) {
                                controller.sendMessage(textController.text);
                                textController.clear();
                              }
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ],
          );
        }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.medical_services_rounded,
                size: 130,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Row(
            children: [
              Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () {
                      if (controller.selectedDoctor.value != null) {
                        controller.exitChat();
                      } else {
                        Get.back();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  if (controller.selectedDoctor.value != null) {
                    final doc = controller.selectedDoctor.value!;
                    final docName = doc['name'] ?? 'Dokter';
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.DETAIL_DOKTER, arguments: doc);
                      },
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final photoBase64 = doc['photoBase64'] ?? doc['strImageBase64'] ?? '';
                              return CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white24,
                                backgroundImage: photoBase64.isNotEmpty ? MemoryImage(const Base64Decoder().convert(photoBase64)) : null,
                                child: photoBase64.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                              );
                            }
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final String jadwalOnline = doc['jadwal_online'] ?? '';
                                bool isOnline = false;
                                try {
                                  final parts = jadwalOnline.split('-');
                                  if (parts.length == 2) {
                                    final startParts = parts[0].trim().split(':');
                                    final endParts = parts[1].trim().split(':');
                                    if (startParts.length == 2 && endParts.length == 2) {
                                      final now = DateTime.now();
                                      final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
                                      final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
                                      isOnline = now.isAfter(startTime) && now.isBefore(endTime);
                                    }
                                  }
                                } catch (_) {}
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      docName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      isOnline ? 'Online' : 'Offline', 
                                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: isOnline ? Colors.white70 : Colors.red.shade200)
                                    ),
                                  ],
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Row(
                    children: [
                      Text('Pilih Konsultan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                    ],
                  );
                }),
              ),
              Obx(() {
                if (controller.selectedDoctor.value != null) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteChatDialog();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus Chat', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.delete_sweep_rounded, size: 140, color: Colors.red.shade900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Hapus Semua Chat?", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Apakah Anda yakin ingin menghapus seluruh riwayat chat ini? Tindakan ini tidak dapat dibatalkan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey.shade300)
                            ),
                            onPressed: () => Get.back(),
                            child: const Text("Batal", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.back();
                              controller.deleteChat();
                            },
                            child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildDoctorList() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }

    if (controller.nakesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Belum ada konsultan yang tersedia",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.nakesList.length,
      itemBuilder: (context, index) {
        final doc = controller.nakesList[index];
        final name = doc['name'] ?? 'Konsultan';
        final int antreanCount = int.tryParse(doc['antrean']?.toString() ?? '0') ?? 0;
        final photoBase64 = doc['photoBase64'] ?? doc['strImageBase64'] ?? '';
        final String jadwalOnline = doc['jadwal_online'] ?? 'Tidak ada jadwal';
        bool isOnline = false;
        try {
          final parts = jadwalOnline.split('-');
          if (parts.length == 2) {
            final startParts = parts[0].trim().split(':');
            final endParts = parts[1].trim().split(':');
            if (startParts.length == 2 && endParts.length == 2) {
              final now = DateTime.now();
              final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
              final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
              isOnline = now.isAfter(startTime) && now.isBefore(endTime);
            }
          }
        } catch (_) {}

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.openChatWithDoctor(doc),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.05,
                        child: Icon(
                          Icons.local_hospital_rounded,
                          size: 110,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          photoBase64.isNotEmpty
                              ? CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.white,
                                  backgroundImage: MemoryImage(const Base64Decoder().convert(photoBase64)),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.medical_information_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 28,
                                  ),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isOnline ? Colors.green : Colors.red.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        isOnline ? 'Online' : 'Offline',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isOnline ? Colors.green : Colors.red.shade400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (antreanCount > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.people_alt_rounded, size: 14, color: Colors.orange.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Antrean: $antreanCount",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String? id;
  final String text;
  final bool isUser;
  final String? senderName;
  final String? senderRole;
  final DateTime time;

  const _ChatBubble({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
  });

  void _showDeleteDialog(BuildContext context, ChatController controller) {
    if (id == null || id == 'system') return;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.04,
                  child: Icon(Icons.delete_sweep_rounded, size: 120, color: Colors.red.shade900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Hapus Pesan?", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Apakah Anda yakin ingin menghapus pesan ini?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(color: Colors.grey.shade300)
                            ),
                            onPressed: () => Get.back(),
                            child: const Text("Batal", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.back();
                              if (id != null) {
                                controller.deleteSingleMessage(id!);
                              }
                            },
                            child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu
    String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    final controller = Get.find<ChatController>();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isUser ? () => _showDeleteDialog(context, controller) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75, // Maksimal lebar chat 75%
          ),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Nama pengirim untuk dokter
              if (!isUser && senderName != null && senderRole != 'sistem')
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    "$senderName (${senderRole?.toUpperCase() ?? ''})",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                
              // Bubble Chat
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF2E7D32) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4), // Lebih lancip di bawah
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: isUser ? null : Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : Colors.grey.shade500,
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all, size: 12, color: Colors.white70),
                        ]
                      ],
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
