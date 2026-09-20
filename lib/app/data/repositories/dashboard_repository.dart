import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

class ChannelConnection {
  final dynamic id;
  final String platform;
  final String platformAccountName;
  final String status;
  final String? lastSyncedAt;

  ChannelConnection({
    required this.id,
    required this.platform,
    required this.platformAccountName,
    required this.status,
    this.lastSyncedAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isDisconnected => status.toUpperCase() == 'DISCONNECTED';
  bool get isReauthRequired =>
      status.toUpperCase() == 'REAUTH_REQUIRED' ||
      status.toUpperCase() == 'EXPIRED' ||
      status.toUpperCase() == 'AUTH_EXPIRED';

  factory ChannelConnection.fromJson(Map<String, dynamic> json) {
    return ChannelConnection(
      id: json['id'],
      platform: json['platform']?.toString().toUpperCase() ?? '',
      platformAccountName: json['platformAccountName']?.toString() ?? '',
      status: json['status']?.toString().toUpperCase() ?? 'ACTIVE',
      lastSyncedAt: json['lastSyncedAt']?.toString(),
    );
  }
}

class PlatformEntitlement {
  final int limit;
  final int connected;
  final int active;
  final int entitlementExceeded;
  final int remaining;

  PlatformEntitlement({
    this.limit = 1,
    this.connected = 0,
    this.active = 0,
    this.entitlementExceeded = 0,
    this.remaining = 1,
  });

  factory PlatformEntitlement.fromJson(Map<String, dynamic> json) {
    final limitVal = (json['limit'] as num?)?.toInt() ?? 1;
    final connectedVal = (json['connected'] as num?)?.toInt() ?? 0;
    final activeVal = (json['active'] as num?)?.toInt() ?? 0;
    final exceededVal = (json['entitlementExceeded'] as num?)?.toInt() ?? 0;
    final remainingVal = (json['remaining'] as num?)?.toInt() ??
        ((limitVal - activeVal) > 0 ? (limitVal - activeVal) : 0);

    return PlatformEntitlement(
      limit: limitVal,
      connected: connectedVal,
      active: activeVal,
      entitlementExceeded: exceededVal,
      remaining: remainingVal,
    );
  }
}

class ConnectionsResponseData {
  final List<ChannelConnection> connections;
  final Map<String, PlatformEntitlement> entitlements;

  ConnectionsResponseData({
    required this.connections,
    required this.entitlements,
  });

  factory ConnectionsResponseData.fromJson(Map<String, dynamic> json) {
    final list = json['connections'] is List ? json['connections'] as List : [];
    final entMap = <String, PlatformEntitlement>{};

    if (json['entitlements'] is Map) {
      final ents = json['entitlements'] as Map;
      for (final key in ents.keys) {
        if (ents[key] is Map) {
          entMap[key.toString().toLowerCase()] =
              PlatformEntitlement.fromJson(Map<String, dynamic>.from(ents[key] as Map));
        }
      }
    }

    return ConnectionsResponseData(
      connections: list
          .map((item) => ChannelConnection.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      entitlements: entMap,
    );
  }
}

class ChannelAuditData {
  final dynamic auditId;
  final dynamic connectedAccountId;
  final String platform;
  final int healthScore;
  final int engagementScore;
  final int consistencyScore;
  final int growthScore;
  final int reachScore;
  final String auditStatus;
  final String? dataAsOf;
  final String? lastRefreshAttempt;
  final Map<String, List<String>> swot;
  final List<Map<String, dynamic>> recommendations;

  ChannelAuditData({
    required this.auditId,
    required this.connectedAccountId,
    required this.platform,
    required this.healthScore,
    required this.engagementScore,
    required this.consistencyScore,
    required this.growthScore,
    required this.reachScore,
    required this.auditStatus,
    this.dataAsOf,
    this.lastRefreshAttempt,
    required this.swot,
    required this.recommendations,
  });

  factory ChannelAuditData.fromJson(Map<String, dynamic> json) {
    // Parse SWOT: Handles native Map (Milestone 2 unified schema) or JSON string
    Map<String, List<String>> parsedSwot = {
      "strengths": [],
      "weaknesses": [],
      "opportunities": [],
      "threats": [],
    };

    try {
      final rawSwot = json['swot'] ?? json['swotJson'];
      Map<String, dynamic>? swotMap;
      if (rawSwot is Map) {
        swotMap = Map<String, dynamic>.from(rawSwot);
      } else if (rawSwot is String && rawSwot.isNotEmpty) {
        swotMap = jsonDecode(rawSwot) as Map<String, dynamic>?;
      }

      if (swotMap != null) {
        for (final key in ['strengths', 'weaknesses', 'opportunities', 'threats']) {
          if (swotMap[key] is List) {
            parsedSwot[key] = (swotMap[key] as List).map((e) => e.toString()).toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing swot: $e");
    }

    // Parse Recommendations: Handles native List (Milestone 2 unified schema) or JSON string
    List<Map<String, dynamic>> parsedRecommendations = [];
    try {
      final rawRecs = json['recommendations'] ?? json['recommendationsJson'];
      dynamic recsList;
      if (rawRecs is List) {
        recsList = rawRecs;
      } else if (rawRecs is String && rawRecs.isNotEmpty) {
        recsList = jsonDecode(rawRecs);
      }

      if (recsList is List) {
        parsedRecommendations = recsList.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return {
            'title': item.toString(),
            'priority': 'ORANGE',
            'expectedOutcome': '',
            'tag': 'Growth',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint("Error parsing recommendations: $e");
    }

    return ChannelAuditData(
      auditId: json['auditId'],
      connectedAccountId: json['connectedAccountId'],
      platform: json['platform']?.toString() ?? 'YOUTUBE',
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 0,
      engagementScore: (json['engagementScore'] as num?)?.toInt() ?? 0,
      consistencyScore: (json['consistencyScore'] as num?)?.toInt() ?? 0,
      growthScore: (json['growthScore'] as num?)?.toInt() ?? 0,
      reachScore: (json['reachScore'] as num?)?.toInt() ?? 0,
      auditStatus: json['auditStatus']?.toString() ?? 'FRESH',
      dataAsOf: json['dataAsOf']?.toString(),
      lastRefreshAttempt: json['lastRefreshAttempt']?.toString(),
      swot: parsedSwot,
      recommendations: parsedRecommendations,
    );
  }
}

class TodoItemModel {
  final dynamic id;
  final dynamic connectedAccountId;
  final dynamic channelAuditId;
  final String title;
  final String? subtitle;
  final String? details;
  final String priority;
  final String tag;
  final String expectedOutcome;
  final bool isDone;
  final String? dueDate;
  final String? createdAt;

  TodoItemModel({
    required this.id,
    this.connectedAccountId,
    this.channelAuditId,
    required this.title,
    this.subtitle,
    this.details,
    this.priority = 'ORANGE',
    this.tag = 'General',
    this.expectedOutcome = '',
    this.isDone = false,
    this.dueDate,
    this.createdAt,
  });

  factory TodoItemModel.fromJson(Map<String, dynamic> json) {
    return TodoItemModel(
      id: json['id'] ?? json['todoId'],
      connectedAccountId: json['connectedAccountId'],
      channelAuditId: json['channelAuditId'],
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      details: json['details']?.toString(),
      priority: json['priority']?.toString().toUpperCase() ?? 'ORANGE',
      tag: json['tag']?.toString() ?? 'General',
      expectedOutcome: json['expectedOutcome']?.toString() ?? '',
      isDone: json['isDone'] == true,
      dueDate: json['dueDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

abstract class DashboardRepository {
  Future<List<ChannelConnection>> getConnectedChannels();
  Future<ConnectionsResponseData?> getConnectionsWithEntitlements();
  Future<ChannelAuditData?> getDashboardOverview(dynamic connectedAccountId);
  Future<bool> triggerAudit(dynamic connectedAccountId);
  Future<List<TodoItemModel>> getTodos({dynamic connectedAccountId});
  Future<bool> convertRecommendationToTodo({
    required dynamic connectedAccountId,
    required dynamic channelAuditId,
    required String title,
    required String priority,
    required String expectedOutcome,
  });
  Future<bool> updateTodoStatus(dynamic todoId, bool isDone);
  Future<bool> deleteTodo(dynamic todoId);
}

class ApiDashboardRepository implements DashboardRepository {
  @override
  Future<List<ChannelConnection>> getConnectedChannels() async {
    try {
      final response = await ApiService.get(ApiEndpoints.creatorConnections);
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        final list = data is Map && data['connections'] is List
            ? data['connections'] as List
            : (data is List ? data : []);
        return list
            .map((item) => ChannelConnection.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint("getConnectedChannels error: $e");
    }
    return [];
  }

  @override
  Future<ConnectionsResponseData?> getConnectionsWithEntitlements() async {
    try {
      final response = await ApiService.get(ApiEndpoints.creatorConnections);
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        if (data is Map) {
          return ConnectionsResponseData.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint("getConnectionsWithEntitlements error: $e");
    }
    return null;
  }

  @override
  Future<ChannelAuditData?> getDashboardOverview(dynamic connectedAccountId) async {
    try {
      final response = await ApiService.get(ApiEndpoints.dashboardOverview(connectedAccountId));
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        if (data is Map) {
          // Check if payload has { status: "SUCCESS", audit: { ... } }
          if (data['status'] == 'SUCCESS' && data['audit'] is Map) {
            return ChannelAuditData.fromJson(Map<String, dynamic>.from(data['audit'] as Map));
          } else if (data['auditId'] != null) {
            return ChannelAuditData.fromJson(Map<String, dynamic>.from(data));
          }
        }
      }
    } catch (e) {
      debugPrint("getDashboardOverview error: $e");
    }
    return null;
  }

  @override
  Future<bool> triggerAudit(dynamic connectedAccountId) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.dashboardAudit,
        body: {'connectedAccountId': connectedAccountId},
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint("triggerAudit error: $e");
      return false;
    }
  }

  @override
  Future<List<TodoItemModel>> getTodos({dynamic connectedAccountId}) async {
    try {
      final response = await ApiService.get(ApiEndpoints.dashboardTodos(connectedAccountId));
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        List rawTodos = [];
        if (data is Map && data['todos'] is List) {
          rawTodos = data['todos'] as List;
        } else if (data is List) {
          rawTodos = data;
        }
        return rawTodos
            .map((item) => TodoItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint("getTodos error: $e");
    }
    return [];
  }

  @override
  Future<bool> convertRecommendationToTodo({
    required dynamic connectedAccountId,
    required dynamic channelAuditId,
    required String title,
    required String priority,
    required String expectedOutcome,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.dashboardTodosConvert,
        body: {
          'connectedAccountId': connectedAccountId,
          'channelAuditId': channelAuditId,
          'title': title,
          'priority': priority,
          'expectedOutcome': expectedOutcome,
        },
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint("convertRecommendationToTodo error: $e");
      return false;
    }
  }

  @override
  Future<bool> updateTodoStatus(dynamic todoId, bool isDone) async {
    try {
      final response = await ApiService.put(
        ApiEndpoints.dashboardTodoUpdate(todoId),
        body: {'isDone': isDone},
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint("updateTodoStatus error: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteTodo(dynamic todoId) async {
    try {
      final response = await ApiService.delete(
        ApiEndpoints.dashboardTodoDelete(todoId),
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint("deleteTodo error: $e");
      return false;
    }
  }
}
