//
//  SenhaService.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation

// Dados enviados para pedir recuperacao da senha.
struct RecuperarSenhaRequest: Encodable {
    let email: String
}

// Dados enviados para confirmar o codigo e gravar a nova senha.
struct RedefinirSenhaRequest: Encodable {
    let email: String
    let codigo: String
    let novaSenha: String
    let confirmSenha: String
}

// Resposta simples das rotas de senha.
struct SenhaResponse: Decodable {
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case message
        case mensagem
        case msg
        case error
        case erro
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = (try? container.decode(String.self, forKey: .message))
            ?? (try? container.decode(String.self, forKey: .mensagem))
            ?? (try? container.decode(String.self, forKey: .msg))
            ?? (try? container.decode(String.self, forKey: .error))
            ?? (try? container.decode(String.self, forKey: .erro))
    }
}

// Erros que podem acontecer nas rotas de senha.
enum SenhaServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case network(message: String)
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A rota da API nao esta valida."
        case .invalidResponse:
            return "A API respondeu de uma forma inesperada."
        case .invalidData:
            return "Nao foi possivel ler a resposta da API."
        case .network(let message):
            return message
        case .server(let message):
            return message
        }
    }
}

// Service responsavel apenas por falar com a API de senha.
struct SenhaService {
    func recuperarSenha(email: String) async throws -> String {
        let response = try await post(
            endpoint: Endpoints.senhaRecuperar,
            body: RecuperarSenhaRequest(email: email)
        )

        return response.message ?? "Se o e-mail existir, vamos enviar o codigo de recuperacao."
    }

    func redefinirSenha(
        email: String,
        codigo: String,
        novaSenha: String,
        confirmarNovaSenha: String
    ) async throws -> String {
        let response = try await post(
            endpoint: Endpoints.senhaResetar,
            body: RedefinirSenhaRequest(
                email: email,
                codigo: codigo,
                novaSenha: novaSenha,
                confirmSenha: confirmarNovaSenha
            )
        )

        return response.message ?? "Senha actualizada com sucesso."
    }

    // Funcao comum para enviar JSON por POST.
    private func post<Body: Encodable>(endpoint: String, body: Body) async throws -> SenhaResponse {
        guard let url = URL(string: endpoint) else {
            throw SenhaServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw SenhaServiceError.network(
                message: "Nao foi possivel ligar a API. Confirma se o servidor esta ligado."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SenhaServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(SenhaResponse.self, from: data)
            throw SenhaServiceError.server(
                message: apiError?.message ?? "A API recusou o pedido. Codigo \(httpResponse.statusCode)."
            )
        }

        do {
            return try JSONDecoder().decode(SenhaResponse.self, from: data)
        } catch {
            throw SenhaServiceError.invalidData
        }
    }
}
