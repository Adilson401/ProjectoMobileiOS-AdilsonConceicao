//
//  Endpoints.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import Foundation

// Aqui ficam os caminhos da API.
enum Endpoints {
    // Endereco base da API na rede local.
    static let baseURL = "http://172.20.10.2:3000/api"

    // Caminho usado para fazer login.
    static let login = "\(baseURL)/login"

    // Caminhos usados no cadastro de usuario.
    static let usuarios = "\(baseURL)/usuarios"
    static let usuariosConfirmar = "\(baseURL)/usuarios/confirmar"

    // Caminhos usados no perfil do usuario.
    static let usuarioPerfil = "\(baseURL)/usuarioperfil"
    static let consultasTotas = "\(baseURL)/consultastotas"
    static let pacientes = "\(baseURL)/paciente"

    // Caminho usado para buscar a ultima marcacao do paciente.
    static let marcacaoUltimaBase = "\(baseURL)/marcacaoultima"

    // Caminho usado para criar uma nova marcacao.
    static let marcacao = "\(baseURL)/marcacao"

    // Caminho usado para listar consultas feitas.
    static let marcacoesFeitasBase = "\(baseURL)/marcacaofeitas"

    // Caminho usado para carregar nomes das especialidades.
    static let especialidadeNomes = "\(baseURL)/especialidade/nomes"

    // Caminho usado para filtrar a agenda medica por usuario e especialidade.
    static let agendaMedicaFiltrarBase = "\(baseURL)/agendamedicafiltrar"

    static func marcacaoUltima(usuarioId: String) -> String {
        var components = URLComponents(string: marcacaoUltimaBase)
        components?.queryItems = [
            URLQueryItem(name: "usuarioId", value: usuarioId),
            URLQueryItem(name: "idUsuario", value: usuarioId),
            URLQueryItem(name: "pacienteId", value: usuarioId)
        ]

        return components?.url?.absoluteString ?? "\(marcacaoUltimaBase)?usuarioId=\(usuarioId)"
    }

    static func marcacoesFeitas(usuarioId: String) -> String {
        var components = URLComponents(string: marcacoesFeitasBase)
        components?.queryItems = [
            URLQueryItem(name: "usuarioId", value: usuarioId)
        ]

        return components?.url?.absoluteString ?? "\(marcacoesFeitasBase)?usuarioId=\(usuarioId)"
    }

    static func agendaMedicaFiltrar(usuarioId: String, especialidadeId: String) -> String {
        var components = URLComponents(string: agendaMedicaFiltrarBase)
        components?.queryItems = [
            URLQueryItem(name: "usuarioId", value: usuarioId),
            URLQueryItem(name: "especialidadeId", value: especialidadeId)
        ]

        return components?.url?.absoluteString
            ?? "\(agendaMedicaFiltrarBase)?usuarioId=\(usuarioId)&especialidadeId=\(especialidadeId)"
    }

    // Caminhos usados no fluxo de recuperar senha.
    static let senhaRecuperar = "\(baseURL)/senha/recuperar"
    static let senhaResetar = "\(baseURL)/senha/resetar"
}
