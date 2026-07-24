import SwiftUI

struct AboutView: View {
    @State private var reveal = false

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(
                                colors: [
                                    Color(red: 0.35, green: 0.55, blue: 0.42),
                                    Color(red: 0.78, green: 0.32, blue: 0.44),
                                    Color(red: 0.86, green: 0.90, blue: 0.92)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(height: 220)
                            .overlay {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 80, weight: .ultraLight))
                                    .foregroundStyle(.white.opacity(0.22))
                                    .offset(x: 80, y: -20)
                                    .scaleEffect(reveal ? 1.05 : 0.95)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Freeze Dried Apples")
                                    .font(Theme.brandFont)
                                    .foregroundStyle(.white)
                                Text("Miami · Florida")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding(20)
                        }

                        VStack(alignment: .leading, spacing: 18) {
                            Text("Small-batch freeze-dried Pink Lady apples for Florida living.")
                                .font(.title3)
                                .foregroundStyle(Theme.ink)
                                .opacity(reveal ? 1 : 0)
                                .offset(y: reveal ? 0 : 12)

                            Text("We started Freeze Dried Apples in Miami because humidity and fresh fruit don’t always get along — but crunchy apple flavor still belongs in every tote. Our organic Pink Lady apples are freeze-dried to lock in bright taste without syrups or fillers.")
                                .font(.body)
                                .foregroundStyle(Theme.muted)
                                .opacity(reveal ? 1 : 0)

                            VStack(alignment: .leading, spacing: 12) {
                                aboutRow(
                                    icon: "leaf.circle.fill",
                                    title: "Organic fruit only",
                                    detail: "Pink Lady apples, nothing else in the pouch."
                                )
                                aboutRow(
                                    icon: "snowflake",
                                    title: "Freeze-dried freshness",
                                    detail: "Airy crunch that stays stable in Florida heat."
                                )
                                aboutRow(
                                    icon: "shippingbox.fill",
                                    title: "Shippo from Brickell",
                                    detail: "Paid rates on singles; free shipping on the 10-pack."
                                )
                                aboutRow(
                                    icon: "creditcard.fill",
                                    title: "Stripe checkout",
                                    detail: "Simple, secure payment when you’re ready to order."
                                )
                            }
                            .padding(.top, 4)

                            Text("Built for neighbors from Coconut Grove to Coral Gables — and anyone who wants a clean apple snack that travels well.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.muted)
                                .padding(.top, 4)
                        }
                        .padding(20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) {
                    reveal = true
                }
            }
        }
    }

    private func aboutRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.roseDeep)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.8))
        )
    }
}
