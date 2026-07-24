import Foundation

struct Review: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let neighborhood: String
    let rating: Int
    let title: String
    let body: String
    let dateLabel: String
}

enum ReviewData {
    static let samples: [Review] = [
        Review(
            author: "Camila R.",
            neighborhood: "Coconut Grove",
            rating: 5,
            title: "Perfect pool-day snack",
            body: "Crispy, sweet-tart Pink Lady flavor without the fridge. We keep a pouch in the tote for afternoon beach runs.",
            dateLabel: "Jun 2026"
        ),
        Review(
            author: "James T.",
            neighborhood: "Brickell",
            rating: 5,
            title: "Office desk staple",
            body: "Light enough for humidity, bold enough to feel like a real apple. The 10-pack disappeared in two weeks.",
            dateLabel: "May 2026"
        ),
        Review(
            author: "Sofia M.",
            neighborhood: "Wynwood",
            rating: 4,
            title: "Clean and local vibes",
            body: "Love that it’s organic and Florida-shipped. Texture is airy crunch — kids ask for these over chips.",
            dateLabel: "Apr 2026"
        ),
        Review(
            author: "Diego L.",
            neighborhood: "Coral Gables",
            rating: 5,
            title: "Gifted a bundle",
            body: "Sent the free-shipping 10-pack to my sister in Tampa. Arrived fast, packaging looked thoughtful.",
            dateLabel: "Mar 2026"
        )
    ]
}
