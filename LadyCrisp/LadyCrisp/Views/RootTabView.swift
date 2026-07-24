import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ProductHomeView()
                .tabItem {
                    Label("Shop", systemImage: "leaf.fill")
                }

            ReviewsView()
                .tabItem {
                    Label("Reviews", systemImage: "star.bubble")
                }

            ContactView()
                .tabItem {
                    Label("Contact", systemImage: "envelope")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .tint(Theme.roseDeep)
    }
}
