import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  final String? id;
  final String text;
  final bool isUser;
  final DateTime time;
  final String? senderName;
  final String? senderRole;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;

  // Live Chat Data
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  StreamSubscription<QuerySnapshot>? _chatSubscription;

  // List of doctors
  final doctors = <Map<String, dynamic>>[].obs;
  final isLoadingDoctors = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchDoctors();
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (selectedDoctor.value != null) {
      if (text.toLowerCase().contains('terima kasih')) {
        _sendToFirebase(text);
        exitChat();
        return;
      }
      _sendToFirebase(text);
    }
  }

  Future<void> _fetchDoctors() async {
    if (doctors.isNotEmpty) return;

    isLoadingDoctors.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('website')
          .get();

      print("DOKTER DEBUG: Found ${snapshot.docs.length} docs in website collection");
      
      final List<Map<String, dynamic>> tempDoctors = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final peran = (data['peran'] ?? '').toString().toLowerCase();
        if (peran == 'dokter') {
          tempDoctors.add({'id': doc.id, ...data});
        }
      }

      doctors.value = tempDoctors;
    } catch (e) {
      print("Error fetching doctors: $e");
    }
    isLoadingDoctors.value = false;
  }

  Future<void> openChatWithDoctor(Map<String, dynamic> doctor) async {
    selectedDoctor.value = doctor;
    messages.clear();
    _listenToFirebaseChat();
  }

  void exitChat() {
    _chatSubscription?.cancel();
    selectedDoctor.value = null;
    messages.clear();
  }

  Future<void> _sendToFirebase(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final userName = user?.displayName ?? 'Pasien';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    final messageData = {
      'text': text,
      'senderId': userId,
      'senderName': userName,
      'senderRole': 'pasien',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Simpan di sub-collection mobile
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .add(messageData);

      // Simpan di sub-collection website (untuk dokter)
      await FirebaseFirestore.instance
          .collection('website')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pesan: $e');
    }
  }

  void _listenToFirebaseChat() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    _chatSubscription?.cancel();

    final query = FirebaseFirestore.instance
        .collection('mobile')
        .doc(userId)
        .collection('chats')
        .doc(doctorId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    _chatSubscription = query.snapshots().listen((snapshot) {
      final List<ChatMessage> newMessages = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final text = data['text'] ?? '';
        final senderId = data['senderId'] ?? '';
        final isUser = senderId == userId;
        final ts = data['timestamp'] as Timestamp?;
        final time = ts?.toDate() ?? DateTime.now();
        final senderName = data['senderName'] ?? (isUser ? 'Pasien' : (selectedDoctor.value?['username'] ?? 'Dokter'));
        final senderRole = data['senderRole'] ?? (isUser ? 'pasien' : (selectedDoctor.value?['peran'] ?? 'dokter'));

        newMessages.add(
          ChatMessage(
            id: doc.id,
            text: text, 
            isUser: isUser, 
            time: time,
            senderName: senderName,
            senderRole: senderRole
          )
        );
      }
      
      // Tambahkan pesan sistem di bagian paling bawah (index paling akhir karena reverse list)
      final docName = selectedDoctor.value?['username'] ?? 'Dokter';
      newMessages.add(
        ChatMessage(
          id: 'system',
          text: "--- Anda terhubung dengan $docName ---",
          isUser: false,
          time: DateTime.now(),
          senderName: 'Sistem',
          senderRole: 'sistem',
        )
      );

      messages.value = newMessages;
    });
  }

  Future<void> deleteSingleMessage(String msgId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final doctorId = selectedDoctor.value?['id'];

    if (userId == null || doctorId == null || msgId == 'system') return;

    try {
      // Hapus dari sisi mobile
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .doc(msgId)
          .delete();

      // Hapus dari sisi website (opsional, tapi baik untuk konsistensi)
      await FirebaseFirestore.instance
          .collection('website')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .doc(msgId)
          .delete();

      Get.snackbar('Berhasil', 'Pesan berhasil dihapus', backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus pesan: $e');
    }
  }

  Future<void> deleteChat() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final doctorId = selectedDoctor.value?['id'];

    if (userId == null || doctorId == null) return;

    try {
      final messagesRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages');

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      messages.clear();
      final docName = selectedDoctor.value?['username'] ?? 'Dokter';
      messages.insert(
        0,
        ChatMessage(
          text: "--- Chat dengan $docName telah dihapus ---",
          isUser: false,
          time: DateTime.now(),
          senderName: 'Sistem',
          senderRole: 'sistem',
        ),
      );
      
      Get.snackbar('Berhasil', 'Chat berhasil dihapus', backgroundColor: Get.theme.primaryColor.withOpacity(0.1));
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus chat: $e');
    }
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    super.onClose();
  }
}
