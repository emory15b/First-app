import Foundation

struct ShippingAddress: Equatable {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var line1: String = ""
    var line2: String = ""
    var city: String = "Miami"
    var state: String = "FL"
    var postalCode: String = ""
    var country: String = "US"

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !line1.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        state.count == 2 &&
        postalCode.count >= 5
    }
}

struct ShippingRate: Identifiable, Equatable {
    let id: String
    let carrier: String
    let service: String
    let amountCents: Int
    let estimatedDays: String
    let provider: String

    var amountDisplay: String {
        amountCents == 0 ? "Free" : String(format: "$%.2f", Double(amountCents) / 100.0)
    }
}

/// Shippo-backed shipping quotes. Uses live API when `SHIPPO_API_TOKEN` is set;
/// otherwise returns realistic Florida demo rates so the checkout flow works offline.
actor ShippoService {
    static let shared = ShippoService()

    /// Replace with your Shippo test/live token, or inject via Info.plist / xcconfig.
    private var apiToken: String {
        Bundle.main.object(forInfoDictionaryKey: "SHIPPO_API_TOKEN") as? String ?? ""
    }

    private let origin: [String: String] = [
        "name": "Freeze Dried Apples",
        "street1": "1000 Brickell Ave",
        "city": "Miami",
        "state": "FL",
        "zip": "33131",
        "country": "US",
        "phone": "3055550140"
    ]

    func quoteRates(
        for address: ShippingAddress,
        cart: [CartItem],
        freeShipping: Bool
    ) async throws -> [ShippingRate] {
        if freeShipping {
            return [
                ShippingRate(
                    id: "free_bundle",
                    carrier: "Freeze Dried Apples",
                    service: "Free Florida bundle shipping",
                    amountCents: 0,
                    estimatedDays: "2–4 business days",
                    provider: "Shippo"
                )
            ]
        }

        let weightOz = cart.reduce(0.0) { $0 + ($1.sku.weightOz * Double($1.quantity)) }

        if apiToken.isEmpty || apiToken.hasPrefix("YOUR_") {
            return demoRates(weightOz: weightOz)
        }

        return try await fetchShippoRates(address: address, weightOz: max(weightOz, 1))
    }

    private func demoRates(weightOz: Double) -> [ShippingRate] {
        let base = weightOz <= 2 ? 499 : (weightOz <= 8 ? 699 : 899)
        return [
            ShippingRate(
                id: "usps_ground",
                carrier: "USPS",
                service: "Ground Advantage",
                amountCents: base,
                estimatedDays: "2–5 business days",
                provider: "Shippo (demo)"
            ),
            ShippingRate(
                id: "ups_ground",
                carrier: "UPS",
                service: "Ground",
                amountCents: base + 250,
                estimatedDays: "1–3 business days",
                provider: "Shippo (demo)"
            ),
            ShippingRate(
                id: "fedex_home",
                carrier: "FedEx",
                service: "Home Delivery",
                amountCents: base + 350,
                estimatedDays: "1–3 business days",
                provider: "Shippo (demo)"
            )
        ]
    }

    private func fetchShippoRates(address: ShippingAddress, weightOz: Double) async throws -> [ShippingRate] {
        let payload: [String: Any] = [
            "address_from": origin,
            "address_to": [
                "name": address.name,
                "street1": address.line1,
                "street2": address.line2,
                "city": address.city,
                "state": address.state,
                "zip": address.postalCode,
                "country": address.country,
                "email": address.email,
                "phone": address.phone
            ],
            "parcels": [[
                "length": "8",
                "width": "6",
                "height": "3",
                "distance_unit": "in",
                "weight": String(format: "%.2f", weightOz),
                "mass_unit": "oz"
            ]],
            "async": false
        ]

        var request = URLRequest(url: URL(string: "https://api.goshippo.com/shipments/")!)
        request.httpMethod = "POST"
        request.setValue("ShippoToken \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ShippoError.requestFailed
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let rates = json?["rates"] as? [[String: Any]] ?? []

        let mapped: [ShippingRate] = rates.compactMap { rate in
            guard
                let objectId = rate["object_id"] as? String,
                let provider = rate["provider"] as? String,
                let service = rate["servicelevel"] as? [String: Any],
                let serviceName = service["name"] as? String,
                let amountString = rate["amount"] as? String,
                let amount = Double(amountString)
            else { return nil }

            let days = rate["estimated_days"] as? Int
            return ShippingRate(
                id: objectId,
                carrier: provider,
                service: serviceName,
                amountCents: Int((amount * 100).rounded()),
                estimatedDays: days.map { "\($0) business days" } ?? "Varies",
                provider: "Shippo"
            )
        }

        return mapped.sorted { $0.amountCents < $1.amountCents }
    }
}

enum ShippoError: LocalizedError {
    case requestFailed

    var errorDescription: String? {
        "Unable to fetch shipping rates from Shippo. Please try again."
    }
}
