//
//  MarcacaoService.swift
//  Famor
//
//  Created by Aluno ISTEC on 06/07/2026.
//

import Foundation

// Dados da marcacao que vem da API.
struct MarcacaoHojeResponse: Decodable, Identifiable, Equatable {
    let id: String?
    let medico: String?
    let medicoId: String?
    let especialidade: String?
    let especialidadeId: String?
    let dataConsulta: Date?
    let hora: String?
    let horaInicio: String?
    let horaFim: String?
    let agendaMedicaId: String?
    let codigoConfirmacao: String?
    let observacao: String?
    let estado: String?
    let estadoCor: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case medico
        case medicoMaiusculo = "Medico"
        case medicoId
        case especialidade
        case especialidadeMaiusculo = "Especialidade"
        case especialidadeId
        case data
        case dataConsultas
        case hora
        case horaInicio
        case horaFim
        case agendaMedicaId
        case codigoConfirmacao
        case observacao
        case estado
        case estadoCor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id])
        medico = container.decodeStringIfExists(forKeys: [.medico, .medicoMaiusculo])
        medicoId = container.decodeStringIfExists(forKeys: [.medicoId])
        especialidade = container.decodeStringIfExists(forKeys: [.especialidade, .especialidadeMaiusculo])
        especialidadeId = container.decodeStringIfExists(forKeys: [.especialidadeId])
        dataConsulta = container.decodeDateIfExists(forKeys: [.dataConsultas, .data])
        hora = container.decodeStringIfExists(forKeys: [.hora])
        horaInicio = container.decodeStringIfExists(forKeys: [.horaInicio])
        horaFim = container.decodeStringIfExists(forKeys: [.horaFim])
        agendaMedicaId = container.decodeStringIfExists(forKeys: [.agendaMedicaId])
        codigoConfirmacao = container.decodeStringIfExists(forKeys: [.codigoConfirmacao])
        observacao = container.decodeStringIfExists(forKeys: [.observacao])
        estado = container.decodeStringIfExists(forKeys: [.estado])
        estadoCor = container.decodeStringIfExists(forKeys: [.estadoCor])
    }

    // Confirma se esta marcacao e mesmo do dia actual.
    var eHoje: Bool {
        guard let dataConsulta else { return false }
        return Calendar.current.isDateInToday(dataConsulta)
    }

    // Ajuda a saber se a API mandou uma marcacao de verdade.
    var temDados: Bool {
        id != nil || medico != nil || especialidade != nil || dataConsulta != nil
    }
}

// Dados usados na tela Minhas Consultas.
struct MarcacaoFeitaResponse: Decodable, Identifiable, Equatable {
    let id: String
    let medicoNome: String
    let medicoId: String?
    let especialidade: String?
    let especialidadeId: String?
    let dataConsulta: Date?
    let horaInicio: String?
    let horaFim: String?
    let codigoConfirmacao: String?
    let observacao: String?
    let estado: String?
    let estadoCor: String?

    // Permite montar o mesmo modelo com dados locais.
    init(
        id: String,
        medicoNome: String,
        medicoId: String? = nil,
        especialidade: String? = nil,
        especialidadeId: String? = nil,
        dataConsulta: Date? = nil,
        horaInicio: String? = nil,
        horaFim: String? = nil,
        codigoConfirmacao: String? = nil,
        observacao: String? = nil,
        estado: String? = nil,
        estadoCor: String? = nil
    ) {
        self.id = id
        self.medicoNome = medicoNome
        self.medicoId = medicoId
        self.especialidade = especialidade
        self.especialidadeId = especialidadeId
        self.dataConsulta = dataConsulta
        self.horaInicio = horaInicio
        self.horaFim = horaFim
        self.codigoConfirmacao = codigoConfirmacao
        self.observacao = observacao
        self.estado = estado
        self.estadoCor = estadoCor
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case medicoNome
        case mediconome
        case nomeMedico
        case medico
        case medicoMaiusculo = "Medico"
        case medicoId
        case especialidade
        case especialidadeMaiusculo = "Especialidade"
        case nomeEspecialidade
        case especialidadeId
        case data
        case dataConsultas
        case dataConsulta
        case hora
        case horaInicio
        case horaFim
        case codigoConfirmacao
        case codigo
        case observacao
        case estado
        case status
        case estadoCor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id, .mongoId]) ?? UUID().uuidString
        medicoNome = container.decodeStringIfExists(
            forKeys: [.medicoNome, .mediconome, .nomeMedico, .medico, .medicoMaiusculo]
        ) ?? "Medico"
        medicoId = container.decodeStringIfExists(forKeys: [.medicoId])
        especialidade = container.decodeStringIfExists(
            forKeys: [.especialidade, .especialidadeMaiusculo, .nomeEspecialidade]
        )
        especialidadeId = container.decodeStringIfExists(forKeys: [.especialidadeId])
        dataConsulta = container.decodeDateIfExists(forKeys: [.dataConsultas, .dataConsulta, .data])
        horaInicio = container.decodeStringIfExists(forKeys: [.horaInicio, .hora])
        horaFim = container.decodeStringIfExists(forKeys: [.horaFim])
        codigoConfirmacao = container.decodeStringIfExists(forKeys: [.codigoConfirmacao, .codigo])
        observacao = container.decodeStringIfExists(forKeys: [.observacao])
        estado = container.decodeStringIfExists(forKeys: [.estado, .status])
        estadoCor = container.decodeStringIfExists(forKeys: [.estadoCor])
    }

    var temDados: Bool {
        medicoNome.isEmpty == false || especialidade != nil || dataConsulta != nil
    }
}

// Nome da especialidade que vem da API.
struct EspecialidadeNomeResponse: Decodable, Identifiable, Equatable {
    let id: String
    let nome: String

    private enum CodingKeys: String, CodingKey {
        case id
        case nome
        case name
    }

    init(id: String, nome: String) {
        self.id = id
        self.nome = nome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id]) ?? UUID().uuidString
        nome = container.decodeStringIfExists(forKeys: [.nome, .name]) ?? "Especialidade"
    }
}

// Agenda medica devolvida pela API para o segundo passo da marcacao.
struct AgendaMedicaResponse: Decodable, Identifiable, Equatable {
    let id: String
    let medicoId: String?
    let medicoNome: String
    let codigo: String
    let especialidadeId: String?
    let diasDisponiveis: [String]
    let descricao: String?
    let data: Date?
    let hora: String?
    let horaInicio: String?
    let horaFim: String?
    let horarios: [AgendaMedicaHorarioResponse]

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case medicoId
        case idMedico
        case medico
        case profissional
        case nomeMedico
        case medicoNome
        case medicoNomeMinusculo = "mediconome"
        case nome
        case codigo
        case codigoMedico
        case crm
        case numeroOrdem
        case numeroOrdemMinusculo = "numeroordem"
        case especialidadeId
        case idEspecialidade
        case diasDisponiveis
        case diasSemanaDisponivel
        case diasSemana
        case dias
        case disponibilidade
        case horarios
        case agendas
        case data
        case dataConsulta
        case dataConsultas
        case date
        case dia
        case hora
        case horario
        case horaConsulta
        case horaAtendimento
        case horaInicio
        case inicio
        case horaInicial
        case horarioInicio
        case horaFim
        case fim
        case horaFinal
        case horarioFim
        case descricao
        case observacao
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let medico = (try? container.decode(AgendaMedicaMedicoDTO.self, forKey: .medico))
            ?? (try? container.decode(AgendaMedicaMedicoDTO.self, forKey: .profissional))

        id = container.decodeStringIfExists(forKeys: [.id, .mongoId])
            ?? medico?.id
            ?? UUID().uuidString
        medicoId = container.decodeStringIfExists(forKeys: [.medicoId, .idMedico])
            ?? medico?.id
        medicoNome = container.decodeStringIfExists(forKeys: [.nomeMedico, .medicoNome, .medicoNomeMinusculo, .nome])
            ?? medico?.nome
            ?? "Medico"
        codigo = container.decodeStringIfExists(forKeys: [.codigo, .codigoMedico, .crm, .numeroOrdem, .numeroOrdemMinusculo])
            ?? medico?.codigo
            ?? medicoId
            ?? id
        especialidadeId = container.decodeStringIfExists(forKeys: [.especialidadeId, .idEspecialidade])
        diasDisponiveis = container.decodeStringArrayIfExists(
            forKeys: [.diasDisponiveis, .diasSemanaDisponivel, .diasSemana, .dias, .disponibilidade]
        ) ?? []
        descricao = container.decodeStringIfExists(forKeys: [.descricao, .observacao])
        data = container.decodeDateIfExists(forKeys: [.dataConsultas, .dataConsulta, .data, .date, .dia])
        hora = container.decodeStringIfExists(forKeys: [.hora, .horario, .horaConsulta, .horaAtendimento])
        horaInicio = container.decodeStringIfExists(forKeys: [.horaInicio, .inicio, .horaInicial, .horarioInicio])
        horaFim = container.decodeStringIfExists(forKeys: [.horaFim, .fim, .horaFinal, .horarioFim])
        horarios = (try? container.decode([AgendaMedicaHorarioResponse].self, forKey: .horarios))
            ?? (try? container.decode([AgendaMedicaHorarioResponse].self, forKey: .agendas))
            ?? []
    }
}

struct AgendaMedicaHorarioResponse: Decodable, Equatable {
    let id: String?
    let data: Date?
    let diasDisponiveis: [String]
    let hora: String?
    let horaInicio: String?
    let horaFim: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case agendaMedicaId
        case data
        case dataConsulta
        case dataConsultas
        case date
        case dia
        case diasDisponiveis
        case diasSemanaDisponivel
        case diasSemana
        case dias
        case disponibilidade
        case hora
        case horario
        case horaConsulta
        case horaAtendimento
        case horaInicio
        case inicio
        case horaInicial
        case horarioInicio
        case horaFim
        case fim
        case horaFinal
        case horarioFim
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id, .mongoId, .agendaMedicaId])
        data = container.decodeDateIfExists(forKeys: [.dataConsultas, .dataConsulta, .data, .date, .dia])
        diasDisponiveis = container.decodeStringArrayIfExists(
            forKeys: [.diasDisponiveis, .diasSemanaDisponivel, .diasSemana, .dias, .disponibilidade]
        ) ?? []
        hora = container.decodeStringIfExists(forKeys: [.hora, .horario, .horaConsulta, .horaAtendimento])
        horaInicio = container.decodeStringIfExists(forKeys: [.horaInicio, .inicio, .horaInicial, .horarioInicio])
        horaFim = container.decodeStringIfExists(forKeys: [.horaFim, .fim, .horaFinal, .horarioFim])
    }
}

// Dados enviados para criar a marcacao no backend.
struct CriarMarcacaoRequest: Encodable, Equatable {
    let pacienteId: String
    let usuarioId: String
    let medicoId: String
    let especialidadeId: String
    let agendaMedicaId: String
    let dataConsultas: String
    let hora: String
    let observacao: String
    let codigoConfirmacao: String
    let estado: String
}

// Resposta devolvida depois de confirmar a marcacao.
struct MarcacaoConfirmadaResponse: Decodable, Equatable {
    let id: String?
    let codigoConfirmacao: String?
    let estado: String?
    let mensagem: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case codigoConfirmacao
        case codigo
        case estado
        case status
        case message
        case mensagem
        case msg
    }

    init(
        id: String? = nil,
        codigoConfirmacao: String? = nil,
        estado: String? = nil,
        mensagem: String? = nil
    ) {
        self.id = id
        self.codigoConfirmacao = codigoConfirmacao
        self.estado = estado
        self.mensagem = mensagem
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id, .mongoId])
        codigoConfirmacao = container.decodeStringIfExists(forKeys: [.codigoConfirmacao, .codigo])
        estado = container.decodeStringIfExists(forKeys: [.estado, .status])
        mensagem = container.decodeStringIfExists(forKeys: [.message, .mensagem, .msg])
    }
}

private struct AgendaMedicaMedicoDTO: Decodable {
    let id: String?
    let nome: String?
    let codigo: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case nome
        case name
        case codigo
        case codigoMedico
        case crm
        case numeroOrdem
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeStringIfExists(forKeys: [.id, .mongoId])
        nome = container.decodeStringIfExists(forKeys: [.nome, .name])
        codigo = container.decodeStringIfExists(forKeys: [.codigo, .codigoMedico, .crm, .numeroOrdem])
    }
}

private struct AgendaMedicaDiaDTO: Decodable {
    let nome: String?

    private enum CodingKeys: String, CodingKey {
        case dia
        case diaSemana
        case nome
        case name
        case day
        case descricao
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nome = container.decodeStringIfExists(forKeys: [.dia, .diaSemana, .nome, .name, .day, .descricao, .data])
    }
}

// Mensagem de erro que pode vir do backend.
private struct MarcacaoApiErrorResponse: Decodable {
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case message
        case mensagem
        case msg
        case error
        case erro
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = (try? container.decode(String.self, forKey: .message))
            ?? (try? container.decode(String.self, forKey: .mensagem))
            ?? (try? container.decode(String.self, forKey: .msg))
            ?? (try? container.decode(String.self, forKey: .error))
            ?? (try? container.decode(String.self, forKey: .erro))
    }
}

// Caso a API venha embrulhada em data, tambem conseguimos ler.
private struct MarcacaoWrapperResponse: Decodable {
    let marcacao: MarcacaoHojeResponse?

    private enum CodingKeys: String, CodingKey {
        case data
        case marcacao
        case consulta
        case resultado
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        marcacao = (try? container.decode(MarcacaoHojeResponse.self, forKey: .data))
            ?? (try? container.decode(MarcacaoHojeResponse.self, forKey: .marcacao))
            ?? (try? container.decode(MarcacaoHojeResponse.self, forKey: .consulta))
            ?? (try? container.decode(MarcacaoHojeResponse.self, forKey: .resultado))
    }
}

private struct MarcacoesFeitasWrapperResponse: Decodable {
    let marcacoes: [MarcacaoFeitaResponse]

    private enum CodingKeys: String, CodingKey {
        case data
        case marcacoes
        case consultas
        case resultado
        case resultados
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        marcacoes = (try? container.decode([MarcacaoFeitaResponse].self, forKey: .data))
            ?? (try? container.decode([MarcacaoFeitaResponse].self, forKey: .marcacoes))
            ?? (try? container.decode([MarcacaoFeitaResponse].self, forKey: .consultas))
            ?? (try? container.decode([MarcacaoFeitaResponse].self, forKey: .resultado))
            ?? (try? container.decode([MarcacaoFeitaResponse].self, forKey: .resultados))
            ?? []
    }
}

private struct AgendaMedicaWrapperResponse: Decodable {
    let agendas: [AgendaMedicaResponse]

    private enum CodingKeys: String, CodingKey {
        case data
        case agenda
        case agendas
        case resultado
        case resultados
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        agendas = (try? container.decode([AgendaMedicaResponse].self, forKey: .data))
            ?? (try? container.decode([AgendaMedicaResponse].self, forKey: .agenda))
            ?? (try? container.decode([AgendaMedicaResponse].self, forKey: .agendas))
            ?? (try? container.decode([AgendaMedicaResponse].self, forKey: .resultado))
            ?? (try? container.decode([AgendaMedicaResponse].self, forKey: .resultados))
            ?? []
    }
}

private struct MarcacaoConfirmadaWrapperResponse: Decodable {
    let marcacao: MarcacaoConfirmadaResponse?

    private enum CodingKeys: String, CodingKey {
        case data
        case marcacao
        case consulta
        case resultado
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        marcacao = (try? container.decode(MarcacaoConfirmadaResponse.self, forKey: .data))
            ?? (try? container.decode(MarcacaoConfirmadaResponse.self, forKey: .marcacao))
            ?? (try? container.decode(MarcacaoConfirmadaResponse.self, forKey: .consulta))
            ?? (try? container.decode(MarcacaoConfirmadaResponse.self, forKey: .resultado))
    }
}

// Erros da chamada das marcacoes.
enum MarcacaoServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidAgendaData
    case tokenAusente
    case usuarioAusente
    case especialidadeAusente
    case pacienteAusente
    case marcacaoIncompleta
    case agendaMedicaAusente
    case network(message: String)
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A rota das consultas nao esta valida."
        case .invalidResponse:
            return "A API respondeu de uma forma inesperada."
        case .invalidData:
            return "Nao foi possivel ler a consulta de hoje."
        case .invalidAgendaData:
            return "Nao foi possivel ler a agenda medica."
        case .tokenAusente:
            return "Sessao expirada. Faz login novamente."
        case .usuarioAusente:
            return "Nao encontrei o usuario para buscar as consultas."
        case .especialidadeAusente:
            return "Seleciona uma especialidade para carregar os medicos."
        case .pacienteAusente:
            return "Nao encontrei o cadastro de paciente associado ao usuario autenticado."
        case .marcacaoIncompleta:
            return "Preenche todos os dados da consulta antes de confirmar."
        case .agendaMedicaAusente:
            return "Nao foi possivel identificar a agenda medica selecionada. Volta a escolher o medico e o horario."
        case .network(let message):
            return message
        case .server(let message):
            return message
        }
    }
}

// Servicos fica so com a conversa da API de marcacoes.
struct MarcacaoService {
    func buscarEspecialidades(token: String) async throws -> [EspecialidadeNomeResponse] {
        guard token.isEmpty == false else {
            throw MarcacaoServiceError.tokenAusente
        }

        guard let url = URL(string: Endpoints.especialidadeNomes) else {
            throw MarcacaoServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        ApiConstants.aplicarToken(token, na: &request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MarcacaoServiceError.network(
                message: "Nao foi possivel carregar as especialidades agora."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MarcacaoServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(MarcacaoApiErrorResponse.self, from: data)
            throw MarcacaoServiceError.server(
                message: apiError?.message ?? "A API nao conseguiu devolver as especialidades. Codigo \(httpResponse.statusCode)."
            )
        }

        do {
            return try JSONDecoder().decode([EspecialidadeNomeResponse].self, from: data)
        } catch {
            throw MarcacaoServiceError.invalidData
        }
    }

    func buscarAgendaMedica(
        usuarioId: String,
        especialidadeId: String,
        token: String
    ) async throws -> [AgendaMedicaResponse] {
        guard usuarioId.isEmpty == false else {
            throw MarcacaoServiceError.usuarioAusente
        }

        guard especialidadeId.isEmpty == false else {
            throw MarcacaoServiceError.especialidadeAusente
        }

        guard token.isEmpty == false else {
            throw MarcacaoServiceError.tokenAusente
        }

        guard let url = URL(string: Endpoints.agendaMedicaFiltrar(usuarioId: usuarioId, especialidadeId: especialidadeId)) else {
            throw MarcacaoServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        ApiConstants.aplicarToken(token, na: &request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MarcacaoServiceError.network(
                message: "Nao foi possivel carregar a agenda medica agora."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MarcacaoServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(MarcacaoApiErrorResponse.self, from: data)
            throw MarcacaoServiceError.server(
                message: apiError?.message ?? "A API nao conseguiu devolver a agenda medica. Codigo \(httpResponse.statusCode)."
            )
        }

        return try decodeAgendaMedica(data)
    }

    func criarMarcacao(
        _ marcacao: CriarMarcacaoRequest,
        token: String
    ) async throws -> MarcacaoConfirmadaResponse {
        guard marcacao.usuarioId.isEmpty == false,
              marcacao.pacienteId.isEmpty == false,
              marcacao.medicoId.isEmpty == false,
              marcacao.especialidadeId.isEmpty == false,
              marcacao.agendaMedicaId.isEmpty == false,
              marcacao.dataConsultas.isEmpty == false,
              marcacao.hora.isEmpty == false,
              marcacao.observacao.isEmpty == false,
              marcacao.codigoConfirmacao.isEmpty == false,
              marcacao.estado.isEmpty == false else {
            throw MarcacaoServiceError.marcacaoIncompleta
        }

        guard token.isEmpty == false else {
            throw MarcacaoServiceError.tokenAusente
        }

        guard let url = URL(string: Endpoints.marcacao) else {
            throw MarcacaoServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        ApiConstants.aplicarToken(token, na: &request)

        do {
            request.httpBody = try JSONEncoder().encode(marcacao)
        } catch {
            throw MarcacaoServiceError.invalidData
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MarcacaoServiceError.network(
                message: "Nao foi possivel confirmar o agendamento agora."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MarcacaoServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(MarcacaoApiErrorResponse.self, from: data)
            throw MarcacaoServiceError.server(
                message: apiError?.message ?? "A API nao conseguiu confirmar o agendamento. Codigo \(httpResponse.statusCode)."
            )
        }

        return try decodeMarcacaoConfirmada(data)
    }

    func buscarUltimaMarcacao(usuarioId: String, token: String) async throws -> MarcacaoHojeResponse? {
        guard usuarioId.isEmpty == false else {
            throw MarcacaoServiceError.usuarioAusente
        }

        guard token.isEmpty == false else {
            throw MarcacaoServiceError.tokenAusente
        }

        guard let url = URL(string: Endpoints.marcacaoUltima(usuarioId: usuarioId)) else {
            throw MarcacaoServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        ApiConstants.aplicarToken(token, na: &request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MarcacaoServiceError.network(
                message: "Nao foi possivel carregar as consultas agora. Confirma a ligacao."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MarcacaoServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(MarcacaoApiErrorResponse.self, from: data)
            throw MarcacaoServiceError.server(
                message: apiError?.message ?? "A API nao conseguiu devolver as consultas. Codigo \(httpResponse.statusCode)."
            )
        }

        return try decodeMarcacao(data)
    }

    func buscarMarcacoesFeitas(usuarioId: String, token: String) async throws -> [MarcacaoFeitaResponse] {
        guard usuarioId.isEmpty == false else {
            throw MarcacaoServiceError.usuarioAusente
        }

        guard token.isEmpty == false else {
            throw MarcacaoServiceError.tokenAusente
        }

        guard let url = URL(string: Endpoints.marcacoesFeitas(usuarioId: usuarioId)) else {
            throw MarcacaoServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        ApiConstants.aplicarToken(token, na: &request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MarcacaoServiceError.network(
                message: "Nao foi possivel carregar as consultas agora. Confirma a ligacao."
            )
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MarcacaoServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(MarcacaoApiErrorResponse.self, from: data)
            throw MarcacaoServiceError.server(
                message: apiError?.message ?? "A API nao conseguiu devolver as consultas. Codigo \(httpResponse.statusCode)."
            )
        }

        return try decodeMarcacoesFeitas(data)
    }

    private func decodeMarcacaoConfirmada(_ data: Data) throws -> MarcacaoConfirmadaResponse {
        let texto = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

        if texto == nil || texto == "" || texto == "null" {
            return MarcacaoConfirmadaResponse()
        }

        let decoder = JSONDecoder()

        if let direta = try? decoder.decode(MarcacaoConfirmadaResponse.self, from: data) {
            return direta
        }

        if let wrapper = try? decoder.decode(MarcacaoConfirmadaWrapperResponse.self, from: data),
           let marcacao = wrapper.marcacao {
            return marcacao
        }

        throw MarcacaoServiceError.invalidData
    }

    // A rota pode devolver objecto, lista, null com data errado.
    private func decodeMarcacao(_ data: Data) throws -> MarcacaoHojeResponse? {
        let texto = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

        if texto == nil || texto == "" || texto == "null" || texto == "[]" {
            return nil
        }

        let decoder = JSONDecoder()

        if let lista = try? decoder.decode([MarcacaoHojeResponse].self, from: data) {
            return lista.first { $0.temDados }
        }

        if let direta = try? decoder.decode(MarcacaoHojeResponse.self, from: data), direta.temDados {
            return direta
        }

        if let wrapper = try? decoder.decode(MarcacaoWrapperResponse.self, from: data) {
            return wrapper.marcacao?.temDados == true ? wrapper.marcacao : nil
        }

        throw MarcacaoServiceError.invalidData
    }

    private func decodeMarcacoesFeitas(_ data: Data) throws -> [MarcacaoFeitaResponse] {
        let texto = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

        if texto == nil || texto == "" || texto == "null" || texto == "[]" {
            return []
        }

        let decoder = JSONDecoder()

        if let lista = try? decoder.decode([MarcacaoFeitaResponse].self, from: data) {
            return lista.filter(\.temDados)
        }

        if let direta = try? decoder.decode(MarcacaoFeitaResponse.self, from: data), direta.temDados {
            return [direta]
        }

        if let wrapper = try? decoder.decode(MarcacoesFeitasWrapperResponse.self, from: data) {
            return wrapper.marcacoes.filter(\.temDados)
        }

        throw MarcacaoServiceError.invalidData
    }

    private func decodeAgendaMedica(_ data: Data) throws -> [AgendaMedicaResponse] {
        let texto = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

        if texto == nil || texto == "" || texto == "null" || texto == "[]" {
            return []
        }

        let decoder = JSONDecoder()

        if let lista = try? decoder.decode([AgendaMedicaResponse].self, from: data) {
            return lista
        }

        if let direta = try? decoder.decode(AgendaMedicaResponse.self, from: data) {
            return [direta]
        }

        if let wrapper = try? decoder.decode(AgendaMedicaWrapperResponse.self, from: data) {
            return wrapper.agendas
        }

        throw MarcacaoServiceError.invalidAgendaData
    }
}

// Ajuda a ler valores que podem vir em formatos diferentes.
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

    func decodeDateIfExists(forKeys keys: [K]) -> Date? {
        for key in keys {
            if let date = try? decode(Date.self, forKey: key) {
                return date
            }

            guard let value = try? decode(String.self, forKey: key) else {
                continue
            }

            if let date = ISO8601DateFormatter().date(from: value) {
                return date
            }

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

            if let date = formatter.date(from: value) {
                return date
            }

            formatter.dateFormat = "yyyy-MM-dd"

            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
    }

    func decodeStringArrayIfExists(forKeys keys: [K]) -> [String]? {
        for key in keys {
            if let values = try? decode([String].self, forKey: key) {
                let validos = values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
                if validos.isEmpty == false {
                    return validos
                }
            }

            if let values = try? decode([Int].self, forKey: key) {
                return values.map { String($0) }
            }

            if let values = try? decode([AgendaMedicaDiaDTO].self, forKey: key) {
                let validos = values.compactMap(\.nome)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
                if validos.isEmpty == false {
                    return validos
                }
            }

            if let value = try? decode(String.self, forKey: key) {
                let partes = value
                    .split { caractere in
                        caractere == "," || caractere == ";" || caractere == "|" || caractere == "/"
                    }
                    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }

                if partes.isEmpty == false {
                    return partes
                }
            }
        }

        return nil
    }
}
