import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AndamentoScreen extends StatelessWidget {
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
            // Banner
            Container(
              margin: EdgeInsets.all(8), // Margem ao redor do banner
              child: Image.asset('assets/Banner.png'), // Imagem do banner
            ),

            // Botões de navegação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Alinha os botões no centro
              children: [
                _buildIconButton('Cursos', Icons.book, () {
                  Navigator.pushReplacementNamed(context, '/'); // Volta para a Home
                }),
                _buildIconButton('Andamento', Icons.edit, () {}), // Botão atual, sem ação
                _buildIconButton('Histórico', Icons.school, () {
                  Navigator.pushNamed(context, 'HistoricoScreen'); // Navega para a tela de histórico
                }),
              ],
            ),
            SizedBox(height: 20), // Espaço entre os botões e o título

            // Título dos cursos em andamento
            Padding(
              padding: const EdgeInsets.all(8.0), // Preenchimento ao redor do título
              child: Text(
                'ANDAMENTO', // Título da seção
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Estilo do texto
              ),
            ),

            // StreamBuilder para exibir cursos em andamento
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('cursos').snapshots(), // Observa a coleção de cursos
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Carregando
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhum curso em andamento.')); // Mensagem se não houver cursos
                }

                // Exibe cada curso em um bloco
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    // Verificação de segurança para a existência dos campos
                    var data = doc.data() as Map<String, dynamic>;
                    if (!data.containsKey('nome') || !data.containsKey('dataEscolhida')) {
                      return Text('Dados inválidos ou incompletos para este curso.'); // Mensagem de erro
                    }

                    String courseName = data['nome']; // Nome do curso
                    String chosenDate = data['dataEscolhida']; // Data escolhida

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Margem ao redor do bloco do curso
                      padding: EdgeInsets.all(16), // Preenchimento interno do bloco
                      decoration: BoxDecoration(
                        color: Colors.white, // Cor de fundo do bloco
                        borderRadius: BorderRadius.circular(8), // Bordas arredondadas
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3), // Sombra do bloco
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha os itens do bloco
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento do texto à esquerda
                            children: [
                              Text(
                                courseName, // Nome do curso
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold, // Estilo do nome do curso
                                ),
                              ),
                              SizedBox(height: 4), // Espaço entre o nome e a data
                              Text(
                                'Data: $chosenDate', // Exibe a data escolhida
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey, // Cor da data
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue), // Ícone de editar
                                onPressed: () {
                                  _showEditPopup(context, doc.id, courseName, chosenDate); // Mostra o popup de edição
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red), // Ícone de deletar
                                onPressed: () async {
                                  // Exclui o curso do Firestore
                                  await FirebaseFirestore.instance
                                      .collection('cursos')
                                      .doc(doc.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(), // Converte a lista de documentos em widgets
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Função para exibir o popup de edição
  void _showEditPopup(BuildContext context, String docId, String courseName, String currentDate) {
    TextEditingController dateController = TextEditingController(text: currentDate); // Controlador para o campo de data

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar $courseName'), // Título do popup
          content: Column(
            mainAxisSize: MainAxisSize.min, // Tamanho mínimo da coluna
            children: [
              TextField(
                controller: dateController, // Controlador do campo de texto
                decoration: InputDecoration(
                  labelText: 'Nova Data', // Rótulo do campo
                  hintText: 'dd/mm/aaaa', // Dica sobre o formato da data
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Atualiza a data no Firestore
                String newDate = dateController.text; // Captura a nova data
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(docId)
                    .update({'dataEscolhida': newDate}); // Atualiza a data escolhida

                Navigator.of(context).pop(); // Fecha o popup
              },
              child: Text('Salvar Data'), // Texto do botão para salvar
            ),
            ElevatedButton(
              onPressed: () async {
                // Move o curso para a coleção de cursos concluídos
                DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(docId)
                    .get();

                // Verifica se os dados não são nulos e converte corretamente para Map<String, dynamic>
                if (docSnapshot.exists) {
                  Map<String, dynamic> courseData = docSnapshot.data() as Map<String, dynamic>;

                  // Adiciona o curso à coleção de cursos concluídos
                  await FirebaseFirestore.instance
                      .collection('cursos_concluidos')
                      .doc(docId)
                      .set(courseData);

                  // Exclui o curso da coleção atual
                  await FirebaseFirestore.instance
                      .collection('cursos')
                      .doc(docId)
                      .delete();
                }

                Navigator.of(context).pop(); // Fecha o popup
              },
              child: Text('Concluir Curso'), // Texto do botão para concluir
            ),
          ],
        );
      },
    );
  }

  // Função para criar um botão com ícone
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
