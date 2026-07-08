//
//  SplashView.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import SwiftUI

struct SplashView: View {
    // Estado da splash.
    @State private var isLoading = true
    @State private var animateContent = false

    var body: some View {
        ZStack {
            // Decide qual tela mostrar.
            if isLoading {
                splashContent
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                TelaLoginView(onLoginFailure: reiniciarSplash)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: isLoading)
        .onAppear {
            iniciarSplash()
        }
    }

    // Layout visual da splash.
    private var splashContent: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.98, blue: 0.98),
                    Color(red: 0.84, green: 0.94, blue: 0.95),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.teal.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 28)
                .offset(x: -120, y: -260)

            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 34)
                .offset(x: 150, y: 260)

            VStack(spacing: 28) {
                Image("famorIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 156, height: 156)
                    .padding(24)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: Color.black.opacity(0.14), radius: 28, x: 0, y: 18)

                VStack(spacing: 8) {
                    Text("Centro Médico Famor")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.05, green: 0.24, blue: 0.25))

                    Text("Cuidando da sua saúde")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    ProgressView()
                        .tint(Color.teal)

                    Text("A carregar")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.thinMaterial)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .scaleEffect(animateContent ? 1 : 0.92)
            .opacity(animateContent ? 1 : 0)
        }
    }

    // Comeca o loading e depois abre sempre a tela de login.
    private func iniciarSplash() {
        animateContent = false
        isLoading = true

        withAnimation(.spring(response: 0.7, dampingFraction: 0.82)) {
            animateContent = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isLoading = false
        }
    }

    // Se o login falhar, voltamos a mostrar a splash.
    private func reiniciarSplash() {
        iniciarSplash()
    }
}

#Preview {
    SplashView()
}
