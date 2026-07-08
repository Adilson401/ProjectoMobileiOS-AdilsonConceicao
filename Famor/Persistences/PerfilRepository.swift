//
//  PerfilRepository.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import Foundation
import SwiftData

// Repository cuida do perfil guardado no telemovel.
@MainActor
final class PerfilRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Busca o perfil que ficou guardado da primeira leitura.
    func buscarPrimeiraLeitura() throws -> PerfilLocalModel? {
        var descriptor = FetchDescriptor<PerfilLocalModel>(
            sortBy: [SortDescriptor(\.dataLeitura, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    // Guarda ou actualiza a leitura local que veio da API.
    func salvarPrimeiraLeitura(
        perfil: PerfilUsuarioResponse,
        totais: TotaisConsultasResponse,
        usuarioId: String?
    ) throws {
        if let perfilLocal = try buscarPrimeiraLeitura() {
            perfilLocal.usuarioId = usuarioId ?? perfilLocal.usuarioId
            perfilLocal.perfilId = textoValido(perfil.id) ?? perfilLocal.perfilId
            perfilLocal.nome = textoValido(perfil.nome) ?? perfilLocal.nome
            perfilLocal.email = textoValido(perfil.email) ?? perfilLocal.email
            perfilLocal.morada = textoValido(perfil.morada) ?? perfilLocal.morada
            perfilLocal.funcao = textoValido(perfil.funcao) ?? perfilLocal.funcao
            perfilLocal.perfil = textoValido(perfil.perfil) ?? perfilLocal.perfil
            perfilLocal.status = textoValido(perfil.status) ?? perfilLocal.status
            perfilLocal.dataRegisto = perfil.dataRegisto ?? perfilLocal.dataRegisto
            perfilLocal.totalConsultas = totais.totalConsultas
            perfilLocal.concluidas = totais.concluidas
            perfilLocal.canceladas = totais.canceladas
            perfilLocal.dataLeitura = .now
        } else {
            let perfilLocal = PerfilLocalModel(
                usuarioId: usuarioId,
                perfilId: perfil.id,
                nome: textoValido(perfil.nome) ?? "Paciente Famor",
                email: textoValido(perfil.email) ?? "email nao informado",
                morada: textoValido(perfil.morada),
                funcao: textoValido(perfil.funcao),
                perfil: textoValido(perfil.perfil),
                status: textoValido(perfil.status),
                dataRegisto: perfil.dataRegisto,
                totalConsultas: totais.totalConsultas,
                concluidas: totais.concluidas,
                canceladas: totais.canceladas
            )

            modelContext.insert(perfilLocal)
        }

        try modelContext.save()
    }

    // Guarda o perfil basico que vem logo no login.
    func salvarPrimeiraLeitura(usuario: UsuarioModel) throws {
        if let perfilLocal = try buscarPrimeiraLeitura() {
            perfilLocal.usuarioId = usuario.id
            perfilLocal.perfilId = perfilLocal.perfilId ?? usuario.id
            perfilLocal.nome = textoValido(usuario.nome) ?? perfilLocal.nome
            perfilLocal.email = textoValido(usuario.email) ?? perfilLocal.email
            perfilLocal.funcao = perfilLocal.funcao ?? textoValido(usuario.perfil) ?? textoValido(usuario.role)
            perfilLocal.perfil = perfilLocal.perfil ?? textoValido(usuario.perfil)
            perfilLocal.dataRegisto = perfilLocal.dataRegisto ?? usuario.dataLogin
            perfilLocal.dataLeitura = .now
        } else {
            let perfilLocal = PerfilLocalModel(
                usuarioId: usuario.id,
                perfilId: usuario.id,
                nome: textoValido(usuario.nome) ?? "Paciente Famor",
                email: textoValido(usuario.email) ?? "email nao informado",
                funcao: textoValido(usuario.perfil) ?? textoValido(usuario.role),
                perfil: textoValido(usuario.perfil),
                dataRegisto: usuario.dataLogin
            )

            modelContext.insert(perfilLocal)
        }

        try modelContext.save()
    }

    // Limpa o perfil local ao terminar sessao.
    func limparPerfilLocal() throws {
        let perfis = try modelContext.fetch(FetchDescriptor<PerfilLocalModel>())

        for perfil in perfis {
            modelContext.delete(perfil)
        }

        try modelContext.save()
    }

    private func textoValido(_ texto: String?) -> String? {
        guard let texto else { return nil }
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }
}
