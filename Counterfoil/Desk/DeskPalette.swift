import SwiftUI

/// Role: Desk. One color accessor. Named colors in Assets.xcassets. Hex is recorded here once. Never a second palette.
enum DeskColor {
    /// background `#1B2C1E`
    static var background: Color { Color("background") }
    /// surface `#293D36`
    static var surface: Color { Color("surface") }
    /// ink `#F1F4F1`
    static var ink: Color { Color("ink") }
    /// accent `#73D3B0`
    static var accent: Color { Color("accent") }
    /// muted `#B0BFB3`
    static var muted: Color { Color("muted") }
}

/// Role: Desk. SF Pro via Font.system. Six steps: display, title, headline, body, caption, micro. No Font.custom.
enum DeskFont {
    static var display: Font { .system(.title, design: .default).weight(.semibold) }
    static var title: Font { .system(.title2, design: .default).weight(.semibold) }
    static var headline: Font { .system(.headline, design: .default) }
    static var body: Font { .system(.body, design: .default) }
    static var caption: Font { .system(.footnote, design: .default) }
    static var micro: Font { .system(.caption, design: .default) }
}

/// Role: Desk. One spacing accessor. Base unit 8 pt. Only multiples.
enum DeskSpace {
    static let unit: CGFloat = 8
    static let rule: CGFloat = 1

    static func n(_ count: Int) -> CGFloat {
        unit * CGFloat(count)
    }
}

/// Role: Desk. One radius accessor. 32 pt cards, 16 pt chips. Never a second radius.
enum DeskRadius {
    static let card: CGFloat = 32
    static let chip: CGFloat = 16
}
