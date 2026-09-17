class SubscriptionModel {
  final String? planTier;
  final String? status;
  final String? billingDuration;
  final String? currentPeriodEnd;
  final int maxYoutubeAccounts;
  final int maxInstagramAccounts;

  SubscriptionModel({
    this.planTier,
    this.status,
    this.billingDuration,
    this.currentPeriodEnd,
    this.maxYoutubeAccounts = 0,
    this.maxInstagramAccounts = 0,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      planTier: json['planTier']?.toString(),
      status: json['status']?.toString(),
      billingDuration: json['billingDuration']?.toString(),
      currentPeriodEnd: json['currentPeriodEnd']?.toString(),
      maxYoutubeAccounts: int.tryParse(json['maxYoutubeAccounts']?.toString() ?? '0') ?? 0,
      maxInstagramAccounts: int.tryParse(json['maxInstagramAccounts']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planTier': planTier,
      'status': status,
      'billingDuration': billingDuration,
      'currentPeriodEnd': currentPeriodEnd,
      'maxYoutubeAccounts': maxYoutubeAccounts,
      'maxInstagramAccounts': maxInstagramAccounts,
    };
  }
}

