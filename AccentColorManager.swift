import SwiftUI

class AccentColorManager: ObservableObject {
    @AppStorage("accentColorHex") private var accentColorHex: String = "#8E44AD" // violet par défaut

    var color: Color {
        Color(hex: accentColorHex)
    }

    func setAccentColor(_ color: Color) {
        accentColorHex = color.toHex() ?? "#8E44AD"
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 8:
            (a, r, g, b) = (int >> 24, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        case 6:
            (a, r, g, b) = (255, int >> 16, (int >> 8) & 0xff, int & 0xff)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let rgb = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)
        return String(format:"#%06x", rgb)
    }
}
