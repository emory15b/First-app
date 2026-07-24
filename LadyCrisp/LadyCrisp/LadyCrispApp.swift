import SwiftUI

@main
struct LadyCrispApp: App {
    @StateObject private var cart = CartStore()
    @StateObject private var orderService = OrderService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(cart)
                .environmentObject(orderService)
                .preferredColorScheme(.light)
        }
    }
}
