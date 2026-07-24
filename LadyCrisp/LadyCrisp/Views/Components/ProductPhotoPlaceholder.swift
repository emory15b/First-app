import SwiftUI

struct ProductPhotoPlaceholder: View {
    let index: Int
    var height: CGFloat = 280

    private var gradient: [Color] {
        switch index % 3 {
        case 0:
            return [
                Color(red: 0.86, green: 0.42, blue: 0.52),
                Color(red: 0.72, green: 0.24, blue: 0.36),
                Color(red: 0.35, green: 0.55, blue: 0.40)
            ]
        case 1:
            return [
                Color(red: 0.55, green: 0.72, blue: 0.58),
                Color(red: 0.82, green: 0.38, blue: 0.48),
                Color(red: 0.30, green: 0.48, blue: 0.38)
            ]
        default:
            return [
                Color(red: 0.78, green: 0.88, blue: 0.90),
                Color(red: 0.84, green: 0.45, blue: 0.54),
                Color(red: 0.40, green: 0.58, blue: 0.45)
            ]
        }
    }

    private var caption: String {
        switch index % 3 {
        case 0: return "Freeze-dried Pink Lady slices"
        case 1: return "Pouch ready for Miami heat"
        default: return "Crisp orchard color, airy crunch"
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            // Soft apple silhouette marks — placeholder until real product photos land.
            GeometryReader { geo in
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.12 + Double(i) * 0.04))
                        .frame(width: geo.size.width * (0.28 - Double(i) * 0.04))
                        .offset(
                            x: geo.size.width * (0.15 + Double(i) * 0.22),
                            y: geo.size.height * (0.18 + Double(i) * 0.12)
                        )
                }

                Image(systemName: "apple.logo")
                    .font(.system(size: 72, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.28))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: -10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("PHOTO PLACEHOLDER")
                    .font(.caption2.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.75))
                Text(caption)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
            }
            .padding(20)
        }
        .frame(height: height)
        .clipped()
        .accessibilityLabel(caption)
    }
}

struct ProductPhotoCarousel: View {
    @State private var page = 0

    var body: some View {
        TabView(selection: $page) {
            ForEach(0..<3, id: \.self) { index in
                ProductPhotoPlaceholder(index: index, height: 320)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 320)
        .animation(.easeInOut(duration: 0.35), value: page)
    }
}
