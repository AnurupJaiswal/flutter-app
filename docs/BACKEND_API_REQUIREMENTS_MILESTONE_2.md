# Lala AI — Milestone 2: Backend API Specifications & Requirements
**Target Audience:** Backend Developers  
**Scope:** Home Dashboard, Channel Health Audit, Actionable To-Dos, and Multi-Platform Analytics (YouTube & Instagram with Date Range Filtering)

---

## 1. Global Standards & Authentication

- **Base URL:** `https://<api-domain>/api/v1`
- **Auth Header:** `Authorization: Bearer <accessToken>` (Required on all protected endpoints)
- **Content-Type:** `application/json`
- **User Identification:** The backend identifies the creator from the JWT claims. Do **not** require `userId` or `creatorId` in query/body params unless specifically stated.
- **Channel Identification:** When querying or acting on a specific channel, use `connectedAccountId` (Integer ID returned by `GET /api/v1/creators/me/connections` or `GET /api/v1/auth/me`).

---

## 2. Standard Error Response Format

All error responses across all endpoints must follow this unified schema:

```json
{
  "success": false,
  "message": "Human readable explanation of the error",
  "errorCode": "INVALID_CONNECTED_ACCOUNT",
  "data": null
}
```

---

## 3. Home Dashboard & Channel Audit APIs

### 3.1. Current User Profile & Active Connected Accounts
- **Endpoint:** `GET /api/v1/auth/me`
- **Auth:** Bearer Token
- **Description:** Returns the creator's profile, active subscription, and connected platform accounts.
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "message": "User profile and subscription state retrieved successfully",
  "data": {
    "user": {
      "id": 3,
      "email": "creator@example.com",
      "fullName": "Anurup Jaiswal",
      "displayName": "Anurup",
      "avatarUrl": "https://cdn.lalaai.com/avatars/user_3.png",
      "role": "USER",
      "status": "ACTIVE"
    },
    "creatorProfile": {
      "id": 2,
      "displayName": "Anurup",
      "bio": "Content creator & AI builder",
      "niche": "Tech & AI",
      "streakDays": 14
    },
    "subscription": {
      "status": "ACTIVE",
      "planTier": "PRO",
      "billingDuration": "ONE_MONTH",
      "currentPeriodEnd": "2026-10-17T19:17:46Z"
    },
    "connectedAccounts": {
      "youtube": {
        "id": 34,
        "connected": true,
        "handle": "Anurup Jaiswal"
      },
      "instagram": {
        "id": null,
        "connected": false,
        "handle": null
      }
    }
  }
}
```

---

### 3.2. Channel Health Score & SWOT Audit Overview
- **Endpoint:** `GET /api/v1/dashboard/overview?connectedAccountId={connectedAccountId}`
- **Auth:** Bearer Token
- **Query Parameters:**
  - `connectedAccountId` (Integer, required): The ID of the currently selected connected YouTube/Instagram account from the UI dropdown (e.g. `34`).
- **UI & Flow Logic:**
  - The Home Dashboard features a **Channel Switcher Dropdown** in the header.
  - On initial load, the app picks the active channel ID from `/auth/me` and passes `?connectedAccountId={id}`.
  - Whenever the creator switches between channels in the dropdown (e.g., switches to Instagram or a second YouTube channel), Flutter immediately queries `GET /api/v1/dashboard/overview?connectedAccountId={newId}` to load that channel's specific health audit.
- **Expected Response (`200 OK` when audit exists):**
```json
{
  "status": "SUCCESS",
  "audit": {
    "auditId": 12,
    "connectedAccountId": 34,
    "platform": "YOUTUBE",
    "healthScore": 78,
    "engagementScore": 74,
    "consistencyScore": 80,
    "growthScore": 72,
    "reachScore": 78,
    "auditStatus": "FRESH",
    "dataAsOf": "2026-09-18T23:23:04Z",
    "swot": {
      "strengths": [
        "High Shorts Retention (>75% on 45s videos)",
        "Consistent Upload Schedule (Tue & Fri)"
      ],
      "weaknesses": [
        "Missing Description SEO Keywords",
        "Low Thumbnail Text Color Contrast"
      ],
      "opportunities": [
        "Trending Topic: 'AI Tools 2026' (+320% search velocity)",
        "Peak Post Window: Friday 6:00 PM EST"
      ],
      "threats": [
        "Niche Creator Saturation in Tech category",
        "Audience drop-off at 45s intro transition"
      ]
    },
    "recommendations": [
      {
        "id": 1,
        "title": "Double down on 45s Hook-Challenge-Resolution format",
        "priority": "ORANGE",
        "expectedOutcome": "+18% Non-Follower Reach",
        "tag": "Strategy"
      },
      {
        "id": 2,
        "title": "Add 3 high-volume search keywords to your next description",
        "priority": "RED",
        "expectedOutcome": "+24% YouTube Search Impressions",
        "tag": "SEO"
      }
    ]
  }
}
```
*(When no audit has been run for the channel: `{"status": "NO_AUDIT"}` with HTTP 200).*

> **Backend Improvement Request:** Please return `swot` and `recommendations` as native JSON objects/arrays rather than escaped JSON strings (`swotJson` / `recommendationsJson`).

---

### 3.3. Trigger Channel Audit
- **Endpoint:** `POST /api/v1/dashboard/audit`
- **Auth:** Bearer Token
- **Request Body:**
```json
{
  "connectedAccountId": 34
}
```
*(The Flutter app always passes the `connectedAccountId` of the currently selected channel in the dropdown).*
- **Expected Response (`200 OK` or `202 Accepted`):**
```json
{
  "success": true,
  "message": "Channel audit initiated successfully",
  "data": {
    "auditId": 13,
    "status": "COMPLETED",
    "healthScore": 78
  }
}
```

---

### 3.4. Convert Audit Recommendation to To-Do Action Item
- **Endpoint:** `POST /api/v1/dashboard/todos/convert`
- **Auth:** Bearer Token
- **Request Body:**
```json
{
  "connectedAccountId": 34,
  "channelAuditId": 12,
  "title": "Add 3 high-volume search keywords to your next description",
  "priority": "ORANGE",
  "expectedOutcome": "+24% YouTube Search Impressions"
}
```
- **Expected Response (`201 Created` or `200 OK`):**
```json
{
  "success": true,
  "message": "Recommendation converted to todo",
  "data": {
    "id": 101,
    "title": "Add 3 high-volume search keywords to your next description",
    "priority": "ORANGE",
    "expectedOutcome": "+24% YouTube Search Impressions",
    "isDone": false,
    "createdAt": "2026-09-18T23:30:00Z"
  }
}
```

---

### 3.5. 🚨 NEW REQUIRED ENDPOINT: List Creator Saved To-Dos
- **Endpoint:** `GET /api/v1/dashboard/todos?connectedAccountId={connectedAccountId}`
- **Auth:** Bearer Token
- **Query Parameters:**
  - `connectedAccountId` (Integer, optional): Filter by channel or omit for all creator To-Dos.
- **Description:** Allows the Flutter app to retrieve previously converted tasks on cold app restart.
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "total": 3,
    "completed": 1,
    "todos": [
      {
        "id": 101,
        "connectedAccountId": 34,
        "channelAuditId": 12,
        "title": "Add 3 high-volume search keywords to your next description",
        "subtitle": "Recommendation from SWOT Audit — Weakness",
        "details": "Include target search phrases in the first 2 lines of your video description.",
        "priority": "HIGH",
        "tag": "SEO",
        "expectedOutcome": "+24% YouTube Search Impressions",
        "isDone": false,
        "dueDate": "Next Video",
        "createdAt": "2026-09-18T23:30:00Z"
      },
      {
        "id": 102,
        "connectedAccountId": 34,
        "channelAuditId": 12,
        "title": "Schedule next upload for Friday at 6:00 PM EST",
        "subtitle": "Identified as your peak audience active window",
        "details": "Publish when 82% of your subscriber base is online.",
        "priority": "MEDIUM",
        "tag": "Timing",
        "expectedOutcome": "+35% First 24hr Views",
        "isDone": true,
        "dueDate": "Friday 6:00 PM",
        "createdAt": "2026-09-18T23:35:00Z"
      }
    ]
  }
}
```

---

### 3.6. 🚨 NEW REQUIRED ENDPOINT: Update & Delete To-Do Status
- **Update Completion Status:** `PUT /api/v1/dashboard/todos/{todoId}`
  - **Request Body:** `{"isDone": true}`
  - **Expected Response:** `{"success": true, "message": "To-Do status updated"}`
- **Delete To-Do:** `DELETE /api/v1/dashboard/todos/{todoId}`
  - **Expected Response:** `{"success": true, "message": "To-Do removed"}`

---

## 4. Multi-Platform Channel Analytics APIs

The Analytics screen has **two primary interactive filters**:
1. **Platform Filter:** `YOUTUBE` vs `INSTAGRAM`
2. **Time Range Filter:** `7d` (7 Days), `30d` (30 Days), `90d` (90 Days)

---

### 4.1. YouTube Analytics Overview (Key Metrics & Score)
- **Endpoint:** `GET /api/v1/creators/me/analytics/youtube/overview?period={period}`
- **Auth:** Bearer Token
- **Query Parameters:**
  - `period` (String, optional, default: `30d`): Options: `7d`, `30d`, `90d`.
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "account": {
      "name": "Anurup Jaiswal",
      "handle": "@anurupjaiswal",
      "avatarUrl": "https://cdn.lalaai.com/avatars/yt_34.png",
      "isVerified": true
    },
    "channelScore": {
      "score": 84,
      "status": "Good",
      "summary": "Your channel is performing well, with strong retention but inconsistent posting.",
      "breakdown": {
        "profile": 85,
        "content": 72,
        "engagement": 88,
        "consistency": 64
      }
    },
    "keyMetrics": [
      { "key": "subscribers", "title": "Subscribers", "value": "47.8K", "change": "+12.6%", "isUp": true },
      { "key": "views", "title": "Views", "value": "412K", "change": "+26.8%", "isUp": true },
      { "key": "likes", "title": "Likes", "value": "24.6K", "change": "+19.1%", "isUp": true },
      { "key": "consistency", "title": "Consistency", "value": "74%", "change": "+4.5%", "isUp": true }
    ]
  }
}
```

---

### 4.2. Instagram Analytics Overview (Key Metrics & Score)
- **Endpoint:** `GET /api/v1/creators/me/analytics/instagram/overview?period={period}`
- **Auth:** Bearer Token
- **Query Parameters:**
  - `period` (String, optional, default: `30d`): Options: `7d`, `30d`, `90d`.
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "account": {
      "name": "Anurup Reels",
      "handle": "@anurup_reels",
      "avatarUrl": "https://cdn.lalaai.com/avatars/ig_1.png",
      "isVerified": true
    },
    "channelScore": {
      "score": 78,
      "status": "Good",
      "summary": "High Reel reach with opportunities in carousel engagement.",
      "breakdown": {
        "profile": 82,
        "content": 75,
        "engagement": 84,
        "consistency": 70
      }
    },
    "keyMetrics": [
      { "key": "followers", "title": "Followers", "value": "12.4K", "change": "+8.4%", "isUp": true },
      { "key": "views", "title": "Views", "value": "184K", "change": "+21.3%", "isUp": true },
      { "key": "likes", "title": "Likes", "value": "9.8K", "change": "+14.2%", "isUp": true },
      { "key": "consistency", "title": "Consistency", "value": "64%", "change": "+3.1%", "isUp": true }
    ]
  }
}
```

---

### 4.3. Audience Growth & Views Performance Graphs
- **Endpoint:** `GET /api/v1/creators/me/analytics/{platform}/growth?period={period}`
- **Auth:** Bearer Token
- **Path Parameters:** `platform` (`youtube` or `instagram`)
- **Query Parameters:** `period` (`7d`, `30d`, `90d`)
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "audienceGrowth": {
      "startValue": "44.2K",
      "endValue": "47.8K",
      "gainText": "+3,600 (+12.6%)",
      "timeLabels": ["Week 1", "Week 2", "Week 3", "Week 4"],
      "points": [44.2, 45.1, 46.4, 47.8]
    },
    "viewsOverTime": {
      "totalViews": "412K",
      "avgDailyViews": "13.7K / day",
      "change": "+26.8%",
      "insight": "Views increased 26.8% compared to the previous 30-day cycle.",
      "timeLabels": ["Week 1", "Week 2", "Week 3", "Week 4"],
      "points": [65.0, 92.0, 115.0, 140.0]
    }
  }
}
```

---

### 4.4. Engagement & Interactions Graph
- **Endpoint:** `GET /api/v1/creators/me/analytics/{platform}/engagement?period={period}`
- **Auth:** Bearer Token
- **Path Parameters:** `platform` (`youtube` or `instagram`)
- **Query Parameters:** `period` (`7d`, `30d`, `90d`)
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "avgRate": "8.1%",
    "likesCount": "24.6K",
    "commentsCount": "3.2K",
    "timeLabels": ["Week 1", "Week 2", "Week 3", "Week 4"],
    "likesPoints": [40.0, 58.0, 48.0, 76.0],
    "commentsPoints": [18.0, 26.0, 22.0, 35.0]
  }
}
```

---

### 4.5. Content Activity & Consistency Breakdown
- **Endpoint:** `GET /api/v1/creators/me/analytics/{platform}/activity?period={period}`
- **Auth:** Bearer Token
- **Path Parameters:** `platform` (`youtube` or `instagram`)
- **Query Parameters:** `period` (`7d`, `30d`, `90d`)
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "totalContentText": "9 Shorts in the last 30 Days",
    "avgPacingText": "Average: 2.2 posts/week",
    "bestWeekText": "Best Week: Week 3 (3 posts, 142K views)",
    "weeklyBars": [
      { "week": "Week 1", "count": 3, "label": "3 posts" },
      { "week": "Week 2", "count": 1, "label": "1 post" },
      { "week": "Week 3", "count": 3, "label": "3 posts" },
      { "week": "Week 4", "count": 2, "label": "2 posts" }
    ]
  }
}
```

---

### 4.6. Top Performing Content List
- **Endpoint:** `GET /api/v1/creators/me/analytics/{platform}/top-content?period={period}&limit=5`
- **Auth:** Bearer Token
- **Path Parameters:** `platform` (`youtube` or `instagram`)
- **Query Parameters:**
  - `period` (`7d`, `30d`, `90d`)
  - `limit` (Integer, default: `5`)
- **Expected Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "rank": "01",
        "videoId": "yt_vid_901",
        "title": "Build a Complete Flutter AI App in 10 Minutes",
        "platform": "YouTube",
        "views": "48.6K views",
        "likes": "2.4K",
        "comments": "194",
        "engagementRate": "8.9%",
        "thumbnailUrl": "https://cdn.lalaai.com/thumbnails/yt_901.jpg",
        "publishedAt": "2026-09-10T14:00:00Z"
      },
      {
        "rank": "02",
        "videoId": "yt_vid_902",
        "title": "Top 5 AI Tools for Shorts Creators in 2026",
        "platform": "YouTube",
        "views": "36.2K views",
        "likes": "1.8K",
        "comments": "142",
        "engagementRate": "8.2%",
        "thumbnailUrl": "https://cdn.lalaai.com/thumbnails/yt_902.jpg",
        "publishedAt": "2026-09-14T18:30:00Z"
      }
    ]
  }
}
```

---

## 5. Summary of Actions for Backend Developers

| Task # | Action | Priority | API Route |
| :--- | :--- | :--- | :--- |
| **1** | **Return native JSON objects in Overview** (replace `swotJson` / `recommendationsJson` stringified strings with direct `swot` and `recommendations` maps/arrays). | `HIGH` | `GET /api/v1/dashboard/overview?connectedAccountId={id}` |
| **2** | **Implement Saved To-Dos List API** so converted action items persist across app sessions. | `HIGH` | `GET /api/v1/dashboard/todos?connectedAccountId={id}` |
| **3** | **Implement To-Do Status Update & Delete APIs** (`PUT` & `DELETE`). | `HIGH` | `PUT/DELETE /api/v1/dashboard/todos/{todoId}` |
| **4** | **Support `period` filter (`7d`, `30d`, `90d`)** in analytics growth, views, and overview endpoints. | `MEDIUM` | `GET /api/v1/creators/me/analytics/{platform}/*` |
| **5** | **Provide Top Performing Content endpoint** with thumbnail URLs, formatted views, and engagement rates. | `MEDIUM` | `GET /api/v1/creators/me/analytics/{platform}/top-content` |
