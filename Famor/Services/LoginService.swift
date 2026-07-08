//
//  LoginService.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation

// Dados enviados para a API no momento do login.
struct LoginRequest: Encodable {
    let email: String
    let passwordHash: String
}

// Erros que podem acontecer quando chamamos a API.
enum LoginServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case network(message: String)
    case server(message: String, statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A rota da API nao esta valida."
        case .invalidResponse:
            return "A API respondeu de uma forma inesperada."
        case .invalidData:
            return "Nao foi possivel ler os dados que vieram da API."
        case .network(let message):
            return message
        case .server(let message, _):
            return message
        }
    }
}

// Servico responsavel apenas por comunicar com a API.
struct LoginService {
    func login(email: String, senha: String) async throws -> LoginResponse {
        guard let url = URL(string: Endpoints.login) else {
            throw LoginServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Aqui mandamos igual ao Postman: email e passwordHash.
        request.httpBody = try JSONEncoder().encode(LoginRequest(email: email, passwordHash: senha))

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw LoginServiceError.network(
                message: "Nao foi possivel ligar a API. Confirma se o servidor esta ligado e na mesma rede."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LoginServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(ApiErrorResponse.self, from: data)
            throw LoginServiceError.server(
                message: apiError?.message ?? "Login nao autorizado. Verifica o e-mail e a senha.",
                statusCode: httpResponse.statusCode
            )
        }

        do {
            return try JSONDecoder().decode(LoginResponse.self, from: data)
        } catch {
            throw LoginServiceError.invalidData
        }
    }
}

// Implementacao das mensagens de erro que podem vir do backend.
private struct ApiErrorResponse: Decodable {
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case message
        case mensagem
        case erro
        case error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = (try? container.decode(String.self, forKey: .message))
            ?? (try? container.decode(String.self, forKey: .mensagem))
            ?? (try? container.decode(String.self, forKey: .erro))
            ?? (try? container.decode(String.self, forKey: .error))
    }
}
