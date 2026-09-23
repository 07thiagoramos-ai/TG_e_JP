import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool adm = false;

  get User => _auth.currentUser;

  //criar novo participante
  Future<String?> signUp({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: senha
      );
      return null;
    } on FirebaseAuthException catch (erro)  {
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
      return null;
    } on FirebaseAuthException catch (erro) {
      return erro.message;
    }
  }

  Future<bool> VerificarNivelUsuario() async {
    final uid = _auth.currentUser?.uid;
    
    if (uid != null) {
      try {
        final documento = await FirebaseFirestore.instance
            .collection('admins')
            .doc(uid)
            .get();

        if (documento.exists) {
          adm = true; 
        } else {
          adm = false;
        }
      } on FirebaseException {
        adm = false;
      }
    } else {
      adm = false;
    }
    return adm;
  }

  Future<void> signOut() async {
    await _auth.signOut();
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