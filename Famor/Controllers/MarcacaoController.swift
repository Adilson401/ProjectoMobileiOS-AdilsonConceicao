//
//  MarcacaoController.swift
//  Famor
//
//  Created by Aluno ISTEC on 06/07/2026.
//

import Foundation
import SwiftData

// Controller organiza as marcacoes que aparecem no painel.
@MainActor
final class MarcacaoController {
    private let marcacaoService: MarcacaoService
    private let perfilService: PerfilService

    init() {
        self.marcacaoService = MarcacaoService()
        self.perfilService = PerfilService()
    }

    init(marcacaoService: MarcacaoService, perfilService: PerfilService) {
        self.marcacaoService = marcacaoService
        self.perfilService = perfilService
    }

    // Busca as especialidades usadas no primeiro passo da marcacao.
    func carregarEspecialidades() async throws -> [EspecialidadeNomeResponse] {
        let token = UserDefaults.standard.string(forKey: ApiConstants.tokenKey) ?? ""
        return try await marcacaoService.buscarEspecialidades(token: token)
    }

    // Busca as especialidades guardadas no telemovel para modo offline.
    func carregarEspecialidadesLocais(modelContext: ModelContext) throws -> [EspecialidadeNomeResponse] {
        let repository = EspecialidadeRepository(modelContext: modelContext)
        return try repository.buscarTodas().map { especialidade in
            EspecialidadeNomeResponse(
                id: especialidade.id,
                nome: especialidade.nome
            )
        }
    }

    // Guarda a resposta boa da API para abrir a tela depois sem internet.
    func guardarEspecialidadesLocais(
        _ especialidades: [EspecialidadeNomeResponse],
        modelContext: ModelContext
    ) throws {
        let repository = EspecialidadeRepository(modelContext: modelContext)
        try repository.salvarEspecialidades(especialidades)
    }

    // Limpa cache antiga usada apenas no modo offline.
    func limparCacheMarcacaoLocal(modelContext: ModelContext) throws {
        try MarcacaoRascunhoRepository(modelContext: modelContext).limparTodos()
        try EspecialidadeRepository(modelContext: modelContext).limparTudo()
    }

    // Busca a agenda medica para a especialidade escolhida pelo paciente.
    func carregarAgendaMedica(
        usuario: UsuarioModel?,
        especialidadeId: String
    ) async throws -> [AgendaMedicaResponse] {
        guard let usuario else {
            throw MarcacaoServiceError.usuarioAusente
        }

        let token = UserDefaults.standard.string(forKey: ApiConstants.tokenKey) ?? usuario.token
        return try await marcacaoService.buscarAgendaMedica(
            usuarioId: usuario.id,
            especialidadeId: especialidadeId,
            token: token
        )
    }

    // Confirma a marcacao escolhida pelo paciente na API.
    func confirmarMarcacao(
        usuario: UsuarioModel?,
        especialidadeId: String,
        medicoId: String,
        agendaMedicaId: String?,
        dataConsulta: Date,
        hora: String,
        observacao: String?,
        codigoConfirmacao: String,
        estado: String
    ) async throws -> MarcacaoConfirmadaResponse {
        guard let usuario else {
            throw MarcacaoServiceError.usuarioAusente
        }

        guard let agendaMedicaId = Self.textoValido(agendaMedicaId) else {
            throw MarcacaoServiceError.agendaMedicaAusente
        }

        let token = UserDefaults.standard.string(forKey: ApiConstants.tokenKey) ?? usuario.token
        let perfil = try await perfilService.buscarPerfil(token: token)
        let usuarioIdAutenticado = Self.textoValido(perfil.usuarioId)
            ?? Self.textoValido(perfil.id)
            ?? usuario.id

        let pacienteDaApi = try await perfilService.buscarPacienteDoUsuario(
            usuarioId: usuarioIdAutenticado,
            token: token
        )
        guard let pacienteId = Self.textoValido(perfil.pacienteId)
            ?? Self.textoValido(pacienteDaApi?.id) else {
            throw MarcacaoServiceError.pacienteAusente
        }

        let request = CriarMarcacaoRequest(
            pacienteId: pacienteId,
            usuarioId: usuarioIdAutenticado,
            medicoId: medicoId,
            especialidadeId: especialidadeId,
            agendaMedicaId: agendaMedicaId,
            dataConsultas: Self.dataApiTexto(dataConsulta),
            hora: hora,
            observacao: Self.observacaoObrigatoria(observacao),
            codigoConfirmacao: codigoConfirmacao,
            estado: estado
        )

        return try await marcacaoService.criarMarcacao(request, token: token)
    }

    // Busca a ultima marcacao usando o usuario logado.
    func carregarUltimaMarcacao(usuario: UsuarioModel?) async throws -> MarcacaoHojeResponse? {
        guard let usuario else {
            throw MarcacaoServiceError.usuarioAusente
        }

        let token = UserDefaults.standard.string(forKey: ApiConstants.tokenKey) ?? usuario.token
        return try await marcacaoService.buscarUltimaMarcacao(usuarioId: usuario.id, token: token)
    }

    // Busca todas as consultas feitas/agendadas do usuario logado.
    func carregarMarcacoesFeitas(usuario: UsuarioModel?) async throws -> [MarcacaoFeitaResponse] {
        guard let usuario else {
            throw MarcacaoServiceError.usuarioAusente
        }

        let token = UserDefaults.standard.string(forKey: ApiConstants.tokenKey) ?? usuario.token
        return try await marcacaoService.buscarMarcacoesFeitas(usuarioId: usuario.id, token: token)
    }

    private static func dataApiTexto(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: data)
    }

    private static func textoValido(_ texto: String?) -> String? {
        guard let texto else { return nil }
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }

    private static func observacaoObrigatoria(_ texto: String?) -> String {
        textoValido(texto) ?? "Sem observacao"
    }
}
