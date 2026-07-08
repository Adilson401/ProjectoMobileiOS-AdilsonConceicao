//
//  UsuarioPerfil.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import SwiftUI
import SwiftData

struct UsuarioPerfil: View {
    // Contexto usado para limpar a sessao local.
    @Environment(\.modelContext) private var modelContext

    // Usuario guardado localmente depois do login.
    @Query(sort: \UsuarioModel.dataLogin, order: .reverse) private var usuarios: [UsuarioModel]

    // Primeira leitura do perfil guardada no telemovel.
    @Query(sort: \PerfilLocalModel.dataLeitura, order: .reverse) private var perfisLocais: [PerfilLocalModel]

    // Chamada usada para voltar ao login depois de sair.
    var onLogout: (() -> Void)? = nil

    // Dados carregados da API.
    @State private var perfil: PerfilUsuarioResponse?
    @State private var totais = TotaisConsultasResponse(totalConsultas: 0, concluidas: 0, canceladas: 0)

    // Estados da tela.
    @State private var loading = false
    @State private var mensagemErro: String?
    @State private var mensagemAviso: String?
    @State private var mensagemLoading = "A buscar dados do perfil..."

    var body: some View {
        ZStack {
            TemaStyles.backgroundColor
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 22) {
                    profileHeader
                    statsGrid
                    infoCard

                    if let mensagemAviso {
                        statusMessage(mensagemAviso, isError: false)
                    }

                    if let mensagemErro {
                        statusMessage(mensagemErro, isError: true)
                    }

                    logoutButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable {
                await carregarPerfil()
            }

            if loading {
                loadingOverlay
            }
        }
        .task {
            await carregarPerfil()
        }
    }

    // Loading com mensagem enquanto tenta falar com a API.
    private var loadingOverlay: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(TemaStyles.primaryColor)

            Text(mensagemLoading)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(TemaStyles.titleColor.opacity(0.76))
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: 260)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.58), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.14), radius: 16, x: 0, y: 8)
    }

    // Cabecalho com avatar, nome, email e perfil.
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person")
                .font(.system(size: 50, weight: .semibold))
                .foregroundStyle(Color(red: 0.00, green: 0.66, blue: 0.62))
                .frame(width: 82, height: 82)
                .background(Color(red: 0.84, green: 0.97, blue: 0.95))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

            VStack(spacing: 6) {
                Text(nomePerfil)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(TemaStyles.titleColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "envelope")
                    Text(emailPerfil)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            }

            HStack(spacing: 6) {
                Image(systemName: "shield.checkered")
                Text(funcaoPerfil)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(Color(red: 0.00, green: 0.58, blue: 0.56))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(red: 0.84, green: 0.97, blue: 0.95))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color(red: 0.55, green: 0.86, blue: 0.84), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // Cards com totais das consultas.
    private var statsGrid: some View {
        HStack(spacing: 12) {
            statCard(value: totais.totalConsultas, title: "Total", color: TemaStyles.titleColor)
            statCard(value: totais.concluidas, title: "Concluidas", color: Color(red: 0.00, green: 0.64, blue: 0.50))
            statCard(value: totais.canceladas, title: "Canceladas", color: Color(red: 0.90, green: 0.08, blue: 0.22))
        }
    }

    // Card com informacoes do usuario.
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Informações")
                .font(.headline.weight(.bold))
                .foregroundStyle(TemaStyles.titleColor)

            VStack(spacing: 18) {
                infoRow(icon: "person", label: "Nome", value: nomePerfil)
                infoRow(icon: "envelope", label: "Email", value: emailPerfil)
                infoRow(icon: "mappin", label: "Morada", value: moradaPerfil)
                infoRow(icon: "briefcase", label: "Função", value: funcaoPerfil)
                infoRow(icon: "calendar", label: "Data de registo", value: dataRegistoTexto)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.58), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)
    }

    // Botao vermelho para terminar sessao.
    private var logoutButton: some View {
        Button {
            terminarSessao()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Terminar Sessao")
            }
            .font(.headline.weight(.bold))
            .foregroundStyle(Color(red: 0.84, green: 0.22, blue: 0.26))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(Color(red: 0.94, green: 0.55, blue: 0.58).opacity(0.75), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // Card pequeno de estatistica.
    private func statCard(value: Int, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.58), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.13), radius: 14, x: 0, y: 8)
    }

    // Linha de informacao dentro do card.
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(red: 0.55, green: 0.62, blue: 0.70))
                .frame(width: 42, height: 42)
                .background(Color(red: 0.91, green: 0.96, blue: 1.00))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    // Mostra aviso ou erro mantendo o visual do app.
    private func statusMessage(_ text: String, isError: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "wifi.slash")
                .font(.footnote.weight(.semibold))

            Text(text)
                .font(.footnote.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(isError ? Color(red: 0.78, green: 0.12, blue: 0.12) : Color(red: 0.02, green: 0.45, blue: 0.52))
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isError ? Color(red: 1.00, green: 0.93, blue: 0.93) : Color(red: 0.90, green: 0.98, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
    }

    // Carrega dados locais primeiro e depois tenta actualizar pela API.
    private func carregarPerfil() async {
        guard loading == false else { return }

        let temCache = prepararLeituraLocal()
        mensagemLoading = temCache
            ? "A actualizar dados pela API..."
            : "A buscar dados do perfil..."
        loading = true
        mensagemErro = nil
        mensagemAviso = nil

        do {
            let controller = PerfilController()
            let dados = try await controller.carregarPerfil()
            perfil = dados.perfil
            totais = dados.totais
            guardarLeituraLocal(dados)
            loading = false
        } catch {
            let carregouLocal = prepararLeituraLocal()
            loading = false

            if carregouLocal {
                mensagemAviso = "Sem internet ou servidor indisponivel. A mostrar os dados guardados no telemovel."
            } else {
                mensagemErro = error.localizedDescription
            }
        }
    }

    // Garante que existe alguma leitura local para modo offline.
    @discardableResult
    private func prepararLeituraLocal() -> Bool {
        if aplicarPrimeiraLeituraLocal() {
            return true
        }

        guard let usuarioLocal else {
            return false
        }

        do {
            let repository = PerfilRepository(modelContext: modelContext)
            try repository.salvarPrimeiraLeitura(usuario: usuarioLocal)
        } catch {
            mensagemAviso = "Nao foi possivel guardar o perfil no telemovel."
        }

        perfil = PerfilUsuarioResponse(
            id: usuarioLocal.id,
            nome: usuarioLocal.nome,
            email: usuarioLocal.email,
            morada: nil,
            funcao: usuarioLocal.perfil ?? usuarioLocal.role,
            perfil: usuarioLocal.perfil,
            status: nil,
            dataRegisto: usuarioLocal.dataLogin
        )
        totais = TotaisConsultasResponse(totalConsultas: 0, concluidas: 0, canceladas: 0)
        return true
    }

    // Aplica os dados guardados da primeira leitura, se existir.
    @discardableResult
    private func aplicarPrimeiraLeituraLocal() -> Bool {
        guard let perfilLocal = perfisLocais.first else {
            return false
        }

        perfil = perfilLocal.toPerfilResponse()
        totais = perfilLocal.toTotaisResponse()
        return true
    }

    // Guarda a resposta boa da API no SwiftData para usar offline depois.
    private func guardarLeituraLocal(_ dados: PerfilTelaDados) {
        do {
            let repository = PerfilRepository(modelContext: modelContext)
            try repository.salvarPrimeiraLeitura(
                perfil: dados.perfil,
                totais: dados.totais,
                usuarioId: usuarioLocal?.id
            )
        } catch {
            mensagemAviso = "Perfil carregado, mas nao foi possivel guardar no telemovel."
        }
    }

    // Limpa dados locais e volta para o login.
    private func terminarSessao() {
        do {
            let repository = UsuarioRepository(modelContext: modelContext)
            try repository.limparUsuarioAutenticado()
            onLogout?()
        } catch {
            mensagemErro = "Nao foi possivel terminar a sessao agora."
        }
    }

    private var usuarioLocal: UsuarioModel? {
        usuarios.first
    }

    private var nomePerfil: String {
        textoValido(perfil?.nome) ?? textoValido(usuarioLocal?.nome) ?? "Paciente Famor"
    }

    private var emailPerfil: String {
        textoValido(perfil?.email) ?? textoValido(usuarioLocal?.email) ?? "email nao informado"
    }

    private var moradaPerfil: String {
        textoValido(perfil?.morada) ?? "Nao informado"
    }

    private var funcaoPerfil: String {
        textoValido(perfil?.funcao)
            ?? textoValido(perfil?.perfil)
            ?? textoValido(usuarioLocal?.perfil)
            ?? "Pacientes"
    }

    private var dataRegistoTexto: String {
        guard let data = perfil?.dataRegisto ?? usuarioLocal?.dataLogin else {
            return "Nao informado"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "dd 'de' MMMM 'de' yyyy"
        return formatter.string(from: data)
    }

    private func textoValido(_ texto: String?) -> String? {
        guard let texto else { return nil }
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }
}

#Preview {
    UsuarioPerfil()
        .modelContainer(for: [UsuarioModel.self, PerfilLocalModel.self], inMemory: true)
}
