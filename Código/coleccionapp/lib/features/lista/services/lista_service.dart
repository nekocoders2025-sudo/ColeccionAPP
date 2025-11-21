import 'dart:convert';
import 'package:coleccionapp/features/lista/models/lista_productos.dart';
import 'package:coleccionapp/features/lista/models/producto.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ListaService {
  static const String _key = 'listas_productos';

  Future<List<ListaProductos>> obtenerListas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? listasJson = prefs.getString(_key);
    
    if (listasJson == null) {
      return [];
    }

    final List<dynamic> listasData = json.decode(listasJson);
    return listasData
        .map((lista) => ListaProductos.fromJson(lista as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardarListas(List<ListaProductos> listas) async {
    final prefs = await SharedPreferences.getInstance();
    final String listasJson = json.encode(
      listas.map((lista) => lista.toJson()).toList(),
    );
    await prefs.setString(_key, listasJson);
  }

  Future<void> agregarLista(ListaProductos lista) async {
    final listas = await obtenerListas();
    listas.add(lista);
    await guardarListas(listas);
  }

  Future<void> actualizarLista(ListaProductos listaActualizada) async {
    final listas = await obtenerListas();
    final index = listas.indexWhere((l) => l.id == listaActualizada.id);
    if (index != -1) {
      listas[index] = listaActualizada;
      await guardarListas(listas);
    }
  }

  Future<void> eliminarLista(String id) async {
    final listas = await obtenerListas();
    listas.removeWhere((l) => l.id == id);
    await guardarListas(listas);
  }

  Future<void> agregarProducto(String listaId, Producto producto) async {
    final listas = await obtenerListas();
    final index = listas.indexWhere((l) => l.id == listaId);
    if (index != -1) {
      listas[index].productos.add(producto);
      await guardarListas(listas);
    }
  }

  Future<void> eliminarProducto(String listaId, String productoId) async {
    final listas = await obtenerListas();
    final index = listas.indexWhere((l) => l.id == listaId);
    if (index != -1) {
      listas[index].productos.removeWhere((p) => p.id == productoId);
      await guardarListas(listas);
    }
  }
}

