//
//  TelaloingView.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import SwiftUI
import SwiftData

struct TelaLoginView: View {
    // Contexto usado para guardar o usuario no SwiftData.
    @Environment(\.modelContext) private var modelContext

    // Quando o login falhar, a splash pode ser chamada de novo.
    var onLoginFailure: (() -> Void)? = nil

    // Aqui definimos os campos onde o teclado pode ficar.
    private enum CampoLogin: Hashable {
        case email
        case senha
    }

    // Aqui ficam os dados temporario do utilizador digitados.
    @State private var usuario = ""
    @State private var senha = ""

    // Estes estados controlam o comportamento da tela.
    @State private var loading = false
    @State private var entrar = false
    @State private var mostrarRecuperarSenha = false
    @State private var mostrarRegistarUsuario = false
    @State private var lembrarMe = false
    @State private var mostrarSenha = false
    @State private var mensagemErro: String?

    // Seta o campo que está activo no momento.
    @FocusState private var campoAtivo: CampoLogin?

    // Cores mais usadas nesta tela.
    private let primaryColor = TemaStyles.primaryColor
    private let titleColor = TemaStyles.titleColor

    var body: some View {
        // Se o login chamar, abre a página principal.
        if entrar {
            MainPrincipalView {
                withAnimation(.easeInOut(duration: 0.25)) {
                    entrar = false
                    usuario = ""
                    senha = ""
                }
            }
        } else if mostrarRecuperarSenha {
            RecuperarSenha {
                withAnimation(.easeInOut(duration: 0.25)) {
                    mostrarRecuperarSenha = false
                }
            }
        } else if mostrarRegistarUsuario {
            RegistarUsuarios {
                withAnimation(.easeInOut(duration: 0.25)) {
                    mostrarRegistarUsuario = false
                }
            }
        } else {
            loginScreen
        }
    }

    // Montagem do fundo e centraliza o cards.
    private var loginScreen: some View {
        GeometryReader { proxy in
            ZStack {
                // Fundo solido para ficar mais parecido com app iOS.
                TemaStyles.backgroundColor
                .ignoresSafeArea()

                // Ajustar o formulário a não cortar em telemóveis pequenos.
                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 24)
                        loginCard
                        Spacer(minLength: 24)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                    .padding(.horizontal, TemaStyles.authHorizontalPadding)
                }
            }
        }
    }

    // A estrutura de todo o formulário.
    private var loginCard: some View {
        VStack(spacing: 28) {
            // Logo da aplicação.
            Image("famorIcon")
                .resizable()
                .scaledToFit()
                .frame(width: TemaStyles.logoWidth, height: TemaStyles.logoHeight)

            // Texto principal de boas-vindas.
            VStack(spacing: 6) {
                Text("Bem-vindo ao Centro\nMédico Famor")
                    .font(.system(size: TemaStyles.titleSize, weight: .bold, design: .rounded))
                    .foregroundStyle(titleColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("Digite seus dados da conta")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Aqui juntamos os campos e botões do formulário.
            VStack(alignment: .leading, spacing: TemaStyles.formSpacing) {
                emailField
                passwordField
                loginOptions

                if let mensagemErro {
                    errorMessage(mensagemErro)
                }

                enterButton
            }

            registerLink
        }
        .padding(.horizontal, TemaStyles.authCardHorizontalPadding)
        .padding(.vertical, TemaStyles.authCardVerticalPadding)
        .frame(maxWidth: TemaStyles.authCardMaxWidth)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.68), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.16), radius: 24, x: 0, y: 14)
        .shadow(color: primaryColor.opacity(0.12), radius: 0, x: 0, y: 8)
    }

    // Espaço para escrever o e-mail.
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("E-mail")

            inputContainer(isFocused: campoAtivo == .email) {
                HStack(spacing: 12) {
                    // O ícone ganha cor quando este campo está activo.
                    Image(systemName: "envelope")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(campoAtivo == .email ? primaryColor : .secondary)
                        .frame(width: 22)

                    TextField("Digite seu e-mail", text: $usuario)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                        .focused($campoAtivo, equals: .email)
                        .onSubmit {
                            // Quando carregar em Next, passa para a senha.
                            campoAtivo = .senha
                        }
                }
            }
        }
    }

    // Espaço para escrever a senha e escolher se quer ver ou esconder.
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Senha")

            inputContainer(isFocused: campoAtivo == .senha) {
                HStack(spacing: 12) {
                    // O ícone ganha cor quando este campo está activo.
                    Image(systemName: "lock")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(campoAtivo == .senha ? primaryColor : .secondary)
                        .frame(width: 22)

                    Group {
                        if mostrarSenha {
                            TextField("Digite sua senha", text: $senha)
                        } else {
                            SecureField("Digite sua senha", text: $senha)
                        }
                    }
                    .textContentType(.password)
                    .submitLabel(.go)
                    .focused($campoAtivo, equals: .senha)
                    .onSubmit {
                        // Também deixa entrar usando o teclado.
                        fazerLogin()
                    }

                    Button {
                        mostrarSenha.toggle()
                    } label: {
                        Text(mostrarSenha ? "Ocultar" : "Mostrar")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(primaryColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // Pequenas opções abaixo da senha.
    private var loginOptions: some View {
        HStack {
            Button {
                // Liga ou desliga o lembrar-me.
                lembrarMe.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: lembrarMe ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(lembrarMe ? primaryColor : .secondary)

                    Text("Lembrar-me")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 12)

            Button("Esqueceu a senha?") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    mostrarRecuperarSenha = true
                }
            }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(primaryColor)
        }
    }

    // Botão  entrar.
    private var enterButton: some View {
        Button {
            fazerLogin()
        } label: {
            HStack(spacing: 10) {
                // Enquanto espera, mostramos o loading.
                if loading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Entrar")
                }
            }
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: TemaStyles.buttonHeight)
            .background(
                LinearGradient(
                    colors: [
                        primaryColor,
                        Color(red: 0.02, green: 0.54, blue: 0.96)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .shadow(color: primaryColor.opacity(0.28), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(loading)
        .opacity(loading ? 0.82 : 1)
    }

    // botao para criar uma conta nova.
    private var registerLink: some View {
        HStack(spacing: 5) {
            Text("Ainda não tem conta?")
                .foregroundStyle(.secondary)

            Button("Novo registo") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    mostrarRegistarUsuario = true
                }
            }
                .fontWeight(.semibold)
                .foregroundStyle(primaryColor)
        }
        .font(.footnote)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
    }

    // Mostra erro quando a API nao aceitar o login.
    private func errorMessage(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.footnote.weight(.semibold))

            Text(message)
                .font(.footnote.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Color(red: 0.78, green: 0.12, blue: 0.12))
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 1.00, green: 0.91, blue: 0.91))
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
    }

    // apresentacao da visualizacao usado nos nomes dos campos.
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(titleColor.opacity(0.82))
    }

    // Caixa usada nos campos de texto.
    private func inputContainer<Content: View>(
        isFocused: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.horizontal, 16)
            .frame(height: TemaStyles.inputHeight)
            .background(TemaStyles.inputColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(isFocused ? primaryColor : TemaStyles.outlineColor, lineWidth: isFocused ? 1.6 : 1)
            }
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // Faz login na API e guarda o usuario localmente.
    func fazerLogin() {
        guard loading == false else { return }

        // Tira o foco do campo para fechar o teclado.
        campoAtivo = nil
        mensagemErro = nil
        loading = true

        Task {
            do {
                let controller = LoginController(modelContext: modelContext)
                _ = try await controller.autenticar(email: usuario, senha: senha)

                loading = false

                // Abre a pagina principal com uma transicao.
                withAnimation(.easeInOut(duration: 0.25)) {
                    entrar = true
                }
            } catch {
                loading = false
                mensagemErro = error.localizedDescription

                // Se for erro da API/rede, voltamos para a splash.
                if !(error is LoginControllerError) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        onLoginFailure?()
                    }
                }
            }
        }
    }
}


#Preview {
    TelaLoginView()
}
