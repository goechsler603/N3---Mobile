import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/main.dart';

class PerfilScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para desconectar o usuário
  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Redirecionar para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } catch (e) {
      print('Erro ao desconectar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(user.photoURL ?? 'https://www.w3schools.com/howto/img_avatar.png'),
            ),
            SizedBox(height: 16),
            Text(
              user.displayName ?? 'Nome não disponível',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(user.email ?? 'E-mail não disponível'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('Desconectar'),
              style: ElevatedButton.styleFrom(iconColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
