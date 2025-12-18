//
//  RootView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/17/25
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        MainTabView()
            .environmentObject(lang)
            .onAppear {
                Task {
                    try? await AuthManager.shared.ensureSignedIn()
                }
            }
    }
}
