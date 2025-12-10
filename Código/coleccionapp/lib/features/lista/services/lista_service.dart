import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coleccionapp/features/lista/models/lista_productos.dart';
import 'package:coleccionapp/features/lista/models/producto.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String LISTAS_PRODUCTOS_COLLECTION_REF = "listasProductos";

class ListaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final CollectionReference<ListaProductos> _listasRef;

  ListaService() {
    _listasRef = _firestore
        .collection(LISTAS_PRODUCTOS_COLLECTION_REF)
        .withConverter<ListaProductos>(
          fromFirestore: (snapshot, _) =>
              ListaProductos.fromJson(snapshot.data()!),
          toFirestore: (lista, _) => lista.toJson(),
        );
  }

  // Obtener el UID del usuario actual
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<List<ListaProductos>> obtenerListas() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
      }

      final querySnapshot = await _listasRef
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al obtener listas: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener listas: $e');
    }
  }

  Future<void> agregarLista(ListaProductos lista) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
      }

      // Asegurar que la lista pertenece al usuario actual
      if (lista.userId != userId) {
        throw Exception('No tienes permiso para crear esta lista.');
      }

      await _listasRef.doc(lista.id).set(lista);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al agregar lista: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al agregar lista: $e');
    }
  }

  Future<void> actualizarLista(ListaProductos listaActualizada) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
      }

      // Verificar que la lista pertenece al usuario actual
      final listaDoc = await _listasRef.doc(listaActualizada.id).get();
      if (!listaDoc.exists) {
        throw Exception('La lista no existe');
      }

      final listaExistente = listaDoc.data()!;
      if (listaExistente.userId != userId) {
        throw Exception('No tienes permiso para modificar esta lista.');
      }

      // Asegurar que el userId no cambie
      final listaConUserId = listaActualizada.copyWith(userId: userId);
      await _listasRef.doc(listaActualizada.id).update(
            listaConUserId.toJson(),
          );
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al actualizar lista: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar lista: $e');
    }
  }

  Future<void> eliminarLista(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
      }

      // Verificar que la lista pertenece al usuario actual
      final listaDoc = await _listasRef.doc(id).get();
      if (!listaDoc.exists) {
        throw Exception('La lista no existe');
      }

      final lista = listaDoc.data()!;
      if (lista.userId != userId) {
        throw Exception('No tienes permiso para eliminar esta lista.');
      }

      await _listasRef.doc(id).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al eliminar lista: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar lista: $e');
    }
  }

  Future<void> agregarProducto(String listaId, Producto producto) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
      }

      final listaDoc = await _listasRef.doc(listaId).get();
      if (!listaDoc.exists) {
        throw Exception('La lista no existe');
      }

      final lista = listaDoc.data()!;
      // Verificar que la lista pertenece al usuario actual
      if (lista.userId != userId) {
        throw Exception('No tienes permiso para modificar esta lista.');
      }

      final productosActualizados = [...lista.productos, producto];
      final listaActualizada = lista.copyWith(productos: productosActualizados);

      await _listasRef.doc(listaId).update(listaActualizada.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al agregar producto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al agregar producto: $e');
    }
  }

  Future<void> actualizarProducto(String listaId, Producto productoActualizado) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
      }

      final listaDoc = await _listasRef.doc(listaId).get();
      if (!listaDoc.exists) {
        throw Exception('La lista no existe');
      }

      final lista = listaDoc.data()!;
      // Verificar que la lista pertenece al usuario actual
      if (lista.userId != userId) {
        throw Exception('No tienes permiso para modificar esta lista.');
      }

      final productosActualizados = lista.productos.map((p) {
        if (p.id == productoActualizado.id) {
          return productoActualizado;
        }
        return p;
      }).toList();
      
      final listaActualizada = lista.copyWith(productos: productosActualizados);

      await _listasRef.doc(listaId).update(listaActualizada.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al actualizar producto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar producto: $e');
    }
  }

  Future<void> eliminarProducto(String listaId, String productoId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión.');
      }

      final listaDoc = await _listasRef.doc(listaId).get();
      if (!listaDoc.exists) {
        throw Exception('La lista no existe');
      }

      final lista = listaDoc.data()!;
      // Verificar que la lista pertenece al usuario actual
      if (lista.userId != userId) {
        throw Exception('No tienes permiso para modificar esta lista.');
      }

      final productosActualizados = lista.productos
          .where((p) => p.id != productoId)
          .toList();
      final listaActualizada = lista.copyWith(productos: productosActualizados);

      await _listasRef.doc(listaId).update(listaActualizada.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception(
          'La base de datos Firestore no existe. Por favor, crea la base de datos en la consola de Firebase.',
        );
      }
      throw Exception('Error al eliminar producto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar producto: $e');
    }
  }
}

