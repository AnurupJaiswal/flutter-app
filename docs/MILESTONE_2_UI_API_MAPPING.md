# Milestone 2 — Dashboard & Channel Audit: Deep Gap Analysis & UI-API Architecture

---

## 1. Executive Summary: What We Have vs What Is Missing

### KYA AA RAHA HAI (Currently Working & Provided by Backend)
1. **Creator & User Profile**: `GET /api/v1/auth/me` returns `user`, `creatorProfile`, `subscription`, and `connectedAccounts` (YouTube & Instagram connection status, handles, and account IDs).
2. **Channel Connections List**: `GET /api/v1/creators/me/connections` returns list of all connected platform accounts with `id`, `platform`, `platformAccountName`, `status` (`ACTIVE`/`DISCONNECTED`), and platform entitlement limits.
3. **Common Channel Health & SWOT Audit**: `GET /api/v1/dashboard/overview?connectedAccountId={id}` returns:
   - `healthScore` (0–100 integer)
   - 4-pillar sub-scores: `engagementScore`, `consistencyScore`, `growthScore`, `reachScore`
   - `auditStatus` (`FRESH`, `IN_PROGRESS`, etc.)
   - `dataAsOf` timestamp
   - `swotJson` (contains stringified JSON of `strengths`, `weaknesses`, `opportunities`, `threats`)
   - `recommendationsJson` (contains stringified JSON array with `title`, `priority`, `expectedOutcome`)
4. **Trigger Audit**: `POST /api/v1/dashboard/audit` with body `{"connectedAccountId": <id>}` initiates asynchronous/synchronous audit re-calculation for the target channel.
5. **Convert Recommendation to To-Do**: `POST /api/v1/dashboard/todos/convert` with body `{"connectedAccountId": <id>, "channelAuditId": <id>, "title": "...", "priority": "...", "expectedOutcome": "..."}` creates a server-side action item.
6. **Platform Stats Overviews**:
   - `GET /api/v1/creators/me/analytics/youtube/overview` (`subscriberCount`, `viewCount`, `videoCount`, `avgEngagementRate`)
   - `GET /api/v1/creators/me/analytics/instagram/overview` (`followerCount`, `mediaCount`, `avgEngagementRate`)

---

### KYA NAHI AA RAHA HAI (Gaps & Missing Pieces)
1. **Persistent To-Do Fetching (`GET /api/v1/dashboard/todos`)**:
   - Currently, converted To-Dos are posted to the server via `todos/convert`, but there is **no GET endpoint** to retrieve the creator's active To-Do list on app restart / fresh login.
2. **To-Do Status Updating (`PUT/DELETE /api/v1/dashboard/todos/{id}`)**:
   - When a creator marks a To-Do as completed (checkbox) or deletes it in Flutter, there is no backend endpoint to persist `isDone = true` or `DELETE`.
3. **Recent Content Dashboard Feed (`GET /api/v1/creators/me/analytics/{platform}/history`)**:
   - `GET .../youtube/history` endpoint exists in route constants, but the response schema is not yet mapped to recent video/reel thumbnail cards on the home screen.
4. **SWOT JSON Parsing Structure**:
   - `swotJson` and `recommendationsJson` are returned as serialized JSON strings inside the JSON response, requiring double parsing in Flutter instead of native JSON objects/arrays.

---

## 2. Individual Channel vs Platform vs Creator Audit Architecture

### Is Audit Per-Creator, Per-Platform, or Per-Channel?
- **Backend Architecture is Per-Connected-Account (Per-Channel)**:
  - Each YouTube channel and Instagram account has its own unique `connectedAccountId` (integer ID, e.g. YouTube ID `34`, Instagram ID `1`).
  - Audits, health scores, SWOT, and recommendations are linked directly to `connectedAccountId`.
  - **Reason**: A creator can have multiple channels (e.g. Main YouTube Channel ID 34 + Gaming Channel ID 35 + Instagram Account ID 1). Each channel has completely distinct audience metrics, SEO pacing, and SWOT factors.

### Single Common API vs Separate Platform APIs:
| Domain | Approach | Architecture Decision & Reason |
| :--- | :--- | :--- |
| **Audit Trigger** | **Common API** (`POST /api/v1/dashboard/audit`) | `connectedAccountId` is passed in request body. Backend resolves the platform (`YOUTUBE` or `INSTAGRAM`) and channel tokens automatically. **No need for separate `/youtube/audit` or `/instagram/audit`**. |
| **Audit Overview (SWOT & Health)** | **Common API** (`GET /api/v1/dashboard/overview?connectedAccountId={id}`) | Common endpoint handles any platform via query param `connectedAccountId`. Returns unified schema (`healthScore`, 4 sub-scores, SWOT, recommendations). |
| **To-Do Conversion** | **Common API** (`POST /api/v1/dashboard/todos/convert`) | Common endpoint linking `connectedAccountId` and `channelAuditId`. |
| **Channel Analytics (Stats)** | **Platform-Specific APIs** (`GET .../analytics/youtube/overview` & `GET .../analytics/instagram/overview`) | YouTube has `subscriberCount`, `viewCount`, `videoCount`; Instagram has `followerCount`, `mediaCount`, `reachCount`. Metrics differ by nature, so dedicated platform overviews are clean and appropriate. |

---

## 3. Health Score: Calculation, Platform & Channel Breakdown

### Health Score Source:
- **Backend-Driven Deterministic Audit**:
  - The health score is **NOT generated locally by random formulas**.
  - It is returned by `GET /api/v1/dashboard/overview?connectedAccountId={id}` inside `response.audit.healthScore` (0–100).
  - 4 sub-scores are returned explicitly:
    - `engagementScore` (Weight: 30%)
    - `consistencyScore` (Weight: 25%)
    - `growthScore` (Weight: 25%)
    - `reachScore` (Weight: 20%)

### Channel-Level vs Overall Creator Health Score:
- **Channel Health Score**:
  - When YouTube is active (`connectedAccountId = 34`), the dashboard displays YouTube Health Score (e.g. `43/100`).
  - When Instagram is active, it displays Instagram Health Score.
- **Overall Creator Health Score**:
  - Optional composite aggregate. Can be derived as a weighted average across all active connections or retrieved if backend provides multi-channel rollup. Current UI cleanly focuses on the **selected active channel's health score**.

---

## 4. Token vs ID Analysis: What Identifies What

```text
1. Bearer Access Token (JWT):
   └── Identifies: The Creator / User session.
   └── Used for: All requests in Authorization header (`Authorization: Bearer <accessToken>`).
   └── NEVER send userId in query/body — backend extracts creatorId directly from the JWT.

2. connectedAccountId (Integer / BigInt):
   └── Identifies: The specific platform channel connection (e.g. YouTube Channel #34).
   └── Derived from: `GET /api/v1/auth/me` -> `data.connectedAccounts.youtube.id` OR `GET /api/v1/creators/me/connections` -> `connections[i].id`.
   └── Used for:
         - `GET /api/v1/dashboard/overview?connectedAccountId=34`
         - `POST /api/v1/dashboard/audit` (`{"connectedAccountId": 34}`)
         - `POST /api/v1/dashboard/todos/convert` (`{"connectedAccountId": 34, ...}`)

3. channelAuditId (Integer):
   └── Identifies: The specific audit run snapshot.
   └── Derived from: `response.audit.auditId` in `GET /api/v1/dashboard/overview`.
   └── Used for: Linking converted To-Dos to the exact audit observation.
```

---

## 5. Complete Milestone 2 API Matrix

| Requirement | Platform | Existing API | Data Available in API | Missing in Current API | Action Required |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Creator Identity & Handles** | Common | `GET /api/v1/auth/me` | `user.displayName`, `connectedAccounts.youtube.id`, `connectedAccounts.youtube.handle`, `connectedAccounts.instagram.handle` | None | **REUSE EXISTING API** |
| **Channel Connections** | Common | `GET /api/v1/creators/me/connections` | `id`, `platform`, `platformAccountName`, `status`, `lastSyncedAt`, platform limits | None | **REUSE EXISTING API** |
| **YouTube Channel Stats** | YouTube | `GET /api/v1/creators/me/analytics/youtube/overview` | `subscriberCount`, `viewCount`, `videoCount`, `avgEngagementRate` | Historical graph points (in `/growth`) | **REUSE EXISTING API** |
| **Instagram Channel Stats** | Instagram | `GET /api/v1/creators/me/analytics/instagram/overview` | `followerCount`, `mediaCount`, `avgEngagementRate` | Historical graph points (in `/growth`) | **REUSE EXISTING API** |
| **Channel Health Score** | Common (Per Channel) | `GET /api/v1/dashboard/overview?connectedAccountId={id}` | `healthScore`, `engagementScore`, `consistencyScore`, `growthScore`, `reachScore`, `dataAsOf` | None | **REUSE EXISTING API** |
| **Channel SWOT Audit** | Common (Per Channel) | `GET /api/v1/dashboard/overview?connectedAccountId={id}` | `swotJson` (`strengths`, `weaknesses`, `opportunities`, `threats`) | None (Needs clean JSON deserialization) | **REUSE EXISTING API** |
| **Channel Action Recommendations** | Common (Per Channel) | `GET /api/v1/dashboard/overview?connectedAccountId={id}` | `recommendationsJson` (`title`, `priority`, `expectedOutcome`) | None | **REUSE EXISTING API** |
| **Trigger Channel Audit** | Common (Per Channel) | `POST /api/v1/dashboard/audit` | Initiates audit for `connectedAccountId` | None | **REUSE EXISTING API** |
| **Convert Recommendation to To-Do** | Common (Per Channel) | `POST /api/v1/dashboard/todos/convert` | Persists converted action item to backend | None | **REUSE EXISTING API** |
| **List Saved To-Dos** | Common | `GET /api/v1/dashboard/todos` | None | Entire task list retrieval endpoint | **BACKEND API REQUIRED** |
| **Update / Delete To-Do** | Common | `PUT / DELETE /api/v1/dashboard/todos/{id}` | None | Toggle `isDone` and delete task | **BACKEND API REQUIRED** |
| **Recent Content List** | YouTube | `GET /api/v1/creators/me/analytics/youtube/history` | Historical video metadata | Thumbnail URLs and view counts | **EXISTING API — RESPONSE EXTENSION** |

---

## 6. Detailed API Response Gap Analysis

### 1. `GET /api/v1/auth/me`
```text
CURRENT RESPONSE:
✅ data.user.id
✅ data.user.displayName
✅ data.creatorProfile.displayName
✅ data.connectedAccounts.youtube.id (e.g. 34)
✅ data.connectedAccounts.youtube.connected (true/false)
✅ data.connectedAccounts.youtube.handle (e.g. "Anurup Jaiswal")
✅ data.connectedAccounts.instagram.id
✅ data.connectedAccounts.instagram.connected
✅ data.connectedAccounts.instagram.handle

STATUS: COMPLETE & FULLY READY FOR MILESTONE 2.
```

---

### 2. `GET /api/v1/dashboard/overview?connectedAccountId={id}`
```text
CURRENT RESPONSE:
✅ status ("SUCCESS" or "NO_AUDIT")
✅ audit.auditId (12)
✅ audit.connectedAccountId (34)
✅ audit.platform ("YOUTUBE")
✅ audit.healthScore (43)
✅ audit.engagementScore (74)
✅ audit.consistencyScore (80)
✅ audit.growthScore (72)
✅ audit.reachScore (78)
✅ audit.auditStatus ("FRESH")
✅ audit.dataAsOf ("2026-09-18T23:23:04Z")
✅ audit.swotJson (serialized JSON string with strengths, weaknesses, opportunities, threats)
✅ audit.recommendationsJson (serialized JSON string with title, priority, expectedOutcome)

NOT COMING / SUB-OPTIMAL:
⚠️ swotJson and recommendationsJson are returned as escaped JSON strings instead of direct JSON objects.
   (Flutter parses this safely via jsonDecode).

STATUS: FULLY OPERATIONAL.
```

---

### 3. `POST /api/v1/dashboard/audit`
```text
REQUEST:
{"connectedAccountId": 34}

CURRENT RESPONSE:
✅ success: true
✅ message: "Channel audit initiated successfully"

STATUS: FULLY OPERATIONAL.
```

---

### 4. `POST /api/v1/dashboard/todos/convert`
```text
REQUEST:
{
  "connectedAccountId": 34,
  "channelAuditId": 12,
  "title": "Double down on 45s Hook format",
  "priority": "ORANGE",
  "expectedOutcome": "+15% Channel Reach"
}

CURRENT RESPONSE:
✅ success: true
✅ message: "Recommendation converted to todo"

STATUS: FULLY OPERATIONAL.
```

---

### 5. `GET /api/v1/dashboard/todos?connectedAccountId={id}` (GAP: Needs Backend Implementation)
```text
REQUIRED REQUEST:
GET /api/v1/dashboard/todos?connectedAccountId=34
Authorization: Bearer <accessToken>

REQUIRED RESPONSE:
{
  "success": true,
  "data": {
    "todos": [
      {
        "id": 101,
        "connectedAccountId": 34,
        "channelAuditId": 12,
        "title": "Double down on 45s Hook format",
        "priority": "ORANGE",
        "expectedOutcome": "+15% Channel Reach",
        "isDone": false,
        "createdAt": "2026-09-18T23:25:00Z"
      }
    ]
  }
}

STATUS: BACKEND API REQUIRED. (Flutter currently handles local in-memory caching gracefully).
```

---

## 7. API Optimization, Reduction & Combination Analysis

### 1. APIs We Can Reuse Immediately (No Changes Needed)
1. `GET /api/v1/auth/me` -> Identity, handles, connection states, and active account IDs.
2. `GET /api/v1/creators/me/connections` -> All platform connections and entitlements.
3. `GET /api/v1/dashboard/overview?connectedAccountId={id}` -> Complete Health Score, 4 Sub-Scores, SWOT analysis, and Recommendations.
4. `POST /api/v1/dashboard/audit` -> Trigger audit.
5. `POST /api/v1/dashboard/todos/convert` -> Action item persistence.
6. `GET /api/v1/creators/me/analytics/youtube/overview` -> YouTube statistics.
7. `GET /api/v1/creators/me/analytics/instagram/overview` -> Instagram statistics.

### 2. Redundant Calls Avoided
- **Avoid calling `GET /creators/me/connections` every time the dashboard loads**:
  - `GET /api/v1/auth/me` **already provides** `data.connectedAccounts.youtube.id` and `connectedAccounts.youtube.connected`.
  - By reading the active account ID directly from `auth/me`, we save 1 redundant network call on every app launch!
  - `GET /creators/me/connections` is kept only for multi-account management in `ConnectAccountsView`.

### 3. APIs That Need Response Extension
- `GET /api/v1/creators/me/analytics/youtube/history`: Add thumbnail image URL, publication date, and view count to display live cards in the "Recent Content" section.

### 4. New APIs Actually Required
- `GET /api/v1/dashboard/todos?connectedAccountId={id}`: Fetch saved To-Dos on cold start.
- `PUT /api/v1/dashboard/todos/{todoId}`: Sync completion state (`isDone`).
- `DELETE /api/v1/dashboard/todos/{todoId}`: Remove task.

---

## 8. Final End-to-End Execution Flow

```text
                        ┌───────────────────────────────┐
                        │        Creator Login          │
                        └──────────────┬────────────────┘
                                       │
                                       ▼
                        ┌───────────────────────────────┐
                        │      JWT Bearer Token         │
                        └──────────────┬────────────────┘
                                       │
                                       ▼
                        ┌───────────────────────────────┐
                        │      GET /api/v1/auth/me      │
                        └──────────────┬────────────────┘
                                       │
            ┌──────────────────────────┴──────────────────────────┐
            │                                                     │
            ▼                                                     ▼
┌───────────────────────────────┐               ┌──────────────────────────────────┐
│ YouTube Connected (id: 34)    │               │  Instagram Connected (id: 1)     │
└───────────┬───────────────────┘               └─────────────────┬────────────────┘
            │                                                     │
            ▼                                                     ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                   GET /api/v1/dashboard/overview?connectedAccountId={id}         │
└──────────────────────────────────────┬───────────────────────────────────────────┘
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         ▼                             ▼                             ▼
┌─────────────────┐           ┌─────────────────┐           ┌─────────────────┐
│  Health Score   │           │   SWOT Audit    │           │ Recommendations │
│  (43/100, 4 Sub)│           │   (4 Categories)│           │ (Action Items)  │
└─────────────────┘           └─────────────────┘           └────────┬────────┘
                                                                     │
                                                                     ▼ Tap "+ To-Do"
                                                            ┌─────────────────┐
                                                            │  POST todos/    │
                                                            │  convert        │
                                                            └────────┬────────┘
                                                                     │
                                                                     ▼
                                                            ┌─────────────────┐
                                                            │ Creator To-Dos  │
                                                            │ (Progress & Bar)│
                                                            └─────────────────┘
```

---

## 9. Final Metric Summary

```text
UI READY:
9

UI PARTIAL:
2 (Recent Content & Full Analytics Graph Integration)

UI MISSING:
0

API READY & REUSABLE:
7

API RESPONSE EXTENSIONS:
1 (YouTube History Thumbnails)

NEW BACKEND APIs REQUIRED:
2 (GET todos & PUT/DELETE todos)

TOKEN-BASED APIs:
5 (auth/me, connections, profile, youtube/overview, instagram/overview)

ID-BASED APIs:
2 (disconnect account, select account)

MIXED (TOKEN + ACCOUNT ID) APIs:
3 (dashboard/overview, dashboard/audit, todos/convert)
```
