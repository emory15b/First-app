import SwiftUI

struct ProductHomeView: View {
    @EnvironmentObject private var cart: CartStore
    @State private var selectedSKU: ProductSKU = .individual
    @State private var showCheckout = false
    @State private var pulseCTA = false

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        hero
                        productChooser
                            .padding(.horizontal, 20)
                            .padding(.top, 28)
                        details
                            .padding(.horizontal, 20)
                            .padding(.top, 28)
                        miamiNote
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 120)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                checkoutBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Freeze Dried Apples")
                        .font(.system(.headline, design: .serif).weight(.bold))
                        .foregroundStyle(Theme.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCheckout = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bag")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                            if cart.totalItemCount > 0 {
                                Text("\(cart.totalItemCount)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Theme.rose)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .accessibilityLabel("Open checkout")
                }
            }
            .sheet(isPresented: $showCheckout) {
                CheckoutView()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulseCTA = true
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProductPhotoCarousel()

            VStack(alignment: .leading, spacing: 10) {
                Text("Freeze Dried Apples")
                    .font(Theme.brandFont)
                    .foregroundStyle(Theme.ink)
                    .padding(.top, 22)

                Text("Organic freeze-dried Pink Lady apples, packed in Miami.")
                    .font(.title3)
                    .foregroundStyle(Theme.ink.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)

                Text("Light crunch for Florida heat — no fridge, no fuss.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.muted)
            }
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    private var productChooser: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose your pack")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.ink)

            VStack(spacing: 12) {
                ForEach(ProductSKU.allCases) { sku in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            selectedSKU = sku
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 14) {
                            Circle()
                                .strokeBorder(selectedSKU == sku ? Theme.rose : Theme.sandLine, lineWidth: 2)
                                .background(
                                    Circle()
                                        .fill(selectedSKU == sku ? Theme.rose : .clear)
                                        .padding(5)
                                )
                                .frame(width: 22, height: 22)
                                .padding(.top, 3)

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(sku.name)
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                    Spacer()
                                    Text(sku.priceDisplay)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(Theme.roseDeep)
                                }
                                Text(sku.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                                    .multilineTextAlignment(.leading)

                                Text(sku.includesFreeShipping ? "Free shipping via Shippo" : "Paid shipping via Shippo")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(sku.includesFreeShipping ? Theme.leaf : Theme.muted)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(selectedSKU == sku ? 0.92 : 0.62))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedSKU == sku ? Theme.rose.opacity(0.55) : Theme.sandLine.opacity(0.7), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What’s inside")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.ink)

            VStack(alignment: .leading, spacing: 10) {
                bullet("100% organic Pink Lady apples, freeze-dried")
                bullet("No added sugar, nothing artificial")
                bullet("Shelf-stable for lunchboxes, desks, and beach bags")
                bullet("Ships from Miami across Florida and the U.S.")
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.7))
            )
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.leaf)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.ink.opacity(0.9))
        }
    }

    private var miamiNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title3)
                .foregroundStyle(Theme.roseDeep)
            VStack(alignment: .leading, spacing: 4) {
                Text("Miami-made for local snacking")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text("Brickell fulfillment · Florida-first delivery windows")
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.leaf.opacity(0.08))
        )
    }

    private var checkoutBar: some View {
        HStack(spacing: 12) {
            Button {
                cart.add(selectedSKU)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showCheckout = true
                }
            } label: {
                Text("Add & checkout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.roseDeep)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .scaleEffect(pulseCTA ? 1.015 : 1.0)
            }

            Button {
                cart.add(selectedSKU)
            } label: {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.roseDeep)
                    .frame(width: 54, height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.rose.opacity(0.35), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Add to bag")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
