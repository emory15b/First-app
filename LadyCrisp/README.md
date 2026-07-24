# Freeze Dried Apples

SwiftUI iOS shop for **organic freeze-dried Pink Lady apples**, packed in Miami, Florida.

## Features

- **Product page** with full-bleed photo placeholders, Miami-focused copy, and pack selection
- **Single Pack** — `$1.99` with **paid Shippo shipping**
- **10-Pack Bundle** — `$20.00` with **free shipping**
- **Checkout** — address form, Shippo rate quotes, Stripe payment flow
- **Reviews** — local Miami neighborhood testimonials
- **Contact form** — simple in-app inquiry form
- **About** — separate brand story page

## Open in Xcode

1. Open `LadyCrisp.xcodeproj` on a Mac with Xcode 15+
2. Select an iPhone simulator or device (iOS 17+)
3. Set your Development Team under Signing & Capabilities
4. Run

## Configure Stripe & Shippo

Edit `LadyCrisp/Info.plist`:

| Key | Purpose |
| --- | --- |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key (`pk_test_…`) |
| `STRIPE_BACKEND_URL` | Your PaymentIntent server base URL |
| `SHIPPO_API_TOKEN` | Shippo API token |

### Demo mode (default)

Leave the placeholder values as-is. The app will:

- show realistic **Shippo demo rates** for singles
- apply **free shipping** for the 10-pack
- simulate a successful **Stripe** payment so you can walk the full UI

### Live mode

1. Start the sample backend:

```bash
cd Backend
export STRIPE_SECRET_KEY=sk_test_your_key
npm install
npm start
```

2. Set `STRIPE_BACKEND_URL` to `http://localhost:4242` (simulator) or your deployed URL  
3. Set `STRIPE_PUBLISHABLE_KEY` to your publishable key  
4. Set `SHIPPO_API_TOKEN` to your Shippo token  
5. For production card UI, add the [Stripe iOS SDK](https://stripe.com/docs/payments/accept-a-payment?platform=ios) via SPM and present `PaymentSheet` with the returned `clientSecret` in `OrderService`

## Project layout

```
LadyCrisp/
├── LadyCrispApp.swift
├── Models/          Product, cart, reviews
├── Views/           Shop, checkout, reviews, contact, about
├── Services/        Stripe + Shippo + orders
├── Theme/           Colors, atmosphere, typography
└── Assets.xcassets
Backend/             Minimal Stripe PaymentIntent server
```

## Brand notes

Freeze Dried Apples is a Miami-first snack brand: rose + orchard green palette, serif wordmark, soft coastal mist backgrounds, and placeholder product photography ready to swap for real pouch shots.
