import Foundation
import Combine

@MainActor
final class CartStore: ObservableObject {
    @Published var items: [CartItem] = []

    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotalCents: Int {
        items.reduce(0) { $0 + ($1.sku.priceCents * $1.quantity) }
    }

    var qualifiesForFreeShipping: Bool {
        items.contains { $0.sku.includesFreeShipping && $0.quantity > 0 }
    }

    func add(_ sku: ProductSKU, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.sku == sku }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(sku: sku, quantity: quantity))
        }
    }

    func updateQuantity(for sku: ProductSKU, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.sku == sku }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
    }

    func clear() {
        items.removeAll()
    }
}
