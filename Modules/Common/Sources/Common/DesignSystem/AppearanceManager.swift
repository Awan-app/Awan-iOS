import SwiftUI
import Observation

public enum AppAppearance: String, CaseIterable, Sendable {
    case light
    case dark
    case system
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

@MainActor
@Observable
public final class AppearanceManager {
    public var currentAppearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(currentAppearance.rawValue, forKey: "app_appearance")
        }
    }
    
    public init() {
        if let savedValue = UserDefaults.standard.string(forKey: "app_appearance"),
           let savedAppearance = AppAppearance(rawValue: savedValue) {
            self.currentAppearance = savedAppearance
        } else {
            self.currentAppearance = .system
        }
    }
}
