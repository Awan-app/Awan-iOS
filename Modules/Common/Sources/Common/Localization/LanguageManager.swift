import SwiftUI
import Observation

@MainActor
@Observable
public final class LanguageManager {
    public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }
    
    public var locale: Locale {
        Locale(identifier: currentLanguage.rawValue)
    }
    
    public var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = locale
        return cal
    }

    public init() {
        if let savedValue = UserDefaults.standard.string(forKey: "app_language"),
           let savedLanguage = AppLanguage(rawValue: savedValue) {
            self.currentLanguage = savedLanguage
        } else {
            // Default to device locale or english
            let preferred = Locale.preferredLanguages.first ?? "en"
            if preferred.starts(with: "ar") {
                self.currentLanguage = .arabic
            } else {
                self.currentLanguage = .english
            }
        }
    }
}
