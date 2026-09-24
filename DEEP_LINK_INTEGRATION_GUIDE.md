  # Lala AI — Deep Linking & Existing Callback Discovery Guide

  **Domain:** `https://lala-ai-green.vercel.app/`  
  **Android Package Name:** `com.lalaai.app`  
  **iOS Bundle ID:** `com.lalaai.app`  

  ---

  ## 1. Message to Send to Backend Team (Request Existing Callbacks)

  Copy and send this directly to your backend / website developers:

  ```text
  Hi Team,

  We have implemented a flexible, centralized deep-linking router in the Flutter mobile app. 

  Instead of asking you to rewrite or modify your existing backend redirect logic, please provide the EXACT callback URLs, query parameters, and endpoints you are CURRENTLY using. We will configure the Flutter app to listen directly to your existing setup.

  Please fill in or confirm the details below:

  1. PAYMENT / SUBSCRIPTION REDIRECTS:
    - What is your existing success redirect URL?
      (e.g., https://lala-ai-green.vercel.app/subscription/success?orderId=... or /payment/success or /checkout/success?)
    - What query parameter name do you pass for the order/session ID?
      (e.g., orderId, order_id, sessionId, or id?)
    - What is your failure/cancel redirect URL?

  2. SOCIAL OAUTH REDIRECTS:
    - What exact OAuth redirect URI is registered for YouTube in Google Cloud Console?
      (e.g., https://lala-ai-green.vercel.app/oauth/youtube/callback or /api/v1/auth/youtube/callback?)
    - What exact OAuth redirect URI is registered for Instagram in Meta Developer Console?
      (e.g., https://lala-ai-green.vercel.app/oauth/instagram/callback?)
    - How does the mobile app receive confirmation? Does the browser redirect with code & state, or does the backend handle the exchange and redirect with a status flag?

  3. PASSWORD RESET EMAIL LINK:
    - What exact URL format is sent in the "Forgot Password" reset emails?
      (e.g., https://lala-ai-green.vercel.app/auth/reset-password?token=... or /reset-password?token=...?)
    - What query parameter name holds the token (e.g., token, resetToken, code)?

  4. DOMAIN ASSOCIATION FILES (One-time setup on Vercel):
    Please add these two files under public/.well-known/ on the website so Android & iOS open the app directly:
    - Android assetlinks.json:
      https://lala-ai-green.vercel.app/.well-known/assetlinks.json
      (Package: com.lalaai.app)
    - Apple apple-app-site-association:
      https://lala-ai-green.vercel.app/.well-known/apple-app-site-association
      (Bundle ID: com.lalaai.app)

  Thank you! Once you share your existing URLs, we will map them immediately in the app router with zero changes needed on your end.
  ```

  ---

  ## 2. Currently Supported Patterns in the Flutter App

  The Flutter app currently supports all the following patterns out-of-the-box (and can easily add any alias your backend team provides):

  ### A. Subscriptions & Payments
  * `https://lala-ai-green.vercel.app/subscription/success?orderId=...`
  * `https://lala-ai-green.vercel.app/subscription/failed?orderId=...`
  * `https://lala-ai-green.vercel.app/subscription/pending?orderId=...`
  * *Accepted parameter keys:* `orderId`, `order_id`, `id`, `sessionId`, `session_id`

  ### B. OAuth Connections
  * `https://lala-ai-green.vercel.app/oauth/youtube/callback?code=...&state=...`
  * `https://lala-ai-green.vercel.app/oauth/instagram/callback?code=...&state=...`
  * *Accepted error keys:* `error`, `error_description`, `message`

  ### C. Password Reset
  * `https://lala-ai-green.vercel.app/auth/reset-password?token=...`
  * `https://lala-ai-green.vercel.app/reset-password?token=...`
  * *Accepted token keys:* `token`, `reset_token`, `resetToken`, `code`

  ### D. Content, Social & Referral Links
  * `https://lala-ai-green.vercel.app/content/{id}`
  * `https://lala-ai-green.vercel.app/post/{id}`
  * `https://lala-ai-green.vercel.app/creator/{id}`
  * `https://lala-ai-green.vercel.app/share/{type}/{id}`
  * `https://lala-ai-green.vercel.app/invite/{code}`

  ---


  ### E. Open Mobile App

* `https://lala-ai-green.vercel.app/open-app`

**Purpose:**
This route is used by the website's **"Open in Mobile App"** button.

When the user taps the button:

`https://lala-ai-green.vercel.app/open-app`

the installed Lala AI mobile application should open.

The Flutter app does not need to navigate to a special screen for this route. It should simply open the normal application/home screen.L̥


  ## 3. Website Configuration (`https://lala-ai-green.vercel.app/`)

  ### A. Android Asset Links
  * **Target URL:** `https://lala-ai-green.vercel.app/.well-known/assetlinks.json`
  * **File Path in Website Repo:** `public/.well-known/assetlinks.json`
  * **Content-Type:** `application/json`

  ```json
  [
    {
      "relation": [
        "delegate_permission/common.handle_all_urls"
      ],
      "target": {
        "namespace": "android_app",
        "package_name": "com.lalaai.app",
        "sha256_cert_fingerprints": [
          "PASTE_YOUR_RELEASE_KEYSTORE_SHA256_HERE",
          "PASTE_YOUR_DEBUG_KEYSTORE_SHA256_HERE"
        ]
      }
    }
  ]
  ```

  ### B. Apple App Site Association
  * **Target URL:** `https://lala-ai-green.vercel.app/.well-known/apple-app-site-association`
  * **File Path in Website Repo:** `public/.well-known/apple-app-site-association`
  * **Response Header:** `Content-Type: application/json`

  ```json
  {
    "applinks": {
      "apps": [],
      "details": [
        {
          "appID": "<APPLE_TEAM_ID>.com.lalaai.app",
          "paths": [
            "*"
          ]
        }
      ]
    }
  }
  ```
