//
//  RegistarUsuarios.swift
//  Famor
//
//  Created by Aluno ISTEC on 05/07/2026.
//

import SwiftUI

struct RegistarUsuarios: View {
    // Usado para voltar para a tela de login.
    var onBack: (() -> Void)? = nil

    // Campos que podem receber foco no formulario.
    private enum CampoCadastro: Hashable {
        case nome
        case morada
        case email
        case dataNascimento
        case senha
        case codigo
    }

    // Dados escritos pelo utilizador.
    @State private var nome = ""
    @State private var morada = ""
    @State private var email = ""
    @State private var dataNascimento = ""
    @State private var senha = ""
    @State private var codigoConfirmacao = ""

    // Estados para controlar a tela.
    @State private var loading = false
    @State private var mostrarSenha = false
    @State private var mostrarConfirmacao = false
    @State private var mensagemErro: String?
    @State private var mensagemSucesso: String?

    // Campo que esta activo no teclado.
    @FocusState private var campoAtivo: CampoCadastro?

    // Medidas desta tela, porque o formulario tem mais campos.
    private let cadastroInputHeight: CGFloat = 56
    private let cadastroFormSpacing: CGFloat = 16
    private let cadastroCardPadding: CGFloat = 28

    var body: some View {
        ZStack {
            TemaStyles.backgroundColor
                .ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        cardAtual
                            .padding(.horizontal, TemaStyles.authHorizontalPadding)
                            .padding(.top, 16)
                            .padding(.bottom, 110)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: campoAtivo) { _, novoCampo in
                    rolarParaCampo(novoCampo, usando: scrollProxy)
                }
            }
        }
    }

    // Decide se mostra cadastro ou confirmacao do e-mail.
    private var cardAtual: some View {
        Group {
            if mostrarConfirmacao {
                confirmacaoCard
            } else {
                cadastroCard
            }
        }
    }

    // Card principal do cadastro.
    private var cadastroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            backButton

            headerTexts

            VStack(alignment: .leading, spacing: cadastroFormSpacing) {
                nomeField
                    .id(CampoCadastro.nome)
                moradaField
                    .id(CampoCadastro.morada)
                emailField
                    .id(CampoCadastro.email)
                dataNascimentoField
                    .id(CampoCadastro.dataNascimento)
                senhaField
                    .id(CampoCadastro.senha)

                if let mensagemErro {
                    statusMessage(mensagemErro, isError: true)
                }

                if let mensagemSucesso {
                    statusMessage(mensagemSucesso, isError: false)
                }

                cadastrarButton
                cancelarButton
            }
        }
        .padding(.horizontal, cadastroCardPadding)
        .padding(.vertical, cadastroCardPadding)
        .frame(maxWidth: TemaStyles.authCardMaxWidth)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.68), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.16), radius: 24, x: 0, y: 14)
        .shadow(color: TemaStyles.primaryColor.opacity(0.12), radius: 0, x: 8, y: 8)
    }

    // Card usado para confirmar o codigo recebido por e-mail.
    private var confirmacaoCard: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Verifique o seu e-mail")
                    .font(.system(size: TemaStyles.titleSize, weight: .bold, design: .rounded))
                    .foregroundStyle(TemaStyles.titleColor)
                    .multilineTextAlignment(.center)

                Text("Escreva o codigo recebido em \(email.trimmingCharacters(in: .whitespacesAndNewlines)).")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                codigoField
                    .id(CampoCadastro.codigo)

                if let mensagemErro {
                    statusMessage(mensagemErro, isError: true)
                }

                if let mensagemSucesso {
                    statusMessage(mensagemSucesso, isError: false)
                }

                verificarButton
                reenviarCodigoButton
                cancelarButton
            }
        }
        .padding(.horizontal, cadastroCardPadding)
        .padding(.vertical, cadastroCardPadding)
        .frame(maxWidth: TemaStyles.authCardMaxWidth)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.68), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.16), radius: 24, x: 0, y: 14)
        .shadow(color: TemaStyles.primaryColor.opacity(0.12), radius: 0, x: 8, y: 8)
    }

    // Botao para voltar sem cadastrar.
    private var backButton: some View {
        Button {
            onBack?()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left")
                Text("Voltar")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(TemaStyles.primaryColor)
        }
        .buttonStyle(.plain)
    }

    // Titulo e texto curto da tela.
    private var headerTexts: some View {
        VStack(spacing: 8) {
            Text("Cadastro Centro\nMédico Famor")
                .font(.system(size: TemaStyles.titleSize, weight: .bold, design: .rounded))
                .foregroundStyle(TemaStyles.titleColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("Preencha seus dados para criar uma conta.")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // Campo do nome completo.
    private var nomeField: some View {
        campoTexto(
            titulo: "Nome",
            placeholder: "Digite seu nome",
            text: $nome,
            focus: .nome,
            keyboard: .default,
            submitLabel: .next
        ) {
            campoAtivo = .morada
        }
    }

    // Campo da morada do utilizador.
    private var moradaField: some View {
        campoTexto(
            titulo: "Morada",
            placeholder: "Digite sua morada",
            text: $morada,
            focus: .morada,
            keyboard: .default,
            submitLabel: .next
        ) {
            campoAtivo = .email
        }
    }

    // Campo do e-mail.
    private var emailField: some View {
        campoTexto(
            titulo: "E-mail",
            placeholder: "Digite seu e-mail",
            text: $email,
            focus: .email,
            keyboard: .emailAddress,
            submitLabel: .next
        ) {
            campoAtivo = .dataNascimento
        }
        .textInputAutocapitalization(.never)
    }

    // Campo da data no formato pedido pela API.
    private var dataNascimentoField: some View {
        campoTexto(
            titulo: "Data de Nascimento",
            placeholder: "YYYY-MM-DD",
            text: $dataNascimento,
            focus: .dataNascimento,
            keyboard: .numbersAndPunctuation,
            submitLabel: .next
        ) {
            campoAtivo = .senha
        }
    }

    // Campo da senha com opcao de mostrar.
    private var senhaField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Senha")

            inputContainer(isFocused: campoAtivo == .senha) {
                HStack(spacing: 12) {
                    Group {
                        if mostrarSenha {
                            TextField("Digite sua senha", text: $senha)
                        } else {
                            SecureField("Digite sua senha", text: $senha)
                        }
                    }
                    .textContentType(.newPassword)
                    .submitLabel(.send)
                    .focused($campoAtivo, equals: .senha)
                    .onSubmit {
                        cadastrarUsuario()
                    }

                    Button {
                        mostrarSenha.toggle()
                    } label: {
                        Text(mostrarSenha ? "Ocultar" : "Mostrar")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(TemaStyles.primaryColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // Campo do codigo enviado por e-mail.
    private var codigoField: some View {
        inputContainer(isFocused: campoAtivo == .codigo) {
            TextField("Digite o codigo", text: $codigoConfirmacao)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($campoAtivo, equals: .codigo)
                .submitLabel(.send)
                .onSubmit {
                    confirmarCodigo()
                }
        }
    }

    // Botao azul que chama /api/usuarios.
    private var cadastrarButton: some View {
        Button {
            cadastrarUsuario()
        } label: {
            HStack(spacing: 8) {
                if loading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Cadastrar")
                    Image(systemName: "arrow.right")
                }
            }
            .primaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(loading)
        .opacity(loading ? 0.82 : 1)
    }

    // Botao para confirmar o codigo na API.
    private var verificarButton: some View {
        Button {
            confirmarCodigo()
        } label: {
            HStack(spacing: 8) {
                if loading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Verificar")
                }
            }
            .primaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(loading)
        .opacity(loading ? 0.82 : 1)
    }

    // Botao para pedir outro codigo.
    private var reenviarCodigoButton: some View {
        Button {
            reenviarCodigo()
        } label: {
            HStack(spacing: 8) {
                Text("Reenviar código")
                Image(systemName: "arrow.clockwise")
            }
            .secondaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(loading)
    }

    // Botao para cancelar o cadastro.
    private var cancelarButton: some View {
        Button {
            onBack?()
        } label: {
            Text("Cancelar")
                .secondaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(loading)
    }

    // Campo simples usado nos dados do cadastro.
    private func campoTexto(
        titulo: String,
        placeholder: String,
        text: Binding<String>,
        focus: CampoCadastro,
        keyboard: UIKeyboardType,
        submitLabel: SubmitLabel,
        onSubmit: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(titulo)

            inputContainer(isFocused: campoAtivo == focus) {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled()
                    .focused($campoAtivo, equals: focus)
                    .submitLabel(submitLabel)
                    .onSubmit(onSubmit)
            }
        }
    }

    // Texto pequeno acima dos campos.
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(TemaStyles.titleColor.opacity(0.82))
    }

    // Caixa visual de cada input.
    private func inputContainer<Content: View>(
        isFocused: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.horizontal, 16)
            .frame(height: cadastroInputHeight)
            .background(TemaStyles.inputColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(isFocused ? TemaStyles.primaryColor : TemaStyles.outlineColor, lineWidth: isFocused ? 1.6 : 1)
            }
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // Mostra mensagem da API ou validacao local.
    private func statusMessage(_ text: String, isError: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .font(.footnote.weight(.semibold))

            Text(text)
                .font(.footnote.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(isError ? Color(red: 0.78, green: 0.12, blue: 0.12) : Color(red: 0.04, green: 0.48, blue: 0.28))
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isError ? Color(red: 1.00, green: 0.93, blue: 0.93) : Color(red: 0.91, green: 0.98, blue: 0.94))
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
    }

    // Leva o campo activo para uma zona visivel da tela.
    private func rolarParaCampo(_ campo: CampoCadastro?, usando scrollProxy: ScrollViewProxy) {
        guard let campo else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeInOut(duration: 0.25)) {
                let posicao: UnitPoint = campo == .senha ? .top : .center
                scrollProxy.scrollTo(campo, anchor: posicao)
            }
        }
    }

    // Faz cadastro na API.
    private func cadastrarUsuario() {
        guard loading == false else { return }

        campoAtivo = nil
        mensagemErro = nil
        mensagemSucesso = nil
        loading = true

        Task {
            do {
                let controller = UsuarioController()
                mensagemSucesso = try await controller.registarUsuario(
                    nome: nome,
                    morada: morada,
                    email: email,
                    dataNascimento: dataNascimento,
                    senha: senha
                )
                codigoConfirmacao = ""
                loading = false

                withAnimation(.easeInOut(duration: 0.25)) {
                    mostrarConfirmacao = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    campoAtivo = .codigo
                }
            } catch {
                mensagemErro = error.localizedDescription
                loading = false
            }
        }
    }

    // Confirma o codigo na rota /usuarios/confirmar.
    private func confirmarCodigo() {
        guard loading == false else { return }

        campoAtivo = nil
        mensagemErro = nil
        mensagemSucesso = nil
        loading = true

        Task {
            do {
                let controller = UsuarioController()
                mensagemSucesso = try await controller.confirmarCadastro(
                    email: email,
                    codigo: codigoConfirmacao
                )
                loading = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    onBack?()
                }
            } catch {
                mensagemErro = error.localizedDescription
                loading = false
            }
        }
    }

    // Pede outro codigo usando os mesmos dados do cadastro.
    private func reenviarCodigo() {
        cadastrarUsuario()
    }
}

private extension View {
    // Visual do botao principal.
    func primaryButtonSurface() -> some View {
        self
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(TemaStyles.primaryColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .shadow(color: TemaStyles.primaryColor.opacity(0.28), radius: 14, x: 0, y: 8)
    }

    // Visual do botao secundario.
    func secondaryButtonSurface() -> some View {
        self
            .font(.headline.weight(.semibold))
            .foregroundStyle(TemaStyles.titleColor.opacity(0.72))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(TemaStyles.secondaryButtonColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(TemaStyles.outlineColor, lineWidth: 1)
            }
    }
}

#Preview {
    RegistarUsuarios()
}
