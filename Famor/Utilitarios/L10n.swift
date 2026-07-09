//
//  L10n.swift
//  Famor
//
//  Created by Aluno ISTEC on 08/07/2026.
//

import Foundation

// Idiomas que o paciente pode escolher.
enum AppLanguage: String, CaseIterable, Identifiable {
    case portuguese = "pt"
    case english = "en"

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .portuguese:
            return "PT"
        case .english:
            return "EN"
        }
    }

    var title: String {
        switch self {
        case .portuguese:
            return "Português"
        case .english:
            return "English"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .portuguese:
            return "pt_AO"
        case .english:
            return "en_US"
        }
    }

    static var current: AppLanguage {
        let value = UserDefaults.standard.string(forKey: ApiConstants.languageKey)
        return AppLanguage(rawValue: value ?? "") ?? .portuguese
    }
}

// Tradutor simples usado nas telas.
enum L10n {
    static func tr(_ text: String, languageCode: String? = nil) -> String {
        let language = AppLanguage(rawValue: languageCode ?? "") ?? AppLanguage.current

        guard language == .english else {
            return text
        }

        return english[text] ?? text
    }

    static func format(_ text: String, languageCode: String? = nil, _ args: CVarArg...) -> String {
        String(format: tr(text, languageCode: languageCode), locale: Locale(identifier: AppLanguage.current.localeIdentifier), arguments: args)
    }

    private static let english: [String: String] = [
        "Bem-vindo ao Centro\nMédico Famor": "Welcome to Famor\nMedical Center",
        "Digite seus dados da conta": "Enter your account details",
        "Centro Médico Famor": "Famor Medical Center",
        "Cuidando da sua saúde": "Taking care of your health",
        "A carregar": "Loading",
        "Idioma": "Language",
        "E-mail": "Email",
        "Senha": "Password",
        "Digite seu e-mail": "Enter your email",
        "Digite sua senha": "Enter your password",
        "Ocultar": "Hide",
        "Mostrar": "Show",
        "Lembrar-me": "Remember me",
        "Esqueceu a senha?": "Forgot password?",
        "Entrar": "Sign in",
        "A entrar...": "Signing in...",
        "Ainda não tem conta?": "Don't have an account yet?",
        "Criar conta": "Create account",
        "Voltar": "Back",
        "Recuperar senha": "Recover password",
        "Informe seu e-mail para receber o codigo de recuperacao.": "Enter your email to receive the recovery code.",
        "Definir nova senha": "Set new password",
        "Coloca o codigo recebido no e-mail e define a tua nova senha.": "Enter the code received by email and set your new password.",
        "Codigo de confirmacao": "Confirmation code",
        "Nova senha": "New password",
        "Confirmar nova senha": "Confirm new password",
        "Cancelar": "Cancel",
        "Enviar codigo": "Send code",
        "Recuperar": "Recover",
        "Actualizar senha": "Update password",
        "Atualizar senha": "Update password",
        "Cadastro Centro\nMédico Famor": "Famor Medical Center\nRegistration",
        "Preencha seus dados para criar uma conta.": "Fill in your details to create an account.",
        "Verifique o seu e-mail": "Check your email",
        "Escreva o codigo recebido em": "Enter the code received at",
        "Nome": "Name",
        "Digite seu nome": "Enter your name",
        "Morada": "Address",
        "Digite sua morada": "Enter your address",
        "Data de Nascimento": "Date of Birth",
        "Digite o codigo": "Enter the code",
        "Cadastrar": "Register",
        "Verificar": "Verify",
        "Reenviar código": "Resend code",
        "Criar Conta": "Create Account",
        "Confirmar cadastro": "Confirm registration",
        "Reenviar codigo": "Resend code",
        "Inicio": "Home",
        "Agendar": "Book",
        "Consultas": "Visits",
        "Avisos": "Alerts",
        "Perfil": "Profile",
        "Bom dia,": "Good morning,",
        "Boa tarde,": "Good afternoon,",
        "Boa noite,": "Good evening,",
        "Paciente Famor": "Famor Patient",
        "Agendar Consulta": "Book Visit",
        "Marcar nova consulta": "Schedule a new visit",
        "Minhas Consultas": "My Visits",
        "Ver agendamentos": "View appointments",
        "Especialidades": "Specialties",
        "Explorar medicos": "Explore doctors",
        "Historico": "History",
        "Consultas anteriores": "Previous visits",
        "Consultas de Hoje": "Today's Visits",
        "A carregar consultas": "Loading visits",
        "Estamos a buscar a consulta agendada.": "Fetching the scheduled visit.",
        "Nao foi possivel carregar": "Could not load",
        "Ver todas": "View all",
        "Sem consulta agendada para hoje": "No visit scheduled for today",
        "Quando tiver consulta hoje, ela aparece aqui.": "When you have a visit today, it will appear here.",
        "Escolha a Especialidade": "Choose Specialty",
        "Agendamento Confirmado": "Appointment Confirmed",
        "A sua consulta foi marcada com sucesso": "Your visit was booked successfully",
        "Selecione a especialidade desejada": "Select the desired specialty",
        "Selecione uma area medica": "Select a medical area",
        "Escolha o Medico": "Choose Doctor",
        "Selecione o profissional": "Select the professional",
        "Data e Horario": "Date and Time",
        "Escolha quando deseja ser atendido": "Choose when you want to be attended",
        "Confirmar Agendamento": "Confirm Appointment",
        "Reveja os dados antes de confirmar": "Review the details before confirming",
        "Revise os dados antes de confirmar": "Review the details before confirming",
        "Passo": "Step",
        "de": "of",
        "Continuar": "Continue",
        "A carregar especialidades...": "Loading specialties...",
        "A carregar agenda medica...": "Loading medical schedule...",
        "Sem agenda disponivel": "No schedule available",
        "Nao encontramos medicos para esta especialidade agora.": "We could not find doctors for this specialty right now.",
        "Horarios em": "Times on",
        "Observações (opcional)": "Notes (optional)",
        "Descreva sintomas ou informações relevantes...": "Describe symptoms or relevant information...",
        "Descreva sintomas ou informações\nrelevantes...": "Describe symptoms or relevant\ninformation...",
        "A confirmar...": "Confirming...",
        "Novo Agendamento": "New Appointment",
        "Consulta Agendada!": "Visit Scheduled!",
        "Seu agendamento foi realizado com sucesso": "Your appointment was successfully completed",
        "Medico": "Doctor",
        "Especialidade": "Specialty",
        "Data": "Date",
        "Horario": "Time",
        "Código de Confirmação": "Confirmation Code",
        "Codigo de Confirmacao": "Confirmation Code",
        "Apresente este código na recepção": "Show this code at reception",
        "Ver Consultas": "View Visits",
        "Voltar ao Início": "Back to Home",
        "Filtrar por estado": "Filter by status",
        "Todas": "All",
        "Abertas": "Open",
        "Agendadas": "Scheduled",
        "Canceladas": "Cancelled",
        "Concluidas": "Completed",
        "Limpar": "Clear",
        "A carregar consultas...": "Loading visits...",
        "Tentar novamente": "Try again",
        "Nenhuma consulta encontrada": "No visits found",
        "Quando houver consultas neste filtro, elas aparecem aqui.": "When there are visits in this filter, they will appear here.",
        "A mostrar consultas guardadas no telemovel.": "Showing visits saved on the phone.",
        "Editar": "Edit",
        "Cancelar consulta": "Cancel visit",
        "Escolha uma area para marcar consulta": "Choose an area to book a visit",
        "Ver agenda": "View schedule",
        "A mostrar especialidades guardadas no telemovel.": "Showing specialties saved on the phone.",
        "Sem especialidades": "No specialties",
        "Nao encontramos especialidades disponiveis agora.": "We could not find available specialties right now.",
        "A buscar dados do perfil...": "Loading profile data...",
        "A actualizar dados pela API...": "Updating data from the API...",
        "Sem internet ou servidor indisponivel. A mostrar os dados guardados no telemovel.": "No internet or server unavailable. Showing data saved on the phone.",
        "Nao foi possivel guardar o perfil no telemovel.": "Could not save the profile on the phone.",
        "Perfil carregado, mas nao foi possivel guardar no telemovel.": "Profile loaded, but it could not be saved on the phone.",
        "Nao foi possivel terminar a sessao agora.": "Could not sign out right now.",
        "Informações": "Information",
        "Função": "Role",
        "Data de registo": "Registration date",
        "Terminar Sessao": "Sign Out",
        "Total": "Total",
        "Nao informado": "Not provided",
        "email nao informado": "email not provided",
        "Pacientes": "Patients"
    ]
}
