import SwiftUI

enum DesignSystem {
    enum Colors {
        static let tint = Color.indigo
        static let organize = Color.indigo
        static let convert = Color.teal
        static let images = Color.orange

        static func color(for category: ToolCategory) -> Color {
            switch category {
            case .organize: organize
            case .convert: convert
            case .images: images
            }
        }
    }

    enum Spacing {
        static let compact: CGFloat = 8
        static let regular: CGFloat = 16
        static let section: CGFloat = 24
    }
}
