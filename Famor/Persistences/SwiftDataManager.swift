//
//  SwiftDataManager.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation
import SwiftData

// Aqui centralizamos a configuracao do SwiftData.
enum SwiftDataManager {
    // Todos os modelos guardados localmente entram neste schema.
    static let schema = Schema([
        UsuarioModel.self,
        PerfilLocalModel.self,
        EspecialidadeLocalModel.self,
        MarcacaoRascunhoLocalModel.self,
        MarcacaoFeitaLocalModel.self
    ])

    private static let storeFileName = "Famor.sqlite"

    // Criamos o container usado pela app inteira.
    static func criarContainer() -> ModelContainer {
        let defaultConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [defaultConfiguration])
        } catch {
            return criarContainerRecuperado()
        }
    }

    private static func criarContainerRecuperado() -> ModelContainer {
        let storeURL = criarStoreURL()
        let configuration = ModelConfiguration("Famor", schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            limparStoreLocal(em: storeURL)

            do {
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                return criarContainerEmMemoria()
            }
        }
    }

    // Container usado apenas em previews para nao escrever no armazenamento real.
    static func criarContainerEmMemoria() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Nao foi possivel iniciar o SwiftData em memoria: \(error)")
        }
    }

    private static func criarStoreURL() -> URL {
        let diretorio = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        do {
            try FileManager.default.createDirectory(
                at: diretorio,
                withIntermediateDirectories: true
            )
        } catch {
            return FileManager.default.temporaryDirectory.appendingPathComponent(storeFileName)
        }

        return diretorio.appendingPathComponent(storeFileName)
    }

    private static func limparStoreLocal(em storeURL: URL) {
        let caminhos = [
            storeURL.path,
            "\(storeURL.path)-shm",
            "\(storeURL.path)-wal"
        ]

        for caminho in caminhos {
            try? FileManager.default.removeItem(atPath: caminho)
        }
    }
}
