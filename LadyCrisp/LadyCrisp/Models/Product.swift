import Foundation

enum ProductSKU: String, CaseIterable, Identifiable, Codable {
    case individual
    case bundle10

    var id: String { rawValue }

    var name: String {
        switch self {
        case .individual: return "Single Pack"
        case .bundle10: return "10-Pack Bundle"
        }
    }

    var subtitle: String {
        switch self {
        case .individual: return "One pouch of organic freeze-dried Pink Lady apples"
        case .bundle10: return "Ten pouches — best value for Miami snacking"
        }
    }

    var priceCents: Int {
        switch self {
        case .individual: return 199
        case .bundle10: return 2000
        }
    }

    var priceDisplay: String {
        String(format: "$%.2f", Double(priceCents) / 100.0)
    }

    var includesFreeShipping: Bool {
        self == .bundle10
    }

    var weightOz: Double {
        switch self {
        case .individual: return 1.2
        case .bundle10: return 12.0
        }
    }

    var stripePriceHint: String {
        switch self {
        case .individual: return "price_individual_199"
        case .bundle10: return "price_bundle10_2000"
        }
    }
}

struct CartItem: Identifiable, Equatable {
    let id = UUID()
    let sku: ProductSKU
    var quantity: Int
}
