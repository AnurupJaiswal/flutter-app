# LALA-AI — Category & Niche API Specification
**Version:** `1.0.0`  
**Base URL:** `https://api.lala-ai.com/api/v1`  
**Content-Type:** `application/json`  
**Authorization:** `Bearer <JWT_ACCESS_TOKEN>`

---

## 1. Overview & Architecture

This document defines the complete backend API specification for **Category Management** and **Category AI Insights** used throughout the LALA-AI Flutter application.

### Connected App Modules:
1. **Discover / Category Insights Screen** (`lib/app/modules/category_insights/`)
   - Category switcher tabs (e.g. *Fashion, Beauty, Lifestyle, Tech, Gaming...*)
   - Real-time breakout trends, popular themes, and shared category intelligence.
   - Category management modal (add/remove active categories for quick switching).
2. **Profile & Onboarding Niche Selection** (`lib/app/modules/profile/`, `lib/app/data/models/content_niche_model.dart`)
   - Searchable single-select primary niche / master categories picker.

---

## 2. Standard API Response Structure

All responses conform to the standard JSON envelope:

```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": {},
  "meta": {
    "timestamp": "2026-09-20T15:20:00.000Z",
    "requestId": "req_cat_9812739182"
  }
}
```

---

## 3. Endpoints Summary

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| **GET** | `/categories` | Fetch all master categories available on platform | Yes (Bearer) |
| **GET** | `/creators/me/categories` | Get creator's saved active categories | Yes (Bearer) |
| **PUT** | `/creators/me/categories` | Update/save creator's managed category list | Yes (Bearer) |
| **GET** | `/categories/insights` | Get real-time AI insights & trending topics for a specific category | Yes (Bearer) |

---

## 4. API Endpoints Specification

### 4.1. Get Master Categories List
`GET /categories`

Retrieves the platform-wide master list of content categories and niches. Used for category selection, onboarding, search filters, and "Manage Categories" configuration.

#### Query Parameters:
| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `search` | `string` | Optional | `""` | Filter categories by name (case-insensitive substring) |
| `isPopular` | `boolean` | Optional | `null` | Filter only trending/popular categories |
| `limit` | `integer` | Optional | `50` | Number of items to return |

#### Request Headers:
```http
GET /api/v1/categories?search=tech HTTP/1.1
Host: api.lala-ai.com
Authorization: Bearer eyJhbGciOi...
Accept: application/json
```

#### Success Response (`200 OK`):
```json
{
  "status": "success",
  "message": "Categories fetched successfully",
  "data": {
    "categories": [
      {
        "id": "cat_tech_001",
        "slug": "tech",
        "name": "Tech",
        "isPopular": true,
        "totalCreators": 14200
      },
      {
        "id": "cat_gaming_002",
        "slug": "gaming",
        "name": "Gaming",
        "isPopular": true,
        "totalCreators": 28400
      },
      {
        "id": "cat_fashion_003",
        "slug": "fashion",
        "name": "Fashion",
        "isPopular": true,
        "totalCreators": 19500
      },
      {
        "id": "cat_beauty_004",
        "slug": "beauty",
        "name": "Beauty",
        "isPopular": true,
        "totalCreators": 16200
      },
      {
        "id": "cat_lifestyle_005",
        "slug": "lifestyle",
        "name": "Lifestyle",
        "isPopular": true,
        "totalCreators": 22100
      },
      {
        "id": "cat_fitness_006",
        "slug": "fitness-health",
        "name": "Fitness & Health",
        "isPopular": false,
        "totalCreators": 11300
      },
      {
        "id": "cat_travel_007",
        "slug": "travel-vlogs",
        "name": "Travel & Vlogs",
        "isPopular": false,
        "totalCreators": 9800
      },
      {
        "id": "cat_food_008",
        "slug": "food-cooking",
        "name": "Food & Cooking",
        "isPopular": false,
        "totalCreators": 13400
      },
      {
        "id": "cat_finance_009",
        "slug": "finance-business",
        "name": "Finance & Business",
        "isPopular": false,
        "totalCreators": 8700
      },
      {
        "id": "cat_ent_010",
        "slug": "entertainment",
        "name": "Entertainment",
        "isPopular": true,
        "totalCreators": 31000
      }
    ],
    "total": 10
  },
  "meta": {
    "timestamp": "2026-09-20T15:20:00.000Z",
    "requestId": "req_cat_01"
  }
}
```

---

### 4.2. Get Creator's Saved Categories
`GET /creators/me/categories`

Retrieves the authenticated creator's pinned/active categories list that populates their horizontal category bar in Discover / Category Insights.

#### Request Headers:
```http
GET /api/v1/creators/me/categories HTTP/1.1
Host: api.lala-ai.com
Authorization: Bearer eyJhbGciOi...
Accept: application/json
```

#### Success Response (`200 OK`):
```json
{
  "status": "success",
  "message": "User categories retrieved successfully",
  "data": {
    "selectedCategories": [
      "Fashion",
      "Beauty",
      "Lifestyle",
      "Tech",
      "Gaming"
    ],
    "maxAllowed": 10,
    "lastConfiguredAt": "2026-09-18T10:14:22.000Z"
  },
  "meta": {
    "timestamp": "2026-09-20T15:20:00.000Z",
    "requestId": "req_user_cat_01"
  }
}
```

---

### 4.3. Manage / Update Creator's Categories
`PUT /creators/me/categories`

Updates the creator's pinned categories. Called when saving changes from the "Manage Categories" bottom sheet.

#### Request Headers:
```http
PUT /api/v1/creators/me/categories HTTP/1.1
Host: api.lala-ai.com
Authorization: Bearer eyJhbGciOi...
Content-Type: application/json
```

#### Request Body Schema:
| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `selectedCategories` | `array[string]` | Required | Array of category names or slugs to display | Min 1, Max 10 items |

#### Request Body Example:
```json
{
  "selectedCategories": [
    "Fashion",
    "Tech",
    "Gaming",
    "Fitness & Health",
    "Finance & Business"
  ]
}
```

#### Success Response (`200 OK`):
```json
{
  "status": "success",
  "message": "Category preferences updated successfully",
  "data": {
    "selectedCategories": [
      "Fashion",
      "Tech",
      "Gaming",
      "Fitness & Health",
      "Finance & Business"
    ],
    "updatedAt": "2026-09-20T15:21:10.000Z"
  },
  "meta": {
    "timestamp": "2026-09-20T15:21:10.000Z",
    "requestId": "req_update_cat_01"
  }
}
```

#### Validation Error (`422 Unprocessable Entity`):
```json
{
  "status": "error",
  "code": "VALIDATION_FAILED",
  "message": "At least 1 category must be selected (Maximum 10).",
  "errors": [
    {
      "field": "selectedCategories",
      "message": "selectedCategories cannot be empty."
    }
  ]
}
```

---

### 4.4. Get Category Insights (AI Intel & Trending Topics)
`GET /categories/insights`

Fetches AI-curated category intelligence, breakout trends, popular themes, and shared insights for a specific category.

#### Query Parameters:
| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `category` | `string` | Required | — | Name or slug of the category (e.g., `Fashion`, `Tech`, `Gaming`) |
| `timeframe` | `string` | Optional | `7d` | Trend window: `24h`, `7d`, `30d` |

#### Request Headers:
```http
GET /api/v1/categories/insights?category=Fashion&timeframe=7d HTTP/1.1
Host: api.lala-ai.com
Authorization: Bearer eyJhbGciOi...
Accept: application/json
```

#### Success Response (`200 OK`):
```json
{
  "status": "success",
  "message": "Category insights fetched successfully",
  "data": {
    "categoryName": "Fashion",
    "slug": "fashion",
    "updatedTime": "Updated 2 hours ago",
    "trendingNow": [
      "Oversized silhouettes",
      "Minimal styling",
      "Sustainable fabrics"
    ],
    "popularTopics": [
      "Streetwear",
      "Luxury fashion",
      "Creator fashion"
    ],
    "sharedInsights": [
      {
        "id": "ins_001",
        "tag": "Rising Topic",
        "title": "Sustainable Fashion",
        "description": "Growing interest in ethical clothing choices, capsule wardrobes, and thrift styling among Gen-Z creators.",
        "iconType": "eco",
        "trendVelocity": "+48%"
      },
      {
        "id": "ins_002",
        "tag": "Trending Format",
        "title": "1 Piece, 3 Ways",
        "description": "Fast-paced styling transition videos are driving 2.4x higher watch time and bookmark saves.",
        "iconType": "style",
        "trendVelocity": "+35%"
      },
      {
        "id": "ins_003",
        "tag": "Popular Theme",
        "title": "Capsule Wardrobes",
        "description": "High engagement with minimal wardrobe investment guides and seasonal rotation advice.",
        "iconType": "inventory_2",
        "trendVelocity": "+22%"
      }
    ]
  },
  "meta": {
    "timestamp": "2026-09-20T15:20:00.000Z",
    "requestId": "req_insights_01"
  }
}
```

---

## 5. Flutter Integration & Models

### 5.1. Dart Model Implementation (`category_insights_model.dart`)

```dart
class CategoryInsightsModel {
  final String categoryName;
  final String updatedTime;
  final List<String> trendingNow;
  final List<String> popularTopics;
  final List<CategoryInsightItem> sharedInsights;

  CategoryInsightsModel({
    required this.categoryName,
    required this.updatedTime,
    required this.trendingNow,
    required this.popularTopics,
    required this.sharedInsights,
  });

  factory CategoryInsightsModel.fromJson(Map<String, dynamic> json) {
    return CategoryInsightsModel(
      categoryName: json['categoryName'] ?? '',
      updatedTime: json['updatedTime'] ?? 'Recently updated',
      trendingNow: List<String>.from(json['trendingNow'] ?? []),
      popularTopics: List<String>.from(json['popularTopics'] ?? []),
      sharedInsights: (json['sharedInsights'] as List<dynamic>? ?? [])
          .map((item) => CategoryInsightItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryName': categoryName,
    'updatedTime': updatedTime,
    'trendingNow': trendingNow,
    'popularTopics': popularTopics,
    'sharedInsights': sharedInsights.map((e) => e.toJson()).toList(),
  };
}

class CategoryInsightItem {
  final String tag;
  final String title;
  final String description;
  final String iconType;

  CategoryInsightItem({
    required this.tag,
    required this.title,
    required this.description,
    required this.iconType,
  });

  factory CategoryInsightItem.fromJson(Map<String, dynamic> json) {
    return CategoryInsightItem(
      tag: json['tag'] ?? 'Insight',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconType: json['iconType'] ?? 'trending_up',
    );
  }

  Map<String, dynamic> toJson() => {
    'tag': tag,
    'title': title,
    'description': description,
    'iconType': iconType,
  };
}
```

---

## 6. Error Codes & Handling

| Status Code | Error Code | Meaning / Action |
| :--- | :--- | :--- |
| `400` | `INVALID_CATEGORY` | Category name or slug passed does not exist in master registry |
| `401` | `UNAUTHORIZED` | Expired or missing Bearer token; redirect user to login |
| `404` | `INSIGHTS_NOT_FOUND` | No insights computed for this category yet; app falls back to cached state |
| `422` | `LIMIT_EXCEEDED` | Selected categories exceed 10 or less than 1; show warning toast |
| `500` | `INTERNAL_SERVER_ERROR` | AI/Backend engine error; show friendly retry toast |
