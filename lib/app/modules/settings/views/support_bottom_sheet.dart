import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/app/modules/settings/controllers/settings_controller.dart';

void showContactSupportSheet(BuildContext context) {
  final msgController = TextEditingController();
  final settingsController = Get.find<SettingsController>();
  String selectedCategory = "GENERAL";
  final categories = ["GENERAL", "BILLING", "TECHNICAL", "FEATURE_REQUEST"];

  CW.showCustomBottomSheet(
    context: context,
    title: "Contact 24/7 Support",
    titleIcon: Icons.support_agent_rounded,
    children: [
      StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Our creator support team typically responds within 1 hour.",
                style: TS.caption(color: CC.textSecondary),
              ),
              12.height,
              Text("Category", style: TS.bodySmall(color: CC.textPrimary)),
              4.height,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CC.stroke),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    dropdownColor: CC.surface,
                    style: TS.body(color: CC.textPrimary),
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              16.height,
              CW.commonTextFormField(
                controller: msgController,
                hintText: "Describe your issue or question...",
                labelText: "Your Message",
                maxLines: 4,
              ),
              16.height,
              SizedBox(
                width: double.infinity,
                child: CW.commonBtn(
                  title: isLoading ? "Sending..." : "Send Message",
                  onTap: isLoading
                      ? () {}
                      : () async {
                          if (msgController.text.trim().isEmpty) {
                            CM.showToast("Please enter a message");
                            return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            // Wait for the controller method
                            await settingsController.createSupportTicket(msgController.text.trim());
                            if (context.mounted) {
                              CW.dismissBottomSheet();
                            }
                          } catch (e) {
                            // Ignore error for now
                          } finally {
                            if (context.mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                ),
              ),
            ],
          );
        },
      ),
    ],
  ).then((_) => msgController.dispose());
}
