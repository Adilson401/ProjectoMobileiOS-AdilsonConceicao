//
//  UsuarioService.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import Foundation

// Dados que a API pede para abrir o cadastro.
struct RegistarUsuarioRequest: Encodable {
    let nome: String
    let morada: String
    let email: String
    let datanascimento: String
    let passwordHash: String
    let status: String
}

// Dados enviados para confirmar o codigo do cadastro.
struct ConfirmarUsuarioRequest: Encodable {
    let email: String
    let codigo: String
}

// Resposta simples que vem do cadastro.
struct RegistarUsuarioResponse: Decodable {
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

// Erros que podem aparecer ao cadastrar usuario.
enum UsuarioServiceError: LocalizedError {
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

// Service responsavel apenas por falar com a API de usuarios.
struct UsuarioService {
    func registarUsuario(
        nome: String,
        morada: String,
        email: String,
        dataNascimento: String,
        senha: String
    ) async throws -> String {
        // O backend espera datanascimento, passwordHash e status.
        let response = try await post(
            endpoint: Endpoints.usuarios,
            body: RegistarUsuarioRequest(
                nome: nome,
                morada: morada,
                email: email,
                datanascimento: dataNascimento,
                passwordHash: senha,
                status: "Activo"
            )
        )

        return response.message ?? "Cadastro enviado. Verifica o teu e-mail."
    }

    func confirmarCadastro(email: String, codigo: String) async throws -> String {
        let response = try await post(
            endpoint: Endpoints.usuariosConfirmar,
            body: ConfirmarUsuarioRequest(email: email, codigo: codigo)
        )

        return response.message ?? "Cadastro confirmado com sucesso. Agora ja podes entrar."
    }

    // Funcao comum para enviar JSON por POST.
    private func post<Body: Encodable>(endpoint: String, body: Body) async throws -> RegistarUsuarioResponse {
        guard let url = URL(string: endpoint) else {
            throw UsuarioServiceError.invalidURL
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
            throw UsuarioServiceError.network(
                message: "Nao foi possivel ligar a API. Confirma se o servidor esta ligado."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsuarioServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(RegistarUsuarioResponse.self, from: data)
            throw UsuarioServiceError.server(
                message: apiError?.message ?? "A API recusou o pedido. Codigo \(httpResponse.statusCode)."
            )
        }

        do {
            return try JSONDecoder().decode(RegistarUsuarioResponse.self, from: data)
        } catch {
            throw UsuarioServiceError.invalidData
        }
    }
}
