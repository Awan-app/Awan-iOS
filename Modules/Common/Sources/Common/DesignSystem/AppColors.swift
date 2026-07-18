import SwiftUI

public enum AppColors {
    public static let accentGreen = asset("AccentGreen")
    public static let accentGreenDepth = asset("AccentGreenDepth")
    public static let accentBlue = asset("AccentBlue")
    public static let accentPurple = asset("AccentPurple")
    public static let warning = asset("Warning")
    public static let destructive = asset("Destructive")
    public static let reward = asset("Reward")
    public static let neutralAction = asset("NeutralAction")
    public static let runtimeFallback = asset("RuntimeFallback")
    public static let screenBackground = asset("ScreenBackground")
    public static let sheetBackground = asset("SheetBackground")
    public static let surface = asset("Surface")
    public static let infoSurface = asset("InfoSurface")
    public static let warningSurface = asset("WarningSurface")
    public static let divider = asset("Divider")
    public static let textPrimary = asset("TextPrimary")
    public static let textSecondary = asset("TextSecondary")
    public static let onAccent = asset("OnAccent")
    public static let outline = asset("Outline")
    public static let shadow = asset("Shadow")
    public static let otpTopColor = asset("OtpTopColor")
    public static let otpWhite = asset("OtpWhite")

    public static let brandDarkBlue = asset("BrandDarkBlue")

    // TODO: These are meant to be the canonical shared colors. Once the OTP branch merges,
    // delete its OTP-specific color assets and repoint them to use these skyGradient properties instead.
    public static let skyGradientTop = asset("SkyGradientTop")
    public static let skyGradientBottom = asset("SkyGradientBottom")

    public static func runtime(hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16) else {
            return runtimeFallback
        }
        return Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    private static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}
