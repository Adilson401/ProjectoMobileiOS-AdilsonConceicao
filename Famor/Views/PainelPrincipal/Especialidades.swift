//
//  Especialidades.swift
//  Famor
//
//  Created by Aluno ISTEC on 07/07/2026.
//

import SwiftUI
import SwiftData

// Tela que mostra as especialidades da clínica.
struct Especialidades: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(ApiConstants.languageKey) private var languageCode = AppLanguage.portuguese.rawValue

    // Chama o fluxo de marcação quando o paciente escolhe uma área.
    var onAgendar: (() -> Void)? = nil

    // Estados da lista que vem da API.
    @State private var especialidades: [EspecialidadeNomeResponse] = []
    @State private var carregando = false
    @State private var mensagemErro: String?
    @State private var usandoDadosLocais = false

    // Estrutura principal da tela.
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 26) {
                topBar
                titleArea
                conteudoArea
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 132)
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable {
            await carregarEspecialidades()
        }
        .task {
            await carregarEspecialidades()
        }
    }

    // Cabeçalho simples usado nas telas do painel.
    private var topBar: some View {
        HStack {
            Text("FM")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color(red: 0.00, green: 0.65, blue: 0.64))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 6)

            Spacer()

            Button {
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(Color(red: 0.28, green: 0.31, blue: 0.39))
                    .frame(width: 46, height: 46)
                    .background(TemaStyles.surfaceColor.opacity(0.65))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // Título e botão para actualizar a lista.
    private var titleArea: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(t("Especialidades"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(TemaStyles.titleColor)
                    .fixedSize(horizontal: false, vertical: true)

                Text(t("Escolha uma area para marcar consulta"))
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Button {
                Task {
                    await carregarEspecialidades()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                    .frame(width: 48, height: 48)
                    .background(Color(red: 0.90, green: 0.99, blue: 0.98))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(TemaStyles.outlineColor.opacity(0.65), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .disabled(carregando)
            .opacity(carregando ? 0.65 : 1)
        }
        .padding(.top, 8)
    }

    // Decide se mostra loading, erro, cache local, vazio ou grelha.
    @ViewBuilder
    private var conteudoArea: some View {
        if carregando {
            loadingCard
        }

        if let mensagemErro {
            avisoCard(mensagemErro)
        }

        if usandoDadosLocais && especialidades.isEmpty == false {
            dadosLocaisCard
        }

        if especialidades.isEmpty && carregando == false && mensagemErro == nil {
            vazioCard
        } else if especialidades.isEmpty == false {
            especialidadesGrid
        }
    }

    // Grelha com as especialidades disponíveis.
    private var especialidadesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ],
            spacing: 20
        ) {
            ForEach(especialidades) { especialidade in
                especialidadeCard(especialidade)
            }
        }
    }

    // Card de uma especialidade.
    private func especialidadeCard(_ especialidade: EspecialidadeNomeResponse) -> some View {
        Button {
            onAgendar?()
        } label: {
            VStack(spacing: 18) {
                Image(systemName: iconeEspecialidade(especialidade.nome))
                    .font(.system(size: 31, weight: .semibold))
                    .foregroundStyle(corEspecialidade(especialidade.nome))
                    .frame(width: 64, height: 64)
                    .background(fundoEspecialidade(especialidade.nome))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(spacing: 6) {
                    Text(especialidade.nome)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(TemaStyles.titleColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(t("Ver agenda"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 166)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    // Mostra quando a API ainda está a responder.
    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(Color(red: 0.00, green: 0.67, blue: 0.67))

            Text(t("A carregar especialidades..."))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
    }

    // Aviso curto quando algo falha.
    private func avisoCard(_ mensagem: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.88, green: 0.13, blue: 0.13))

            Text(mensagem)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.76, green: 0.10, blue: 0.10))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 1.00, green: 0.91, blue: 0.91))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // Indica que a lista veio do telemóvel.
    private var dadosLocaisCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))

            Text(t("A mostrar especialidades guardadas no telemovel."))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.39, green: 0.45, blue: 0.54))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.88, green: 0.98, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
    }

    // Estado vazio quando não há especialidades.
    private var vazioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "stethoscope")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                .frame(width: 52, height: 52)
                .background(Color(red: 0.88, green: 0.98, blue: 0.97))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(t("Sem especialidades"))
                .font(.headline.weight(.bold))
                .foregroundStyle(TemaStyles.titleColor)

            Text(t("Nao encontramos especialidades disponiveis agora."))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
    }

    // Busca primeiro na API; se a net falhar, tenta o SwiftData.
    @MainActor
    private func carregarEspecialidades() async {
        carregando = true
        mensagemErro = nil
        usandoDadosLocais = false

        let controller = MarcacaoController()

        do {
            let resposta = try await controller.carregarEspecialidades()
            especialidades = resposta
            try? controller.guardarEspecialidadesLocais(resposta, modelContext: modelContext)
        } catch {
            if ehErroComunicacao(error), aplicarEspecialidadesLocais(usando: controller) {
                usandoDadosLocais = true
                mensagemErro = nil
            } else {
                especialidades = []
                mensagemErro = error.localizedDescription
            }
        }

        carregando = false
    }

    // Carrega a lista guardada no telemóvel.
    @discardableResult
    private func aplicarEspecialidadesLocais(usando controller: MarcacaoController) -> Bool {
        do {
            let locais = try controller.carregarEspecialidadesLocais(modelContext: modelContext)
            guard locais.isEmpty == false else { return false }
            especialidades = locais
            return true
        } catch {
            return false
        }
    }

    // Só activa cache local quando a falha é de comunicação.
    private func ehErroComunicacao(_ error: Error) -> Bool {
        if let marcacaoError = error as? MarcacaoServiceError,
           case .network = marcacaoError {
            return true
        }

        return error is URLError
    }

    // Escolhe um ícone conforme o nome da especialidade.
    private func iconeEspecialidade(_ nome: String) -> String {
        let normalizado = textoNormalizado(nome)

        if normalizado.contains("cardio") {
            return "heart.text.square"
        } else if normalizado.contains("estoma") || normalizado.contains("dent") {
            return "mouth"
        } else if normalizado.contains("fisio") {
            return "figure.strengthtraining.traditional"
        } else if normalizado.contains("labor") {
            return "testtube.2"
        } else if normalizado.contains("obstre") || normalizado.contains("gine") {
            return "cross.case"
        } else if normalizado.contains("psico") {
            return "brain.head.profile"
        }

        return "stethoscope"
    }

    // Cor principal do card conforme a área.
    private func corEspecialidade(_ nome: String) -> Color {
        let normalizado = textoNormalizado(nome)

        if normalizado.contains("cardio") {
            return Color(red: 0.88, green: 0.13, blue: 0.24)
        } else if normalizado.contains("labor") {
            return Color(red: 0.02, green: 0.43, blue: 0.84)
        } else if normalizado.contains("psico") {
            return Color(red: 0.47, green: 0.33, blue: 0.88)
        }

        return Color(red: 0.00, green: 0.67, blue: 0.67)
    }

    // Fundo suave do ícone.
    private func fundoEspecialidade(_ nome: String) -> Color {
        corEspecialidade(nome).opacity(0.13)
    }

    // Normaliza texto para comparar sem acentos.
    private func textoNormalizado(_ texto: String) -> String {
        texto
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_AO"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func t(_ text: String) -> String {
        L10n.tr(text, languageCode: languageCode)
    }
}

#Preview {
    Especialidades()
        .modelContainer(SwiftDataManager.criarContainerEmMemoria())
}
