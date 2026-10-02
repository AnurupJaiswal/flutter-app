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
  final subjectController = TextEditingController();
  final settingsController = Get.find<SettingsController>();
  String selectedCategory = "OTHER";
  bool isLoading = false;
  final categoriesMap = {
    "OTHER": "General / Other",
    "BILLING_SUBSCRIPTION": "Billing & Subscription",
    "TECHNICAL_ISSUE": "Technical Issue",
    "ACCOUNT_SYNC": "Account Sync",
    "FEATURE_REQUEST": "Feature Request",
  };

  CW.showCustomBottomSheet(
    context: context,
    title: "Contact 24/7 Support",
    titleIcon: Icons.support_agent_rounded,
    children: [
      StatefulBuilder(
        builder: (context, setState) {
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
                height: 46, // Match the height of the commonTextFormField
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                decoration: BoxDecoration(
                  color: CC.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CC.stroke, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    isDense: true,
                    alignment: Alignment.centerLeft,
                    dropdownColor: CC.surface,
                    style: TS.body(color: CC.textPrimary),
                    items: categoriesMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
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
              Text("Subject", style: TS.bodySmall(color: CC.textPrimary)),
              4.height,
              CW.commonTextFormField(
                controller: subjectController,
                hintText: "Brief summary of your issue...",
              ),
              16.height,
              Text("Your Message", style: TS.bodySmall(color: CC.textPrimary)),
              4.height,
              CW.commonTextFormField(
                controller: msgController,
                hintText: "Describe your issue or question (min 10 chars)...",
              ),
              16.height,
              SizedBox(
                width: double.infinity,
                child: CW.commonBtn(
                  title: isLoading ? "Sending..." : "Send Message",
                  onTap: isLoading
                      ? () {}
                      : () async {
                          if (subjectController.text.trim().isEmpty) {
                            CM.showToast("Please enter a subject");
                            return;
                          }
                          if (msgController.text.trim().length < 10) {
                            CM.showToast("Please enter at least 10 characters for the message");
                            return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            // Wait for the controller method
                            bool success = await settingsController.createSupportTicket(
                              msgController.text.trim(), 
                              category: selectedCategory,
                              subject: subjectController.text.trim(),
                            );
                            if (success && context.mounted) {
                              Get.back(); // Auto-close bottom sheet on success
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
  ).then((_) {
    msgController.dispose();
    subjectController.dispose();
  });
}
