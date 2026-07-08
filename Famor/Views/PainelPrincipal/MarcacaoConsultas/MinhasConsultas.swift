//
//  MinhasConsultas.swift
//  Famor
//
//  Created by Aluno ISTEC on 07/07/2026.
//

import SwiftUI
import SwiftData

// Tela que lista as consultas do paciente.
struct MinhasConsultas: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UsuarioModel.dataLogin, order: .reverse) private var usuarios: [UsuarioModel]

    // Dados e estados usados pela lista.
    @State private var consultas: [MarcacaoFeitaResponse] = []
    @State private var especialidades: [EspecialidadeNomeResponse] = []
    @State private var filtroSelecionado: ConsultaEstadoFiltro = .todas
    @State private var carregando = false
    @State private var mensagemErro: String?
    @State private var usandoDadosLocais = false

    // Estrutura principal da tela.
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 26) {
                topBar
                tituloArea
                filtroArea
                conteudoArea
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 132)
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable {
            await carregarDados()
        }
        .task(id: usuarioAtualId) {
            await carregarDados()
        }
    }

    // Cabeçalho com logo e menu.
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

    // Título da tela e botão de actualizar.
    private var tituloArea: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Minhas Consultas")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(TemaStyles.titleColor)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 12)

            Button {
                Task {
                    await carregarDados()
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

    // Filtros rápidos por estado da consulta.
    private var filtroArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Filtrar por estado")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(red: 0.39, green: 0.45, blue: 0.54))

                Spacer()

                if filtroSelecionado != .todas {
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            filtroSelecionado = .todas
                        }
                    } label: {
                        Text("Limpar")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                    }
                    .buttonStyle(.plain)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ConsultaEstadoFiltro.allCases) { filtro in
                        filtroChip(filtro)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // Chip do filtro com a quantidade.
    private func filtroChip(_ filtro: ConsultaEstadoFiltro) -> some View {
        let selecionado = filtroSelecionado == filtro
        let quantidade = quantidadeFiltro(filtro)

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                filtroSelecionado = filtro
            }
        } label: {
            HStack(spacing: 8) {
                Text(filtro.titulo)
                    .lineLimit(1)

                Text("\(quantidade)")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(selecionado ? Color.white : Color(red: 0.00, green: 0.67, blue: 0.67))
                    .frame(minWidth: 22, minHeight: 22)
                    .background(selecionado ? Color.white.opacity(0.20) : Color(red: 0.89, green: 0.98, blue: 0.97))
                    .clipShape(Capsule())
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(selecionado ? Color.white : TemaStyles.titleColor)
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(selecionado ? Color(red: 0.00, green: 0.67, blue: 0.67) : TemaStyles.surfaceColor)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        selecionado ? Color.clear : Color(red: 0.74, green: 0.91, blue: 0.90),
                        lineWidth: 1.1
                    )
            }
            .shadow(
                color: selecionado ? Color(red: 0.00, green: 0.67, blue: 0.67).opacity(0.20) : Color.clear,
                radius: 10,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }

    // Decide que conteúdo aparece na lista.
    @ViewBuilder
    private var conteudoArea: some View {
        if carregando {
            loadingCard
        } else if let mensagemErro {
            erroCard(mensagemErro)
        } else if consultasFiltradas.isEmpty {
            vazioCard
        } else {
            LazyVStack(spacing: 18) {
                if usandoDadosLocais {
                    dadosLocaisCard
                }

                ForEach(consultasFiltradas) { consulta in
                    consultaCard(consulta)
                }
            }
        }
    }

    // Aviso quando a lista veio do telemóvel.
    private var dadosLocaisCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))

            Text("A mostrar consultas guardadas no telemovel.")
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

    // Mostra enquanto a API responde.
    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(Color(red: 0.00, green: 0.67, blue: 0.67))

            Text("A carregar consultas...")
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

    // Mensagem de erro com botão para tentar de novo.
    private func erroCard(_ mensagem: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color(red: 0.88, green: 0.13, blue: 0.13))

                Text(mensagem)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.76, green: 0.10, blue: 0.10))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                Task {
                    await carregarDados()
                }
            } label: {
                Text("Tentar novamente")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.00, green: 0.67, blue: 0.67))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 1.00, green: 0.91, blue: 0.91))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // Estado vazio do filtro actual.
    private var vazioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                .frame(width: 52, height: 52)
                .background(Color(red: 0.88, green: 0.98, blue: 0.97))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text("Nenhuma consulta encontrada")
                .font(.headline.weight(.bold))
                .foregroundStyle(TemaStyles.titleColor)

            Text("Quando houver consultas neste filtro, elas aparecem aqui.")
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

    // Card com os dados principais da consulta.
    private func consultaCard(_ consulta: MarcacaoFeitaResponse) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "person")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                    .frame(width: 60, height: 60)
                    .background(Color(red: 0.84, green: 0.98, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(consulta.medicoNome)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(TemaStyles.titleColor)
                        .lineLimit(2)

                    Text(especialidadeNome(consulta))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                estadoBadge(consulta)
            }

            HStack(spacing: 18) {
                Label(dataTexto(consulta.dataConsulta), systemImage: "calendar")
                    .lineLimit(1)

                Label(horarioTexto(consulta), systemImage: "clock")
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.64))

            codigoArea(consulta.codigoConfirmacao)

            HStack {
                Button {
                } label: {
                    Label("Editar", systemImage: "square.and.pencil")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                        .lineLimit(1)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 16)

                Button {
                } label: {
                    Label("Cancelar consulta", systemImage: "xmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.90, green: 0.28, blue: 0.40))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.45), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.13), radius: 14, x: 0, y: 8)
    }

    // Etiqueta visual do estado da consulta.
    private func estadoBadge(_ consulta: MarcacaoFeitaResponse) -> some View {
        let cores = coresEstado(consulta.estado)

        return Text(estadoTexto(consulta.estado))
            .font(.caption.weight(.black))
            .foregroundStyle(cores.texto)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(cores.fundo)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(cores.texto.opacity(0.22), lineWidth: 1)
            }
    }

    // Caixa do código de confirmação.
    private func codigoArea(_ codigo: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "qrcode")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 6) {
                Text("Codigo de Confirmacao")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.53, green: 0.60, blue: 0.69))

                Text(codigoValido(codigo))
                    .font(.headline.weight(.black).monospaced())
                    .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.91, green: 0.95, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // Lista já filtrada pelo estado escolhido.
    private var consultasFiltradas: [MarcacaoFeitaResponse] {
        consultas.filter { filtroSelecionado.aceita($0.estado) }
    }

    // Conta quantas consultas existem em cada filtro.
    private func quantidadeFiltro(_ filtro: ConsultaEstadoFiltro) -> Int {
        consultas.filter { filtro.aceita($0.estado) }.count
    }

    // ID do paciente logado.
    private var usuarioAtualId: String {
        usuarios.first?.id ?? ""
    }

    // Busca na API; se a net falhar, usa o SwiftData.
    @MainActor
    private func carregarDados() async {
        guard let usuario = usuarios.first else {
            consultas = []
            especialidades = []
            mensagemErro = nil
            usandoDadosLocais = false
            return
        }

        carregando = true
        mensagemErro = nil
        usandoDadosLocais = false

        let controller = MarcacaoController()

        do {
            let consultasApi = try await controller.carregarMarcacoesFeitas(usuario: usuario)
            consultas = consultasApi
            salvarConsultasLocais(consultasApi, usuarioId: usuario.id)
        } catch {
            if ehErroComunicacao(error), aplicarConsultasLocais(usuarioId: usuario.id) {
                mensagemErro = nil
                usandoDadosLocais = true
            } else {
                consultas = []
                mensagemErro = error.localizedDescription
                usandoDadosLocais = false
            }
        }

        do {
            let especialidadesApi = try await controller.carregarEspecialidades()
            especialidades = especialidadesApi
            try? controller.guardarEspecialidadesLocais(especialidadesApi, modelContext: modelContext)
        } catch {
            if ehErroComunicacao(error) {
                especialidades = (try? controller.carregarEspecialidadesLocais(modelContext: modelContext)) ?? []
            } else {
                especialidades = []
            }
        }

        carregando = false
    }

    // Guarda no telemóvel a resposta boa da API.
    private func salvarConsultasLocais(_ consultas: [MarcacaoFeitaResponse], usuarioId: String?) {
        do {
            let repository = MarcacaoFeitaRepository(modelContext: modelContext)
            try repository.salvar(consultas, usuarioId: usuarioId)
        } catch {
            // Cache local e secundario; a tela continua com os dados da API.
        }
    }

    // Restaura consultas guardadas localmente.
    @discardableResult
    private func aplicarConsultasLocais(usuarioId: String?) -> Bool {
        do {
            let repository = MarcacaoFeitaRepository(modelContext: modelContext)
            let locais = try repository.buscar(usuarioId: usuarioId)

            guard locais.isEmpty == false else {
                return false
            }

            consultas = locais.map { consulta in
                MarcacaoFeitaResponse(
                    id: consulta.marcacaoId,
                    medicoNome: consulta.medicoNome,
                    medicoId: consulta.medicoId,
                    especialidade: consulta.especialidade,
                    especialidadeId: consulta.especialidadeId,
                    dataConsulta: consulta.dataConsulta,
                    horaInicio: consulta.horaInicio,
                    horaFim: consulta.horaFim,
                    codigoConfirmacao: consulta.codigoConfirmacao,
                    observacao: consulta.observacao,
                    estado: consulta.estado,
                    estadoCor: consulta.estadoCor
                )
            }

            return true
        } catch {
            return false
        }
    }

    // Cache local só entra quando falha a comunicação.
    private func ehErroComunicacao(_ error: Error) -> Bool {
        if let marcacaoError = error as? MarcacaoServiceError,
           case .network = marcacaoError {
            return true
        }

        if let perfilError = error as? PerfilServiceError,
           case .network = perfilError {
            return true
        }

        return error is URLError
    }

    // Resolve o nome da especialidade.
    private func especialidadeNome(_ consulta: MarcacaoFeitaResponse) -> String {
        if let nome = textoValido(consulta.especialidade) {
            return nome
        }

        if let especialidadeId = textoValido(consulta.especialidadeId),
           let especialidade = especialidades.first(where: { $0.id == especialidadeId }) {
            return especialidade.nome
        }

        return "Especialidade"
    }

    // Data curta no formato usado na app.
    private func dataTexto(_ data: Date?) -> String {
        guard let data else {
            return "-- --- ----"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_AO")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: data).replacingOccurrences(of: ".", with: "").lowercased()
    }

    // Junta hora inicial e final quando houver.
    private func horarioTexto(_ consulta: MarcacaoFeitaResponse) -> String {
        let inicio = textoValido(consulta.horaInicio)
        let fim = textoValido(consulta.horaFim)

        if let inicio, let fim, inicio != fim {
            return "\(inicio) - \(fim)"
        }

        return inicio ?? fim ?? "--:--"
    }

    // Texto seguro para o estado.
    private func estadoTexto(_ estado: String?) -> String {
        textoValido(estado)?.lowercased() ?? "sem estado"
    }

    // Código seguro para mostrar no card.
    private func codigoValido(_ codigo: String?) -> String {
        textoValido(codigo) ?? "SEM-CODIGO"
    }

    // Remove espaços e evita texto vazio.
    private func textoValido(_ texto: String?) -> String? {
        guard let texto else { return nil }
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }

    // Define cores por tipo de estado.
    private func coresEstado(_ estado: String?) -> (texto: Color, fundo: Color) {
        let normalizado = estadoNormalizado(estado)

        if normalizado.contains("cancel") {
            return (
                Color(red: 0.87, green: 0.20, blue: 0.34),
                Color(red: 1.00, green: 0.91, blue: 0.94)
            )
        }

        if normalizado.contains("conclu") || normalizado.contains("realiz") {
            return (
                Color(red: 0.02, green: 0.54, blue: 0.34),
                Color(red: 0.88, green: 0.98, blue: 0.92)
            )
        }

        return (
            Color(red: 0.86, green: 0.61, blue: 0.06),
            Color(red: 1.00, green: 0.96, blue: 0.78)
        )
    }

    // Normaliza estado para comparar sem acentos.
    private func estadoNormalizado(_ estado: String?) -> String {
        (estado ?? "")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_AO"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Filtros disponíveis na tela.
private enum ConsultaEstadoFiltro: String, CaseIterable, Identifiable {
    case todas
    case abertas
    case agendadas
    case canceladas
    case concluidas

    var id: String { rawValue }

    // Texto que aparece no chip.
    var titulo: String {
        switch self {
        case .todas:
            return "Todas"
        case .abertas:
            return "Abertas"
        case .agendadas:
            return "Agendadas"
        case .canceladas:
            return "Canceladas"
        case .concluidas:
            return "Concluidas"
        }
    }

    // Diz se a consulta entra neste filtro.
    func aceita(_ estado: String?) -> Bool {
        let valor = (estado ?? "")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_AO"))
            .lowercased()

        switch self {
        case .todas:
            return true
        case .abertas:
            return valor.contains("abert")
        case .agendadas:
            return valor.contains("agend")
        case .canceladas:
            return valor.contains("cancel")
        case .concluidas:
            return valor.contains("conclu") || valor.contains("realiz")
        }
    }
}

#Preview {
    MinhasConsultas()
        .modelContainer(SwiftDataManager.criarContainerEmMemoria())
}
