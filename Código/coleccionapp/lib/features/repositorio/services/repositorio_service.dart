import 'dart:convert';
import 'package:coleccionapp/features/repositorio/models/figura_accion.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RepositorioService {
  static const String _key = 'repositorio_figuras';

  Future<List<FiguraAccion>> obtenerFiguras() async {
    final prefs = await SharedPreferences.getInstance();
    final String? figurasJson = prefs.getString(_key);
    
    if (figurasJson == null) {
      return [];
    }

    final List<dynamic> figurasData = json.decode(figurasJson);
    return figurasData
        .map((figura) => FiguraAccion.fromJson(figura as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardarFiguras(List<FiguraAccion> figuras) async {
    final prefs = await SharedPreferences.getInstance();
    final String figurasJson = json.encode(
      figuras.map((figura) => figura.toJson()).toList(),
    );
    await prefs.setString(_key, figurasJson);
  }

  Future<void> agregarFigura(FiguraAccion figura) async {
    final figuras = await obtenerFiguras();
    figuras.add(figura);
    await guardarFiguras(figuras);
  }

  Future<void> actualizarFigura(FiguraAccion figuraActualizada) async {
    final figuras = await obtenerFiguras();
    final index = figuras.indexWhere((f) => f.id == figuraActualizada.id);
    if (index != -1) {
      figuras[index] = figuraActualizada;
      await guardarFiguras(figuras);
    }
  }

  Future<void> eliminarFigura(String id) async {
    final figuras = await obtenerFiguras();
    figuras.removeWhere((f) => f.id == id);
    await guardarFiguras(figuras);
  }

  Future<FiguraAccion?> obtenerFiguraPorId(String id) async {
    final figuras = await obtenerFiguras();
    try {
      return figuras.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
}

