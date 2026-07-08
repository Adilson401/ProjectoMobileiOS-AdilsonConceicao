//
//  PerfilController.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import Foundation

// Dados prontos para a tela de perfil.
struct PerfilTelaDados {
    let perfil: PerfilUsuarioResponse
    let totais: TotaisConsultasResponse
}

// Controller organiza o carregamento do perfil.
@MainActor
final class PerfilController {
    private let perfilService: PerfilService

    init() {
        self.perfilService = PerfilService()
    }

    init(perfilService: PerfilService) {
        self.perfilService = perfilService
    }

    // Busca perfil e totais em paralelo na API.
    func carregarPerfil() async throws -> PerfilTelaDados {
        let token = UserDefaults.standard.string(forKey: ApiConstants.tokenKey) ?? ""

        async let perfil = perfilService.buscarPerfil(token: token)
        async let totais = perfilService.buscarTotaisConsultas(token: token)

        return try await PerfilTelaDados(perfil: perfil, totais: totais)
    }
}
