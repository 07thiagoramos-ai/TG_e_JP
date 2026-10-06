import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tg_e_jp/authentication.dart';
import 'package:tg_e_jp/funcao/widget.dart';

class TelaComentarios extends StatefulWidget {
  final String eventoId;
  final String tituloEvento;

  const TelaComentarios({
    super.key,
    required this.eventoId,
    required this.tituloEvento,
  });

  @override
  State<TelaComentarios> createState() => _TelaComentariosState();
}

class _TelaComentariosState extends State<TelaComentarios> {
  final _controladorComentario = TextEditingController();
  bool _enviando = false;

  CollectionReference<Map<String, dynamic>> 
  get _colecaoComentarios =>
      FirebaseFirestore.instance
          .collection('eventos')
          .doc(widget.eventoId)
          .collection('comentarios');

  Future<void> _enviar() async {
    final texto = _controladorComentario.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);
    final usuario = FirebaseAuth.instance.currentUser!;

    try {
      final documentoParticipante = await FirebaseFirestore.instance
          .collection('participantes')
          .doc(usuario.uid)
          .get();
      final nome =
          documentoParticipante.data()?['nome'] ?? usuario.email ?? 'Participante';

      await _colecaoComentarios.add({
        'texto': texto,
        'autorUid': usuario.uid,
        'autorNome': nome,
        'criado': FieldValue.serverTimestamp(),
      });
      _controladorComentario.clear();
    } on FirebaseException catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao comentar: ${erro.code}')),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _controladorComentario.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: appBarGeral(context, widget.tituloEvento),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _colecaoComentarios.orderBy('criado').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final comentarios = snapshot.data!.docs;
                if (comentarios.isEmpty) {
                  return Center(child: Text("Nenhum comentário ainda."));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: comentarios.length,
                  itemBuilder: (context, indice) {
                    final comentario = comentarios[indice];
                    final dados = comentario.data();
                    final podeApagar = dados['autorUid'] == uid || Authentication().adm;

                    return Card(
                      child: ListTile(
                        title: Text(dados['autorNome'] ?? 'Participante'),
                        subtitle: Text(dados['texto'] ?? ''),
                        trailing: podeApagar
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  comentario.reference.delete();
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // campo para escrever o comentário
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controladorComentario,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        _enviar();
                      },
                      decoration: InputDecoration(
                        hintText: "Escreva um comentário",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  IconButton.filled(
                    onPressed: _enviando ? null : _enviar,
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}