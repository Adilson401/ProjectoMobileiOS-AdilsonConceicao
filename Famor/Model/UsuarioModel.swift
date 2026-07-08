//
//  UsuarioModel.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation
import SwiftData

// Este e o utilizador guardado no telemovel depois do login.
@Model
final class UsuarioModel {
    // Usamos id unico para o SwiftData saber actualizar sem duplicar.
    @Attribute(.unique) var id: String

    var nome: String
    var email: String
    var telefone: String?
    var token: String
    var role: String?
    var perfil: String?
    var dataLogin: Date

    init(
        id: String,
        nome: String,
        email: String,
        telefone: String? = nil,
        token: String,
        role: String? = nil,
        perfil: String? = nil,
        dataLogin: Date = .now
    ) {
        self.id = id
        self.nome = nome
        self.email = email
        self.telefone = telefone
        self.token = token
        self.role = role
        self.perfil = perfil
        self.dataLogin = dataLogin
    }
}

// Modelo usado para ler o utilizador que vem da API.
struct UsuarioDTO: Decodable {
    let id: String?
    let nome: String?
    let email: String?
    let telefone: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case nome
        case name
        case email
        case telefone
        case phone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // A API pode mandar id como String ou numero.
        id = container.decodeStringIfExists(forKeys: [.id, .mongoId])
        nome = container.decodeStringIfExists(forKeys: [.nome, .name])
        email = container.decodeStringIfExists(forKeys: [.email])
        telefone = container.decodeStringIfExists(forKeys: [.telefone, .phone])
    }
}

// Resposta principal do login.
struct LoginResponse: Decodable {
    let token: String
    let role: String?
    let perfil: String?
    let usuario: UsuarioDTO?
    let mensagem: String?

    private enum CodingKeys: String, CodingKey {
        case token
        case accessToken
        case role
        case perfil
        case usuario
        case user
        case data
        case message
        case mensagem
        case msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

        // Algumas APIs mandam token directo, outras mandam dentro de data.
        let tokenRecebido = container.decodeStringIfExists(forKeys: [.token, .accessToken])
            ?? dataContainer?.decodeStringIfExists(forKeys: [.token, .accessToken])

        guard let tokenRecebido, tokenRecebido.isEmpty == false else {
            throw DecodingError.keyNotFound(
                CodingKeys.token,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "A API nao devolveu token no login."
                )
            )
        }

        token = tokenRecebido
        role = container.decodeStringIfExists(forKeys: [.role])
            ?? dataContainer?.decodeStringIfExists(forKeys: [.role])
        perfil = container.decodeStringIfExists(forKeys: [.perfil])
            ?? dataContainer?.decodeStringIfExists(forKeys: [.perfil])

        // Tambem aceitamos usuario ou user, directo ou dentro de data.
        usuario = (try? container.decode(UsuarioDTO.self, forKey: .usuario))
            ?? (try? container.decode(UsuarioDTO.self, forKey: .user))
            ?? (try? dataContainer?.decode(UsuarioDTO.self, forKey: .usuario))
            ?? (try? dataContainer?.decode(UsuarioDTO.self, forKey: .user))

        mensagem = container.decodeStringIfExists(forKeys: [.message, .mensagem, .msg])
            ?? dataContainer?.decodeStringIfExists(forKeys: [.message, .mensagem, .msg])
    }

    // Transforma a resposta da API no modelo que guardamos no SwiftData.
    func toUsuarioModel(emailDigitado: String) -> UsuarioModel {
        let emailFinal = usuario?.email ?? emailDigitado
        let idFinal = usuario?.id ?? emailFinal

        return UsuarioModel(
            id: idFinal,
            nome: usuario?.nome ?? "",
            email: emailFinal,
            telefone: usuario?.telefone,
            token: token,
            role: role,
            perfil: perfil
        )
    }
}

// Ajuda para ler valores que podem vir como String ou numero.
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
}
