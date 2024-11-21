import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'andamento.dart'; // Certifique-se de ter esses arquivos
import 'historico.dart'; // Importa a tela de histórico

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inicializa os bindings do Flutter
  await Firebase.initializeApp(); // Inicializa o Firebase
  runApp(MyApp()); // Inicia o aplicativo Flutter
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(), // Define a HomePage como tela inicial
      routes: {
        'HomeScreen': (context) => HomePage(), // Rota para a tela inicial
        'AndamentoScreen': (context) => AndamentoScreen(), // Rota para a tela de andamento
        'HistoricoScreen': (context) => HistoricoScreen(), // Rota para a tela de histórico
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // Cria o estado da HomePage
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(); // Controlador do carrossel de imagens
  int _currentPage = 0; // Página atual do carrossel

  // Navegação para a próxima página do carrossel
  void _nextPage() {
    if (_currentPage < 3) { // Verifica se não está na última página
      _currentPage++; // Avança para a próxima página
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300), // Duração da animação
        curve: Curves.easeInOut, // Curva de animação
      );
    }
  }

  // Navegação para a página anterior do carrossel
  void _previousPage() {
    if (_currentPage > 0) { // Verifica se não está na primeira página
      _currentPage--; // Retorna para a página anterior
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300), // Duração da animação
        curve: Curves.easeInOut, // Curva de animação
      );
    }
  }

  // Exibe um popup para inserir a data do curso
  void _showPopup(String courseName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController dateController = TextEditingController(); // Controlador para o campo de data

        return AlertDialog(
          title: Text(courseName), // Título do popup com o nome do curso
          content: Column(
            mainAxisSize: MainAxisSize.min, // Define o tamanho mínimo da coluna
            children: [
              TextField(
                controller: dateController, // Associa o controlador ao campo de texto
                decoration: InputDecoration(
                  labelText: 'Insira a data', // Rótulo do campo de texto
                  hintText: 'dd/mm/aaaa', // Dica sobre o formato da data
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String chosenDate = dateController.text; // Captura a data inserida

                // Referência do documento do curso
                DocumentReference courseRef = FirebaseFirestore.instance.collection('cursos').doc(courseName.replaceAll(' ', '_').toLowerCase());

                // Cria ou atualiza o documento do curso
                await courseRef.set({
                  'nome': courseName, // Armazena o nome do curso
                  'dataEscolhida': chosenDate // Adiciona a data escolhida
                }, SetOptions(merge: true)); // Usa merge para evitar substituição de dados existentes

                Navigator.of(context).pop(); // Fecha o popup
              },
              child: Text('Salvar data'), // Texto do botão para salvar a data
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCDADA), // Cor de fundo da tela
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1), // Cor da AppBar
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40), // Logo no título da AppBar
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {}, // Ação para o ícone de perfil
            icon: Icon(Icons.person), // Ícone de perfil
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              margin: EdgeInsets.all(8), // Margem ao redor do banner
              child: Image.asset('assets/Banner.png'), // Imagem do banner
            ),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Alinha os botões no centro
              children: [
                _buildIconButton('Cursos', Icons.book, () { // Botão para cursos
                  _showPopup('Curso de APP'); // Mostra popup ao clicar
                }),
                _buildIconButton('Andamento', Icons.edit, () { // Botão para andamento
                  Navigator.pushNamed(context, 'AndamentoScreen'); // Navega para a tela de andamento
                }),
                _buildIconButton('Histórico', Icons.school, () { // Botão para histórico
                  Navigator.pushNamed(context, 'HistoricoScreen'); // Navega para a tela de histórico
                }),
              ],
            ),
            SizedBox(height: 20), // Espaço entre os botões e o título do carrossel

            // Título do carrossel
            Padding(
              padding: const EdgeInsets.all(8.0), // Preenchimento ao redor do título
              child: Text(
                'CURSOS', // Título do carrossel
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Estilo do texto
              ),
            ),

            // Carrossel de imagens
            SizedBox(
              height: 200, // Altura do carrossel
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Alinha o carrossel no centro
                children: [
                  IconButton(
                    onPressed: _previousPage, // Botão para página anterior
                    icon: Icon(Icons.arrow_back), // Ícone de seta para trás
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController, // Controlador do carrossel
                      onPageChanged: (index) { // Atualiza a página atual
                        setState(() {
                          _currentPage = index; // Atualiza o índice da página atual
                        });
                      },
                      children: [
                        GestureDetector(
                          onTap: () => _showPopup('Curso de APP'), // Mostra popup ao tocar na imagem
                          child: Image.asset('assets/app.png'), // Imagem do curso de APP
                        ),
                        GestureDetector(
                          onTap: () => _showPopup('Curso de APQ'), // Mostra popup ao tocar na imagem
                          child: Image.asset('assets/apq.png'), // Imagem do curso de APQ
                        ),
                        GestureDetector(
                          onTap: () => _showPopup('Curso de WMS'), // Mostra popup ao tocar na imagem
                          child: Image.asset('assets/wms.png'), // Imagem do curso de WMS
                        ),
                        GestureDetector(
                          onTap: () => _showPopup('Curso de Office'), // Mostra popup ao tocar na imagem
                          child: Image.asset('assets/office.png'), // Imagem do curso de Office
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _nextPage, // Botão para próxima página
                    icon: Icon(Icons.arrow_forward), // Ícone de seta para frente
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função que cria um botão com ícone
  Widget _buildIconButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed, // Ação ao tocar no botão
          child: CircleAvatar(
            radius: 30, // Raio do círculo do botão
            backgroundColor: Colors.blue, // Cor de fundo do botão
            child: Icon(icon, color: Colors.white, size: 30), // Ícone do botão
          ),
        ),
        SizedBox(height: 8), // Espaço entre o botão e o texto
        Text(label), // Texto abaixo do botão
      ],
    );
  }
}
