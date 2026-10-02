import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/app/data/models/support_ticket_model.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import '../controllers/support_ticket_detail_controller.dart';
import 'package:lala_ai/utils/common_methods.dart';

class SupportTicketDetailView extends StatelessWidget {
  final String ticketId;

  const SupportTicketDetailView({Key? key, required this.ticketId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller for this specific ticket ID
    final controller = Get.put(SupportTicketDetailController(ticketId), tag: ticketId);

    return Scaffold(
      backgroundColor: CC.background,
      appBar: AppBar(
        title: const Text('Ticket Thread'),
        centerTitle: true,
        backgroundColor: CC.surface,
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final detail = controller.ticketDetail.value;
        if (detail == null) {
          return const Center(child: Text("Could not load ticket details."));
        }

        return Column(
          children: [
            _buildTicketHeader(detail),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: false, // Show oldest first (top to bottom)
                itemCount: detail.messages.length,
                itemBuilder: (context, index) {
                  final msg = detail.messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
            if (detail.status.toUpperCase() != 'CLOSED') _buildMessageInput(controller),
          ],
        );
      }),
    );
  }

  Widget _buildTicketHeader(SupportTicketDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: CC.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detail.subject,
                  style: TS.headingMedium(fontWeight: FontWeight.bold),
                ),
              ),
              _buildStatusBadge(detail.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Category: ${CM.formatEnum(detail.category)}",
            style: TS.bodySmall(color: CC.grey),
          ),
          const SizedBox(height: 4),
          Text(
            "Ticket ID: ${detail.ticketId}",
            style: TS.bodySmall(color: CC.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportTicketMessage msg) {
    bool isUser = msg.senderType == 'USER';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? CC.primary : (CC.isDark ? CC.darkMessageSender : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Text(
                msg.senderName,
                style: TS.bodySmall(fontWeight: FontWeight.bold, color: CC.grey),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              msg.message,
              style: TS.bodyMedium(color: isUser ? CC.whiteText : CC.textPrimary),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('MMM d, h:mm a').format(msg.createdAt.toLocal()),
                style: TS.bodySmall(
                  color: (isUser ? CC.whiteText : CC.grey).withOpacity(0.7),
                ).copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(SupportTicketDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CC.surface,
        border: Border(top: BorderSide(color: CC.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: "Type a reply...",
                hintStyle: TextStyle(color: CC.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: CC.borderSubtle),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            return FloatingActionButton(
              mini: true,
              backgroundColor: CC.primary,
              elevation: 0,
              onPressed: controller.isSending.value ? null : controller.sendMessage,
              child: controller.isSending.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'IN_PROGRESS':
        color = Colors.blue;
        break;
      case 'RESOLVED':
        color = Colors.green;
        break;
      case 'CLOSED':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        CM.formatEnum(status).toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
