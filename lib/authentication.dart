import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  // sempre devolve o mesmo objeto, assim o valor de "adm" não se perde entre telas
  static final Authentication _instancia = Authentication._interno();
  factory Authentication() => _instancia;
  Authentication._interno();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool adm = false;

  get User => _auth.currentUser;

  // guarda no aparelho que a pessoa quer continuar logada
  Future<void> _estarLogado() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setBool('manter_logado', true);
  }

  //criar novo participante
  Future<String?> signUp({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await _estarLogado();
      return null;
    } on FirebaseAuthException catch (erro) {
      return erro.message;
    }
  }

  //fazer login
  Future<String?> signIn({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await VerificarNivelUsuario();
      await _estarLogado();
      return null;
    } on FirebaseAuthException catch (erro) {
      return erro.message;
    }
  }

  // lê participantes/{uid} e confere se o campo adm é true
  Future<bool> VerificarNivelUsuario() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      adm = false;
      return adm;
    }

    try {
      final documento = await FirebaseFirestore.instance
          .collection('participantes')
          .doc(uid)
          .get();
      adm = documento.data()?['adm'] == true;
    } on FirebaseException {
      adm = false;
    }
    return adm;
  }

  // chamada ao abrir o app: decide se a pessoa volta direto para a conta
  Future<bool> sessaoSalva() async {
    final preferencias = await SharedPreferences.getInstance();
    final manterLogado = preferencias.getBool('manter_logado') ?? false;
    if (!manterLogado) return false;

    // espera o Firebase restaurar a sessão (importante na versão web)
    final usuario = await _auth.authStateChanges().first;
    if (usuario == null) return false;

    await VerificarNivelUsuario(); // carrega o adm
    return true;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove('manter_logado');
    adm = false;
  }

  String traduzirRetorno(String msg) {
    String retorno = '';
    switch (msg) {
      case "The email address is badly formatted.":
        retorno = "Formato inválido de email";
        break;
      case "Password should be at least 6 characters":
        retorno = "A senha deve possuir ao menos 6 caracteres";
        break;
      case "The email address is already in use by another account.":
        retorno = "O email digitado já está em uso por outra conta";
        break;
      case "The password is invalid or the user does not have a password.":
        retorno = "Senha inválida.";
        break;
      case "There is no user record corresponding to this identifier. The user may have been deleted.":
        retorno = "Usuário não encontrado.";
        break;
      default:
        retorno = msg;
        break;
    }
    return retorno;
  }
}