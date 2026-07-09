# ProjectoMobileiOS-AdilsonConceicao
Projecto iOS

As notas do projectos para execuçao sao:

1. Conta de usuario: 
E-mail: root@famor.com
senha: root

2. Caso for necessario executar API devem alterar duas coisa no backend
- No ficheiro env. para alterar endereço do email para cliente receba os codigos.
- Alterar no frontend, Endpoints para fazer alteraçao do ip da maquina.

Tecnologias Utilizadas

As principais tecnologias usadas no projecto são:

• Swift: linguagem principal usada no desenvolvimento da aplicação iOS.
• SwiftUI: framework usada para criar as telas e componentes visuais.
• SwiftData: usado para armazenamento local dos dados no telemóvel.
• URLSession com async/await: usado para fazer chamadas HTTP à API.
• API REST: permite a comunicação entre a app iOS e o backend.
• JSON / Codable: usado para enviar e receber dados da API.
• UserDefaults: usado para guardar dados simples, como token, sessão e idioma escolhido.
• Xcode / iOS SDK: ambiente usado para desenvolver, testar e compilar a aplicação.
• SF Symbols: biblioteca de ícones usada nas interfaces da app.
• Node.js: tecnologia usada no backend da API.
• JWT: usado para autenticação e proteção das rotas.
• Prisma ORM: usado no backend para acesso aos dados.
• MongoDB: base de dados usada para guardar as informações do sistema.


Armazenamento Local

O armazenamento local foi implementado com SwiftData, principalmente na pasta Persistences e nos modelos locais da pasta Model.

Principais ficheiros:

• SwiftDataManager.swift: configura os modelos usados pelo SwiftData.
• UsuarioRepository.swift: guarda e lê o utilizador autenticado.
• PerfilRepository.swift: guarda dados do perfil para uso offline.
• EspecialidadeRepository.swift: guarda especialidades localmente.
• MarcacaoRascunhoRepository.swift: guarda os dados temporários da marcação.
• MarcacaoFeitaRepository.swift: guarda consultas feitas para consulta offline.

Modelos usados no armazenamento local:

• UsuarioModel.swift
• PerfilLocalModel.swift
• EspecialidadeLocalModel.swift
• MarcacaoRascunhoLocalModel.swift
• MarcacaoFeitaLocalModel.swift

Conversão de Português para Inglês

A tradução PT/EN foi implementada no ficheiro:

• L10n.swift

Neste ficheiro foi criado um tradutor simples com o enum AppLanguage e a função L10n.tr(...), que recebe um texto em português e devolve a tradução em inglês quando o idioma escolhido for EN.

A escolha do idioma é guardada em:

• ApiConstants.swift, através da chave languageKey
• UserDefaults, usando @AppStorage

A seleção do idioma foi colocada na tela de login:

• TelaLoginView.swift

Depois da escolha PT | EN, as principais telas usam a função t(...), que chama L10n.tr(...) para apresentar os textos no idioma selecionado.
