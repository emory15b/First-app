import Foundation
import Combine

struct PlacedOrder: Identifiable, Equatable {
    let id: String
    let summary: CheckoutSummary
    let placedAt: Date
    let isDemo: Bool
}

@MainActor
final class OrderService: ObservableObject {
    @Published var lastOrder: PlacedOrder?
    @Published var isProcessing = false
    @Published var errorMessage: String?

    func checkout(summary: CheckoutSummary) async -> PlacedOrder? {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            let intent = try await StripeService.shared.createPaymentIntent(for: summary)

            // In production, present Stripe PaymentSheet with intent.clientSecret here.
            // Demo mode simulates a successful card confirmation.
            if intent.isDemo {
                try await Task.sleep(nanoseconds: 600_000_000)
            }

            let order = PlacedOrder(
                id: intent.paymentIntentId,
                summary: summary,
                placedAt: Date(),
                isDemo: intent.isDemo
            )
            lastOrder = order
            return order
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
