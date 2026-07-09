//
//  MarcacoesUsuarios.swift
//  Famor
//
//  Created by Aluno ISTEC on 06/07/2026.
//

import SwiftUI
import SwiftData

struct MarcacoesUsuarios: View {
    // Contexto usado para guardar as especialidades localmente.
    @Environment(\.modelContext) private var modelContext
    @AppStorage(ApiConstants.languageKey) private var languageCode = AppLanguage.portuguese.rawValue

    // Usuario autenticado usado para filtrar a agenda medica.
    @Query(sort: \UsuarioModel.dataLogin, order: .reverse) private var usuarios: [UsuarioModel]

    var onVerConsultas: (() -> Void)? = nil
    var onVoltarInicio: (() -> Void)? = nil

    // Especialidade escolhida pelo paciente.
    @State private var especialidadeSelecionada: EspecialidadeMarcacao?
    @State private var especialidades: [EspecialidadeMarcacao] = []
    @State private var loadingEspecialidades = false
    @State private var mensagemErro: String?
    @State private var medicoSelecionado: MedicoMarcacao?
    @State private var medicos: [MedicoMarcacao] = []
    @State private var loadingAgendaMedica = false
    @State private var mensagemAgendaErro: String?
    @State private var agendaEspecialidadeIdCarregada: String?
    @State private var mesCalendario = Date()
    @State private var dataSelecionada: Date?
    @State private var horarioSelecionado: HorarioMarcacao?
    @State private var observacoesMarcacao = ""
    @State private var enviandoMarcacao = false
    @State private var mensagemConfirmacaoErro: String?
    @State private var marcacaoConfirmada: MarcacaoConfirmadaResponse?
    @State private var agendamentoConfirmado = false
    @State private var usandoDadosLocais = false
    @State private var rascunhoFoiCarregado = false
    @State private var passoAtual = 1

    private let totalPassos = 4
    private let diasSemanaCalendario = ["seg", "ter", "qua", "qui", "sex", "sab", "dom"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 28) {
                topBar

                if agendamentoConfirmado {
                    confirmacaoFinalArea
                } else {
                    progressArea
                    titleArea
                    conteudoPassoAtual
                    continuarButton
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 132)
        }
        .scrollDismissesKeyboard(.interactively)
        .task {
            await carregarEspecialidades()
        }
    }

    // Barra simples do topo da marcacao.
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
                // Depois podemos abrir menu de opcoes aqui.
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

    // Mostra em que passo o paciente esta.
    private var progressArea: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                if passoAtual > 1 && agendamentoConfirmado == false {
                    voltarButton
                } else {
                    Spacer()
                }

                Spacer()

                Text("\(t("Passo")) \(passoAtual) \(t("de")) \(totalPassos)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.39, green: 0.45, blue: 0.54))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(TemaStyles.outlineColor.opacity(0.42))
                        .frame(height: 7)

                    Capsule()
                        .fill(Color(red: 0.00, green: 0.67, blue: 0.67))
                        .frame(width: proxy.size.width * progresso, height: 7)
                }
            }
            .frame(height: 7)
        }
        .padding(.top, 8)
    }

    // Volta para o passo anterior da marcacao.
    private var voltarButton: some View {
        Button {
            voltarPasso()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "arrow.left")
                Text(t("Voltar"))
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.64))
        }
        .buttonStyle(.plain)
    }

    // Titulo principal do passo actual.
    private var titleArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(tituloPassoAtual))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(TemaStyles.titleColor)
                .fixedSize(horizontal: false, vertical: true)

            Text(t(subtituloPassoAtual))
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // Decide qual conteudo aparece no corpo da tela.
    @ViewBuilder
    private var conteudoPassoAtual: some View {
        if passoAtual == 1 {
            especialidadesArea
        } else if passoAtual == 2 {
            medicosArea
        } else if passoAtual == 3 {
            dataHorarioArea
        } else {
            confirmacaoArea
        }
    }

    // Mostra loading, aviso e depois os cards da API.
    @ViewBuilder
    private var especialidadesArea: some View {
        if loadingEspecialidades {
            loadingCard("A carregar especialidades...")
        }

        if let mensagemErro {
            avisoCard(mensagemErro)
        }

        if especialidades.isEmpty == false {
            especialidadesGrid
        }
    }

    // Grelha de especialidades da primeira etapa.
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

    // Card usado para cada especialidade.
    private func especialidadeCard(_ especialidade: EspecialidadeMarcacao) -> some View {
        let selecionada = especialidadeSelecionada == especialidade

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                especialidadeSelecionada = especialidade
                medicoSelecionado = nil
                medicos = []
                mensagemAgendaErro = nil
                agendaEspecialidadeIdCarregada = nil
                dataSelecionada = nil
                horarioSelecionado = nil
            }
            salvarRascunhoLocal(passo: 1)
        } label: {
            VStack(spacing: 18) {
                Image(systemName: especialidade.icone)
                    .font(.system(size: 31, weight: .semibold))
                    .foregroundStyle(especialidade.cor)
                    .frame(width: 64, height: 64)
                    .background(especialidade.fundo)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(especialidade.nome)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 154)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(selecionada ? Color(red: 0.00, green: 0.67, blue: 0.67) : TemaStyles.outlineColor.opacity(0.55), lineWidth: selecionada ? 2 : 1)
            }
            .shadow(color: Color.black.opacity(selecionada ? 0.16 : 0.12), radius: selecionada ? 18 : 14, x: 0, y: 8)
            .scaleEffect(selecionada ? 1.02 : 1)
        }
        .buttonStyle(.plain)
    }

    // Lista de medicos do segundo passo.
    @ViewBuilder
    private var medicosArea: some View {
        if loadingAgendaMedica {
            loadingCard("A carregar agenda medica...")
        }

        if let mensagemAgendaErro {
            avisoCard(mensagemAgendaErro)
        }

        if medicosDisponiveis.isEmpty && loadingAgendaMedica == false {
            medicosEmptyCard
        } else {
            VStack(spacing: 18) {
                ForEach(medicosDisponiveis) { medico in
                    medicoCard(medico)
                }
            }
        }
    }

    // Card usado para escolher o medico.
    private func medicoCard(_ medico: MedicoMarcacao) -> some View {
        let selecionado = medicoSelecionado == medico

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                medicoSelecionado = medico
                aplicarPrimeiraDataDisponivel(do: medico)
            }
            salvarRascunhoLocal(passo: 2)
        } label: {
            HStack(alignment: .center, spacing: 18) {
                Image(systemName: "person")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                    .frame(width: 76, height: 76)
                    .background(Color(red: 0.83, green: 0.97, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(medico.nome)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(TemaStyles.titleColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(medico.codigo)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.64))

                    Text(medico.descricao)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    diasMedicoGrid(medico.diasDisponiveis)
                }

                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(selecionado ? Color(red: 0.00, green: 0.67, blue: 0.67) : TemaStyles.outlineColor.opacity(0.55), lineWidth: selecionado ? 2 : 1)
            }
            .shadow(color: Color.black.opacity(selecionado ? 0.16 : 0.12), radius: selecionado ? 18 : 14, x: 0, y: 8)
            .scaleEffect(selecionado ? 1.01 : 1)
        }
        .buttonStyle(.plain)
    }

    // Pequenas etiquetas dos dias disponiveis.
    private func diasMedicoGrid(_ dias: [String]) -> some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 42), spacing: 8)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(dias, id: \.self) { dia in
                Text(dia)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.64))
                    .frame(minWidth: 42)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.93, green: 0.96, blue: 0.98))
                    .clipShape(Capsule())
            }
        }
    }

    // Estado vazio quando a API nao devolve medicos para a especialidade.
    private var medicosEmptyCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(TemaStyles.primaryColor)
                .frame(width: 52, height: 52)
                .background(Color(red: 0.91, green: 0.96, blue: 1.00))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(t("Sem agenda disponivel"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)

                Text(t("Nao encontramos medicos para esta especialidade agora."))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
    }

    // Terceiro passo: escolha de data e horario.
    private var dataHorarioArea: some View {
        VStack(alignment: .leading, spacing: 22) {
            calendarioCard
            horariosArea
        }
    }

    // Calendario mensal com os dias disponiveis do medico escolhido.
    private var calendarioCard: some View {
        VStack(spacing: 22) {
            HStack {
                Button {
                    mudarMes(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color(red: 0.54, green: 0.61, blue: 0.70))
                        .frame(width: 42, height: 42)
                        .background(TemaStyles.surfaceColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(TemaStyles.outlineColor.opacity(0.45), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)

                Spacer()

                Text(tituloMesCalendario)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)

                Spacer()

                Button {
                    mudarMes(1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color(red: 0.54, green: 0.61, blue: 0.70))
                        .frame(width: 42, height: 42)
                        .background(TemaStyles.surfaceColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(TemaStyles.outlineColor.opacity(0.45), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: calendarioColumns, spacing: 16) {
                ForEach(diasSemanaCalendario, id: \.self) { dia in
                    Text(dia)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.55, green: 0.60, blue: 0.68))
                        .frame(maxWidth: .infinity)
                }

                ForEach(diasDoCalendario) { dia in
                    calendarioDiaButton(dia)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)
    }

    // Botao de cada dia no calendario.
    private func calendarioDiaButton(_ dia: DiaCalendarioMarcacao) -> some View {
        let disponivel = dataDisponivel(dia.data)
        let selecionado = dataSelecionada.map { calendarioMarcacao.isDate($0, inSameDayAs: dia.data) } ?? false

        return Button {
            selecionarData(dia.data)
        } label: {
            Text("\(calendarioMarcacao.component(.day, from: dia.data))")
                .font(.headline.weight(selecionado ? .bold : .medium))
                .foregroundStyle(corDiaCalendario(dia: dia, disponivel: disponivel, selecionado: selecionado))
                .frame(width: 44, height: 44)
                .background {
                    if selecionado {
                        Circle()
                            .fill(Color(red: 0.83, green: 0.98, blue: 0.97))
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(disponivel == false)
    }

    // Horarios disponiveis para a data escolhida.
    @ViewBuilder
    private var horariosArea: some View {
        if let dataSelecionada {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))

                    Text("\(t("Horarios em")) \(dataSelecionadaTexto(dataSelecionada))")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(TemaStyles.titleColor)
                }

                LazyVGrid(columns: horarioColumns, spacing: 12) {
                    ForEach(horariosDisponiveisNaData) { horario in
                        horarioButton(horario)
                    }
                }
            }
        } else {
            avisoCard("Escolhe uma data disponivel para ver os horarios.")
        }
    }

    // Botao de horario do terceiro passo.
    private func horarioButton(_ horario: HorarioMarcacao) -> some View {
        let selecionado = horarioSelecionado == horario

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                horarioSelecionado = horario
            }
            salvarRascunhoLocal(passo: 3)
        } label: {
            Text(horario.hora)
                .font(.headline.weight(.bold))
                .foregroundStyle(selecionado ? .white : TemaStyles.titleColor)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(selecionado ? Color(red: 0.00, green: 0.67, blue: 0.67) : TemaStyles.surfaceColor)
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                        .stroke(selecionado ? Color.clear : TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    // Quarto passo: resumo local antes de confirmar na API.
    private var confirmacaoArea: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(spacing: 22) {
                resumoMarcacaoRow(
                    icon: "person",
                    iconColor: Color(red: 0.00, green: 0.67, blue: 0.67),
                    iconBackground: Color(red: 0.83, green: 0.97, blue: 0.96),
                    title: "Medico",
                    value: medicoSelecionado?.nome ?? "Nao selecionado"
                )

                resumoMarcacaoRow(
                    icon: "asterisk",
                    iconColor: Color(red: 0.00, green: 0.67, blue: 0.67),
                    iconBackground: Color(red: 0.83, green: 0.97, blue: 0.96),
                    title: "Especialidade",
                    value: especialidadeSelecionada?.nome ?? "Nao selecionada"
                )

                resumoMarcacaoRow(
                    icon: "calendar",
                    iconColor: Color(red: 0.84, green: 0.68, blue: 0.00),
                    iconBackground: Color(red: 1.00, green: 0.97, blue: 0.78),
                    title: "Data",
                    value: dataSelecionada.map(dataConfirmacaoTexto) ?? "Nao selecionada"
                )

                resumoMarcacaoRow(
                    icon: "clock",
                    iconColor: Color(red: 0.24, green: 0.58, blue: 0.79),
                    iconBackground: Color(red: 0.88, green: 0.96, blue: 1.00),
                    title: "Horario",
                    value: horarioSelecionado?.hora ?? "Nao selecionado"
                )
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TemaStyles.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)

            observacoesArea

            if let mensagemConfirmacaoErro {
                avisoCard(mensagemConfirmacaoErro)
            }
        }
    }

    private func resumoMarcacaoRow(
        icon: String,
        iconColor: Color,
        iconBackground: Color,
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 58, height: 58)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    // Tela mostrada depois que a API confirma a marcacao.
    private var confirmacaoFinalArea: some View {
        VStack(spacing: 24) {
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.83, green: 0.97, blue: 0.96))
                        .frame(width: 96, height: 96)

                    Circle()
                        .stroke(Color(red: 0.00, green: 0.67, blue: 0.67), lineWidth: 5)
                        .frame(width: 58, height: 58)

                    Image(systemName: "checkmark")
                        .font(.system(size: 29, weight: .black))
                        .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                }

                Text(t("Consulta Agendada!"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(TemaStyles.titleColor)

                Text(t("Seu agendamento foi realizado com sucesso"))
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)

            consultaAgendadaCard
            botoesConfirmacaoFinal
        }
        .frame(maxWidth: .infinity)
    }

    private var consultaAgendadaCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            confirmacaoTextoLinha(
                titulo: "Médico",
                valor: medicoSelecionado?.nome ?? "Não selecionado"
            )

            confirmacaoTextoLinha(
                titulo: "Especialidade",
                valor: especialidadeSelecionada?.nome ?? "Não selecionada"
            )

            HStack(alignment: .top, spacing: 26) {
                confirmacaoIconeLinha(
                    icon: "calendar",
                    titulo: "Data",
                    valor: dataSelecionada.map(dataResumoTexto) ?? "Não selecionada"
                )

                confirmacaoIconeLinha(
                    icon: "clock",
                    titulo: "Horario",
                    valor: horarioSelecionado?.hora ?? "Não selecionado"
                )

                Spacer(minLength: 0)
            }

            Divider()
                .background(TemaStyles.outlineColor.opacity(0.6))

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .font(.headline.weight(.semibold))

                    Text(t("Código de Confirmação"))
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(Color(red: 0.56, green: 0.62, blue: 0.70))

                VStack(spacing: 10) {
                    Text(codigoConfirmacaoTexto)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))
                        .tracking(4)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(t("Apresente este código na recepção"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 0.56, green: 0.62, blue: 0.70))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.91, green: 0.94, blue: 0.97))
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)
    }

    private func confirmacaoTextoLinha(titulo: String, valor: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(titulo)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(red: 0.56, green: 0.62, blue: 0.70))

            Text(valor)
                .font(.headline.weight(.bold))
                .foregroundStyle(TemaStyles.titleColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func confirmacaoIconeLinha(icon: String, titulo: String, valor: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(red: 0.56, green: 0.62, blue: 0.70))

            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(red: 0.00, green: 0.67, blue: 0.67))

                Text(valor)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
        }
    }

    private var botoesConfirmacaoFinal: some View {
        VStack(spacing: 14) {
            Button {
                onVerConsultas?()
            } label: {
                Text(t("Ver Consultas"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: TemaStyles.buttonHeight)
                    .background(Color(red: 0.00, green: 0.67, blue: 0.67))
                    .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
                    .shadow(color: Color(red: 0.00, green: 0.67, blue: 0.67).opacity(0.20), radius: 16, x: 0, y: 10)
            }
            .buttonStyle(.plain)

            Button {
                onVoltarInicio?()
            } label: {
                Text(t("Voltar ao Início"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: TemaStyles.buttonHeight)
                    .background(TemaStyles.surfaceColor)
                    .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                            .stroke(TemaStyles.outlineColor.opacity(0.75), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private var observacoesArea: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.47, green: 0.54, blue: 0.64))

                Text(t("Observações (opcional)"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TemaStyles.titleColor)
            }

            TextEditor(text: $observacoesMarcacao)
                .font(.body.weight(.medium))
                .foregroundStyle(TemaStyles.titleColor)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 118)
                .padding(12)
                .background(TemaStyles.surfaceColor)
                .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
                .overlay {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                            .stroke(Color(red: 0.00, green: 0.67, blue: 0.67).opacity(0.65), lineWidth: 1.4)

                        if observacoesMarcacao.isEmpty {
                            Text(t("Descreva sintomas ou informações\nrelevantes..."))
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color(red: 0.63, green: 0.69, blue: 0.76))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .onChange(of: observacoesMarcacao) { _, _ in
                    salvarRascunhoLocal(passo: 4)
                }
        }
    }

    // Card usado enquanto a API carrega.
    private func loadingCard(_ mensagem: String) -> some View {
        HStack(spacing: 14) {
            ProgressView()
                .tint(Color(red: 0.00, green: 0.67, blue: 0.67))

            Text(mensagem)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TemaStyles.titleColor.opacity(0.76))

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.55), lineWidth: 1)
        }
    }

    // Aviso simples quando a API nao responder.
    private func avisoCard(_ mensagem: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.footnote.weight(.semibold))

            Text(mensagem)
                .font(.footnote.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Color(red: 0.78, green: 0.12, blue: 0.12))
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 1.00, green: 0.93, blue: 0.93))
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
    }

    // Botao para seguir para o proximo passo.
    private var continuarButton: some View {
        Button {
            avancarPasso()
        } label: {
            HStack(spacing: 12) {
                if enviandoMarcacao {
                    ProgressView()
                        .tint(.white)
                    Text(t("A confirmar..."))
                } else {
                    Text(tituloBotaoContinuar)
                    Image(systemName: passoAtual == 4 ? "checkmark" : "chevron.right")
                }
            }
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: TemaStyles.buttonHeight)
            .background(botaoPodeContinuar ? Color(red: 0.00, green: 0.67, blue: 0.67) : Color(red: 0.45, green: 0.78, blue: 0.79))
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .shadow(color: Color(red: 0.00, green: 0.67, blue: 0.67).opacity(0.22), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(botaoPodeContinuar == false)
        .opacity(botaoPodeContinuar ? 1 : 0.84)
    }

    private var novoAgendamentoButton: some View {
        Button {
            iniciarNovoAgendamento()
        } label: {
            HStack(spacing: 12) {
                Text(t("Novo Agendamento"))
                Image(systemName: "calendar.badge.plus")
            }
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: TemaStyles.buttonHeight)
            .background(Color(red: 0.00, green: 0.67, blue: 0.67))
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .shadow(color: Color(red: 0.00, green: 0.67, blue: 0.67).opacity(0.22), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    private var progresso: CGFloat {
        CGFloat(passoAtual) / CGFloat(totalPassos)
    }

    private var botaoPodeContinuar: Bool {
        if enviandoMarcacao || agendamentoConfirmado {
            return false
        }

        if passoAtual == 1 {
            return especialidadeSelecionada != nil
        }

        if passoAtual == 2 {
            return medicoSelecionado != nil
        }

        if passoAtual == 3 {
            return dataSelecionada != nil && horarioSelecionado != nil
        }

        if passoAtual == 4 {
            return especialidadeSelecionada != nil
                && medicoSelecionado != nil
                && dataSelecionada != nil
                && horarioSelecionado != nil
        }

        return false
    }

    private var tituloPassoAtual: String {
        if agendamentoConfirmado {
            return "Agendamento Confirmado"
        }

        switch passoAtual {
        case 1:
            return "Escolha a Especialidade"
        case 2:
            return "Escolha o Medico"
        case 3:
            return "Data e Horario"
        default:
            return "Confirmar Agendamento"
        }
    }

    private var subtituloPassoAtual: String {
        if agendamentoConfirmado {
            return "A sua consulta foi marcada com sucesso"
        }

        switch passoAtual {
        case 1:
            return "Selecione a especialidade desejada"
        case 2:
            return "Selecione o profissional"
        case 3:
            return "Escolha quando deseja ser atendido"
        default:
            return "Reveja os dados antes de confirmar"
        }
    }

    private var tituloBotaoContinuar: String {
        passoAtual == 4 ? "Confirmar Agendamento" : "Continuar"
    }

    private var medicosDisponiveis: [MedicoMarcacao] {
        medicos
    }

    private var calendarioMarcacao: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "pt_PT")
        calendar.firstWeekday = 2
        return calendar
    }

    private var calendarioColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    }

    private var horarioColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    private var tituloMesCalendario: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: mesCalendario).lowercased()
    }

    private var datasDisponiveis: [Date] {
        guard let medicoSelecionado else { return [] }
        return medicoSelecionado.horarios.map { calendarioMarcacao.startOfDay(for: $0.data) }
    }

    private var diasDoCalendario: [DiaCalendarioMarcacao] {
        guard let inicioMes = calendarioMarcacao.date(
            from: calendarioMarcacao.dateComponents([.year, .month], from: mesCalendario)
        ) else {
            return []
        }

        let weekday = calendarioMarcacao.component(.weekday, from: inicioMes)
        let diasAntes = (weekday - calendarioMarcacao.firstWeekday + 7) % 7
        let inicioGrelha = calendarioMarcacao.date(byAdding: .day, value: -diasAntes, to: inicioMes) ?? inicioMes

        return (0..<42).compactMap { offset in
            guard let data = calendarioMarcacao.date(byAdding: .day, value: offset, to: inicioGrelha) else {
                return nil
            }

            let mesmoMes = calendarioMarcacao.isDate(data, equalTo: mesCalendario, toGranularity: .month)
            return DiaCalendarioMarcacao(data: data, pertenceAoMesAtual: mesmoMes)
        }
    }

    private var horariosDisponiveisNaData: [HorarioMarcacao] {
        guard let dataSelecionada, let medicoSelecionado else { return [] }

        return medicoSelecionado.horarios.filter { horario in
            calendarioMarcacao.isDate(horario.data, inSameDayAs: dataSelecionada)
        }
    }

    private func avancarPasso() {
        guard botaoPodeContinuar else { return }

        switch passoAtual {
        case 1:
            withAnimation(.easeInOut(duration: 0.22)) {
                passoAtual = 2
                medicoSelecionado = nil
            }
            salvarRascunhoLocal(passo: 2)

            Task {
                await carregarAgendaMedica()
            }
        case 2:
            withAnimation(.easeInOut(duration: 0.22)) {
                passoAtual = 3
                if let medicoSelecionado {
                    aplicarPrimeiraDataDisponivel(do: medicoSelecionado)
                }
            }
            salvarRascunhoLocal(passo: 3)
        case 3:
            withAnimation(.easeInOut(duration: 0.22)) {
                passoAtual = 4
            }
            salvarRascunhoLocal(passo: 4)
        case 4:
            salvarRascunhoLocal(passo: 4)
            Task {
                await confirmarAgendamentoEChamarConsultaAgendada()
            }
        default:
            break
        }
    }

    @MainActor
    private func confirmarAgendamentoEChamarConsultaAgendada() async {
        guard enviandoMarcacao == false else { return }
        guard let especialidadeSelecionada,
              let medicoSelecionado,
              let dataSelecionada,
              let horarioSelecionado else {
            mensagemConfirmacaoErro = "Preenche todos os dados da consulta antes de confirmar."
            return
        }

        enviandoMarcacao = true
        mensagemConfirmacaoErro = nil
        salvarRascunhoLocal(passo: 4)

        do {
            let codigoConfirmacao = gerarCodigoConfirmacao()
            let estadoMarcacao = "Agendada"
            let controller = MarcacaoController()
            let resposta = try await controller.confirmarMarcacao(
                usuario: usuarioLocal,
                especialidadeId: especialidadeSelecionada.id,
                medicoId: medicoSelecionado.id,
                agendaMedicaId: horarioSelecionado.agendaMedicaId ?? medicoSelecionado.agendaMedicaId,
                dataConsulta: dataSelecionada,
                hora: horarioSelecionado.hora,
                observacao: observacoesMarcacao,
                codigoConfirmacao: codigoConfirmacao,
                estado: estadoMarcacao
            )
            let respostaFinal = MarcacaoConfirmadaResponse(
                id: resposta.id,
                codigoConfirmacao: resposta.codigoConfirmacao ?? codigoConfirmacao,
                estado: resposta.estado ?? estadoMarcacao,
                mensagem: resposta.mensagem
            )

            chamarTelaConsultaAgendada(com: respostaFinal)
        } catch {
            mensagemConfirmacaoErro = error.localizedDescription
        }

        enviandoMarcacao = false
    }

    @MainActor
    private func chamarTelaConsultaAgendada(com resposta: MarcacaoConfirmadaResponse) {
        marcacaoConfirmada = resposta
        salvarMarcacaoConfirmadaLocal(resposta)

        withAnimation(.easeInOut(duration: 0.22)) {
            agendamentoConfirmado = true
        }
    }

    private func voltarPasso() {
        guard passoAtual > 1 else { return }
        let novoPasso = passoAtual - 1

        withAnimation(.easeInOut(duration: 0.22)) {
            passoAtual = novoPasso
        }
        salvarRascunhoLocal(passo: novoPasso)
    }

    private func mudarMes(_ valor: Int) {
        withAnimation(.easeInOut(duration: 0.18)) {
            mesCalendario = calendarioMarcacao.date(byAdding: .month, value: valor, to: mesCalendario) ?? mesCalendario
        }
    }

    private func dataDisponivel(_ data: Date) -> Bool {
        datasDisponiveis.contains { disponivel in
            calendarioMarcacao.isDate(disponivel, inSameDayAs: data)
        }
    }

    private func selecionarData(_ data: Date) {
        guard dataDisponivel(data) else { return }

        withAnimation(.easeInOut(duration: 0.18)) {
            dataSelecionada = data
            horarioSelecionado = nil
        }
        salvarRascunhoLocal(passo: 3)
    }

    private func aplicarPrimeiraDataDisponivel(do medico: MedicoMarcacao) {
        guard let primeiroHorario = medico.horarios.first else {
            dataSelecionada = nil
            horarioSelecionado = nil
            return
        }

        dataSelecionada = primeiroHorario.data
        horarioSelecionado = nil
        mesCalendario = primeiroHorario.data
    }

    private func corDiaCalendario(
        dia: DiaCalendarioMarcacao,
        disponivel: Bool,
        selecionado: Bool
    ) -> Color {
        if selecionado {
            return Color(red: 0.00, green: 0.67, blue: 0.67)
        }

        if dia.pertenceAoMesAtual == false {
            return Color(red: 0.78, green: 0.82, blue: 0.87).opacity(0.62)
        }

        return disponivel
            ? TemaStyles.titleColor
            : Color(red: 0.78, green: 0.82, blue: 0.87).opacity(0.55)
    }

    private func dataSelecionadaTexto(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "d 'de' MMMM"
        return formatter.string(from: data).lowercased()
    }

    private func dataResumoTexto(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: data)
    }

    private func dataConfirmacaoTexto(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        return formatter.string(from: data).lowercased()
    }

    private var codigoConfirmacaoTexto: String {
        if let codigo = marcacaoConfirmada?.codigoConfirmacao?.trimmingCharacters(in: .whitespacesAndNewlines),
           codigo.isEmpty == false {
            return codigo.uppercased()
        }

        if let id = marcacaoConfirmada?.id?.trimmingCharacters(in: .whitespacesAndNewlines),
           id.isEmpty == false {
            return "FM-\(String(id.suffix(6)).uppercased())"
        }

        return "FM-LOCAL"
    }

    private func gerarCodigoConfirmacao() -> String {
        let caracteres = UUID().uuidString
            .replacingOccurrences(of: "-", with: "")
            .prefix(6)
            .uppercased()

        return "FM-\(caracteres)"
    }

    // Carrega a agenda medica conforme o usuario e a especialidade escolhida.
    @MainActor
    private func carregarAgendaMedica() async {
        guard loadingAgendaMedica == false else { return }
        guard let especialidadeSelecionada else {
            mensagemAgendaErro = "Seleciona uma especialidade para carregar os medicos."
            return
        }

        loadingAgendaMedica = true
        mensagemAgendaErro = nil
        medicos = []
        medicoSelecionado = nil
        usandoDadosLocais = false

        do {
            let controller = MarcacaoController()
            let resposta = try await controller.carregarAgendaMedica(
                usuario: usuarioLocal,
                especialidadeId: especialidadeSelecionada.id
            )
            medicos = MedicoMarcacao.lista(api: resposta)
            agendaEspecialidadeIdCarregada = especialidadeSelecionada.id
        } catch {
            if deveUsarDadosLocais(para: error) {
                usandoDadosLocais = true
                carregarRascunhoLocal()

                if medicos.isEmpty {
                    medicos = MedicoMarcacao.listaPadrao
                }

                agendaEspecialidadeIdCarregada = especialidadeSelecionada.id
                mensagemAgendaErro = "Sem ligacao com a API. Estamos a mostrar a agenda guardada no telemovel."
            } else {
                mensagemAgendaErro = error.localizedDescription
            }
        }

        loadingAgendaMedica = false
    }

    // Carrega os nomes reais das especialidades na API.
    @MainActor
    private func carregarEspecialidades() async {
        guard loadingEspecialidades == false else { return }

        let controller = MarcacaoController()
        loadingEspecialidades = true
        mensagemErro = nil
        usandoDadosLocais = false

        do {
            let resposta = try await controller.carregarEspecialidades()

            if resposta.isEmpty == false {
                limparCacheMarcacaoLocal(usando: controller)
                especialidades = resposta.enumerated().map { index, item in
                    EspecialidadeMarcacao(api: item, index: index)
                }
                guardarEspecialidadesLocais(resposta, usando: controller)
            }

            if let selecionada = especialidadeSelecionada,
               especialidades.contains(where: { $0.id == selecionada.id }) == false {
                especialidadeSelecionada = nil
            }
        } catch {
            let apiSemComunicacao = deveUsarDadosLocais(para: error)
            usandoDadosLocais = apiSemComunicacao

            if apiSemComunicacao, aplicarEspecialidadesLocais(usando: controller) {
                usandoDadosLocais = true
                carregarRascunhoLocal()
                mensagemErro = "Sem ligacao com a API. Estamos a mostrar as especialidades guardadas no telemovel."
            } else {
                mensagemErro = error.localizedDescription
                especialidades = EspecialidadeMarcacao.listaPadrao
            }
        }

        loadingEspecialidades = false
    }

    // Usa primeiro as especialidades que ja ficaram no telemovel.
    @discardableResult
    private func aplicarEspecialidadesLocais(usando controller: MarcacaoController) -> Bool {
        guard let especialidadesLocais = try? controller.carregarEspecialidadesLocais(modelContext: modelContext),
              especialidadesLocais.isEmpty == false else {
            return false
        }

        especialidades = especialidadesLocais.enumerated().map { index, item in
            EspecialidadeMarcacao(api: item, index: index)
        }
        return true
    }

    // Guarda a resposta boa da API para abrir depois sem internet.
    private func guardarEspecialidadesLocais(
        _ resposta: [EspecialidadeNomeResponse],
        usando controller: MarcacaoController
    ) {
        do {
            try controller.guardarEspecialidadesLocais(resposta, modelContext: modelContext)
        } catch {
            mensagemErro = "Especialidades carregadas, mas nao foi possivel guardar no telemovel."
        }
    }

    private func limparCacheMarcacaoLocal(usando controller: MarcacaoController) {
        do {
            try controller.limparCacheMarcacaoLocal(modelContext: modelContext)
            rascunhoFoiCarregado = false
        } catch {
            mensagemErro = "Nao foi possivel limpar a cache local da marcacao."
        }
    }

    private func limparRascunhoLocal() {
        do {
            let repository = MarcacaoRascunhoRepository(modelContext: modelContext)
            try repository.limpar(usuarioId: usuarioLocal?.id)
            rascunhoFoiCarregado = false
        } catch {
            mensagemErro = "Nao foi possivel limpar o rascunho guardado."
        }
    }

    private func deveUsarDadosLocais(para error: Error) -> Bool {
        guard let marcacaoError = error as? MarcacaoServiceError else {
            return false
        }

        if case .network = marcacaoError {
            return true
        }

        return false
    }

    // Restaura o ultimo rascunho local dos passos da marcacao.
    private func carregarRascunhoLocal() {
        guard rascunhoFoiCarregado == false else { return }
        rascunhoFoiCarregado = true

        do {
            let repository = MarcacaoRascunhoRepository(modelContext: modelContext)
            guard let rascunho = try repository.buscar(usuarioId: usuarioLocal?.id) else {
                return
            }

            aplicarRascunhoLocal(rascunho)
        } catch {
            mensagemErro = "Nao foi possivel carregar o rascunho da marcacao."
        }
    }

    // Guarda o estado actual para manter os passos 1, 2, 3 e 4 no SwiftData.
    private func salvarRascunhoLocal(passo: Int? = nil) {
        guard usandoDadosLocais else { return }

        do {
            let repository = MarcacaoRascunhoRepository(modelContext: modelContext)
            try repository.salvar(
                usuarioId: usuarioLocal?.id,
                passoAtual: passo ?? passoAtual,
                especialidadeId: especialidadeSelecionada?.id,
                especialidadeNome: especialidadeSelecionada?.nome,
                medicoId: medicoSelecionado?.id,
                medicoNome: medicoSelecionado?.nome,
                medicoCodigo: medicoSelecionado?.codigo,
                agendaMedicaId: horarioSelecionado?.agendaMedicaId ?? medicoSelecionado?.agendaMedicaId,
                dataConsulta: dataSelecionada,
                hora: horarioSelecionado?.hora,
                observacoes: observacoesMarcacao,
                confirmadoLocalmente: false
            )
        } catch {
            mensagemAgendaErro = "Nao foi possivel guardar o rascunho no telemovel."
        }
    }

    private func salvarMarcacaoConfirmadaLocal(_ resposta: MarcacaoConfirmadaResponse) {
        guard usandoDadosLocais else { return }

        do {
            let repository = MarcacaoRascunhoRepository(modelContext: modelContext)
            try repository.salvar(
                usuarioId: usuarioLocal?.id,
                passoAtual: 4,
                especialidadeId: especialidadeSelecionada?.id,
                especialidadeNome: especialidadeSelecionada?.nome,
                medicoId: medicoSelecionado?.id,
                medicoNome: medicoSelecionado?.nome,
                medicoCodigo: medicoSelecionado?.codigo,
                agendaMedicaId: horarioSelecionado?.agendaMedicaId ?? medicoSelecionado?.agendaMedicaId,
                dataConsulta: dataSelecionada,
                hora: horarioSelecionado?.hora,
                observacoes: observacoesMarcacao,
                confirmadoLocalmente: true,
                sincronizadoApi: true,
                marcacaoId: resposta.id,
                codigoConfirmacao: resposta.codigoConfirmacao,
                estado: resposta.estado
            )
        } catch {
            mensagemConfirmacaoErro = "A consulta foi confirmada, mas nao foi possivel guardar no telemovel."
        }
    }

    private func aplicarRascunhoLocal(_ rascunho: MarcacaoRascunhoLocalModel) {
        if let especialidadeId = rascunho.especialidadeId,
           let especialidadeNome = rascunho.especialidadeNome {
            especialidadeSelecionada = EspecialidadeMarcacao(
                api: EspecialidadeNomeResponse(id: especialidadeId, nome: especialidadeNome),
                index: 0
            )
        }

        if let medicoId = rascunho.medicoId,
           let medicoNome = rascunho.medicoNome {
            let data = rascunho.dataConsulta ?? Date()
            let horario = rascunho.hora.map {
                HorarioMarcacao(data: data, hora: $0, agendaMedicaId: rascunho.agendaMedicaId)
            }
            let medico = MedicoMarcacao(
                id: medicoId,
                nome: medicoNome,
                codigo: rascunho.medicoCodigo ?? medicoId,
                agendaMedicaId: rascunho.agendaMedicaId,
                descricao: "Medico selecionado",
                diasDisponiveis: ["Seg", "Ter", "Qua", "Qui", "Sex"],
                horarios: horario.map { [$0] } ?? MedicoMarcacao.horariosPadrao(offsetDias: 1)
            )

            medicoSelecionado = medico
            medicos = [medico]
        }

        dataSelecionada = rascunho.dataConsulta

        if let dataSelecionada {
            mesCalendario = dataSelecionada
        }

        if let hora = rascunho.hora, let dataSelecionada {
            horarioSelecionado = HorarioMarcacao(
                data: dataSelecionada,
                hora: hora,
                agendaMedicaId: rascunho.agendaMedicaId
            )
        }

        observacoesMarcacao = rascunho.observacoes ?? ""
        agendamentoConfirmado = rascunho.confirmadoLocalmente

        if rascunho.confirmadoLocalmente {
            marcacaoConfirmada = MarcacaoConfirmadaResponse(
                id: rascunho.marcacaoId,
                codigoConfirmacao: rascunho.codigoConfirmacao,
                estado: rascunho.estado
            )
        }

        passoAtual = min(max(rascunho.passoAtual, 1), totalPassos)
    }

    private func iniciarNovoAgendamento() {
        do {
            let repository = MarcacaoRascunhoRepository(modelContext: modelContext)
            try repository.limpar(usuarioId: usuarioLocal?.id)
        } catch {
            mensagemErro = "Nao foi possivel limpar o agendamento guardado."
        }

        withAnimation(.easeInOut(duration: 0.22)) {
            especialidadeSelecionada = nil
            medicoSelecionado = nil
            medicos = []
            mensagemAgendaErro = nil
            mensagemConfirmacaoErro = nil
            agendaEspecialidadeIdCarregada = nil
            dataSelecionada = nil
            horarioSelecionado = nil
            observacoesMarcacao = ""
            marcacaoConfirmada = nil
            agendamentoConfirmado = false
            passoAtual = 1
        }
    }

    private var usuarioLocal: UsuarioModel? {
        usuarios.first
    }

    private func t(_ text: String) -> String {
        L10n.tr(text, languageCode: languageCode)
    }
}

// Modelo simples para montar os cards de especialidade.
private struct EspecialidadeMarcacao: Identifiable, Equatable {
    let id: String
    let nome: String
    let icone: String
    let cor: Color
    let fundo: Color

    init(id: String, nome: String, icone: String, cor: Color, fundo: Color) {
        self.id = id
        self.nome = nome
        self.icone = icone
        self.cor = cor
        self.fundo = fundo
    }

    init(api: EspecialidadeNomeResponse, index: Int) {
        let estilo = EspecialidadeMarcacao.estilo(nome: api.nome, index: index)

        self.init(
            id: api.id,
            nome: api.nome,
            icone: estilo.icone,
            cor: estilo.cor,
            fundo: estilo.fundo
        )
    }

    static let listaPadrao: [EspecialidadeMarcacao] = [
        EspecialidadeMarcacao(
            id: "cardiologia",
            nome: "Cardiologia",
            icone: "heart",
            cor: Color(red: 0.95, green: 0.29, blue: 0.47),
            fundo: Color(red: 1.00, green: 0.86, blue: 0.91)
        ),
        EspecialidadeMarcacao(
            id: "clinica-geral",
            nome: "Clinica Geral",
            icone: "asterisk",
            cor: Color(red: 0.00, green: 0.66, blue: 0.67),
            fundo: Color(red: 0.83, green: 0.97, blue: 0.96)
        ),
        EspecialidadeMarcacao(
            id: "estomalogia",
            nome: "Estomalogia",
            icone: "shield",
            cor: Color(red: 0.95, green: 0.29, blue: 0.47),
            fundo: Color(red: 1.00, green: 0.86, blue: 0.91)
        ),
        EspecialidadeMarcacao(
            id: "laboratorio",
            nome: "Laboratório",
            icone: "heart",
            cor: Color(red: 0.95, green: 0.29, blue: 0.47),
            fundo: Color(red: 1.00, green: 0.86, blue: 0.91)
        )
    ]

    static func == (lhs: EspecialidadeMarcacao, rhs: EspecialidadeMarcacao) -> Bool {
        lhs.id == rhs.id
    }

    // Define o icone e as cores conforme o nome que veio da API.
    private static func estilo(nome: String, index: Int) -> (icone: String, cor: Color, fundo: Color) {
        let nomeLimpo = nome.folding(options: .diacriticInsensitive, locale: .current).lowercased()

        if nomeLimpo.contains("clinica") {
            return (
                "asterisk",
                Color(red: 0.00, green: 0.66, blue: 0.67),
                Color(red: 0.83, green: 0.97, blue: 0.96)
            )
        }

        if nomeLimpo.contains("estoma") {
            return (
                "shield",
                Color(red: 0.95, green: 0.29, blue: 0.47),
                Color(red: 1.00, green: 0.86, blue: 0.91)
            )
        }

        if nomeLimpo.contains("cardio") || nomeLimpo.contains("labor") {
            return (
                "heart",
                Color(red: 0.95, green: 0.29, blue: 0.47),
                Color(red: 1.00, green: 0.86, blue: 0.91)
            )
        }

        return index.isMultiple(of: 2)
            ? (
                "cross.case",
                Color(red: 0.95, green: 0.29, blue: 0.47),
                Color(red: 1.00, green: 0.86, blue: 0.91)
            )
            : (
                "staroflife",
                Color(red: 0.00, green: 0.66, blue: 0.67),
                Color(red: 0.83, green: 0.97, blue: 0.96)
            )
    }
}

// Modelo inicial para montar os cards do passo de medicos.
private struct MedicoMarcacao: Identifiable, Equatable {
    let id: String
    let nome: String
    let codigo: String
    let agendaMedicaId: String?
    let descricao: String
    let diasDisponiveis: [String]
    let horarios: [HorarioMarcacao]

    init(
        id: String,
        nome: String,
        codigo: String,
        agendaMedicaId: String? = nil,
        descricao: String,
        diasDisponiveis: [String],
        horarios: [HorarioMarcacao]
    ) {
        self.id = id
        self.nome = nome
        self.codigo = codigo
        self.agendaMedicaId = agendaMedicaId
        self.descricao = descricao
        self.diasDisponiveis = diasDisponiveis
        self.horarios = horarios
    }

    init(api: AgendaMedicaResponse, index: Int) {
        self.init(
            id: api.medicoId ?? api.id,
            nome: api.medicoNome,
            codigo: api.codigo,
            agendaMedicaId: api.id,
            descricao: api.descricao ?? "Medico disponivel para esta especialidade",
            diasDisponiveis: MedicoMarcacao.diasFormatados(api.diasDisponiveis, index: index),
            horarios: MedicoMarcacao.horarios(api: api, index: index)
        )
    }

    init(agendas: [AgendaMedicaResponse], index: Int) {
        let primeira = agendas[0]
        let dias = agendas.flatMap { agenda in
            MedicoMarcacao.diasFormatados(agenda.diasDisponiveis, index: index)
        }
        let horarios = agendas.enumerated().flatMap { offset, agenda in
            MedicoMarcacao.horarios(api: agenda, index: index + offset)
        }
        let horariosOrdenados = horarios.sorted { lhs, rhs in
            if Calendar.current.isDate(lhs.data, inSameDayAs: rhs.data) {
                return lhs.hora < rhs.hora
            }

            return lhs.data < rhs.data
        }

        self.init(
            id: primeira.medicoId ?? primeira.id,
            nome: primeira.medicoNome,
            codigo: primeira.codigo,
            agendaMedicaId: primeira.id,
            descricao: primeira.descricao ?? "Medico disponivel para esta especialidade",
            diasDisponiveis: Array(Set(dias)).sorted(),
            horarios: horariosOrdenados
        )
    }

    static let listaPadrao: [MedicoMarcacao] = [
        MedicoMarcacao(
            id: "avelino-023",
            nome: "Avelino Nhanga",
            codigo: "023",
            descricao: "Medico disponivel para esta especialidade",
            diasDisponiveis: ["Qua", "Sab", "Seg", "Sex", "Ter"],
            horarios: MedicoMarcacao.horariosPadrao(offsetDias: 2)
        ),
        MedicoMarcacao(
            id: "avelino-5401",
            nome: "Avelino Nhanga",
            codigo: "5401",
            descricao: "Medico disponivel para esta especialidade",
            diasDisponiveis: ["Qui", "Sab", "Sex", "Qua", "Ter", "Seg", "Dom"],
            horarios: MedicoMarcacao.horariosPadrao(offsetDias: 3)
        )
    ]

    static func == (lhs: MedicoMarcacao, rhs: MedicoMarcacao) -> Bool {
        lhs.id == rhs.id
    }

    static func lista(api agendas: [AgendaMedicaResponse]) -> [MedicoMarcacao] {
        var grupos: [String: [AgendaMedicaResponse]] = [:]
        var ordem: [String] = []

        for agenda in agendas {
            let chave = agenda.medicoId ?? "\(agenda.medicoNome)-\(agenda.codigo)"

            if grupos[chave] == nil {
                ordem.append(chave)
                grupos[chave] = []
            }

            grupos[chave]?.append(agenda)
        }

        return ordem.enumerated().compactMap { index, chave in
            guard let agendasMedico = grupos[chave], agendasMedico.isEmpty == false else {
                return nil
            }

            return MedicoMarcacao(agendas: agendasMedico, index: index)
        }
    }

    private static func diasFormatados(_ dias: [String], index: Int) -> [String] {
        let formatados = dias.map { diaCurto($0) }.filter { $0.isEmpty == false }

        if formatados.isEmpty == false {
            return Array(formatados.prefix(7))
        }

        return index.isMultiple(of: 2)
            ? ["Seg", "Qua", "Sex"]
            : ["Ter", "Qui", "Sab"]
    }

    private static func diaCurto(_ valor: String) -> String {
        let limpo = valor
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        if limpo.isEmpty {
            return ""
        }

        if ["1", "segunda", "segunda-feira", "seg"].contains(limpo) {
            return "Seg"
        }

        if ["2", "terca", "terca-feira", "ter"].contains(limpo) {
            return "Ter"
        }

        if ["3", "quarta", "quarta-feira", "qua"].contains(limpo) {
            return "Qua"
        }

        if ["4", "quinta", "quinta-feira", "qui"].contains(limpo) {
            return "Qui"
        }

        if ["5", "sexta", "sexta-feira", "sex"].contains(limpo) {
            return "Sex"
        }

        if ["6", "sabado", "sab"].contains(limpo) {
            return "Sab"
        }

        if ["0", "7", "domingo", "dom"].contains(limpo) {
            return "Dom"
        }

        return String(valor.prefix(3))
    }

    private static func horarios(api: AgendaMedicaResponse, index: Int) -> [HorarioMarcacao] {
        let horariosDetalhados = api.horarios.flatMap { horario in
            horariosGerados(
                agendaId: horario.id ?? api.id,
                data: horario.data ?? api.data,
                dias: horario.diasDisponiveis.isEmpty ? api.diasDisponiveis : horario.diasDisponiveis,
                hora: horario.hora ?? api.hora,
                horaInicio: horario.horaInicio ?? api.horaInicio,
                horaFim: horario.horaFim ?? api.horaFim
            )
        }

        if horariosDetalhados.isEmpty == false {
            return horariosUnicos(horariosDetalhados)
        }

        return horariosUnicos(
            horariosGerados(
                agendaId: api.id,
                data: api.data,
                dias: api.diasDisponiveis,
                hora: api.hora,
                horaInicio: api.horaInicio,
                horaFim: api.horaFim
            )
        )
    }

    private static func horariosGerados(
        agendaId: String,
        data: Date?,
        dias: [String],
        hora: String?,
        horaInicio: String?,
        horaFim: String?
    ) -> [HorarioMarcacao] {
        let datas = datasDisponiveis(data: data, dias: dias)
        guard datas.isEmpty == false else { return [] }

        let horas = horasDisponiveis(hora: hora, horaInicio: horaInicio, horaFim: horaFim)
        guard horas.isEmpty == false else { return [] }

        return datas.flatMap { data in
            horas.map { hora in
                HorarioMarcacao(data: data, hora: hora, agendaMedicaId: agendaId)
            }
        }
    }

    private static func datasDisponiveis(data: Date?, dias: [String]) -> [Date] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "pt_PT")
        calendar.firstWeekday = 2

        if let data {
            return [calendar.startOfDay(for: data)]
        }

        let weekdays = Set(dias.compactMap(weekdayCalendario))
        guard weekdays.isEmpty == false else { return [] }

        let hoje = calendar.startOfDay(for: Date())
        return (0..<60).compactMap { offset in
            guard let data = calendar.date(byAdding: .day, value: offset, to: hoje) else {
                return nil
            }

            return weekdays.contains(calendar.component(.weekday, from: data)) ? data : nil
        }
    }

    private static func horasDisponiveis(
        hora: String?,
        horaInicio: String?,
        horaFim: String?
    ) -> [String] {
        if let hora = horaFormatada(hora) {
            return [hora]
        }

        guard let inicio = minutos(horaInicio) else {
            return []
        }

        guard let fim = minutos(horaFim), fim >= inicio else {
            return [horaTexto(minutos: inicio)]
        }

        return stride(from: inicio, through: fim, by: 30).map(horaTexto)
    }

    nonisolated private static func weekdayCalendario(_ valor: String) -> Int? {
        let limpo = valor
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        if ["1", "segunda", "segunda-feira", "seg"].contains(limpo) {
            return 2
        }

        if ["2", "terca", "terca-feira", "ter"].contains(limpo) {
            return 3
        }

        if ["3", "quarta", "quarta-feira", "qua"].contains(limpo) {
            return 4
        }

        if ["4", "quinta", "quinta-feira", "qui"].contains(limpo) {
            return 5
        }

        if ["5", "sexta", "sexta-feira", "sex"].contains(limpo) {
            return 6
        }

        if ["6", "sabado", "sab"].contains(limpo) {
            return 7
        }

        if ["0", "7", "domingo", "dom"].contains(limpo) {
            return 1
        }

        return nil
    }

    private static func minutos(_ texto: String?) -> Int? {
        guard let texto else { return nil }
        let limpo = texto
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "h", with: ":")

        let partes = limpo.split(separator: ":")
        guard let hora = Int(partes.first ?? "") else { return nil }
        let minuto = partes.count > 1 ? Int(partes[1]) ?? 0 : 0
        return (hora * 60) + minuto
    }

    private static func horaFormatada(_ texto: String?) -> String? {
        guard let valor = minutos(texto) else { return nil }
        return horaTexto(minutos: valor)
    }

    nonisolated private static func horaTexto(minutos: Int) -> String {
        String(format: "%02d:%02d", minutos / 60, minutos % 60)
    }

    private static func horariosUnicos(_ horarios: [HorarioMarcacao]) -> [HorarioMarcacao] {
        var vistos: Set<String> = []

        return horarios.filter { horario in
            let chave = "\(Calendar.current.startOfDay(for: horario.data).timeIntervalSince1970)-\(horario.hora)-\(horario.agendaMedicaId ?? "")"
            guard vistos.contains(chave) == false else { return false }
            vistos.insert(chave)
            return true
        }
    }

    static func horariosPadrao(offsetDias: Int) -> [HorarioMarcacao] {
        let data = dataPadrao(offsetDias: offsetDias)
        return [
            "09:00",
            "09:30",
            "10:00",
            "10:30",
            "11:00",
            "11:30",
            "12:00",
            "12:30",
            "13:00",
            "13:30",
            "14:00",
            "14:30",
            "15:00",
            "15:30",
            "16:00",
            "16:30",
            "17:00"
        ].map { hora in
            HorarioMarcacao(data: data, hora: hora)
        }
    }

    private static func dataPadrao(offsetDias: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offsetDias, to: Date()) ?? Date()
    }
}

private struct DiaCalendarioMarcacao: Identifiable {
    let data: Date
    let pertenceAoMesAtual: Bool

    var id: TimeInterval {
        data.timeIntervalSince1970
    }
}

private struct HorarioMarcacao: Identifiable, Equatable {
    let data: Date
    let hora: String
    let agendaMedicaId: String?

    init(data: Date, hora: String, agendaMedicaId: String? = nil) {
        self.data = data
        self.hora = hora
        self.agendaMedicaId = agendaMedicaId
    }

    var id: String {
        "\(data.timeIntervalSince1970)-\(hora)-\(agendaMedicaId ?? "sem-agenda")"
    }
}

#Preview {
    MarcacoesUsuarios()
        .background(TemaStyles.backgroundColor)
        .modelContainer(SwiftDataManager.criarContainerEmMemoria())
}
