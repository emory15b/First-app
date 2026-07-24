import SwiftUI

enum Theme {
    // Soft rose from Pink Lady skin, orchard green, cool mist — Miami-fresh, not purple or cream-terracotta.
    static let rose = Color(red: 0.78, green: 0.29, blue: 0.42)
    static let roseDeep = Color(red: 0.62, green: 0.18, blue: 0.32)
    static let leaf = Color(red: 0.22, green: 0.45, blue: 0.30)
    static let leafSoft = Color(red: 0.42, green: 0.62, blue: 0.48)
    static let mist = Color(red: 0.94, green: 0.97, blue: 0.95)
    static let skyWash = Color(red: 0.88, green: 0.94, blue: 0.95)
    static let ink = Color(red: 0.12, green: 0.14, blue: 0.13)
    static let muted = Color(red: 0.38, green: 0.42, blue: 0.40)
    static let sandLine = Color(red: 0.82, green: 0.86, blue: 0.84)

    static let brandFont: Font = .system(.largeTitle, design: .serif).weight(.bold)
    static let headlineFont: Font = .system(.title2, design: .serif).weight(.semibold)
    static let bodyFont: Font = .system(.body, design: .default)
}

struct AtmosphereBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Theme.skyWash,
                    Theme.mist,
                    Color(red: 0.96, green: 0.93, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Circle()
                    .fill(Theme.rose.opacity(0.10))
                    .frame(width: geo.size.width * 0.7)
                    .blur(radius: 40)
                    .offset(x: geo.size.width * 0.45, y: -geo.size.height * 0.08)

                Circle()
                    .fill(Theme.leafSoft.opacity(0.12))
                    .frame(width: geo.size.width * 0.55)
                    .blur(radius: 36)
                    .offset(x: -geo.size.width * 0.25, y: geo.size.height * 0.55)
            }
        }
        .ignoresSafeArea()
    }
}
