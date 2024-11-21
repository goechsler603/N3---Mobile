import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCDADA), // Cor de fundo da tela
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1), // Cor da AppBar
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40), // Logo na AppBar
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {}, // Ação do botão do usuário
            icon: Icon(Icons.person), // Ícone do botão do usuário
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

            // Botões de navegação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuição dos botões
              children: [
                _buildIconButton('Cursos', Icons.book, () {
                  Navigator.pushReplacementNamed(context, '/'); // Volta para Home
                }),
                _buildIconButton('Andamento', Icons.edit, () {
                  Navigator.pushNamed(context, 'AndamentoScreen'); // Navega para AndamentoScreen
                }),
                _buildIconButton('Histórico', Icons.school, () {}), // Botão atual, sem ação
              ],
            ),
            SizedBox(height: 20), // Espaçamento entre os botões e o título

            // Título do Histórico de cursos
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'HISTÓRICO', // Título exibido
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Estilo do título
              ),
            ),

            // StreamBuilder para exibir cursos concluídos
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('cursos_concluidos').snapshots(), // Conexão com a coleção de cursos concluídos
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Indicador de carregamento
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhum curso concluído.')); // Mensagem se não houver cursos
                }

                // Exibe cada curso em um bloco
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>; // Obtém os dados do documento
                    if (!data.containsKey('nome')) {
                      return Text('Dados inválidos para este curso.'); // Verifica se o campo 'nome' existe
                    }
                    return _buildCourseCard(data['nome']); // Cria o cartão para o curso
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir o cartão do curso
  Widget _buildCourseCard(String courseName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Margens do cartão
      padding: EdgeInsets.all(16), // Espaçamento interno do cartão
      decoration: BoxDecoration(
        color: Colors.white, // Cor de fundo do cartão
        borderRadius: BorderRadius.circular(8), // Bordas arredondadas
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Sombra do cartão
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuição dos itens no cartão
        children: [
          Text(
            courseName, // Nome do curso
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Estilo do texto
          ),
        ],
      ),
    );
  }

  // Função para construir o botão de navegação
  Widget _buildIconButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed, // Ação ao pressionar o botão
          child: CircleAvatar(
            radius: 30, // Raio do botão
            backgroundColor: Colors.blue, // Cor de fundo do botão
            child: Icon(icon, color: Colors.white, size: 30), // Ícone do botão
          ),
        ),
        SizedBox(height: 8), // Espaçamento entre o botão e o rótulo
        Text(label), // Rótulo do botão
      ],
    );
  }
}
