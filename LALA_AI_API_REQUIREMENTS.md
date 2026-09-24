# LALA-AI — Backend API Requirements (Needed APIs)

> **Document Version:** 2.1.0  
> **Application:** LALA-AI (Flutter Mobile App)  
> **Scope:** Required / Missing Backend APIs for Feature Completion  
> **Note:** Core Authentication (`/api/v1/auth/*`) is already completed and omitted from this document.

---

## 1. Overview & Required API Priority Matrix

This document provides the exact backend API contracts required by the Flutter mobile application to transition all mocked and locally simulated features into full production backend integration.

### Priority Summary:

| Priority | Feature / Module | Endpoint | Method | Status in App |
|---|---|---|---|---|
| **P0** | **AI Script Generator** | `/api/v1/studio/scripts/generate` | `POST` | Simulated in `StudioController` |
| **P0** | **Trend Discovery** | `/api/v1/trends` | `GET` | Using `MockTrendRepository` |
| **P0** | **Content Calendar (List)** | `/api/v1/calendar/posts` | `GET` | Static list in `CalendarController` |
| **P0** | **Content Calendar (Create)** | `/api/v1/calendar/posts` | `POST` | Static list in `CalendarController` |
| **P1** | **AI Viral Hooks & Keywords** | `/api/v1/studio/hooks/generate` | `POST` | Simulated in `StudioController` |
| **P1** | **Trend Deep-Dive Details** | `/api/v1/trends/{trendId}` | `GET` | Using `MockTrendRepository` |
| **P1** | **Content Calendar (Update)** | `/api/v1/calendar/posts/{postId}` | `PUT` | Static list in `CalendarController` |
| **P1** | **Content Calendar (Delete)** | `/api/v1/calendar/posts/{postId}` | `DELETE` | Static list in `CalendarController` |
| **P1** | **Competitor Intelligence** | `/api/v1/competitors/analyze` | `GET` | Simulated in `CompetitorView` |
| **P1** | **Discover Content Feed** | `/api/v1/discover` | `GET` | Using `MockDiscoverRepository` |
| **P1** | **Creator Bookmarks** | `/api/v1/creators/me/bookmarks` | `GET`, `POST`, `DELETE` | Using `MockSavedRepository` |
| **P1** | **Avatar Multipart Upload** | `/api/v1/creators/me/avatar` | `POST` (Multipart) | Local image picker in `EditProfileView` |
| **P2** | **Trend Alerts** | `/api/v1/trends/alerts` | `GET`, `POST`, `DELETE` | In-memory in `TrendingController` |
| **P2** | **Category Insights** | `/api/v1/category-insights` | `GET` | Local dataset in `CategoryInsightsController` |
| **P2** | **Data Export & Deletion** | `/api/v1/settings/export`, `/api/v1/users/me` | `POST`, `DELETE` | Toasts in `SettingsController` |
| **P2** | **Push Token Registration** | `/api/v1/notifications/token` | `POST` | Awaiting backend receiver |

---

## 2. Global Request & Response Specifications

### Headers (Required on all endpoints below):
```http
Authorization: Bearer <accessToken>
Content-Type: application/json
Accept: application/json
```

### Universal Success Response Envelope:
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {}
}
```

### Universal Error Response Envelope:
```json
{
  "success": false,
  "message": "Human readable error description",
  "errorCode": "INVALID_PARAMS",
  "data": null
}
```

---

## 3. Detailed Specifications for Needed APIs

---

### 3.1. AI Script Generator
**Purpose:** Generates full, production-ready video scripts tailored to creator niche, platform, and tone.

* **Endpoint:** `POST /api/v1/studio/scripts/generate`
* **HTTP Method:** `POST`
* **Authentication:** Bearer Token
* **Priority:** **P0**

#### Request Body:
```json
{
  "topic": "10 Secret AI Tools to Automate Your Content in 2026",
  "niche": "Tech & AI",
  "platform": "YouTube Shorts",
  "tone": "Energetic & Engaging",
  "durationSeconds": 60,
  "includeHooks": true,
  "includeCTA": true
}
```

#### Request Fields:
| Field | Type | Required | Description |
|---|---|---|---|
| `topic` | String | Yes | Content concept / title entered by creator |
| `niche` | String | Yes | Creator niche (e.g. `Tech & AI`, `Fitness`, `Finance`) |
| `platform` | String | Yes | Target platform (`YouTube Shorts`, `Instagram Reel`, `Long-form Video`, `TikTok`) |
| `tone` | String | Yes | Script delivery tone (`Energetic & Engaging`, `Educational`, `Storytelling`, `Controversial`) |
| `durationSeconds` | Integer | No | Target video duration (e.g. `30`, `60`, `90`) |
| `includeHooks` | Boolean | No | Generate 3-5 alternative hook options |
| `includeCTA` | Boolean | No | Include verbal engagement call-to-action |

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Script generated successfully",
  "data": {
    "scriptId": "scr_89102",
    "title": "10 Secret AI Tools to Automate Your Content in 2026",
    "hook": "Stop spending 5 hours editing video titles manually. In 30 seconds, I'm showing you the exact AI system content creators are using.",
    "body": "Step 1: Open Lala AI and paste your rough video outline.\nStep 2: Generate 5 high-converting hook options.\nStep 3: Auto-schedule your post for peak viewer retention.",
    "cta": "Comment 'LALA' below and I'll send you the direct access link!",
    "estimatedDurationSeconds": 48,
    "keywords": ["#LalaAI", "#CreatorTools", "#YouTubeGrowth", "#ContentAutomation"],
    "alternativeHooks": [
      "Nobody is talking about this 1 AI shortcut...",
      "This 1 trick saved me 20 hours of scripting this week."
    ]
  }
}
```

* **Frontend Consumer:** `StudioController.generateScript()` → `StudioView` (Tab 0)

---

### 3.2. AI Viral Hooks & Keywords Generator
**Purpose:** Generates multiple high-retention video opening hooks and algorithmic hashtag recommendations.

* **Endpoint:** `POST /api/v1/studio/hooks/generate`
* **HTTP Method:** `POST`
* **Authentication:** Bearer Token
* **Priority:** **P1**

#### Request Body:
```json
{
  "topic": "AI Video Editing Automation",
  "niche": "Tech & AI",
  "count": 5
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "hooks": [
      "Nobody is talking about this 1 AI shortcut...",
      "This 1 trick saved me 20 hours of scripting this week.",
      "If you make content for YouTube or Instagram, stop scrolling right now.",
      "99% of creators are wasting time on this step.",
      "Here is the secret AI workflow top creators don't want you to know."
    ],
    "keywords": [
      "#LalaAI",
      "#PixoAI",
      "#CreatorTools",
      "#YouTubeGrowth",
      "#ReelsViral",
      "#ContentAutomation"
    ]
  }
}
```

* **Frontend Consumer:** `StudioController.generateHooks()` → `StudioView` (Tab 1)

---

### 3.3. Trend Discovery Feed
**Purpose:** Returns real-time trending topics and breakout search queries grouped by category and platform.

* **Endpoint:** `GET /api/v1/trends`
* **HTTP Method:** `GET`
* **Authentication:** Bearer Token
* **Priority:** **P0**

#### Query Parameters:
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `category` | String | No | `All` | Category filter (e.g. `AI`, `Technology`, `Finance`, `Science`, `Business`) |
| `platform` | String | No | `All` | Target platform (`All Platforms`, `YouTube`, `Instagram`, `TikTok`) |
| `scope` | String | No | `Global` | Geographical scope (`Global`, `United States`, `India`, `United Kingdom`) |

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": [
    {
      "id": "trend_1",
      "rank": 1,
      "title": "Autonomous AI Agents",
      "category": "AI",
      "changePercentage": 84.5,
      "summary": "Multi-agent frameworks and autonomous execution systems gain massive enterprise adoption.",
      "source": "Tech Crunch / Industry Report",
      "createdAt": "2026-09-20T12:00:00Z"
    },
    {
      "id": "trend_2",
      "rank": 2,
      "title": "Flutter 3.29 & Impeller Engine",
      "category": "Technology",
      "changePercentage": 42.1,
      "summary": "Flutter's new Impeller rendering pipeline delivers 60fps locked animations across Android & iOS.",
      "source": "Flutter Official Release",
      "createdAt": "2026-09-20T09:00:00Z"
    }
  ]
}
```

* **Frontend Consumer:** `TrendingController.loadTrends()` → `TrendingView` (Tab 0: Discover)

---

### 3.4. Trend Deep-Dive Details
**Purpose:** Returns deep historical data, metrics trajectory, and analysis explaining why a topic is trending.

* **Endpoint:** `GET /api/v1/trends/{trendId}`
* **HTTP Method:** `GET`
* **Authentication:** Bearer Token
* **Priority:** **P1**

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "trendId": "trend_1",
    "title": "Autonomous AI Agents",
    "overview": "Autonomous AI Agents has seen an 84.5% spike in search volume and developer activity over the last 7 days. This growth is driven by enterprise demand for scale, efficiency, and automated workflows.",
    "historicalScores": [42, 48, 55, 68, 79, 88, 96],
    "whyTrending": "Recent advancements in hardware acceleration combined with open-source developer tooling have lowered the barrier to entry, triggering rapid industry adoption.",
    "relatedTopics": [
      "Machine Learning",
      "Developer Productivity",
      "System Architecture",
      "Cloud Infrastructure"
    ],
    "keyInsights": [
      "Enterprise adoption grew by 84% in Q3",
      "Reduction in operational latency by up to 60%",
      "Over 12,000 active GitHub repositories created this month"
    ]
  }
}
```

* **Frontend Consumer:** `TrendingDetailView`

---

### 3.5. Trend Alerts Management
**Purpose:** Allows creators to configure instant threshold or daily digest alerts for emerging topics.

* **Endpoints:**
  - `GET /api/v1/trends/alerts` (List active alerts)
  - `POST /api/v1/trends/alerts` (Create alert)
  - `DELETE /api/v1/trends/alerts/{alertId}` (Delete alert)
* **Priority:** **P2**

#### Create Alert Request Body (`POST /api/v1/trends/alerts`):
```json
{
  "title": "Global AI Video Generators",
  "type": "Global",
  "sensitivity": "Instant (+30%)"
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "id": "alt_102",
    "title": "Global AI Video Generators",
    "type": "Global",
    "sensitivity": "Instant (+30%)",
    "enabled": true,
    "unread": false,
    "createdAt": "2026-09-20T14:00:00Z"
  }
}
```

* **Frontend Consumer:** `TrendingController` (Tab 1: Alerts)

---

### 3.6. Content Calendar (List Scheduled & Draft Posts)
**Purpose:** Fetches scheduled, draft, and published creator content organized by date with AI peak engagement times.

* **Endpoint:** `GET /api/v1/calendar/posts`
* **HTTP Method:** `GET`
* **Authentication:** Bearer Token
* **Priority:** **P0**

#### Query Parameters:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `month` | String | No | Target month formatted as `YYYY-MM` (e.g. `2026-09`) |
| `platform` | String | No | Filter by platform (`YouTube`, `Instagram`, `All`) |
| `status` | String | No | Filter by status (`Scheduled`, `Draft`, `Posted`, `All`) |

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post_1001",
        "title": "10 AI Prompts That Will Save 10 Hours a Week",
        "platform": "YouTube",
        "platformTag": "YouTube Shorts",
        "scheduledAt": "2026-09-20T18:15:00Z",
        "aiSuggestedTime": "6:15 PM (Highest Engagement)",
        "aiIconType": "sparkle",
        "status": "Scheduled",
        "caption": "Here are 10 powerful AI prompts that will automate your content research, scripting, and editing workflow in 2026! Save this reel and steal these prompts for your next video.",
        "hashtags": "#AITools #ContentCreator #Productivity #Shorts #LalaAI #CreatorTools"
      },
      {
        "id": "post_1002",
        "title": "Top 5 AI Tools for Shorts Creators in 2026",
        "platform": "YouTube",
        "platformTag": "YouTube Shorts",
        "scheduledAt": "2026-09-22T18:00:00Z",
        "aiSuggestedTime": "6:15 PM (Highest Engagement)",
        "aiIconType": "chart",
        "status": "Draft",
        "caption": "Looking to scale your short-form video creation? Here are the top 5 AI tools every creator must use in 2026.",
        "hashtags": "#YouTubeShorts #AITools #CreatorTips"
      }
    ]
  }
}
```

* **Frontend Consumer:** `CalendarController` → `CalendarView`

---

### 3.7. Content Calendar (Create, Update & Delete Post)
**Purpose:** Allows creators to add drafts, schedule new posts, update publish status, or remove items.

* **Endpoints:**
  - `POST /api/v1/calendar/posts`
  - `PUT /api/v1/calendar/posts/{postId}`
  - `DELETE /api/v1/calendar/posts/{postId}`
* **Authentication:** Bearer Token
* **Priority:** **P0**

#### Create Post Request Body (`POST /api/v1/calendar/posts`):
```json
{
  "title": "Viral Hook Formulas That Guarantee Retention",
  "platform": "Instagram",
  "platformTag": "Instagram Reel",
  "scheduledAt": "2026-09-25T10:00:00Z",
  "status": "Scheduled",
  "caption": "Master the first 3 seconds of your Instagram Reels with these 5 proven hook formulas.",
  "hashtags": "#InstagramReels #ViralHooks #CreatorGrowth"
}
```

#### Update Post Request Body (`PUT /api/v1/calendar/posts/{postId}`):
```json
{
  "status": "Posted",
  "scheduledAt": "2026-09-25T10:00:00Z"
}
```

* **Frontend Consumer:** `CalendarController.addDraft()`, `CalendarController.markAsPosted()`

---

### 3.8. Competitor Channel Intelligence
**Purpose:** Analyzes public competitor channels across YouTube and Instagram by handle or profile URL.

* **Endpoint:** `GET /api/v1/competitors/analyze?handle={handle}`
* **HTTP Method:** `GET`
* **Authentication:** Bearer Token
* **Priority:** **P1**

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "handle": "@tech_creator",
    "platform": "YOUTUBE",
    "displayName": "Tech Creator Pro",
    "niche": "Tech & AI",
    "subscribers": "142.5K",
    "totalViews": "18.4M",
    "growthRate": "+14.2%",
    "avgViewsPerVideo": "28.5K",
    "avgEngagementRate": "7.4%",
    "uploadFrequency": "3 videos/week",
    "topKeywords": [
      "AI Prompts",
      "Coding Tutorials",
      "Productivity Hacks",
      "Agent Frameworks"
    ],
    "topPerformingRecentVideos": [
      {
        "title": "Build AI Agents in 10 Minutes",
        "views": "84.2K",
        "publishedDaysAgo": 4
      }
    ]
  }
}
```

* **Frontend Consumer:** `CompetitorView`

---

### 3.9. Discover Content Feed
**Purpose:** Returns curated creator articles, case studies, news updates, and workflow guides.

* **Endpoint:** `GET /api/v1/discover`
* **HTTP Method:** `GET`
* **Authentication:** Bearer Token
* **Priority:** **P1**

#### Query Parameters:
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `query` | String | No | `""` | Search query keyword |
| `category` | String | No | `All` | Category filter (`AI`, `Technology`, `Finance`, `Science`) |

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": [
    {
      "id": "disc_1",
      "title": "Building Multi-Agent Frameworks in 2026",
      "description": "A comprehensive analysis on state persistence, task routing, and autonomous error recovery.",
      "type": "ARTICLE",
      "category": "AI",
      "source": "AI Architecture Journal",
      "publishedAt": "2026-09-20T10:00:00Z"
    }
  ]
}
```

* **Frontend Consumer:** `DiscoverController` → `DiscoverView`

---

### 3.10. Creator Bookmarks / Saved Items
**Purpose:** Persists creator saved articles, trends, and prompt ideas in their personal library.

* **Endpoints:**
  - `GET /api/v1/creators/me/bookmarks` (List bookmarks)
  - `POST /api/v1/creators/me/bookmarks` (Save bookmark)
  - `DELETE /api/v1/creators/me/bookmarks/{id}` (Remove bookmark)
* **Priority:** **P1**

#### Save Bookmark Request Body (`POST /api/v1/creators/me/bookmarks`):
```json
{
  "id": "disc_1",
  "title": "Building Multi-Agent Frameworks in 2026",
  "subtitle": "A comprehensive analysis on state persistence and task routing.",
  "category": "AI",
  "type": "ARTICLE"
}
```

* **Frontend Consumer:** `SavedController`, `DiscoverController.bookmarkItem()`

---

### 3.11. Category Insights Engine
**Purpose:** Provides industry-wide macro data, rising themes, and top-performing formats across categories.

* **Endpoint:** `GET /api/v1/category-insights?category={category}`
* **HTTP Method:** `GET`
* **Authentication:** Bearer Token
* **Priority:** **P2**

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "categoryName": "Fashion",
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
        "tag": "Rising Topic",
        "title": "Sustainable Fashion",
        "description": "Growing interest among audiences searching for eco-friendly capsule wardrobes."
      },
      {
        "tag": "Trending Format",
        "title": "Short-Form Video",
        "description": "15-30s outfit transitions & GRWM format driving +48% higher engagement rates."
      }
    ]
  }
}
```

* **Frontend Consumer:** `CategoryInsightsController`

---

### 3.12. Creator Avatar Upload (Multipart Form-Data)
**Purpose:** Uploads, processes, and persists creator profile picture to cloud storage (S3/Cloudinary/GCS).

* **Endpoint:** `POST /api/v1/creators/me/avatar`
* **HTTP Method:** `POST`
* **Authentication:** Bearer Token
* **Content-Type:** `multipart/form-data`
* **Priority:** **P1**

#### Form Fields:
- `avatar`: Binary Image File (JPEG, PNG, WebP — max 5MB)

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Profile photo updated successfully",
  "data": {
    "avatarUrl": "https://cdn.lalaai.com/avatars/user_2_1726849200.jpg"
  }
}
```

* **Frontend Consumer:** `EditProfileView._pickImage()`

---

### 3.13. Data Export & Account Deletion
**Purpose:** GDPR/CCPA compliant data export and account deletion.

* **Endpoints:**
  - `POST /api/v1/settings/export` (Body: `{"dataType": "FULL_ANALYTICS|SCRIPTS|PROFILE"}`)
  - `DELETE /api/v1/users/me`
* **Priority:** **P2**

* **Frontend Consumer:** `SettingsController.exportData()`, `SettingsController.deleteAccount()`

---

### 3.14. Push Notification Token Registration
**Purpose:** Registers Firebase Cloud Messaging (FCM) or Apple Push Notification Service (APNs) device token.

* **Endpoint:** `POST /api/v1/notifications/token`
* **HTTP Method:** `POST`
* **Authentication:** Bearer Token
* **Priority:** **P2**

#### Request Body:
```json
{
  "token": "fcm_token_device_abc123...",
  "platform": "ANDROID",
  "deviceId": "device_uuid_901"
}
```

---

## 4. Summary Checklist for Backend Team

- [ ] **1. Deploy AI Studio Generation:** Connect `POST /api/v1/studio/scripts/generate` and `POST /api/v1/studio/hooks/generate` to OpenAI/Claude pipeline.
- [ ] **2. Deploy Trend Engine:** Implement `GET /api/v1/trends` and `GET /api/v1/trends/{trendId}` with periodic scraping/caching.
- [ ] **3. Implement Content Calendar CRUD:** Deploy `GET /api/v1/calendar/posts` and `POST/PUT/DELETE` routes with database table.
- [ ] **4. Implement Competitor Analytics:** Deploy `GET /api/v1/competitors/analyze` integrating public YouTube & Instagram profile endpoints.
- [ ] **5. Implement Avatar S3 Upload:** Deploy `POST /api/v1/creators/me/avatar` with multipart handling.
- [ ] **6. Implement Bookmarks & Discover:** Deploy `GET /api/v1/discover` and `GET/POST/DELETE /api/v1/creators/me/bookmarks`.
