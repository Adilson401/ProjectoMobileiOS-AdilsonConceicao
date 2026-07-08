//
//  UsuarioRepository.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation
import SwiftData

// Repository cuida apenas dos dados guardados no telemovel.
@MainActor
final class UsuarioRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Guarda o utilizador autenticado no SwiftData.
    func salvarUsuarioAutenticado(_ usuario: UsuarioModel) throws {
        // Neste app vamos manter apenas a sessao actual guardada.
        let usuariosAntigos = try modelContext.fetch(FetchDescriptor<UsuarioModel>())
        let perfisAntigos = try modelContext.fetch(FetchDescriptor<PerfilLocalModel>())

        for usuarioAntigo in usuariosAntigos {
            modelContext.delete(usuarioAntigo)
        }

        for perfilAntigo in perfisAntigos {
            modelContext.delete(perfilAntigo)
        }

        modelContext.insert(usuario)
        try modelContext.save()
    }

    // Busca o utilizador que ficou guardado localmente.
    func buscarUsuarioAutenticado() throws -> UsuarioModel? {
        var descriptor = FetchDescriptor<UsuarioModel>()
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }

    // Limpa a sessao quando for preciso terminar login.
    func limparUsuarioAutenticado() throws {
        let usuarios = try modelContext.fetch(FetchDescriptor<UsuarioModel>())
        let perfis = try modelContext.fetch(FetchDescriptor<PerfilLocalModel>())

        for usuario in usuarios {
            modelContext.delete(usuario)
        }

        for perfil in perfis {
            modelContext.delete(perfil)
        }

        try modelContext.save()

        // Tambem limpamos os dados rapidos da sessao.
        UserDefaults.standard.removeObject(forKey: ApiConstants.tokenKey)
        UserDefaults.standard.removeObject(forKey: ApiConstants.roleKey)
        UserDefaults.standard.removeObject(forKey: ApiConstants.perfilKey)
    }
}
