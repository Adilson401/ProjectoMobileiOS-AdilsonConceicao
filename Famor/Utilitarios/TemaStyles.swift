//
//  TemaStyles.swift
//  Famor
//
//  Created by Aluno ISTEC on 04/07/2026.
//

import SwiftUI

// Aqui ficam cores e medidas usadas nas telas da app.
enum TemaStyles {
    // Azul principal dos botoes e links.
    static let primaryColor = Color(red: 0.03, green: 0.42, blue: 0.95)

    // Cor forte usada nos titulos.
    static let titleColor = Color(red: 0.08, green: 0.10, blue: 0.18)

    // Fundo claro das telas de autenticacao.
    static let backgroundColor = Color(red: 0.90, green: 0.97, blue: 0.95)

    // Superficie solida usada nos cards.
    static let surfaceColor = Color(red: 0.96, green: 0.99, blue: 0.98)

    // Cor dos campos de texto.
    static let inputColor = Color(red: 0.91, green: 0.97, blue: 0.96)

    // Cor do botao secundario.
    static let secondaryButtonColor = Color(red: 0.94, green: 0.98, blue: 0.97)

    // Linha suave para separar superficies.
    static let outlineColor = Color(red: 0.73, green: 0.86, blue: 0.84)

    // Cantos usados nos cards e inputs.
    static let cornerRadius: CGFloat = 10

    // Largura maxima dos formularios em iPhone grande e iPad.
    static let authCardMaxWidth: CGFloat = 620

    // Espacos usados para o formulario respirar melhor no tela.
    static let authHorizontalPadding: CGFloat = 20
    static let authCardHorizontalPadding: CGFloat = 34
    static let authCardVerticalPadding: CGFloat = 44

    // Alturas padrao dos campos e botoes.
    static let inputHeight: CGFloat = 68
    static let buttonHeight: CGFloat = 66

    // Tamanhos principais das telas de autenticacao.
    static let logoWidth: CGFloat = 150
    static let logoHeight: CGFloat = 98
    static let titleSize: CGFloat = 25
    static let formSpacing: CGFloat = 22
}
