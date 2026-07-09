//
//  MainPrincipalView.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import SwiftUI
import SwiftData

struct MainPrincipalView: View {
    // Lemos o ultimo usuario guardado depois do login.
    @Query(sort: \UsuarioModel.dataLogin, order: .reverse) private var usuarios: [UsuarioModel]
    @AppStorage(ApiConstants.languageKey) private var languageCode = AppLanguage.portuguese.rawValue

    // Controla o item activo na barra de baixo.
    @State private var tabSelecionada: PainelTab = .inicio
    @State private var agendarFluxoId = 0
    @State private var ultimaMarcacao: MarcacaoHojeResponse?
    @State private var carregandoMarcacao = false
    @State private var mensagemMarcacao: String?

    // Usado quando o perfil terminar sessao.
    var onLogout: (() -> Void)? = nil

    private let localClinica = "Centro Médico Famor - Boa Esperança, Calemba II, Luanda-Angola"
    private let localClinicaFonte: CGFloat = 11

    var body: some View {
        ZStack {
            TemaStyles.backgroundColor
                .ignoresSafeArea()

            if tabSelecionada == .agendar {
                MarcacoesUsuarios(
                    onVerConsultas: {
                        tabSelecionada = .consultas
                    },
                    onVoltarInicio: {
                        tabSelecionada = .inicio
                    }
                )
                .id(agendarFluxoId)
            } else if tabSelecionada == .consultas {
                MinhasConsultas()
            } else if tabSelecionada == .especialidades {
                // Tela aberta pelo atalho de especialidades.
                Especialidades(
                    onAgendar: {
                        selecionarTab(.agendar)
                    }
                )
            } else if tabSelecionada == .perfil {
                UsuarioPerfil(onLogout: onLogout)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 22) {
                        headerCard
                        atalhosGrid
                        consultasHojeSection
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 22)
                    .padding(.top, 28)
                    .padding(.bottom, 132)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomNavigation
        }
        .task(id: usuarioAtualId) {
            await carregarConsultasHoje()
        }
    }

    // Card com saudacao e dados da clinica.
    private var headerCard: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(saudacao)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(nomeUsuario)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(TemaStyles.titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(localClinica)
                    .font(.system(size: localClinicaFonte, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            Image(systemName: "cloud.sun")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(Color(red: 1.00, green: 0.42, blue: 0.05))
                .frame(width: 46, height: 46)
                .background(Color(red: 0.91, green: 0.96, blue: 1.00))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)
    }

    // Atalhos principais do paciente.
    private var atalhosGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            shortcutCard(
                icon: "calendar.badge.plus",
                title: "Agendar Consulta",
                subtitle: "Marcar nova consulta"
            )

            shortcutCard(
                icon: "cross.case",
                title: "Minhas Consultas",
                subtitle: "Ver agendamentos"
            )

            shortcutCard(
                icon: "heart.text.square",
                title: "Especialidades",
                subtitle: "Explorar medicos"
            )

            shortcutCard(
                icon: "clock",
                title: "Historico",
                subtitle: "Consultas anteriores"
            )
        }
    }

    // Linha com titulo e estado das consultas de hoje.
    private var consultasHojeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(t("Consultas de Hoje"))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)

                Spacer()

                Button {
                    tabSelecionada = .consultas
                } label: {
                    HStack(spacing: 5) {
                        Text(t("Ver todas"))
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TemaStyles.primaryColor)
                }
                .buttonStyle(.plain)
            }

            consultasHojeContent
        }
    }

    // Decide o que aparece na area das consultas de hoje.
    @ViewBuilder
    private var consultasHojeContent: some View {
        if carregandoMarcacao {
            consultaLoadingCard
        } else if let mensagemMarcacao {
            consultaErroCard(mensagemMarcacao)
        } else if let consulta = ultimaMarcacao {
            consultaHojeCard(consulta)
        } else {
            emptyTodayCard
        }
    }

    // Mostra que estamos a buscar os dados na API.
    private var consultaLoadingCard: some View {
        HStack(spacing: 16) {
            ProgressView()
                .tint(TemaStyles.primaryColor)
                .frame(width: 58, height: 58)
                .background(Color(red: 0.91, green: 0.96, blue: 1.00))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(t("A carregar consultas"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)

                Text(t("Estamos a buscar a consulta agendada."))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .modifier(PainelCardModifier())
    }

    // Card quando a API nao conseguir responder.
    private func consultaErroCard(_ mensagem: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(Color(red: 0.78, green: 0.12, blue: 0.12))
                .frame(width: 58, height: 58)
                .background(Color(red: 1.00, green: 0.91, blue: 0.91))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(t("Nao foi possivel carregar"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)

                Text(t(mensagem))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button {
                Task {
                    await carregarConsultasHoje()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(TemaStyles.primaryColor)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.91, green: 0.96, blue: 1.00))
                    .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .modifier(PainelCardModifier())
    }

    // Card com a marcacao devolvida pela API.
    private func consultaHojeCard(_ consulta: MarcacaoHojeResponse) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "person")
                .font(.system(size: 29, weight: .medium))
                .foregroundStyle(Color(red: 0.02, green: 0.50, blue: 0.64))
                .frame(width: 68, height: 68)
                .background(Color(red: 0.85, green: 0.97, blue: 1.00))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: 9) {
                Text(consulta.medico ?? "Médico por confirmar")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)

                Text(consulta.especialidade ?? "Consulta médica")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 16) {
                    Label(dataCurtaMarcacao(consulta), systemImage: "calendar")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.64))

                    Label(horaMarcacao(consulta), systemImage: "clock")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.64))
                }
            }

            Spacer(minLength: 8)

            Text((consulta.estado ?? "Aberto").lowercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(corEstado(consulta.estado, hex: consulta.estadoCor))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(corEstado(consulta.estado, hex: consulta.estadoCor).opacity(0.12))
                .clipShape(Capsule())
        }
        .modifier(PainelCardModifier())
    }

    // Card mostrado quando nao ha consulta para hoje.
    private var emptyTodayCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(Color(red: 0.02, green: 0.50, blue: 0.64))
                .frame(width: 58, height: 58)
                .background(Color(red: 0.85, green: 0.98, blue: 1.00))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(t("Sem consulta agendada para hoje"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
                    .fixedSize(horizontal: false, vertical: true)

                Text(textoConsultaVazia)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .modifier(PainelCardModifier())
    }

    // Barra inferior igual ao painel do print.
    private var bottomNavigation: some View {
        HStack(spacing: 8) {
            ForEach(PainelTab.navegacao) { tab in
                Button {
                    selecionarTab(tab)
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .semibold))

                        Text(tab.title)
                            .font(.caption2.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(tabSelecionada == tab ? TemaStyles.primaryColor : Color(red: 0.46, green: 0.54, blue: 0.65))
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(tabSelecionada == tab ? Color(red: 0.91, green: 0.96, blue: 1.00) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            TemaStyles.surfaceColor
                .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: -4)
        )
    }

    // Linha material usada no acesso rapido.
    private func quickInfoRow(icon: String, title: String, subtitle: String) -> some View {
        Button {
            abrirAtalho(title)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(TemaStyles.primaryColor)
                    .frame(width: 48, height: 48)
                    .background(Color(red: 0.91, green: 0.96, blue: 1.00))
                    .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(t(title))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(TemaStyles.titleColor)

                    Text(t(subtitle))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Color(red: 0.46, green: 0.54, blue: 0.65))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.11), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    // Card pequeno usado no grid de atalhos.
    private func shortcutCard(icon: String, title: String, subtitle: String) -> some View {
        Button {
            abrirAtalho(title)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(TemaStyles.primaryColor)
                    .frame(width: 46, height: 46)
                    .background(Color(red: 0.91, green: 0.96, blue: 1.00))
                    .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text(t(title))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(TemaStyles.titleColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(t(subtitle))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 146, alignment: .leading)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.13), radius: 15, x: 0, y: 9)
        }
        .buttonStyle(.plain)
    }

    // Por agora apenas muda a aba correspondente.
    private func abrirAtalho(_ title: String) {
        switch title {
        case "Agendar Consulta":
            selecionarTab(.agendar)
        case "Minhas Consultas", "Historico":
            selecionarTab(.consultas)
        case "Especialidades":
            // Abre a lista de especialidades sem mexer na barra de baixo.
            selecionarTab(.especialidades)
        case "Perfil do Paciente", "Apoio Famor":
            selecionarTab(.perfil)
        case "Avisos da Clínica":
            selecionarTab(.avisos)
        default:
            selecionarTab(.inicio)
        }
    }

    private func selecionarTab(_ tab: PainelTab) {
        if tab == .agendar, tabSelecionada != .agendar {
            agendarFluxoId += 1
        }

        tabSelecionada = tab
    }

    // Nome usado no card principal.
    private var nomeUsuario: String {
        guard let usuario = usuarios.first else {
            return t("Paciente Famor")
        }

        if usuario.nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return usuario.nome
        }

        if let nomeEmail = usuario.email.split(separator: "@").first {
            return String(nomeEmail)
        }

        return t("Paciente Famor")
    }

    // Saudacao conforme a hora do dia.
    private var saudacao: String {
        let hora = Calendar.current.component(.hour, from: Date())

        if hora < 12 {
            return t("Bom dia,")
        } else if hora < 18 {
            return t("Boa tarde,")
        }

        return t("Boa noite,")
    }

    // Id usado para recarregar as consultas quando mudar o usuario.
    private var usuarioAtualId: String {
        usuarios.first?.id ?? ""
    }

    // Texto usado quando nao existe consulta marcada para hoje.
    private var textoConsultaVazia: String {
        guard let ultimaMarcacao, ultimaMarcacao.eHoje == false, ultimaMarcacao.dataConsulta != nil else {
            return t("Quando tiver consulta hoje, ela aparece aqui.")
        }

        return "A próxima consulta está marcada para \(formatarData(ultimaMarcacao.dataConsulta)) às \(horaMarcacao(ultimaMarcacao))."
    }

    // Chama a API das marcacoes para preencher o painel.
    @MainActor
    private func carregarConsultasHoje() async {
        guard let usuario = usuarios.first else {
            ultimaMarcacao = nil
            mensagemMarcacao = nil
            return
        }

        carregandoMarcacao = true
        mensagemMarcacao = nil

        do {
            let controller = MarcacaoController()
            ultimaMarcacao = try await controller.carregarUltimaMarcacao(usuario: usuario)
        } catch {
            ultimaMarcacao = nil
            mensagemMarcacao = error.localizedDescription
        }

        carregandoMarcacao = false
    }

    // Hora principal da consulta.
    private func horaMarcacao(_ consulta: MarcacaoHojeResponse) -> String {
        consulta.hora ?? consulta.horaInicio ?? "--:--"
    }

    // Data no formato curto usado no card da consulta.
    private func dataCurtaMarcacao(_ consulta: MarcacaoHojeResponse) -> String {
        guard let data = consulta.dataConsulta else {
            return "-- ---"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_AO")
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: data).replacingOccurrences(of: ".", with: "").lowercased()
    }

    // Data curta para aparecer no card vazio quando a proxima nao e hoje.
    private func formatarData(_ data: Date?) -> String {
        guard let data else {
            return "sem data"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_AO")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: data)
    }

    // Usa a cor que vem da API quando ela estiver valida.
    private func corEstado(_ estado: String?, hex: String?) -> Color {
        if estado?.lowercased() == "aberto" {
            return Color(red: 0.93, green: 0.59, blue: 0.07)
        }

        guard let hex else {
            return TemaStyles.primaryColor
        }

        let limpo = hex.replacingOccurrences(of: "#", with: "")
        guard limpo.count == 6, let valor = UInt64(limpo, radix: 16) else {
            return TemaStyles.primaryColor
        }

        let red = Double((valor >> 16) & 0xFF) / 255
        let green = Double((valor >> 8) & 0xFF) / 255
        let blue = Double(valor & 0xFF) / 255

        return Color(red: red, green: green, blue: blue)
    }

    private func t(_ text: String) -> String {
        L10n.tr(text, languageCode: languageCode)
    }
}

// Estilo dos cards pequenos do painel.
private struct PainelCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)
    }
}

// Itens fixos da barra inferior.
private enum PainelTab: String, CaseIterable, Identifiable {
    case inicio
    case agendar
    case consultas
    case especialidades
    case avisos
    case perfil

    var id: String { rawValue }

    // Itens que aparecem na barra inferior.
    static var navegacao: [PainelTab] {
        [.inicio, .agendar, .consultas, .avisos, .perfil]
    }

    var title: String {
        switch self {
        case .inicio:
                    return L10n.tr("Inicio")
        case .agendar:
            return L10n.tr("Agendar")
        case .consultas:
            return L10n.tr("Consultas")
        case .especialidades:
            return L10n.tr("Especialidades")
        case .avisos:
            return L10n.tr("Avisos")
        case .perfil:
            return L10n.tr("Perfil")
        }
    }

    var icon: String {
        switch self {
        case .inicio:
            return "house.fill"
        case .agendar:
            return "calendar.badge.plus"
        case .consultas:
            return "calendar"
        case .especialidades:
            return "stethoscope"
        case .avisos:
            return "bell"
        case .perfil:
            return "person"
        }
    }
}

#Preview {
    MainPrincipalView()
        .modelContainer(for: UsuarioModel.self, inMemory: true)
}
