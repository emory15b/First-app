import Foundation

struct PaymentIntentResult: Equatable {
    let clientSecret: String
    let paymentIntentId: String
    let amountCents: Int
    let isDemo: Bool
}

struct CheckoutSummary: Equatable {
    let items: [CartItem]
    let shipping: ShippingRate
    let address: ShippingAddress

    var subtotalCents: Int {
        items.reduce(0) { $0 + ($1.sku.priceCents * $1.quantity) }
    }

    var totalCents: Int {
        subtotalCents + shipping.amountCents
    }

    var totalDisplay: String {
        String(format: "$%.2f", Double(totalCents) / 100.0)
    }
}

/// Creates Stripe PaymentIntents via your backend when configured.
/// Without a backend URL, returns a demo client secret so UI checkout can be exercised.
actor StripeService {
    static let shared = StripeService()

    /// Point this at your server that creates PaymentIntents with the Stripe secret key.
    /// Never put the Stripe secret key in the iOS app.
    private var backendURL: String {
        Bundle.main.object(forInfoDictionaryKey: "STRIPE_BACKEND_URL") as? String ?? ""
    }

    private var publishableKey: String {
        Bundle.main.object(forInfoDictionaryKey: "STRIPE_PUBLISHABLE_KEY") as? String
            ?? "pk_test_YOUR_PUBLISHABLE_KEY"
    }

    var configuredPublishableKey: String { publishableKey }

    func createPaymentIntent(for summary: CheckoutSummary) async throws -> PaymentIntentResult {
        if backendURL.isEmpty || backendURL.contains("YOUR_") {
            // Demo mode — wire STRIPE_BACKEND_URL for live PaymentSheet.
            try await Task.sleep(nanoseconds: 450_000_000)
            return PaymentIntentResult(
                clientSecret: "pi_demo_secret_\(UUID().uuidString)",
                paymentIntentId: "pi_demo_\(UUID().uuidString.prefix(8))",
                amountCents: summary.totalCents,
                isDemo: true
            )
        }

        guard let url = URL(string: backendURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/create-payment-intent") else {
            throw StripeError.invalidBackend
        }

        let lineItems = summary.items.map {
            [
                "sku": $0.sku.rawValue,
                "quantity": $0.quantity,
                "unit_amount": $0.sku.priceCents
            ] as [String: Any]
        }

        let body: [String: Any] = [
            "amount": summary.totalCents,
            "currency": "usd",
            "customer_email": summary.address.email,
            "shipping": [
                "name": summary.address.name,
                "rate_id": summary.shipping.id,
                "amount": summary.shipping.amountCents,
                "carrier": summary.shipping.carrier,
                "service": summary.shipping.service,
                "address": [
                    "line1": summary.address.line1,
                    "line2": summary.address.line2,
                    "city": summary.address.city,
                    "state": summary.address.state,
                    "postal_code": summary.address.postalCode,
                    "country": summary.address.country
                ]
            ],
            "line_items": lineItems,
            "metadata": [
                "brand": "Freeze Dried Apples",
                "market": "Miami FL"
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw StripeError.requestFailed
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard
            let clientSecret = json?["clientSecret"] as? String,
            let intentId = json?["paymentIntentId"] as? String ?? json?["id"] as? String
        else {
            throw StripeError.invalidResponse
        }

        return PaymentIntentResult(
            clientSecret: clientSecret,
            paymentIntentId: intentId,
            amountCents: summary.totalCents,
            isDemo: false
        )
    }
}

enum StripeError: LocalizedError {
    case invalidBackend
    case requestFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidBackend: return "Stripe backend URL is invalid."
        case .requestFailed: return "Could not create a Stripe payment. Please try again."
        case .invalidResponse: return "Unexpected response from the payment server."
        }
    }
}
