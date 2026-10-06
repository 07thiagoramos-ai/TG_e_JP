import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tg_e_jp/authentication.dart';
import 'package:tg_e_jp/eventos/telaComentarios.dart';
import 'package:tg_e_jp/loginForm.dart';

class TelaEventos extends StatelessWidget {
  const TelaEventos({super.key});

  Future<void> _sair(BuildContext context) async {
    await Authentication().signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
      (context) => false,
    );
  }

  Future<void> _criarEvento(BuildContext context) async {
    final controladorTitulo = TextEditingController();
    final controladorDescricao = TextEditingController();

    // confirmou = null
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Novo evento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controladorTitulo,
              decoration: InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: controladorDescricao,
              decoration: InputDecoration(labelText: "Descrição"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text("Criar"),
          ),
        ],
      ),
    );

    if (confirmou != true || controladorTitulo.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('eventos').add({
      'titulo': controladorTitulo.text.trim(),
      'descricao': controladorDescricao.text.trim(),
      'inscritos': [],
      'criado': FieldValue.serverTimestamp(), // a hora que foi criado
    });
  }

  Future<void> _excluirEvento(
    BuildContext context,
    String eventoId,
    String titulo,
  ) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Excluir evento?"),
        content: Text('"$titulo" e todos os comentários dele serão apagados.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            }, 
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    final referenciaEvento = FirebaseFirestore.instance.collection('eventos').doc(eventoId);

    final comentarios = await referenciaEvento.collection('comentarios').get();
    final lote = FirebaseFirestore.instance.batch();
    for (final comentario in comentarios.docs) { // todos os comentários
      lote.delete(comentario.reference);
    }
    lote.delete(referenciaEvento); // deleta o evento
    await lote.commit(); // executa tudo
  }

  Future<void> _alternarInscricao(String eventoId, bool inscrito) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final referenciaEvento = FirebaseFirestore.instance.collection('eventos').doc(eventoId);

    if (inscrito) {
      await referenciaEvento.update({
        'inscritos': FieldValue.arrayRemove([uid]),
      });
    } else {
      await referenciaEvento.update({
        'inscritos': FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Eventos", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white,),
            tooltip: "Sair",
            onPressed: () {
              _sair(context);
            }, 
          ),
        ],
      ),

      floatingActionButton: Authentication().adm
          ? FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text("Novo evento"),
              onPressed: () {
                _criarEvento(context);
              },
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
            return Center(child: CircularProgressIndicator());
          }

          final eventos = snapshot.data!.docs;
          if (eventos.isEmpty) {
            return Center(child: Text("Nenhum evento ainda."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: eventos.length,
            itemBuilder: (context, indice) {
              final evento = eventos[indice];
              final dados = evento.data();
              final inscritos = List<String>.from(dados['inscritos'] ?? []);
              final inscrito = inscritos.contains(uid);
              final administrador = Authentication().adm;
              final podeComentar = inscrito || administrador;

              return Card(
                child: ListTile(
                  title: Text(dados['titulo']),
                  subtitle: Text(
                    '${dados['descricao']}\n'
                    '${inscritos.length} inscritos'
                    '${podeComentar ? ' · toque para ver os comentários' : ''}',
                  ),
                  isThreeLine: true,
                  onTap: podeComentar
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaComentarios(
                                eventoId: evento.id,
                                tituloEvento: dados['titulo'],
                              ),
                            ),
                          );
                        }
                      : null,

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (administrador)
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: "Excluir evento",
                          onPressed: () {
                            _excluirEvento(
                              context,
                              evento.id,
                              dados['titulo'],
                            );
                          },
                        ),
                      inscrito
                          ? OutlinedButton(
                              onPressed: () {
                                _alternarInscricao(evento.id, true);
                              },
                              child: Text("Sair"),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                _alternarInscricao(evento.id, false);
                              }, 
                              child: Text("Inscrever-me"),
                            ),
                    ],
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