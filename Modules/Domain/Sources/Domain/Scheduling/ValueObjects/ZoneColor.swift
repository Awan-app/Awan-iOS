import Foundation

public struct ZoneColor: Hashable, Sendable {
    public let hex: String

    public init(hex: String) throws {
        let normalized = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let validCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")

        guard normalized.count == 6,
              normalized.unicodeScalars.allSatisfy(validCharacters.contains) else {
            throw SchedulingError.invalidColorHex(hex)
        }

        self.hex = "#" + normalized.uppercased()
    }
}
