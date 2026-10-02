import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/support_controller.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/app/modules/settings/views/support_bottom_sheet.dart';
import 'package:lala_ai/app/modules/support/views/support_ticket_detail_view.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/common_methods.dart';

class SupportListView extends GetView<SupportController> {
  const SupportListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If controller is not initialized yet in binding, initialize it here
    Get.put(SupportController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Center'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open the existing bottom sheet to create a new ticket
          showContactSupportSheet(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tickets.isEmpty) {
          return const Center(
            child: Text("You have no support tickets."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.tickets.length,
          itemBuilder: (context, index) {
            final ticket = controller.tickets[index];
            return GestureDetector(
              onTap: () {
                Get.to(() => SupportTicketDetailView(ticketId: ticket.ticketId));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CC.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CC.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ticket.subject,
                            style: TS.bodySmall(color: CC.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStatusBadge(ticket.status),
                            if (ticket.unreadReplies > 0) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CC.notification,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${ticket.unreadReplies} New",
                                  style: TS.bodySmall(
                                    color: CC.whiteText,
                                  ).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.category_outlined, size: 16, color: CC.grey),
                        const SizedBox(width: 6),
                        Text(
                          CM.formatEnum(ticket.category),
                          style: TS.bodyMedium(color: CC.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: CC.grey),
                        const SizedBox(width: 6),
                        Text(
                          "Updated ${DateFormat.yMMMd().format(ticket.lastUpdatedAt)}",
                          style: TS.bodySmall(color: CC.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        CM.formatEnum(status).toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
