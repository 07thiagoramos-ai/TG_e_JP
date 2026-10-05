import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tg_e_jp/authentication.dart';
import 'package:tg_e_jp/funcao/widget.dart';

class TelaEventos extends StatelessWidget {
  const TelaEventos({super.key});

  // admin: abre um pop-up e cria o evento
  Future<void> _criarEvento(BuildContext context) async {
    final controladorTitulo = TextEditingController();
    final controladorDescricao = TextEditingController();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Novo evento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controladorTitulo,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: controladorDescricao,
              decoration: const InputDecoration(labelText: "Descrição"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Criar"),
          ),
        ],
      ),
    );

    if (confirmou != true || controladorTitulo.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('eventos').add({
      'titulo': controladorTitulo.text.trim(),
      'descricao': controladorDescricao.text.trim(),
      'inscritos': [],
      'criado': FieldValue.serverTimestamp(),
    });
  }

  // participante: entra no evento ou sai dele
  Future<void> _alternarInscricao(String eventoId, bool inscrito) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('eventos').doc(eventoId).update({
      'inscritos': inscrito
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: appBarGeral(context, "Eventos"),
      floatingActionButton: Authentication().adm
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text("Novo evento"),
              onPressed: () => _criarEvento(context),
            )
          : null,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('eventos')
            .orderBy('criado', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventos = snapshot.data!.docs;
          if (eventos.isEmpty) {
            return const Center(child: Text("Nenhum evento ainda."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: eventos.length,
            itemBuilder: (context, indice) {
              final evento = eventos[indice];
              final dados = evento.data();
              final inscritos = List<String>.from(dados['inscritos'] ?? []);
              final inscrito = inscritos.contains(uid);

              return Card(
                child: ListTile(
                  title: Text(dados['titulo']),
                  subtitle: Text('${dados['descricao']}\n${inscritos.length} inscritos'),
                  isThreeLine: true,
                  trailing: inscrito
                      ? OutlinedButton(
                          onPressed: () => _alternarInscricao(evento.id, true),
                          child: const Text("Sair"),
                        )
                      : ElevatedButton(
                          onPressed: () => _alternarInscricao(evento.id, false),
                          child: const Text("Inscrever-me"),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}