import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/support_ticket_model.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
class SupportController extends GetxController {
  final RxList<SupportTicket> tickets = <SupportTicket>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get(ApiEndpoints.supportTickets);
      
      if (response.isSuccess && response.data != null) {
        final dataMap = response.data as Map<String, dynamic>;
        if (dataMap['tickets'] != null) {
          final List<dynamic> ticketsList = dataMap['tickets'];
          tickets.value = ticketsList
              .map((json) => SupportTicket.fromJson(json))
              .toList();
        }
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets');
    } finally {
      isLoading.value = false;
    }
  }
}
