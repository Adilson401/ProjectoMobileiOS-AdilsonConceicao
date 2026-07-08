//
//  PerfilService.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import Foundation

// Dados do perfil que vem da API.
struct PerfilUsuarioResponse: Decodable {
    let id: String?
    let pacienteId: String?
    let usuarioId: String?
    let nome: String?
    let email: String?
    let morada: String?
    let funcao: String?
    let perfil: String?
    let status: String?
    let dataRegisto: Date?

    init(
        id: String?,
        nome: String?,
        email: String?,
        morada: String?,
        funcao: String?,
        perfil: String?,
        status: String?,
        dataRegisto: Date?,
        pacienteId: String? = nil,
        usuarioId: String? = nil
    ) {
        self.id = id
        self.pacienteId = pacienteId
        self.usuarioId = usuarioId
        self.nome = nome
        self.email = email
        self.morada = morada
        self.funcao = funcao
        self.perfil = perfil
        self.status = status
        self.dataRegisto = dataRegisto
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case pacienteId
        case usuarioId
        case nome
        case email
        case morada
        case funcao
        case perfil
        case status
        case dataRegisto
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id, .mongoId])
        pacienteId = container.decodeStringIfExists(forKeys: [.pacienteId])
        usuarioId = container.decodeStringIfExists(forKeys: [.usuarioId])
        nome = container.decodeStringIfExists(forKeys: [.nome])
        email = container.decodeStringIfExists(forKeys: [.email])
        morada = container.decodeStringIfExists(forKeys: [.morada])
        funcao = container.decodeStringIfExists(forKeys: [.funcao])
        perfil = container.decodeStringIfExists(forKeys: [.perfil])
        status = container.decodeStringIfExists(forKeys: [.status])
        dataRegisto = container.decodeDateIfExists(forKey: .dataRegisto)
    }
}

// Registro de paciente associado ao usuario autenticado.
struct PacienteUsuarioResponse: Decodable {
    let id: String?
    let usuarioId: String?
    let estado: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case usuarioId
        case idUsuario
        case estado
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id, .mongoId])
        usuarioId = container.decodeStringIfExists(forKeys: [.usuarioId, .idUsuario])
        estado = container.decodeStringIfExists(forKeys: [.estado, .status])
    }
}

// Totais das consultas do usuario.
struct TotaisConsultasResponse: Decodable {
    let totalConsultas: Int
    let concluidas: Int
    let canceladas: Int

    init(totalConsultas: Int, concluidas: Int, canceladas: Int) {
        self.totalConsultas = totalConsultas
        self.concluidas = concluidas
        self.canceladas = canceladas
    }

    private enum CodingKeys: String, CodingKey {
        case totalConsultas
        case totalMaiusculo = "TotalConsultas"
        case concluidas
        case concluidasMaiusculo = "Concluidas"
        case canceladas
        case canceladasMaiusculo = "Canceladas"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalConsultas = container.decodeIntIfExists(forKeys: [.totalConsultas, .totalMaiusculo]) ?? 0
        concluidas = container.decodeIntIfExists(forKeys: [.concluidas, .concluidasMaiusculo]) ?? 0
        canceladas = container.decodeIntIfExists(forKeys: [.canceladas, .canceladasMaiusculo]) ?? 0
    }
}

// Mensagem de erro devolvida pelo backend.
private struct PerfilApiErrorResponse: Decodable {
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

// Erros que podem acontecer ao carregar perfil.
enum PerfilServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case tokenAusente
    case network(message: String)
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A rota da API nao esta valida."
        case .invalidResponse:
            return "A API respondeu de uma forma inesperada."
        case .invalidData:
            return "Nao foi possivel ler os dados do perfil."
        case .tokenAusente:
            return "Sessao expirada. Faz login novamente."
        case .network(let message):
            return message
        case .server(let message):
            return message
        }
    }
}

// Service responsavel pelas rotas protegidas do perfil.
struct PerfilService {
    func buscarPerfil(token: String) async throws -> PerfilUsuarioResponse {
        try await get(endpoint: Endpoints.usuarioPerfil, token: token)
    }

    func buscarPacienteDoUsuario(usuarioId: String, token: String) async throws -> PacienteUsuarioResponse? {
        let pacientes: [PacienteUsuarioResponse] = try await get(endpoint: Endpoints.pacientes, token: token)
        return pacientes.first { paciente in
            paciente.usuarioId == usuarioId
        }
    }

    func buscarTotaisConsultas(token: String) async throws -> TotaisConsultasResponse {
        try await get(endpoint: Endpoints.consultasTotas, token: token)
    }

    // Funcao comum para GET com Bearer token.
    private func get<Response: Decodable>(endpoint: String, token: String) async throws -> Response {
        guard token.isEmpty == false else {
            throw PerfilServiceError.tokenAusente
        }

        guard let url = URL(string: endpoint) else {
            throw PerfilServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        ApiConstants.aplicarToken(token, na: &request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw PerfilServiceError.network(
                message: "Nao foi possivel ligar a API. Confirma se o servidor esta ligado."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PerfilServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(PerfilApiErrorResponse.self, from: data)
            throw PerfilServiceError.server(
                message: apiError?.message ?? "A API recusou o pedido. Codigo \(httpResponse.statusCode)."
            )
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw PerfilServiceError.invalidData
        }
    }
}

// Ajudar a ler valores flexiveis vindos da API.
private extension KeyedDecodingContainer {
    func decodeStringIfExists(forKeys keys: [K]) -> String? {
        for key in keys {
            if let value = try? decode(String.self, forKey: key) {
                return value
            }

            if let value = try? decode(Int.self, forKey: key) {
                return String(value)
            }
        }

        return nil
    }

    func decodeIntIfExists(forKeys keys: [K]) -> Int? {
        for key in keys {
            if let value = try? decode(Int.self, forKey: key) {
                return value
            }

            if let value = try? decode(String.self, forKey: key), let intValue = Int(value) {
                return intValue
            }
        }

        return nil
    }

    func decodeDateIfExists(forKey key: K) -> Date? {
        if let date = try? decode(Date.self, forKey: key) {
            return date
        }

        guard let value = try? decode(String.self, forKey: key) else {
            return nil
        }

        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: value)
    }
}
