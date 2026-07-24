import XCTest
@testable import Common

final class CommonTests: XCTestCase {
    @MainActor
    func testLocalizationFlow() async throws {
        UserDefaults.standard.set("ar", forKey: "app_language")
        let manager = await LanguageManager()
        print("DEBUG: currentLanguage = \(await manager.currentLanguage)")
        print("DEBUG: currentLocale.identifier = \(L10n.currentLocale.identifier)")
        let arStr = String(localized: "common.save", bundle: .module, locale: L10n.currentLocale)
        print("DEBUG: localized 'common.save' with ar = \(arStr)")

        UserDefaults.standard.set("en", forKey: "app_language")
        let enStr = String(localized: "common.save", bundle: .module, locale: L10n.currentLocale)
        print("DEBUG: localized 'common.save' with en = \(enStr)")
        
        print("DEBUG: Bundle path = \(Bundle.module.bundlePath)")
        if let arPath = Bundle.module.path(forResource: "ar", ofType: "lproj"),
           let arBundle = Bundle(path: arPath) {
            print("DEBUG: Found ar.lproj at: \(arPath)")
            let str = arBundle.localizedString(forKey: "common.save", value: nil, table: "Localizable")
            print("DEBUG: localizedString from arBundle = \(str)")
        } else {
            print("DEBUG: ar.lproj NOT FOUND in Bundle.module")
        }
    }
}
