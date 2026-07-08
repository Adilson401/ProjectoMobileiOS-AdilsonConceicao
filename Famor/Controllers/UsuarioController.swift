//
//  UsuarioController.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import Foundation

// Erros simples antes de chamar a API de usuarios.
enum UsuarioControllerError: LocalizedError {
    case nomeVazio
    case moradaVazia
    case emailVazio
    case dataNascimentoVazia
    case dataNascimentoInvalida
    case senhaVazia
    case codigoVazio

    var errorDescription: String? {
        switch self {
        case .nomeVazio:
            return "Escreve o teu nome para continuar."
        case .moradaVazia:
            return "Escreve a tua morada para continuar."
        case .emailVazio:
            return "Escreve o teu e-mail para continuar."
        case .dataNascimentoVazia:
            return "Escreve a tua data de nascimento."
        case .dataNascimentoInvalida:
            return "A data deve estar no formato YYYY-MM-DD."
        case .senhaVazia:
            return "Escreve a tua senha para continuar."
        case .codigoVazio:
            return "Escreve o codigo recebido no e-mail."
        }
    }
}

// Controller organiza o fluxo de cadastro.
@MainActor
final class UsuarioController {
    private let usuarioService: UsuarioService

    init() {
        self.usuarioService = UsuarioService()
    }

    init(usuarioService: UsuarioService) {
        self.usuarioService = usuarioService
    }

    // Valida os campos e manda para API.
    func registarUsuario(
        nome: String,
        morada: String,
        email: String,
        dataNascimento: String,
        senha: String
    ) async throws -> String {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        let moradaLimpa = morada.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataLimpa = dataNascimento.trimmingCharacters(in: .whitespacesAndNewlines)
        let senhaLimpa = senha.trimmingCharacters(in: .whitespacesAndNewlines)

        guard nomeLimpo.isEmpty == false else {
            throw UsuarioControllerError.nomeVazio
        }

        guard moradaLimpa.isEmpty == false else {
            throw UsuarioControllerError.moradaVazia
        }

        guard emailLimpo.isEmpty == false else {
            throw UsuarioControllerError.emailVazio
        }

        guard dataLimpa.isEmpty == false else {
            throw UsuarioControllerError.dataNascimentoVazia
        }

        guard dataNascimentoValida(dataLimpa) else {
            throw UsuarioControllerError.dataNascimentoInvalida
        }

        guard senhaLimpa.isEmpty == false else {
            throw UsuarioControllerError.senhaVazia
        }

        return try await usuarioService.registarUsuario(
            nome: nomeLimpo,
            morada: moradaLimpa,
            email: emailLimpo,
            dataNascimento: dataLimpa,
            senha: senhaLimpa
        )
    }

    // Confirma o codigo enviado por e-mail.
    func confirmarCadastro(email: String, codigo: String) async throws -> String {
        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let codigoLimpo = codigo.trimmingCharacters(in: .whitespacesAndNewlines)

        guard emailLimpo.isEmpty == false else {
            throw UsuarioControllerError.emailVazio
        }

        guard codigoLimpo.isEmpty == false else {
            throw UsuarioControllerError.codigoVazio
        }

        return try await usuarioService.confirmarCadastro(email: emailLimpo, codigo: codigoLimpo)
    }

    // Confirma se a data esta no formato que o backend entende.
    private func dataNascimentoValida(_ data: String) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        return formatter.date(from: data) != nil
    }
}
