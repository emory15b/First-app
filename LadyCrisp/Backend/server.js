/**
 * Lady Crisp — Stripe PaymentIntent backend
 *
 * Usage:
 *   export STRIPE_SECRET_KEY=sk_test_...
 *   npm install && npm start
 *
 * Then set Info.plist STRIPE_BACKEND_URL to http://localhost:4242
 * (or your deployed URL). Never put the secret key in the iOS app.
 */

const express = require("express");
const cors = require("cors");
const Stripe = require("stripe");

const app = express();
const port = process.env.PORT || 4242;
const stripeSecret = process.env.STRIPE_SECRET_KEY;

if (!stripeSecret) {
  console.warn("Warning: STRIPE_SECRET_KEY is not set. /create-payment-intent will fail until it is.");
}

const stripe = stripeSecret ? new Stripe(stripeSecret) : null;

app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ ok: true, brand: "Lady Crisp", market: "Miami FL" });
});

app.post("/create-payment-intent", async (req, res) => {
  try {
    if (!stripe) {
      return res.status(500).json({ error: "STRIPE_SECRET_KEY not configured" });
    }

    const { amount, currency = "usd", customer_email, shipping, metadata = {} } = req.body || {};

    if (!amount || amount < 50) {
      return res.status(400).json({ error: "Invalid amount" });
    }

    const intent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: { enabled: true },
      receipt_email: customer_email,
      shipping: shipping
        ? {
            name: shipping.name,
            address: {
              line1: shipping.address?.line1,
              line2: shipping.address?.line2 || undefined,
              city: shipping.address?.city,
              state: shipping.address?.state,
              postal_code: shipping.address?.postal_code,
              country: shipping.address?.country || "US",
            },
          }
        : undefined,
      metadata: {
        ...metadata,
        shippo_rate_id: shipping?.rate_id || "",
        shipping_amount: String(shipping?.amount ?? 0),
        carrier: shipping?.carrier || "",
        service: shipping?.service || "",
      },
    });

    res.json({
      clientSecret: intent.client_secret,
      paymentIntentId: intent.id,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || "PaymentIntent creation failed" });
  }
});

app.listen(port, () => {
  console.log(`Lady Crisp Stripe backend listening on http://localhost:${port}`);
});
