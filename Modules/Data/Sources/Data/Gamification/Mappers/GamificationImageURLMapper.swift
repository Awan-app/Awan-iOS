import AwaNetwork
import Foundation

enum GamificationImageURLMapper {
    static func string(from value: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty else { return trimmedValue }
        guard URL(string: trimmedValue)?.scheme == nil else { return trimmedValue }

        let path = trimmedValue.hasPrefix("/") ? trimmedValue : "/\(trimmedValue)"
        return NetworkConfiguration.backendBaseURL + path
    }

    static func url(from value: String?) -> URL? {
        guard let value else { return nil }
        return URL(string: string(from: value))
    }
}
