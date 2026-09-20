# Backend API Specification: Creator Analytics Endpoints (YouTube & Instagram)

This document provides the exact request format and expected response schema for the **Channel Analytics** APIs. Sharing this with the backend engineering team will ensure that the mobile app receives complete, real-time analytics and time-series data.

---

## 1. Summary of Required Endpoints

| Feature | HTTP Method | Endpoint | Query Parameters |
| :--- | :--- | :--- | :--- |
| **Channel Overview & Key Metrics** | `GET` | `/api/v1/creators/me/analytics/{platform}/overview` | `period=7d` (or `30d`, `90d`) |
| **Audience & Views Growth (Time Series)** | `GET` | `/api/v1/creators/me/analytics/{platform}/growth` | `period=7d` (or `30d`, `90d`) |
| **Engagement & Interactions (Time Series)** | `GET` | `/api/v1/creators/me/analytics/{platform}/engagement` | `period=7d` (or `30d`, `90d`) |
| **Content Upload Activity (Consistency)** | `GET` | `/api/v1/creators/me/analytics/{platform}/activity` | `period=7d` (or `30d`, `90d`) |
| **Top Performing Content** | `GET` | `/api/v1/creators/me/analytics/{platform}/top-content` | `period=7d`, `limit=5` |

> Supported `{platform}` path parameters: `youtube`, `instagram`.

---

## 2. Detailed Endpoints & Expected Response Payloads

### 2.1 Channel Overview (`/overview`)
Returns the connected account handle, overall channel health score (0–100), and top key metric cards.

- **Request**: `GET /api/v1/creators/me/analytics/youtube/overview?period=7d`
- **Headers**: `Authorization: Bearer <accessToken>`
- **Expected Response**:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "dataStatus": "FRESH",
    "account": {
      "connectedAccountId": 66,
      "platform": "YOUTUBE",
      "handle": "Viral Bazar",
      "avatarUrl": "https://yt3.googleusercontent.com/..."
    },
    "channelScore": 78,
    "keyMetrics": [
      {
        "label": "Subscribers",
        "value": "229",
        "trend": "+4.2%",
        "positive": true
      },
      {
        "label": "Views",
        "value": "36580",
        "trend": "+12.5%",
        "positive": true
      },
      {
        "label": "Avg Duration",
        "value": "2m 45s",
        "trend": "+1.1%",
        "positive": true
      },
      {
        "label": "Estimated Revenue",
        "value": "$48.50",
        "trend": "+8.0%",
        "positive": true
      }
    ]
  }
}
```

---

### 2.2 Audience Growth & Views Over Time (`/growth`)
Returns time-series data for the graph curves.
> ⚠️ **Key Fix for Backend**: Ensure `timeLabels` contains distinct dates across the requested period, and `points` contains the matching values for each date (e.g., 7 daily points for `7d`, or weekly points for `30d`/`90d`).

- **Request**: `GET /api/v1/creators/me/analytics/youtube/growth?period=7d`
- **Expected Response**:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "dataStatus": "FRESH",
    "audienceGrowth": {
      "current": "229",
      "trend": "+3.2%",
      "positive": true,
      "timeLabels": ["Sep 13", "Sep 14", "Sep 15", "Sep 16", "Sep 17", "Sep 18", "Sep 19"],
      "points": [220.0, 222.0, 223.0, 225.0, 226.0, 228.0, 229.0]
    },
    "viewsOverTime": {
      "current": "36580",
      "trend": "+8.4%",
      "positive": true,
      "timeLabels": ["Sep 13", "Sep 14", "Sep 15", "Sep 16", "Sep 17", "Sep 18", "Sep 19"],
      "points": [34200.0, 34650.0, 35100.0, 35450.0, 35900.0, 36250.0, 36580.0]
    }
  }
}
```

---

### 2.3 Engagement & Interactions (`/engagement`)
Returns likes, comments, and engagement rate trends over time.

- **Request**: `GET /api/v1/creators/me/analytics/youtube/engagement?period=7d`
- **Expected Response**:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "dataStatus": "FRESH",
    "avgRate": "4.8%",
    "likesCount": "1240",
    "commentsCount": "380",
    "reach": "15200",
    "impressions": "48000",
    "timeLabels": ["Sep 13", "Sep 14", "Sep 15", "Sep 16", "Sep 17", "Sep 18", "Sep 19"],
    "likesPoints": [140.0, 160.0, 155.0, 190.0, 185.0, 200.0, 210.0],
    "commentsPoints": [30.0, 45.0, 40.0, 65.0, 55.0, 70.0, 75.0]
  }
}
```

---

### 2.4 Content Activity & Consistency (`/activity`)
Returns upload consistency metrics and weekly upload counts.

- **Request**: `GET /api/v1/creators/me/analytics/youtube/activity?period=30d`
- **Expected Response**:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "dataStatus": "FRESH",
    "totalContentText": "19 videos",
    "avgPacingText": "3.8 videos / week",
    "bestWeekText": "Week 3 (6 videos)",
    "weeklyBars": [3, 4, 6, 4, 2]
  }
}
```

---

### 2.5 Top Performing Content (`/top-content`)
Returns the top videos/posts ranked by performance (views/engagement) during the requested period.

- **Request**: `GET /api/v1/creators/me/analytics/youtube/top-content?period=30d&limit=5`
- **Expected Response**:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "dataStatus": "FRESH",
    "items": [
      {
        "rank": 1,
        "videoId": "074rHzGA0Hc",
        "title": "Motivational WhatsApp Status | Trending Shorts",
        "platform": "YOUTUBE",
        "views": 15420,
        "likes": 840,
        "comments": 92,
        "engagementRate": 6.04,
        "thumbnailUrl": "https://i.ytimg.com/vi/074rHzGA0Hc/hqdefault.jpg",
        "publishedAt": "2024-03-15T05:37:54Z"
      },
      {
        "rank": 2,
        "videoId": "304e4NlIK-I",
        "title": "Lockdown Mask Funny Status #trending #shorts",
        "platform": "YOUTUBE",
        "views": 11200,
        "likes": 620,
        "comments": 45,
        "engagementRate": 5.93,
        "thumbnailUrl": "https://i.ytimg.com/vi/304e4NlIK-I/hqdefault.jpg",
        "publishedAt": "2024-03-10T03:25:17Z"
      }
    ]
  }
}
```

---

## 3. Checklist for Backend Developers

1. **Authentication Error Code**:
   - Always return `HTTP 401 Unauthorized` (never `HTTP 400`) when the `accessToken` is missing or expired.
2. **Time-Series Matching**:
   - Ensure the length of `points` matches the length of `timeLabels` in `/growth` and `/engagement`.
3. **Date Filtering**:
   - For `/top-content`, rank videos by views acquired in the selected `period` window (e.g., views in last 7d, 30d, 90d).
4. **Number Formats**:
   - Avoid unnecessary floating point decimals on counts (e.g. return `"229"` or `229`, rather than `"229.0"`).
