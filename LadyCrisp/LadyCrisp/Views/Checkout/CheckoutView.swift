import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var orderService: OrderService
    @Environment(\.dismiss) private var dismiss

    @State private var address = ShippingAddress()
    @State private var rates: [ShippingRate] = []
    @State private var selectedRate: ShippingRate?
    @State private var isLoadingRates = false
    @State private var rateError: String?
    @State private var showConfirmation = false
    @State private var placedOrder: PlacedOrder?

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                if cart.items.isEmpty && placedOrder == nil {
                    emptyState
                } else if showConfirmation, let placedOrder {
                    OrderConfirmationView(order: placedOrder) {
                        cart.clear()
                        dismiss()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            bagSection
                            addressSection
                            shippingSection
                            totalsSection
                            payButton
                        }
                        .padding(20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task(id: cart.items) {
                await refreshRatesIfNeeded()
            }
            .onChange(of: address.postalCode) { _, _ in
                Task { await refreshRatesIfNeeded() }
            }
            .onChange(of: address.city) { _, _ in
                Task { await refreshRatesIfNeeded() }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag")
                .font(.system(size: 40))
                .foregroundStyle(Theme.muted)
            Text("Your bag is empty")
                .font(Theme.headlineFont)
            Text("Add a Single Pack or 10-Pack Bundle to continue.")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
            Button("Back to shop") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(Theme.roseDeep)
                .padding(.top, 8)
        }
        .padding(24)
    }

    private var bagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your bag")
                .font(Theme.headlineFont)

            ForEach(cart.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.sku.name)
                            .font(.headline)
                        Text(item.sku.includesFreeShipping ? "Free shipping eligible" : "Shipping calculated below")
                            .font(.caption)
                            .foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    Stepper(
                        value: Binding(
                            get: { item.quantity },
                            set: { cart.updateQuantity(for: item.sku, quantity: $0) }
                        ),
                        in: 0...20
                    ) {
                        Text("×\(item.quantity)")
                            .font(.subheadline.weight(.semibold))
                    }
                    .labelsHidden()

                    Text(String(format: "$%.2f", Double(item.sku.priceCents * item.quantity) / 100.0))
                        .font(.subheadline.weight(.bold))
                        .frame(width: 64, alignment: .trailing)
                }
                .padding(14)
                .background(panel)
            }
        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ship to")
                .font(Theme.headlineFont)
            Text("Florida-friendly defaults — edit for anywhere in the U.S.")
                .font(.caption)
                .foregroundStyle(Theme.muted)

            VStack(spacing: 10) {
                field("Full name", text: $address.name)
                field("Email", text: $address.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                field("Phone", text: $address.phone)
                    .keyboardType(.phonePad)
                field("Address", text: $address.line1)
                field("Apt / suite (optional)", text: $address.line2)
                HStack(spacing: 10) {
                    field("City", text: $address.city)
                    field("State", text: $address.state)
                        .frame(width: 72)
                }
                field("ZIP", text: $address.postalCode)
                    .keyboardType(.numberPad)
            }
            .padding(14)
            .background(panel)
        }
    }

    private var shippingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Shipping (Shippo)")
                    .font(Theme.headlineFont)
                Spacer()
                if isLoadingRates {
                    ProgressView()
                }
            }

            if let rateError {
                Text(rateError)
                    .font(.caption)
                    .foregroundStyle(Theme.roseDeep)
            }

            if cart.qualifiesForFreeShipping {
                Text("10-Pack Bundle includes free shipping.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.leaf)
            }

            if rates.isEmpty && !isLoadingRates {
                Text("Enter your address to load Shippo rates.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }

            ForEach(rates) { rate in
                Button {
                    selectedRate = rate
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(rate.carrier) · \(rate.service)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                            Text("\(rate.estimatedDays) · \(rate.provider)")
                                .font(.caption)
                                .foregroundStyle(Theme.muted)
                        }
                        Spacer()
                        Text(rate.amountDisplay)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.roseDeep)
                        Image(systemName: selectedRate == rate ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedRate == rate ? Theme.rose : Theme.sandLine)
                    }
                    .padding(14)
                    .background(panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(selectedRate == rate ? Theme.rose.opacity(0.5) : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var totalsSection: some View {
        VStack(spacing: 8) {
            totalRow("Subtotal", cents: cart.subtotalCents)
            totalRow("Shipping", cents: selectedRate?.amountCents ?? 0)
            Divider()
            totalRow("Total", cents: cart.subtotalCents + (selectedRate?.amountCents ?? 0), bold: true)
            Text("Secure checkout powered by Stripe")
                .font(.caption2)
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(panel)
    }

    private var payButton: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                Task { await pay() }
            } label: {
                HStack {
                    if orderService.isProcessing {
                        ProgressView().tint(.white)
                    }
                    Text(orderService.isProcessing ? "Processing…" : "Pay with Stripe")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canPay ? Theme.roseDeep : Theme.muted.opacity(0.4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(!canPay || orderService.isProcessing)

            if let error = orderService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Theme.roseDeep)
            }
        }
    }

    private var canPay: Bool {
        !cart.items.isEmpty && address.isValid && selectedRate != nil
    }

    private var panel: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.white.opacity(0.82))
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.mist.opacity(0.9))
            )
    }

    private func totalRow(_ label: String, cents: Int, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(bold ? .headline : .subheadline)
            Spacer()
            Text(cents == 0 && label == "Shipping" ? "Free" : String(format: "$%.2f", Double(cents) / 100.0))
                .font(bold ? .headline : .subheadline.weight(.semibold))
        }
        .foregroundStyle(Theme.ink)
    }

    private func refreshRatesIfNeeded() async {
        guard !cart.items.isEmpty else {
            rates = []
            selectedRate = nil
            return
        }

        // Quote as soon as ZIP looks usable; full validation required to pay.
        guard address.postalCode.count >= 5 else { return }

        isLoadingRates = true
        rateError = nil
        defer { isLoadingRates = false }

        do {
            let quoted = try await ShippoService.shared.quoteRates(
                for: address,
                cart: cart.items,
                freeShipping: cart.qualifiesForFreeShipping
            )
            rates = quoted
            if let selectedRate, quoted.contains(selectedRate) {
                // keep selection
            } else {
                selectedRate = quoted.first
            }
        } catch {
            rateError = error.localizedDescription
            rates = []
            selectedRate = nil
        }
    }

    private func pay() async {
        guard let selectedRate else { return }
        let summary = CheckoutSummary(items: cart.items, shipping: selectedRate, address: address)
        if let order = await orderService.checkout(summary: summary) {
            placedOrder = order
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showConfirmation = true
            }
        }
    }
}

struct OrderConfirmationView: View {
    let order: PlacedOrder
    let onDone: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.leaf)
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)

            Text("You’re all set")
                .font(Theme.brandFont)
            Text("Order \(order.id)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.muted)

            Text("Thanks for supporting Miami-made Freeze Dried Apples. \(order.isDemo ? "Demo Stripe payment recorded — connect your backend for live charges." : "Stripe payment confirmed.")")
                .font(.body)
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Text(order.summary.totalDisplay)
                .font(.title.weight(.bold))
                .foregroundStyle(Theme.roseDeep)

            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(Theme.roseDeep)
                .padding(.top, 8)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}
