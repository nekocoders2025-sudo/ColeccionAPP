import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coleccionapp/features/repositorio/models/figura_accion.dart';

const String FIGURAACCION_COLLECTION_REF = "figurasAccion";

class DatabaseService {

  final _firestore  = FirebaseFirestore.instance;

  late final CollectionReference _figuraAccionRef;

  DatabaseService() {
    _figuraAccionRef = _firestore.collection(FIGURAACCION_COLLECTION_REF).withConverter<FiguraAccion>(
      fromFirestore: (snapshots, _) => FiguraAccion.fromJson(snapshots.data()!,), 
      toFirestore: (figuraaccion, _) => figuraaccion.toJson()); 
  }

  Stream<QuerySnapshot> getFigurasAccion() {
    return _figuraAccionRef.snapshots();
  }

  void addFiguraAccion(FiguraAccion figuraaccion) async {
    _figuraAccionRef.add(figuraaccion);
  }

  void updateFiguraAccion(String figuraaccionId, FiguraAccion figuraaccion) async {
    _figuraAccionRef.doc(figuraaccionId).update(figuraaccion.toJson());
  }

  void deleteFiguraAccion(String figuraaccionId) {
    _figuraAccionRef.doc(figuraaccionId).delete();
  }

}