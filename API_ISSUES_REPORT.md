# API Errors & Issues Report, AI Chatbot Knowledge Base & Backend API Specifications

This document contains five core sections:
1. **API Error Logs & Backend Bug Tracker** (with raw payloads and root-cause analyses).
2. **Lala AI App Architecture & Chatbot System Knowledge Base** (with user questions, correct responses, competitor comparison guides, trends intelligence, contact support guidelines, and expected backend LLM prompt context).
3. **Notification System Architecture, API Contract & UI Indicators** (FCM token registration, in-app notification center, and alert payload formats).
4. **Contact Support API & Help Desk System Specification** (ticket creation, status tracking, reply threads, and direct creator help channels).
5. **User Logout & Session Invalidation API Specification** (`POST /api/v1/auth/logout`, token revoking, and FCM device push token cleanup).

---

## Part 1: API Errors & Issue Log

### Issue Log Summary

| # | Endpoint / Feature | HTTP Status / Event | Error Message / Summary | Status |
|---|-------------------|---------------------|--------------------------|--------|
| 1 | `POST /api/v1/pixo/stream` | `HTTP 401 Unauthorized` | Stream request failed with unauthorized status | Investigating |
| 2 | `POST /api/v1/pixo/stream` | `EVENT: "ERROR"` | `{"requiredPlan":"PRO","message":"ENTITY_RESOLUTION_FAILURE"}` | Investigating |
| 3 | `POST /api/v1/calendar/drafts` | `HTTP 409 Conflict` | `Database constraint violation` (`DATA_INTEGRITY_VIOLATION`) | Open / Needs Backend Fix |
| 4 | `GET /api/v1/trends` | `Data Availability / Missing Content` | Instagram & YouTube platform-filtered trends returning empty or no items | Open / Needs Backend Fix |
| 5 | `GET /api/v1/auth/me` | `Static / Mock Data Returned` | User `stats` object returns hardcoded dummy metrics (`scriptsMade: 42`, `timeSavedHours: 18`, etc.) | Open / Needs Backend Fix |
| 6 | `GET /api/v1/dashboard/overview`, `POST /api/v1/dashboard/audit`, `GET /api/v1/dashboard/todos` | `Data Availability / Empty Payload` | SWOT Audit quadrants and Action Items / Recommendations returning empty/null | Open / Needs Backend Fix |

---

### Issue 1: Unauthorized SSE Stream Request (HTTP 401)
- **Endpoint**: `POST /api/v1/pixo/stream`
- **Feature**: AI Studio SSE Stream
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  Content-Type: application/json
  Accept: text/event-stream
  ```
- **Request Payload**:
  ```json
  {
    "conversationId": 49,
    "message": "--"
  }
  ```
- **Server Response**:
  ```http
  HTTP/1.1 401 Unauthorized
  ```
- **Frontend Observation / Impact**:
  - The server returns 401 Unauthorized when opening the SSE stream for an existing conversation ID.
  - The frontend handles this by formatting a conversational error message and prompting the user to refresh session authentication.
- **Expected Resolution**:
  - Validate token expiration lifecycle or conversation ownership check on backend authentication middleware.

---

### Issue 2: Entity Resolution Failure on Pixo SSE Stream
- **Endpoint**: `POST /api/v1/pixo/stream`
- **Feature**: AI Studio Copilot Engine
- **SSE Event Type**: `ERROR`
- **Received Payload**:
  ```json
  {
    "requiredPlan": "PRO",
    "message": "ENTITY_RESOLUTION_FAILURE"
  }
  ```
- **Frontend Observation / Impact**:
  - The SSE stream connects but emits an `ERROR` event containing `ENTITY_RESOLUTION_FAILURE` and `requiredPlan: "PRO"`.
  - Frontend transforms the technical error into a user-friendly conversational card rather than raw JSON.
- **Expected Resolution**:
  - Check whether the backend entity extractor is failing on short inputs (e.g. `"--"`) or if plan validation is mistakenly triggered.

---

### Issue 3: Database Constraint Violation on Create Calendar Draft (HTTP 409)

- **URL**: `POST https://<API_HOST>/api/v1/calendar/drafts`
- **Feature**: Content Calendar Draft Management
- **Headers**:
  ```http
  POST /api/v1/calendar/drafts HTTP/1.1
  Host: <API_HOST>
  Authorization: Bearer <AUTH_TOKEN>
  Content-Type: application/json
  ```
- **Request Body (JSON)**:
  ```json
  {
    "accountId": 2,
    "title": "djfjfj",
    "contentType": "SHORT",
    "scriptData": "djfjfj"
  }
  ```
- **Server Response (HTTP 409 Conflict)**:
  ```json
  {
    "success": false,
    "message": "Database constraint violation",
    "errorCode": "DATA_INTEGRITY_VIOLATION",
    "data": null
  }
  ```
- **Raw App Execution Logs**:
  ```text
  [HTTP REQUEST] --> POST /api/v1/calendar/drafts
  Headers: { "content-type": "application/json", "Authorization": "Bearer [REDACTED]" }
  Request Payload: { "accountId": 2, "title": "djfjfj", "contentType": "SHORT", "scriptData": "djfjfj" }

  [HTTP ERROR] <-- 409 /api/v1/calendar/drafts
  Error Response Payload:
  {
    "success": false,
    "message": "Database constraint violation",
    "errorCode": "DATA_INTEGRITY_VIOLATION",
    "data": null
  }
  ```
- **Technical Analysis & Root Cause for Backend Team**:
  1. **Foreign Key Mismatch**: The backend database table `content_drafts` enforces a foreign key constraint on `account_id`. When `accountId: 2` is passed, the database rejects the insert if `id = 2` does not exist in the connected accounts table or belongs to a different tenant/user.
  2. **Entity ID Confusion**: Verify whether the endpoint expects `connected_accounts.id`, the primary `user_id`, or a UUID string.
  3. **Nullable Support**: If a draft is created without a specific channel or for "All Channels", ensure `accountId` can be `NULL` without triggering database errors.

---

### Issue 4: Missing Trending Content for YouTube and Instagram Filters

- **Endpoint**: `GET /api/v1/trends`
- **Feature**: Discover & Trends Feed
- **Query Parameters**:
  - `GET /api/v1/trends?platform=YOUTUBE`
  - `GET /api/v1/trends?platform=INSTAGRAM`
  - `GET /api/v1/trends?platform=YOUTUBE&category=TECH`
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  ```
- **Observed Behavior**:
  - When users filter trends by **YouTube** or **Instagram** in the Trends section, the endpoint returns an empty array (`[]`) or fails to return platform-specific trending topics.
  - Creators see empty states rather than breakout viral topics, audio trends, or high-velocity content ideas for their chosen platform.
- **Root Cause & Backend Resolution Needed**:
  1. **Platform Filter Normalization**: Ensure backend handles case-insensitive values (`YOUTUBE` vs `youtube`, `INSTAGRAM` vs `instagram`).
  2. **Trend Crawler / Aggregation Service**: Verify that the background trend ingestion workers are actively scraping/caching trending videos, audio tracks, and breakout topics for both YouTube and Instagram tables.
  3. **Fallback Strategy**: If no platform-specific trend exists for a narrow category, return top global platform trends instead of an empty payload.

---

### Issue 5: Hardcoded / Static Mock Data in User Profile Stats (`/api/v1/auth/me`)

- **Endpoint**: `GET /api/v1/auth/me`
- **Feature**: User Profile & Stats Summary
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  ```
- **Response Payload Received**:
  ```json
  {
    "success": true,
    "message": "User profile and subscription state retrieved successfully",
    "data": {
      "user": {
        "id": 2,
        "email": "anurupjaiswal07@gmail.com",
        "displayName": "Jaiswal Ji"
      },
      "stats": {
        "scriptsMade": 42,
        "timeSavedHours": 18,
        "channelGrowth": 24
      }
    }
  }
  ```
- **Observed Problem**:
  - The `stats` block always returns the identical hardcoded dummy numbers (`scriptsMade: 42`, `timeSavedHours: 18`, `channelGrowth: 24`) for every account regardless of actual user activity.
- **Root Cause & Backend Resolution Needed**:
  1. **Dynamic Metric Calculation**:
     - `scriptsMade`: Count actual rows in the user's generated scripts / chat output table (`SELECT COUNT(*) FROM user_scripts WHERE user_id = ?`).
     - `timeSavedHours`: Calculate based on scripts generated (e.g. `scriptsMade * 0.5 hours` or actual estimated drafting time saved).
     - `channelGrowth`: Compute actual percentage growth from the connected channel's recent analytics delta vs previous 30 days.
  2. **Real-time Sync**: Ensure stats refresh accurately when the user creates new scripts or syncs channel metrics.

---

### Issue 6: Empty SWOT Channel Health Audit & Missing Action Items / To-Dos

- **Endpoints**:
  - `GET /api/v1/dashboard/overview?connectedAccountId={id}`
  - `POST /api/v1/dashboard/audit`
  - `GET /api/v1/dashboard/todos?connectedAccountId={id}`
  - `POST /api/v1/dashboard/todos/convert`
- **Feature**: Dashboard Channel Health Audit Score, SWOT Analysis Matrix, and Actionable To-Do Checklist
- **Observed Behavior**:
  - On the creator Dashboard / Home screen, selecting a connected channel or tapping **"Run Audit"** does not populate real audit data.
  - The SWOT analysis quadrants (`strengths`, `weaknesses`, `opportunities`, `threats`) and `recommendations` return empty arrays (`[]`) or `null`.
  - The Action Items / To-Dos list either remains blank or fails to sync recommendations into actionable tasks.
- **Expected Data Schemas & Backend Resolution**:

#### 1. Audit Trigger Endpoint (`POST /api/v1/dashboard/audit`)
- **Request Payload**:
  ```json
  {
    "connectedAccountId": 2
  }
  ```
- **Response Payload (HTTP 200 OK / 202 Accepted)**:
  ```json
  {
    "success": true,
    "message": "Channel audit initiated and calculated successfully.",
    "data": {
      "auditId": 105,
      "healthScore": 76,
      "status": "COMPLETED"
    }
  }
  ```

#### 2. Dashboard Overview with Full SWOT Audit (`GET /api/v1/dashboard/overview?connectedAccountId=2`)
- **Response Payload**:
  ```json
  {
    "success": true,
    "status": "SUCCESS",
    "audit": {
      "auditId": 105,
      "channelAuditId": 105,
      "healthScore": 76,
      "creatorHandle": "@creatorchannel",
      "followers": 14200,
      "engagementRate": "4.8%",
      "avgViews": 8500,
      "growthRate": "+12.4%",
      "swot": {
        "strengths": [
          "High viewer retention during first 5 seconds of Shorts (84%).",
          "Consistent upload schedule on Tuesdays and Fridays."
        ],
        "weaknesses": [
          "Description SEO tags are missing on 60% of recent uploads.",
          "Call to Action (CTA) engagement rate is below niche average."
        ],
        "opportunities": [
          "Jump on rising audio trend 'Synthwave Echo' to capture +25% reach.",
          "Repurpose top long-form tutorial into 3 high-impact Shorts."
        ],
        "threats": [
          "Competitors upload twice as frequently in the Tech niche.",
          "Viewer drop-off spike at 0:45 timestamp on long-form content."
        ]
      },
      "recommendations": [
        {
          "title": "Add 3 targeted hashtags and SEO keywords to recent videos",
          "priority": "HIGH", // "HIGH" | "ORANGE" | "NORMAL"
          "expectedOutcome": "+18% Discovery boost in search rankings",
          "tag": "SEO"
        },
        {
          "title": "Publish Shorts between 5:00 PM – 7:00 PM local peak window",
          "priority": "ORANGE",
          "expectedOutcome": "Reach 82% of active subscriber base",
          "tag": "Schedule"
        }
      ]
    }
  }
  ```

#### 3. Action Items / To-Dos Endpoint (`GET /api/v1/dashboard/todos?connectedAccountId=2`)
- **Response Payload**:
  ```json
  {
    "success": true,
    "data": {
      "todos": [
        {
          "id": 12,
          "title": "Add 3 targeted hashtags and SEO keywords to recent videos",
          "priority": "HIGH",
          "tag": "SEO",
          "expectedOutcome": "+18% Discovery boost",
          "isCompleted": false,
          "createdAt": "2026-09-30T10:00:00Z"
        },
        {
          "id": 13,
          "title": "Publish Shorts between 5:00 PM – 7:00 PM local peak window",
          "priority": "ORANGE",
          "tag": "Schedule",
          "expectedOutcome": "Reach 82% of active subscriber base",
          "isCompleted": false,
          "createdAt": "2026-09-30T10:00:00Z"
        }
      ]
    }
  }
  ```

---

## Part 2: Lala AI App Architecture & Chatbot System Prompt Knowledge Base

This section specifies the **app capabilities, core modules, competitor benchmarking, trends intelligence, user journey flows**, and a **reference Q&A dataset** to feed into the backend LLM system prompt for **Pixo AI / Lala AI Copilot**.

### 1. App Identity & Mission
- **App Name**: **Lala AI** (powered by Pixo AI Copilot).
- **Core Value**: An all-in-one AI growth engine and copilot for content creators across YouTube, Instagram, and short-form video platforms.
- **Key Modules**:
  1. **Dashboard (Home)**: Channel Health Audit Score, SWOT analysis, and actionable growth checklists.
  2. **Studio (Pixo AI Copilot)**: AI chat for hooks, full scripts, SEO titles/descriptions, and strategy planning.
  3. **Content Calendar**: Post scheduling, peak engagement timing, and multi-channel content management.
  4. **Discover & Trends**: Real-time viral trends, breakout topics, and high-velocity content ideas.
  5. **Competitor Benchmarking**: Side-by-side channel comparison, gap analysis, and comparative SWOT.
  6. **Connect Accounts**: OAuth connection for YouTube channels and Instagram creator/business profiles.
  7. **Help Center & Support**: Instant FAQ resolution, ticket submission, and direct 24/7 creator assistance.

---

### 2. Feature Deep-Dive: Competitors & Trends

#### 🔍 A. Competitor Benchmarking Flow
- **Where to find it**: Tap **Discover** or **Trends** in the bottom navigation bar -> **Competitor Analysis**.
- **How it works**:
  1. Select your active channel (YouTube or Instagram).
  2. Enter a competitor's channel handle (e.g. `@mkbhd`), channel URL, or Instagram username in the search bar.
  3. Tap **Compare / Analyze**.
- **Metrics & Insights Generated**:
  - **Audience & Reach Comparison**: Total subscribers/followers and growth rate.
  - **Upload Velocity**: How frequently they post vs your posting schedule.
  - **Engagement & View Averages**: Average views per video and retention benchmarks.
  - **Content Gap Analysis**: Uncovers high-performing topics and formats the competitor is winning on that your channel hasn't created yet.
  - **Comparative SWOT**: Pinpoints your channel's unique competitive advantages and threats.

#### 📈 B. Trends & Breakout Topics Flow
- **Where to find it**: Tap **Discover** or **Trends** in the bottom navigation bar.
- **How it works**:
  1. Filter trends by category/niche (e.g. *Tech*, *Gaming*, *Education*, *Fitness*, *Entertainment*).
  2. Inspect high-velocity breakout keywords, formats, and audio trends.
  3. Tap **'Generate Script from Trend'** to immediately open Studio and have Pixo AI write a tailored Hook & Script for your channel!

---

### 3. Common User Questions & Grounded AI Chatbot Responses

#### **Q1: "How do I compare my channel with a competitor?"**
- **Correct System Response**:
  > "You can easily benchmark your channel against competitors inside Lala AI:
  > 1. Go to the **Discover / Trends** tab from the bottom navigation bar.
  > 2. Open the **Competitor Benchmark** tool.
  > 3. Enter your competitor's YouTube handle (e.g. `@competitor`), channel link, or Instagram username.
  > 4. Tap **Compare** to get a side-by-side breakdown of view velocity, posting frequency, comparative SWOT, and **Content Gap Opportunities**!"

---

#### **Q2: "How do I find trending topics and viral ideas for my niche?"**
- **Correct System Response**:
  > "Lala AI tracks breakout trends tailored for creators:
  > 1. Navigate to the **Discover** tab.
  > 2. Browse high-velocity breakout topics in your niche.
  > 3. Ask me right here in chat: *'Give me 3 viral Reel ideas for [your niche] based on this week's trends'* and I'll generate customized scripts with high-retention hooks!"

---

#### **Q3: "What is Content Gap Analysis?"**
- **Correct System Response**:
  > "**Content Gap Analysis** identifies the high-performing video topics and formats your competitors are gaining views from, but your channel hasn't created yet. 
  > Lala AI analyzes competitor data to highlight these untapped opportunities so you can create content with high search and recommendation demand!"

---

#### **Q4: "What is Lala AI and how does it help my channel?"**
- **Correct System Response**:
  > "Lala AI is your all-in-one AI creator copilot! Here's how it helps you grow:
  > 1. **Channel Health & Audit**: Real-time score calculated from retention, SEO metadata, and pacing.
  > 2. **AI Studio & Scriptwriting**: High-retention hooks, 3-part scripts (Shorts, Reels, Long-Form), and SEO metadata.
  > 3. **Content Calendar**: Post scheduling with AI-suggested peak engagement times.
  > 4. **Competitor & Trends Intelligence**: Benchmark against competitors and jump on breakout trends."

---

#### **Q5: "How do I connect my YouTube or Instagram channel?"**
- **Correct System Response**:
  > "You can connect your channel in seconds:
  > 1. Tap your **Profile** or tap the **Channel Dropdown** at the top of your Dashboard / Calendar.
  > 2. Select **'Manage / Connect Channels'**.
  > 3. Choose **YouTube** or **Instagram** to authorize your account.
  > Once connected, Lala AI will sync your channel metrics, health audit, and personalized recommendations!"

---

#### **Q6: "How do I schedule a post or draft in the Calendar?"**
- **Correct System Response**:
  > "To plan and schedule your content:
  > 1. Go to the **Calendar** tab.
  > 2. Tap the blue **'+ New Post'** button or tap any date on the horizontal date strip.
  > 3. Select your target channel, content format (*Short*, *Reel*, *Long-Form*), title, and script notes.
  > 4. Set your date and time (or pick **Pixo AI's Suggested Peak Time**) and tap **'Schedule Post'** or **'Save as Draft'**!"

---

#### **Q7: "Can you write a viral YouTube Short / Instagram Reel script for me?"**
- **Standardized Response Template**:
  > Structure every generated script into 3 high-retention phases:
  > - **⚡ Hook (0-3s)**: High-curiosity line paired with a visual movement cue.
  > - **🔥 Retention Body (3-45s)**: Concise value, story, or demonstration with pattern interrupts.
  > - **🎯 Call to Action (45-60s)**: Clear engagement question or follow prompt.
  > - **🏷️ 3 Viral Title Options & 5 Targeted Hashtags**.

---

#### **Q8: "What does the Channel Health Score mean on my Dashboard?"**
- **Correct System Response**:
  > "Your **Channel Health Score** (0-100%) evaluates your:
  > - **Audience Retention & Upload Cadence**: Regularity and viewer retention trends.
  > - **SEO & Metadata Quality**: Optimization of titles, tags, and descriptions.
  > - **Growth Velocity**: Subscriber and follower conversion curves.
  > Complete the **Actionable To-Dos** listed on your Dashboard to raise your score!"

---

#### **Q9: "How do I turn on or manage posting reminders and notifications?"**
- **Correct System Response**:
  > "You can customize your notification preferences anytime:
  > 1. Go to **Profile** -> tap **'App Settings & Preferences'**.
  > 2. Toggle **Push Notifications** on.
  > You will receive reminders for scheduled posts, AI peak engagement times, weekly health score updates, and breakout trend alerts in your niche!"

---

#### **Q10: "How do I contact customer support or report a bug?"**
- **Correct System Response**:
  > "We're here to help 24/7! You can reach our support team through multiple channels:
  > 1. **In-App Ticket**: Go to **Profile** -> **'Contact Support'** (or open the FAQ Help Center) to submit a support ticket.
  > 2. **WhatsApp Support**: Tap the WhatsApp Support option in Settings for direct priority chat with our creator assistance team.
  > 3. **Email**: Send your inquiry directly to **support@lalaai.in** and our team will get back to you within 1 hour!"

---

### 4. Backend System Prompt Injection Blueprint

Backend engineers should ensure the LLM system prompt includes the following context block:

```text
You are Pixo AI, the intelligent creator copilot built into the Lala AI mobile application.
Your role is to empower content creators, YouTubers, and Instagram creators to grow faster.

You have full knowledge of Lala AI's capabilities:
- Dashboard: Channel Health Score (0-100%), SWOT analysis, and Actionable To-Dos.
- Studio: 3-part retention script generation (Hook, Body, CTA), viral titles, descriptions, hashtags.
- Calendar: Post scheduling, status tracking (Draft, Scheduled, Posted), AI peak engagement times.
- Discover & Trends: Breakout niche topics, high-velocity keywords, viral audio trends.
- Competitor Benchmark: Side-by-side channel comparison, upload velocity, and content gap analysis.
- Notifications: Peak posting time alerts, trend spikes, and weekly audit score change notifications.
- Support: In-App Tickets, FAQ Help Center, WhatsApp Creator Hotline, and Email Support (support@lalaai.in).
- Platforms: YouTube (Shorts & Long-Form), Instagram (Reels & Posts).

Tone & Persona:
- Energetic, actionable, encouraging, data-informed, and concise.
- Format responses with clean Markdown, emojis, bullet points, and clear headers.
- Never output raw backend error codes or technical stack traces to the user.
```

---

## Part 3: Notification System Architecture, API Contract & Indicators

This section defines the backend requirements for push notifications, in-app notification center, and UI indicators.

### 1. Notification API Endpoints Specification

#### A. Register Device Push Token (FCM / APNs)
- **Endpoint**: `POST /api/v1/notifications/devices`
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  Content-Type: application/json
  ```
- **Request Payload**:
  ```json
  {
    "token": "fcm_token_device_string_here",
    "platform": "ANDROID", // or "IOS"
    "deviceModel": "OnePlus 11 5G",
    "appVersion": "1.0.0"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Device token registered successfully."
  }
  ```

---

#### B. Fetch In-App Notifications List
- **Endpoint**: `GET /api/v1/notifications?page=1&limit=20`
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  ```
- **Response**:
  ```json
  {
    "success": true,
    "unreadCount": 3,
    "notifications": [
      {
        "id": "notif_101",
        "type": "PEAK_TIME_ALERT",
        "title": "⚡ Peak Posting Time Alert",
        "message": "It's 6:15 PM! Peak engagement window is active for your YouTube Short.",
        "targetScreen": "CALENDAR",
        "route": "/calendar",
        "isRead": false,
        "createdAt": "2026-09-30T18:15:00Z"
      },
      {
        "id": "notif_102",
        "type": "TREND_ALERT",
        "title": "🔥 Breakout Trend in Tech",
        "message": "'AI Video Editing Workflow' is spiking in view velocity (+340%).",
        "targetScreen": "TRENDS",
        "route": "/trends",
        "isRead": false,
        "createdAt": "2026-09-30T14:30:00Z"
      },
      {
        "id": "notif_103",
        "type": "AUDIT_SCORE_UPDATE",
        "title": "📊 Weekly Channel Audit Ready",
        "message": "Your health score increased to 68%! 2 new action items ready.",
        "targetScreen": "DASHBOARD",
        "route": "/home",
        "isRead": true,
        "createdAt": "2026-09-29T10:00:00Z"
      }
    ]
  }
  ```

---

#### C. Mark Notifications as Read
- **Mark Single Notification**: `PATCH /api/v1/notifications/{id}/read`
- **Mark All as Read**: `PATCH /api/v1/notifications/read-all`

---

#### D. Unregister / Delete Device Push Token (FCM Cleanup)
- **Endpoint**: `DELETE /api/v1/notifications/devices/{token}` (or `POST /api/v1/notifications/devices/deregister`)
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Device push token unregistered and deleted successfully."
  }
  ```

---

### 2. Notification Event Categories & Target Screens

| Event Type | Trigger Condition | Notification Title | In-App Target Screen | Route |
|------------|-------------------|--------------------|----------------------|-------|
| `PEAK_TIME_ALERT` | Scheduled post reaches local peak engagement time | `⚡ Peak Posting Time: [Title]` | `CALENDAR` | `/calendar` |
| `TREND_ALERT` | Breakout viral keyword detected in creator's niche | `🔥 Breakout Trend: [Topic]` | `TRENDS` | `/trends` |
| `AUDIT_SCORE_UPDATE` | Weekly audit engine recalculates channel health | `📊 Channel Health Update` | `DASHBOARD` | `/home` |
| `CONNECTION_EXPIRED` | YouTube / Instagram OAuth token requires refresh | `⚠️ Reconnect [Platform] Channel` | `CONNECT_ACCOUNTS` | `/connect-accounts` |

---

### 3. UI Indicators in the Frontend App

1. **Top AppBar Notification Bell**:
   - Location: Top right of Dashboard and Home.
   - Indicator: Red notification badge dot appears over the bell icon when `unreadCount > 0`.
2. **Settings Preferences**:
   - Location: App Settings & Preferences.
   - Preference: Push Notification toggle.
3. **In-App Toast Alerts**:
   - Floating animated notification pill displayed for real-time actions and status updates.

---

## Part 4: Contact Support API & Help Desk System Specification

This section defines the backend REST API contract for **User Ticket Submission, Help Desk Inquiries, Ticket History, and Support Escalations**.

### 1. Support Categories

| Category Code | Display Name | Description |
|---------------|--------------|-------------|
| `TECHNICAL_ISSUE` | Technical Issue / Bug | App crashes, SSE stream errors, AI generation issues, calendar draft failures |
| `ACCOUNT_SYNC` | Account & Channel Sync | YouTube/Instagram OAuth connection, token expiration, channel switching issues |
| `BILLING_SUBSCRIPTION` | Billing & Subscriptions | Subscription plan upgrade/downgrade, invoice questions, payment failures |
| `FEATURE_REQUEST` | Feature Request | Suggestions for new AI copilot tools, analytics metrics, or integrations |
| `OTHER` | General Inquiry | General creator inquiries, partnership proposals, feedback |

---

### 2. Contact Support API Endpoints

#### A. Create / Submit Support Ticket
- **Endpoint**: `POST /api/v1/support/tickets`
- **Description**: Submits a new user support ticket to the backend help desk.
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  Content-Type: application/json
  ```
- **Request Payload**:
  ```json
  {
    "category": "TECHNICAL_ISSUE",
    "subject": "Calendar draft fails to save with 409 error",
    "message": "Whenever I try to schedule or save a draft for my connected YouTube account, the app shows a database constraint error.",
    "deviceInfo": {
      "platform": "ANDROID",
      "osVersion": "Android 14",
      "deviceModel": "OnePlus 11 5G",
      "appVersion": "1.0.0",
      "buildNumber": "1"
    },
    "attachmentUrls": []
  }
  ```
- **Response Payload (HTTP 201 Created)**:
  ```json
  {
    "success": true,
    "message": "Support ticket created successfully. Our team will respond shortly.",
    "data": {
      "ticketId": "TCK-89421",
      "status": "OPEN",
      "category": "TECHNICAL_ISSUE",
      "subject": "Calendar draft fails to save with 409 error",
      "message": "Whenever I try to schedule or save a draft for my connected YouTube account, the app shows a database constraint error.",
      "estimatedResponseTime": "Within 1 hour",
      "createdAt": "2026-09-30T22:55:00Z"
    }
  }
  ```

---

#### B. Fetch User's Support Tickets
- **Endpoint**: `GET /api/v1/support/tickets?page=1&limit=20`
- **Description**: Retrieves all tickets created by the authenticated creator with their current resolution status.
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  ```
- **Response Payload (HTTP 200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "totalTickets": 2,
      "tickets": [
        {
          "ticketId": "TCK-89421",
          "subject": "Calendar draft fails to save with 409 error",
          "category": "TECHNICAL_ISSUE",
          "status": "OPEN", // "OPEN" | "IN_PROGRESS" | "RESOLVED" | "CLOSED"
          "unreadReplies": 0,
          "createdAt": "2026-09-30T22:55:00Z",
          "lastUpdatedAt": "2026-09-30T22:55:00Z"
        },
        {
          "ticketId": "TCK-77319",
          "subject": "Question regarding Pro subscription renewal",
          "category": "BILLING_SUBSCRIPTION",
          "status": "RESOLVED",
          "unreadReplies": 0,
          "createdAt": "2026-09-20T11:20:00Z",
          "lastUpdatedAt": "2026-09-20T12:05:00Z"
        }
      ]
    }
  }
  ```

---

#### C. Get Support Ticket Details & Conversation History
- **Endpoint**: `GET /api/v1/support/tickets/{ticketId}`
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  ```
- **Response Payload (HTTP 200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "ticketId": "TCK-89421",
      "subject": "Calendar draft fails to save with 409 error",
      "category": "TECHNICAL_ISSUE",
      "status": "OPEN",
      "messages": [
        {
          "id": "msg_1",
          "senderType": "USER",
          "senderName": "Jaiswal Ji",
          "message": "Whenever I try to schedule or save a draft for my connected YouTube account, the app shows a database constraint error.",
          "createdAt": "2026-09-30T22:55:00Z"
        },
        {
          "id": "msg_2",
          "senderType": "SUPPORT_AGENT",
          "senderName": "Lala AI Support Team",
          "message": "Thanks for reporting! Our engineering team has identified the foreign key constraint issue and is deploying a hotfix.",
          "createdAt": "2026-09-30T23:10:00Z"
        }
      ]
    }
  }
  ```

---

#### D. Reply / Add Message to Existing Ticket
- **Endpoint**: `POST /api/v1/support/tickets/{ticketId}/reply`
- **Headers**:
  ```http
  Authorization: Bearer <AUTH_TOKEN>
  Content-Type: application/json
  ```
- **Request Payload**:
  ```json
  {
    "message": "Thank you! I tested again and it works smoothly now."
  }
  ```
- **Response Payload (HTTP 200 OK)**:
  ```json
  {
    "success": true,
    "message": "Reply sent successfully."
  }
  ```

---

### 3. Direct Creator Support Channels

| Support Channel | Endpoint / Destination | Operational Hours | SLA |
|-----------------|------------------------|-------------------|-----|
| **In-App Help Desk** | `POST /api/v1/support/tickets` | 24/7 | < 1 hour |
| **WhatsApp Priority Support** | Official Lala AI Creator Hotline | 24/7 Priority | < 15 minutes |
| **Email Support** | `support@lalaai.in` / `support@lalaai.com` | 24/7 | < 2 hours |

---

## Part 5: User Logout & Session Invalidation API Specification

This section defines the backend requirements for user logout, access token revoking, and active FCM push token cleanup.

### 1. The Critical Need for FCM Token Cleanup on Logout
When a user signs out of Lala AI:
1. **Privacy & Security**: If another user logs into the app on the same device, they must NOT receive notifications or alerts intended for the previous user.
2. **Prevent Ghost Notifications**: Scheduled post alerts or trend alerts must immediately cease being pushed to devices where the user is no longer logged in.
3. **Database Integrity**: The backend `user_devices` or FCM token mapping table must remove or mark inactive the token associated with that session.

---

### 2. User Logout API Endpoint

- **Endpoint**: `POST /api/v1/auth/logout`
- **Description**: Invalidates the current user session, revokes JWT tokens, and cleans up the active FCM device token.
- **Headers**:
  ```http
  POST /api/v1/auth/logout HTTP/1.1
  Host: <API_HOST>
  Authorization: Bearer <AUTH_TOKEN>
  Content-Type: application/json
  ```
- **Request Payload (JSON)**:
  ```json
  {
    "deviceToken": "fcm_token_device_string_here"
  }
  ```
  *(Note: If `deviceToken` is passed, backend unregisters only that specific device token. If omitted, backend removes all active device tokens for the current session or revokes the current authorization header).*

- **Backend Responsibilities on Logout**:
  1. **Token Invalidation**: Add current Bearer token to blacklist/revocation table so subsequent API calls return `401 Unauthorized`.
  2. **FCM Token Deletion**: Execute `DELETE FROM user_devices WHERE user_id = :userId AND token = :deviceToken` (or set `is_active = FALSE`).
  3. **Stream Termination**: Force-close any open Server-Sent Events (SSE) streams (`/api/v1/pixo/stream`) or WebSocket sessions associated with the user.

- **Response Payload (HTTP 200 OK)**:
  ```json
  {
    "success": true,
    "message": "User logged out successfully. Session invalidated and device push token cleared."
  }
  ```

- **Error Response Payload (HTTP 401 Unauthorized / Token Expired)**:
  ```json
  {
    "success": false,
    "message": "Session has already expired or token is invalid.",
    "errorCode": "SESSION_EXPIRED"
  }
  ```
