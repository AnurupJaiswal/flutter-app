import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/support_ticket_model.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/utils/common_methods.dart';

class SupportTicketDetailController extends GetxController {
  final String ticketId;
  final Rx<SupportTicketDetail?> ticketDetail = Rx<SupportTicketDetail?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  
  final TextEditingController messageController = TextEditingController();

  SupportTicketDetailController(this.ticketId);

  @override
  void onInit() {
    super.onInit();
    fetchTicketDetail();
  }

  Future<void> fetchTicketDetail() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get(ApiEndpoints.supportTicketDetail(ticketId));
      if (response.isSuccess && response.data != null) {
        ticketDetail.value = SupportTicketDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch ticket details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      isSending.value = true;
      final response = await ApiService.post(
        ApiEndpoints.supportTicketReply(ticketId),
        body: {'message': text},
      );

      if (response.isSuccess) {
        messageController.clear();
        // Locally append the message instead of making another API call
        if (ticketDetail.value != null) {
          final newMessage = SupportTicketMessage(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            senderType: 'USER',
            senderName: 'You',
            message: text,
            createdAt: DateTime.now(),
          );
          ticketDetail.value!.messages.add(newMessage);
          ticketDetail.refresh();
        }
      } else {
        CM.showToast(response.message);
      }
    } catch (e) {
      CM.showToast("Failed to send message.");
    } finally {
      isSending.value = false;
    }
  }
}
