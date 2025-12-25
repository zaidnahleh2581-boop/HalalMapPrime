import Foundation
import Combine

final class LanguageManager: ObservableObject {

    @Published var current: AppLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "appLanguage")
            UserDefaults.standard.set(true, forKey: "didChooseLanguage")
        }
    }

    @Published var didChooseLanguage: Bool

    var isArabic: Bool {
        current == .arabic
    }

    init() {
        let chosen = UserDefaults.standard.bool(forKey: "didChooseLanguage")
        self.didChooseLanguage = chosen

        if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: saved) {
            self.current = lang
        } else {
            // اللغة الافتراضية: إنجليزي
            self.current = .english
        }
    }

    func select(_ language: AppLanguage) {
        current = language
        didChooseLanguage = true
    }
}
