//
//  RecuperarSenha.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import SwiftUI

struct RecuperarSenha: View {
    // Campos que podem receber foco na modal.
    private enum CampoRedefinir: Hashable {
        case codigo
        case novaSenha
        case confirmarSenha
    }

    // Usado para voltar para a tela de login.
    var onBack: (() -> Void)? = nil

    // Dados da primeira etapa.
    @State private var email = ""
    @State private var loading = false
    @State private var mensagemErro: String?

    // Dados da modal de nova senha.
    @State private var codigo = ""
    @State private var novaSenha = ""
    @State private var confirmarNovaSenha = ""
    @State private var redefinindo = false
    @State private var mostrarModalRedefinir = false
    @State private var mostrarNovaSenha = false
    @State private var mostrarConfirmarNovaSenha = false
    @State private var mensagemRedefinirSucesso: String?
    @State private var mensagemRedefinirErro: String?

    // Marca o campo activo no teclado.
    @FocusState private var emailAtivo: Bool
    @FocusState private var campoRedefinirAtivo: CampoRedefinir?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 24)
                        recoveryCard
                        Spacer(minLength: 24)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                    .padding(.horizontal, TemaStyles.authHorizontalPadding)
                }

                if mostrarModalRedefinir {
                    redefinirOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: mostrarModalRedefinir)
    }

    // Fundo claro igual ao estilo das telas de login.
    private var background: some View {
        TemaStyles.backgroundColor
            .ignoresSafeArea()
    }

    // Card principal da recuperacao de senha.
    private var recoveryCard: some View {
        VStack(alignment: .leading, spacing: 30) {
            backButton

            VStack(spacing: 28) {
                Image("famorIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: TemaStyles.logoWidth, height: TemaStyles.logoHeight)

                headerTexts
                formContent
            }
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
        .shadow(color: TemaStyles.primaryColor.opacity(0.12), radius: 0, x: 0, y: 8)
    }

    // Modal para definir a nova senha.
    private var redefinirOverlay: some View {
        ZStack {
            Color.black.opacity(0.36)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer(minLength: 36)
                    redefinirCard
                    Spacer(minLength: 36)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, TemaStyles.authHorizontalPadding)
            }
        }
    }

    // Card da modal com codigo e nova senha.
    private var redefinirCard: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text("Definir nova senha")
                    .font(.system(size: TemaStyles.titleSize, weight: .bold, design: .rounded))
                    .foregroundStyle(TemaStyles.titleColor)
                    .multilineTextAlignment(.center)

                Text("Coloca o codigo recebido no e-mail e define a tua nova senha.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: TemaStyles.formSpacing) {
                redefinirTextField(
                    placeholder: "Codigo de confirmacao",
                    systemImage: "number",
                    text: $codigo,
                    focus: .codigo,
                    submitLabel: .next
                ) {
                    campoRedefinirAtivo = .novaSenha
                }

                redefinirPasswordField(
                    placeholder: "Nova senha",
                    systemImage: "lock",
                    text: $novaSenha,
                    isVisible: $mostrarNovaSenha,
                    focus: .novaSenha,
                    submitLabel: .next
                ) {
                    campoRedefinirAtivo = .confirmarSenha
                }

                redefinirPasswordField(
                    placeholder: "Confirmar nova senha",
                    systemImage: "lock.fill",
                    text: $confirmarNovaSenha,
                    isVisible: $mostrarConfirmarNovaSenha,
                    focus: .confirmarSenha,
                    submitLabel: .send
                ) {
                    redefinirSenha()
                }

                if let mensagemRedefinirSucesso {
                    statusMessage(mensagemRedefinirSucesso, isError: false)
                }

                if let mensagemRedefinirErro {
                    statusMessage(mensagemRedefinirErro, isError: true)
                }

                updatePasswordButton
                modalCancelButton
            }
        }
        .padding(.horizontal, TemaStyles.authCardHorizontalPadding)
        .padding(.vertical, TemaStyles.authCardVerticalPadding)
        .frame(maxWidth: TemaStyles.authCardMaxWidth)
        .background(TemaStyles.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                .stroke(TemaStyles.outlineColor.opacity(0.72), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.28), radius: 28, x: 0, y: 18)
    }

    // Botao para voltar ao login.
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

    // Titulo e descricao da tela.
    private var headerTexts: some View {
        VStack(spacing: 10) {
            Text("Recuperar senha")
                .font(.system(size: TemaStyles.titleSize, weight: .bold, design: .rounded))
                .foregroundStyle(TemaStyles.titleColor)
                .multilineTextAlignment(.center)

            Text("Informe seu e-mail para receber o codigo de recuperacao.")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    // Campo, mensagens e botoes da primeira etapa.
    private var formContent: some View {
        VStack(alignment: .leading, spacing: TemaStyles.formSpacing) {
            emailField

            if let mensagemErro {
                statusMessage(mensagemErro, isError: true)
            }

            recoverButton
            cancelButton
        }
        .frame(maxWidth: .infinity)
    }

    // Campo onde o utilizador escreve o e-mail.
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("E-mail")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(TemaStyles.titleColor.opacity(0.72))

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(TemaStyles.primaryColor)
            }

            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(emailAtivo ? TemaStyles.primaryColor : .secondary)
                    .frame(width: 22)

                TextField("Digite seu e-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .submitLabel(.send)
                    .focused($emailAtivo)
                    .onSubmit {
                        recuperarSenha()
                    }
            }
            .inputContainer(isFocused: emailAtivo)
        }
    }

    // Botao azul que chama /senha/recuperar.
    private var recoverButton: some View {
        Button {
            recuperarSenha()
        } label: {
            HStack(spacing: 8) {
                if loading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Recuperar")
                    Image(systemName: "arrow.right")
                }
            }
            .primaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(loading)
        .opacity(loading ? 0.82 : 1)
    }

    // Botao para cancelar e voltar ao login.
    private var cancelButton: some View {
        Button {
            onBack?()
        } label: {
            Text("Cancelar")
                .secondaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(loading)
    }

    // Botao para chamar /senha/resetar.
    private var updatePasswordButton: some View {
        Button {
            redefinirSenha()
        } label: {
            HStack(spacing: 8) {
                if redefinindo {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Atualizar senha")
                }
            }
            .primaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(redefinindo)
        .opacity(redefinindo ? 0.82 : 1)
    }

    // Botao para fechar a modal.
    private var modalCancelButton: some View {
        Button {
            fecharModalRedefinir()
        } label: {
            Text("Cancelar")
                .secondaryButtonSurface()
        }
        .buttonStyle(.plain)
        .disabled(redefinindo)
    }

    // Campo normal usado para o codigo, porque deve ficar visivel.
    private func redefinirTextField(
        placeholder: String,
        systemImage: String,
        text: Binding<String>,
        focus: CampoRedefinir,
        submitLabel: SubmitLabel,
        onSubmit: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(campoRedefinirAtivo == focus ? TemaStyles.primaryColor : .secondary)
                .frame(width: 22)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.numberPad)
                .focused($campoRedefinirAtivo, equals: focus)
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
        }
        .inputContainer(isFocused: campoRedefinirAtivo == focus)
    }

    // Campo de senha com olho para mostrar ou ocultar.
    private func redefinirPasswordField(
        placeholder: String,
        systemImage: String,
        text: Binding<String>,
        isVisible: Binding<Bool>,
        focus: CampoRedefinir,
        submitLabel: SubmitLabel,
        onSubmit: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(campoRedefinirAtivo == focus ? TemaStyles.primaryColor : .secondary)
                .frame(width: 22)

            Group {
                if isVisible.wrappedValue {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($campoRedefinirAtivo, equals: focus)
            .submitLabel(submitLabel)
            .onSubmit(onSubmit)

            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(TemaStyles.primaryColor)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
        }
        .inputContainer(isFocused: campoRedefinirAtivo == focus)
    }

    // Mensagem de sucesso ou erro.
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

    // Chama a rota /senha/recuperar.
    private func recuperarSenha() {
        guard loading == false else { return }

        emailAtivo = false
        mensagemErro = nil
        loading = true

        Task {
            do {
                let controller = SenhaController()
                _ = try await controller.recuperarSenha(email: email)
                loading = false
                abrirModalRedefinir()
            } catch {
                mensagemErro = error.localizedDescription
                loading = false
            }
        }
    }

    // Chama a rota /senha/resetar.
    private func redefinirSenha() {
        guard redefinindo == false else { return }

        campoRedefinirAtivo = nil
        mensagemRedefinirErro = nil
        mensagemRedefinirSucesso = nil
        redefinindo = true

        Task {
            do {
                let controller = SenhaController()
                mensagemRedefinirSucesso = try await controller.redefinirSenha(
                    email: email,
                    codigo: codigo,
                    novaSenha: novaSenha,
                    confirmarNovaSenha: confirmarNovaSenha
                )
                redefinindo = false
                voltarParaLoginDepoisDoSucesso()
            } catch {
                mensagemRedefinirErro = error.localizedDescription
                redefinindo = false
            }
        }
    }

    // Abre a modal depois que o codigo foi enviado.
    private func abrirModalRedefinir() {
        codigo = ""
        novaSenha = ""
        confirmarNovaSenha = ""
        mostrarNovaSenha = false
        mostrarConfirmarNovaSenha = false
        mensagemRedefinirErro = nil
        mensagemRedefinirSucesso = nil

        withAnimation(.easeInOut(duration: 0.25)) {
            mostrarModalRedefinir = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            campoRedefinirAtivo = .codigo
        }
    }

    // Mostra o sucesso um pouco e depois volta para o login.
    private func voltarParaLoginDepoisDoSucesso() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            guard mensagemRedefinirSucesso != nil,
                  mensagemRedefinirErro == nil,
                  redefinindo == false else { return }

            withAnimation(.easeInOut(duration: 0.25)) {
                mostrarModalRedefinir = false
            }

            onBack?()
        }
    }

    // Fecha a modal e limpa os dados temporarios.
    private func fecharModalRedefinir() {
        campoRedefinirAtivo = nil
        codigo = ""
        novaSenha = ""
        confirmarNovaSenha = ""
        mostrarNovaSenha = false
        mostrarConfirmarNovaSenha = false
        mensagemRedefinirErro = nil
        mensagemRedefinirSucesso = nil

        withAnimation(.easeInOut(duration: 0.25)) {
            mostrarModalRedefinir = false
        }
    }
}

private extension View {
    // Visual padrao dos inputs desta tela.
    func inputContainer(isFocused: Bool) -> some View {
        self
            .padding(.horizontal, 16)
            .frame(height: TemaStyles.inputHeight)
            .background(TemaStyles.inputColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(isFocused ? TemaStyles.primaryColor : TemaStyles.outlineColor, lineWidth: isFocused ? 1.6 : 1)
            }
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // Visual do botao principal.
    func primaryButtonSurface() -> some View {
        self
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: TemaStyles.buttonHeight)
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
            .frame(height: TemaStyles.buttonHeight)
            .background(TemaStyles.secondaryButtonColor)
            .clipShape(RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TemaStyles.cornerRadius, style: .continuous)
                    .stroke(TemaStyles.outlineColor, lineWidth: 1)
            }
    }
}

#Preview {
    RecuperarSenha()
}
