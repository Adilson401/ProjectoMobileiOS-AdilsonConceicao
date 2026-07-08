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
    // Container usado para guardar dados locais com SwiftData.
    var sharedModelContainer: ModelContainer = SwiftDataManager.criarContainer()

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(sharedModelContainer)
    }
}

#Preview {
    MainPrincipalView()
}
