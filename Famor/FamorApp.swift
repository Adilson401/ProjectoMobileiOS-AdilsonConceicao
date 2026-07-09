//
//  FamorApp.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import SwiftUI
import SwiftData

@main
struct FamorApp: App {
    @AppStorage(ApiConstants.languageKey) private var languageCode = AppLanguage.portuguese.rawValue

    // Container usado para guardar dados locais com SwiftData.
    var sharedModelContainer: ModelContainer = SwiftDataManager.criarContainer()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.locale, Locale(identifier: AppLanguage(rawValue: languageCode)?.localeIdentifier ?? AppLanguage.portuguese.localeIdentifier))
        }
        .modelContainer(sharedModelContainer)
    }
}

#Preview {
    MainPrincipalView()
}
