import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'andamento.dart';  // Certifique-se de ter esses arquivos
import 'historico.dart';
import 'perfil.dart'; // Tela de perfil

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Inicializa o Firebase
  
  // Desconectar do Google sempre que o app iniciar
  await _logoutGoogle();
  
  runApp(MyApp());
}

Future<void> _logoutGoogle() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Verifica se o usuário está logado e faz o logout
  if (await _googleSignIn.isSignedIn()) {
    await _googleSignIn.signOut();
  }

  // Logout do Firebase Auth
  await _auth.signOut();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      routes: {
        'HomeScreen': (context) => HomePage(),
        'AndamentoScreen': (context) => AndamentoScreen(),
        'HistoricoScreen': (context) => HistoricoScreen(),
        'PerfilScreen': (context) => PerfilScreen(),
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Função para fazer login com o Google
  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;  // Se o usuário cancelar o login
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Realiza o login no Firebase
      await _auth.signInWithCredential(credential);

      // Navega para a HomePage após o login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      print("Erro no login com o Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login com Google')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _loginWithGoogle(context),
          child: Text('Entrar com o Google'),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Navegação para a próxima página
  void _nextPage() {
    if (_currentPage < 3) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navegação para a página anterior
  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Função para exibir o popup de data
  void _showPopup(String courseName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController dateController = TextEditingController();

        return AlertDialog(
          title: Text(courseName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Insira a data',
                  hintText: 'dd/mm/aaaa',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String chosenDate = dateController.text;

                DocumentReference courseRef = FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(courseName.replaceAll(' ', '_').toLowerCase());

                await courseRef.set({
                  'nome': courseName,
                  'dataEscolhida': chosenDate,
                }, SetOptions(merge: true));

                Navigator.of(context).pop();
              },
              child: Text('Salvar data'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCDADA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, 'PerfilScreen');
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(8),
              child: Image.asset('assets/Banner.png'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton('Cursos', Icons.book, () {
                  _showPopup('Curso de APP');
                }),
                _buildIconButton('Andamento', Icons.edit, () {
                  Navigator.pushNamed(context, 'AndamentoScreen');
                }),
                _buildIconButton('Histórico', Icons.school, () {
                  Navigator.pushNamed(context, 'HistoricoScreen');
                }),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'CURSOS',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _previousPage,
                    icon: Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        GestureDetector(
                          onTap: () => _showPopup('Curso de APP'),
                          child: Image.asset('assets/app.png'),
                        ),
                        GestureDetector(
                          onTap: () => _showPopup('Curso de APQ'),
                          child: Image.asset('assets/apq.png'),
                        ),
                        GestureDetector(
                          onTap: () => _showPopup('Curso de WMS'),
                          child: Image.asset('assets/wms.png'),
                        ),
                        GestureDetector(
                          onTap: () => _showPopup('Curso de Office'),
                          child: Image.asset('assets/office.png'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _nextPage,
                    icon: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para criar botões com ícones
  Widget _buildIconButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
