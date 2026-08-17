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
            let preferred = Locale.preferredLanguages.first ?? "en"

            let detectedLanguage: AppLanguage =
                preferred.starts(with: "ar") ? .arabic : .english

            self.currentLanguage = detectedLanguage

            UserDefaults.standard.set(
                detectedLanguage.rawValue,
                forKey: "app_language"
            )
        }
    }
}
