import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para iniciar o login
  Future<User?> signInWithGoogle() async {
    try {
      // Iniciar o Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // O usuário cancelou o login
      }

      // Obter o token de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Criar credenciais com o token de acesso e ID
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Realizar o login no Firebase com as credenciais
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user; // Retorna o usuário autenticado
    } catch (e) {
      print("Erro durante o login com o Google: $e");
      return null;
    }
  }

  // Método para desconectar
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login com Google')),
      body: Center(
        child: ElevatedButton(
        onPressed: () async {
  print("Botão pressionado");
  final user = await signInWithGoogle();
  if (user != null) {
    print('Login bem-sucedido: ${user.displayName}');
  } else {
    print('Login cancelado ou falhou');
  }
},

          child: Text('Entrar com o Google'),
        ),
      ),
    );
  }
}