//
//  SenhaController.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation

// Erros simples antes de chamar a API de senha.
enum SenhaControllerError: LocalizedError {
    case emailVazio
    case codigoVazio
    case senhaVazia
    case senhasDiferentes

    var errorDescription: String? {
        switch self {
        case .emailVazio:
            return "Escreve o teu e-mail para continuar."
        case .codigoVazio:
            return "Escreve o codigo recebido para continuar."
        case .senhaVazia:
            return "Escreve a nova senha para continuar."
        case .senhasDiferentes:
            return "As senhas nao sao iguais. Confirma novamente."
        }
    }
}

// Controller organiza o fluxo da recuperacao de senha.
@MainActor
final class SenhaController {
    private let senhaService: SenhaService

    init() {
        self.senhaService = SenhaService()
    }

    init(senhaService: SenhaService) {
        self.senhaService = senhaService
    }

    // Primeiro passo: pedir codigo de recuperacao.
    func recuperarSenha(email: String) async throws -> String {
        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard emailLimpo.isEmpty == false else {
            throw SenhaControllerError.emailVazio
        }

        return try await senhaService.recuperarSenha(email: emailLimpo)
    }

    // Segundo passo: confirmar codigo e actualizar a senha.
    func redefinirSenha(
        email: String,
        codigo: String,
        novaSenha: String,
        confirmarNovaSenha: String
    ) async throws -> String {
        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let codigoLimpo = codigo.trimmingCharacters(in: .whitespacesAndNewlines)
        let senhaLimpa = novaSenha.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmacaoLimpa = confirmarNovaSenha.trimmingCharacters(in: .whitespacesAndNewlines)

        guard emailLimpo.isEmpty == false else {
            throw SenhaControllerError.emailVazio
        }

        guard codigoLimpo.isEmpty == false else {
            throw SenhaControllerError.codigoVazio
        }

        guard senhaLimpa.isEmpty == false else {
            throw SenhaControllerError.senhaVazia
        }

        guard senhaLimpa == confirmacaoLimpa else {
            throw SenhaControllerError.senhasDiferentes
        }

        return try await senhaService.redefinirSenha(
            email: emailLimpo,
            codigo: codigoLimpo,
            novaSenha: senhaLimpa,
            confirmarNovaSenha: confirmacaoLimpa
        )
    }
}
