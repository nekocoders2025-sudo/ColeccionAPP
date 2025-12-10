import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coleccionapp/features/repositorio/models/figura_accion.dart';
import 'package:coleccionapp/features/auth/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String FIGURAACCION_COLLECTION_REF = "figurasAccion";

class RepositorioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  late final CollectionReference<FiguraAccion> _figuraAccionRef;

  RepositorioService() {
    _figuraAccionRef = _firestore
        .collection(FIGURAACCION_COLLECTION_REF)
        .withConverter<FiguraAccion>(
          fromFirestore: (snapshot, _) =>
              FiguraAccion.fromJson(snapshot.data()!),
          toFirestore: (figura, _) => figura.toJson(),
        );
  }

  // Verificar que el usuario actual tenga rol Admin
  Future<void> _verificarRolAdmin() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
    }

    final usuario = await _userService.obtenerUsuarioPorId(userId);
    if (usuario == null) {
      throw Exception('No se encontró información del usuario.');
    }

    if (usuario.rol != 'Admin') {
      throw Exception('No tienes permisos para realizar esta acción. Solo los administradores pueden modificar el repositorio.');
    }
  }

  Future<List<FiguraAccion>> obtenerFiguras() async {
    try {
      final querySnapshot = await _figuraAccionRef.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al obtener figuras: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener figuras: $e');
    }
  }

  Future<void> agregarFigura(FiguraAccion figura) async {
    try {
      // Verificar que el usuario tenga rol Admin
      await _verificarRolAdmin();
      
      await _figuraAccionRef.doc(figura.id).set(figura);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al agregar figura: ${e.message}');
    } catch (e) {
      // Re-lanzar excepciones de verificación de rol sin modificar
      if (e.toString().contains('permisos') || e.toString().contains('autenticado')) {
        rethrow;
      }
      throw Exception('Error inesperado al agregar figura: $e');
    }
  }

  Future<void> actualizarFigura(FiguraAccion figuraActualizada) async {
    try {
      // Verificar que el usuario tenga rol Admin
      await _verificarRolAdmin();
      
      await _figuraAccionRef.doc(figuraActualizada.id).update(
            figuraActualizada.toJson(),
          );
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al actualizar figura: ${e.message}');
    } catch (e) {
      // Re-lanzar excepciones de verificación de rol sin modificar
      if (e.toString().contains('permisos') || e.toString().contains('autenticado')) {
        rethrow;
      }
      throw Exception('Error inesperado al actualizar figura: $e');
    }
  }

  Future<void> eliminarFigura(String id) async {
    try {
      // Verificar que el usuario tenga rol Admin
      await _verificarRolAdmin();
      
      await _figuraAccionRef.doc(id).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al eliminar figura: ${e.message}');
    } catch (e) {
      // Re-lanzar excepciones de verificación de rol sin modificar
      if (e.toString().contains('permisos') || e.toString().contains('autenticado')) {
        rethrow;
      }
      throw Exception('Error inesperado al eliminar figura: $e');
    }
  }

  Future<FiguraAccion?> obtenerFiguraPorId(String id) async {
    try {
      final docSnapshot = await _figuraAccionRef.doc(id).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

