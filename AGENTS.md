# Lady Crisp

SwiftUI iOS storefront for freeze-dried Pink Lady apples, plus a minimal Node.js Stripe PaymentIntent backend.

## Cursor Cloud specific instructions

- This repo has two parts with very different runtime requirements:
  - `LadyCrisp/` (SwiftUI iOS app + `LadyCrisp.xcodeproj`): requires macOS + Xcode 15 and an iOS 17 simulator. It **cannot be built or run** on the Linux Cloud Agent VM. Treat it as out of scope for building/running here; only static inspection is possible.
  - `LadyCrisp/Backend/` (Node.js/Express Stripe server): this is the only runnable/testable service on Linux.
- Backend run/test commands are in `LadyCrisp/Backend/package.json`. Start it with `npm start` from `LadyCrisp/Backend` (listens on `http://localhost:4242`, override with `PORT`). There are no automated tests and no lint config.
- The backend needs `STRIPE_SECRET_KEY` (a Stripe **test** secret key, `sk_test_...`) to actually create PaymentIntents via `POST /create-payment-intent`. Without it the server still boots and `GET /health` works, but `/create-payment-intent` returns `{"error":"STRIPE_SECRET_KEY not configured"}`. Set it as an env var / secret before exercising the checkout flow end-to-end.
- Gotcha: when `STRIPE_SECRET_KEY` is unset, the `/create-payment-intent` handler returns the "not configured" error **before** the amount validation, so even malformed requests report the missing-key error. Amount validation (`amount >= 50` cents) only runs once a key is present.
- The iOS app has a built-in Demo mode (used when `STRIPE_BACKEND_URL` is empty/placeholder in `LadyCrisp/Info.plist`) that simulates Stripe/Shippo, so the backend is only required for live-mode checkout.
