//
//  ApiConstants.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation

// Aqui ficam constantes gerais usadas na API.
enum ApiConstants {
    // Chaves usadas para guardar a sessao no telemovel.
    static let tokenKey = "token"
    static let roleKey = "role"
    static let perfilKey = "perfil"

    // Monta o token no formato que a API normalmente pede.
    static func bearerToken(_ token: String) -> String {
        "Bearer \(token)"
    }

    // Colocar a permissao na request quando a rota precisar de token.
    static func aplicarToken(_ token: String?, na request: inout URLRequest) {
        guard let token, token.isEmpty == false else { return }
        request.setValue(bearerToken(token), forHTTPHeaderField: "Authorization")
    }
}
