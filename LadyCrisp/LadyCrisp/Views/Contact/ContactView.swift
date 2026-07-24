import SwiftUI

struct ContactView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var topic = ContactTopic.order
    @State private var message = ""
    @State private var submitted = false
    @State private var shake = false

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        message.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Say hello")
                                .font(Theme.brandFont)
                            Text("Questions about orders, wholesale, or Miami pickup? We’re here.")
                                .font(.body)
                                .foregroundStyle(Theme.muted)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("hello@ladycrisp.miami", systemImage: "envelope")
                            Label("Miami, Florida", systemImage: "mappin.and.ellipse")
                            Label("Mon–Fri · 9am–5pm ET", systemImage: "clock")
                        }
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)

                        if submitted {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Message sent")
                                    .font(Theme.headlineFont)
                                Text("Thanks, \(name.isEmpty ? "friend" : name). We’ll reply to \(email) soon.")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                                Button("Send another") {
                                    submitted = false
                                    message = ""
                                }
                                .tint(Theme.roseDeep)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(panel)
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        } else {
                            formFields
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Contact")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var formFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact form")
                .font(Theme.headlineFont)

            field("Name", text: $name)
            field("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            Picker("Topic", selection: $topic) {
                ForEach(ContactTopic.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            TextEditor(text: $message)
                .frame(minHeight: 140)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Theme.mist.opacity(0.95))
                )
                .overlay(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("How can we help?")
                            .foregroundStyle(Theme.muted.opacity(0.7))
                            .padding(18)
                            .allowsHitTesting(false)
                    }
                }

            Button {
                guard canSubmit else {
                    withAnimation(.default) { shake.toggle() }
                    return
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    submitted = true
                }
            } label: {
                Text("Send message")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(canSubmit ? Theme.roseDeep : Theme.muted.opacity(0.35))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .modifier(ShakeEffect(animatableData: shake ? 1 : 0))
        }
        .padding(16)
        .background(panel)
    }

    private var panel: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.82))
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.mist.opacity(0.95))
            )
    }
}

enum ContactTopic: String, CaseIterable, Identifiable {
    case order
    case product
    case wholesale
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .order: return "Order"
        case .product: return "Product"
        case .wholesale: return "Wholesale"
        case .other: return "Other"
        }
    }
}

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(animatableData * .pi * 6) * 6
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
