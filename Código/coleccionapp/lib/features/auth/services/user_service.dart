import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coleccionapp/features/auth/models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String USUARIOS_COLLECTION_REF = "usuarios";

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final CollectionReference<Usuario> _usuariosRef;

  UserService() {
    _usuariosRef = _firestore
        .collection(USUARIOS_COLLECTION_REF)
        .withConverter<Usuario>(
          fromFirestore: (snapshot, _) =>
              Usuario.fromJson(snapshot.data()!),
          toFirestore: (usuario, _) => usuario.toJson(),
        );
  }

  // Verificar si el usuario actual tiene rol Admin
  Future<bool> esAdmin() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return false;
      }

      final usuario = await obtenerUsuarioPorId(userId);
      return usuario?.rol == 'Admin';
    } catch (e) {
      return false;
    }
  }

  Future<void> crearUsuario(Usuario usuario) async {
    try {
      await _usuariosRef.doc(usuario.usuarioId).set(usuario);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al crear usuario: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear usuario: $e');
    }
  }

  Future<Usuario?> obtenerUsuarioPorId(String usuarioId) async {
    try {
      final docSnapshot = await _usuariosRef.doc(usuarioId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> actualizarUsuario(Usuario usuarioActualizado) async {
    try {
      await _usuariosRef.doc(usuarioActualizado.usuarioId).update(
            usuarioActualizado.toJson(),
          );
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al actualizar usuario: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar usuario: $e');
    }
  }
}

