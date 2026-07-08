//
//  LoginController.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation
import SwiftData

// Erros simples antes de chamar a API.
enum LoginControllerError: LocalizedError {
    case emailVazio
    case senhaVazia

    var errorDescription: String? {
        switch self {
        case .emailVazio:
            return "Escreve o teu e-mail para continuar."
        case .senhaVazia:
            return "Escreve a tua senha para continuar."
        }
    }
}

// Controller organiza o fluxo do login.
@MainActor
final class LoginController {
    private let loginService: LoginService
    private let usuarioRepository: UsuarioRepository
    private let perfilRepository: PerfilRepository

    init(modelContext: ModelContext) {
        self.loginService = LoginService()
        self.usuarioRepository = UsuarioRepository(modelContext: modelContext)
        self.perfilRepository = PerfilRepository(modelContext: modelContext)
    }

    init(modelContext: ModelContext, loginService: LoginService) {
        self.loginService = loginService
        self.usuarioRepository = UsuarioRepository(modelContext: modelContext)
        self.perfilRepository = PerfilRepository(modelContext: modelContext)
    }

    // Valida os campos, chama a API e guarda os dados locais.
    func autenticar(email: String, senha: String) async throws -> UsuarioModel {
        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let senhaLimpa = senha.trimmingCharacters(in: .whitespacesAndNewlines)

        guard emailLimpo.isEmpty == false else {
            throw LoginControllerError.emailVazio
        }

        guard senhaLimpa.isEmpty == false else {
            throw LoginControllerError.senhaVazia
        }

        do {
            // Primeiro tenta login normal na API.
            let response = try await loginService.login(email: emailLimpo, senha: senhaLimpa)
            let usuario = response.toUsuarioModel(emailDigitado: emailLimpo)

            // Se a API passou, guardamos para uso offline depois.
            try usuarioRepository.salvarUsuarioAutenticado(usuario)
            try perfilRepository.salvarPrimeiraLeitura(usuario: usuario)

            guardarSessaoRapida(usuario)
            return usuario
        } catch LoginServiceError.network {
            // Sem API, tenta entrar com a sessao local ja guardada.
            return try autenticarComSessaoLocal(email: emailLimpo)
        } catch LoginServiceError.server(_, let statusCode) where statusCode >= 500 {
            // Se a API caiu no servidor, tambem usamos a sessao local.
            return try autenticarComSessaoLocal(email: emailLimpo)
        }
    }

    // Usa o utilizador guardado quando nao ha ligacao com a API.
    private func autenticarComSessaoLocal(email: String) throws -> UsuarioModel {
        guard let usuarioLocal = try usuarioRepository.buscarUsuarioAutenticado() else {
            throw LoginServiceError.network(
                message: "Sem ligacao com a API e sem login guardado neste telemovel."
            )
        }

        guard usuarioLocal.email.lowercased() == email.lowercased() else {
            throw LoginServiceError.network(
                message: "Sem ligacao com a API. Usa o mesmo e-mail do ultimo login guardado."
            )
        }

        guardarSessaoRapida(usuarioLocal)
        return usuarioLocal
    }

    // Mantem token, role e perfil disponiveis para rotas protegidas.
    private func guardarSessaoRapida(_ usuario: UsuarioModel) {
        UserDefaults.standard.set(usuario.token, forKey: ApiConstants.tokenKey)
        UserDefaults.standard.set(usuario.role, forKey: ApiConstants.roleKey)
        UserDefaults.standard.set(usuario.perfil, forKey: ApiConstants.perfilKey)
    }
}
