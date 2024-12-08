# N3-Mobile

### App de autenticação no Google, com Flutter e Firebase
### Desenvolvido por: Guilherme Oechsler, Jeliel Flores Moura e José Mateus Coelho Loose.

## Listagem de funções por tela

### Tela Home

- Exibe um icone que leva para o perfil do usuário.
- Três botões de navegação referente aos cursos as opcões são: CURSOS, EM ANDAMENTO e HISTÓRICO.
- Um carrossel com os cursos disponíveis.

### Tela de Andamento dos cursos

- Vai buscar informações no banco de dados e mostrar o andamento do(s) curso(s) que o usuário está realizando, caso houver.

### Tela Histórico

- Vai buscar informações no banco de dados e mostrar o(s) curso(s) que o usuário concluiu, caso houver.

### Tela de Login

- Descrição:
    - Botão que chama signInWithGoogle ao ser pressionado.
    - Tenta autenticar o usuário via Google utilizando o FirebaseAuth e GoogleSignIn.
    - Realiza a autenticação por meio de credenciais obtidas no Google (accessToken e idToken).
    - Se a autenticação for bem-sucedida redireciona o usuário para a tela de perfil (PerfilScreen).
    - Caso contrário exibe mensagens no console para ajudar no diagnóstico de falhas.

- Passo a passo no código:
    - Usa GoogleSignIn para iniciar o fluxo de login.
    - Obtém a autenticação do Google (GoogleSignInAuthentication).
    - Gera credenciais do Firebase (GoogleAuthProvider.credential).
    - Finaliza o login no Firebase com signInWithCredential.
    - Navega para a tela de perfil com Navigator.pushReplacement

## Listagem de dependências utilizadas

- cloud_firestore: ^5.4.4
- firebase_core: ^3.8.1
- firebase_auth: ^5.3.4
- cupertino_icons: ^1.0.8
- google_sign_in: ^6.2.2

### Versões utilizadas do Flutter e Dart

- Flutter 3.24.3 
- Dart 3.5.3

### Versão mínima do SDK

- Versão: 3.24.3
