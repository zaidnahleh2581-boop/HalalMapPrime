//
//  LanguageManager.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/21/25
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine

final class LanguageManager: ObservableObject {

    enum AppLanguage: String, CaseIterable, Codable {
        case arabic
        case english
    }

    private let keyCurrent = "HMP_language_current"
    private let keyDidChoose = "HMP_language_didChoose"

    @Published private(set) var current: AppLanguage
    @Published private(set) var didChooseLanguage: Bool

    init() {
        let saved = UserDefaults.standard.string(forKey: keyCurrent)
        self.current = AppLanguage(rawValue: saved ?? "") ?? .english
        self.didChooseLanguage = UserDefaults.standard.bool(forKey: keyDidChoose)
    }

    var isArabic: Bool { current == .arabic }

    func select(_ language: AppLanguage) {
        current = language
        didChooseLanguage = true

        UserDefaults.standard.set(language.rawValue, forKey: keyCurrent)
        UserDefaults.standard.set(true, forKey: keyDidChoose)
    }
}
