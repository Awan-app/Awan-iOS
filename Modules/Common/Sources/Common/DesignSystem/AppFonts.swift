import SwiftUI

public enum AppFonts {
    public static let titleBlack = Font.system(
        .title,
        design: .rounded,
        weight: .black
    )
    public static let captionBlack = Font.system(
        .caption,
        design: .rounded,
        weight: .black
    )
    public static let captionHeavy = Font.system(
        .caption,
        design: .rounded,
        weight: .heavy
    )
    public static let captionIconBlack = Font.caption.weight(.black)
    public static let caption2IconBlack = Font.caption2.weight(.black)
    public static let caption2Bold = Font.system(
        .caption2,
        design: .rounded,
        weight: .bold
    )
    public static let subheadlineBlack = Font.system(
        .subheadline,
        design: .rounded,
        weight: .black
    )
    public static let subheadlineHeavy = Font.system(
        .subheadline,
        design: .rounded,
        weight: .heavy
    )
    public static let subheadlineSemibold = Font.system(
        .subheadline,
        design: .rounded,
        weight: .semibold
    )
    public static let subheadlineBold = Font.system(
        .subheadline,
        design: .rounded,
        weight: .bold
    )
    public static let headlineBlack = Font.system(
        .headline,
        design: .rounded,
        weight: .black
    )
    public static let title2Black = Font.system(
        .title2,
        design: .rounded,
        weight: .black
    )
    public static let title3Black = Font.system(
        .title3,
        design: .rounded,
        weight: .black
    )
    public static let body = Font.system(
        .body,
        design: .rounded,
        weight: .regular
    )
    public static let bodySemibold = Font.system(
        .body,
        design: .rounded,
        weight: .semibold
    )
    public static let bodyBold = Font.system(
        .body,
        design: .rounded,
        weight: .bold
    )
    public static let microBlack = Font.system(size: 9, weight: .black, design: .rounded)
    public static let microHeavy = Font.system(size: 9, weight: .heavy, design: .rounded)
    public static let hourLabel = Font.system(size: 10, weight: .bold, design: .rounded)
    public static let progressSymbol = Font.system(size: 20, weight: .black)
    public static let statSymbol = Font.system(size: 17, weight: .black)
    public static let tabSymbol = Font.system(size: 22, weight: .bold)
    public static let taskStatusSymbol = Font.system(size: 18, weight: .black)
    public static let nudgeSymbol = Font.system(size: 26, weight: .black)
    public static let heroSymbol = Font.system(size: 52, weight: .black)
    public static let goalHeroSymbol = Font.system(size: 58, weight: .black)
}
