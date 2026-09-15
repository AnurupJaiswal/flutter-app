class SubscriptionModel {
  final String? planTier;
  final String? status;
  final int maxYoutubeAccounts;
  final int maxInstagramAccounts;

  SubscriptionModel({
    this.planTier,
    this.status,
    this.maxYoutubeAccounts = 0,
    this.maxInstagramAccounts = 0,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      planTier: json['planTier']?.toString(),
      status: json['status']?.toString(),
      maxYoutubeAccounts: int.tryParse(json['maxYoutubeAccounts']?.toString() ?? '0') ?? 0,
      maxInstagramAccounts: int.tryParse(json['maxInstagramAccounts']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planTier': planTier,
      'status': status,
      'maxYoutubeAccounts': maxYoutubeAccounts,
      'maxInstagramAccounts': maxInstagramAccounts,
    };
  }
}
