import SwiftUI

struct ReviewsView: View {
    private let reviews = ReviewData.samples

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphereBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From Miami & beyond")
                                .font(Theme.brandFont)
                                .foregroundStyle(Theme.ink)
                            Text("Neighbors who keep Lady Crisp in the tote.")
                                .font(.body)
                                .foregroundStyle(Theme.muted)
                        }
                        .padding(.top, 8)

                        HStack(spacing: 6) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Theme.rose)
                            }
                            Text("4.8 average · local favorites")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.ink)
                        }

                        ForEach(Array(reviews.enumerated()), id: \.element.id) { index, review in
                            reviewCard(review)
                                .opacity(1)
                                .offset(y: 0)
                                .animation(
                                    .easeOut(duration: 0.45).delay(Double(index) * 0.06),
                                    value: review.id
                                )
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Reviews")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text(review.neighborhood)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.leaf)
                }
                Spacer()
                Text(review.dateLabel)
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }

            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i < review.rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(Theme.rose)
                }
            }

            Text(review.title)
                .font(.system(.title3, design: .serif).weight(.semibold))
                .foregroundStyle(Theme.ink)

            Text(review.body)
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.82))
        )
    }
}
