import 'package:coleccionapp/features/lista/models/producto.dart';

class ListaProductos {
  final String id;
  final String userId; // UID del usuario que creó la lista
  String nombre;
  final List<Producto> productos;

  ListaProductos({
    required this.id,
    required this.userId,
    required this.nombre,
    List<Producto>? productos,
  }) : productos = productos ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nombre': nombre,
      'productos': productos.map((p) => p.toJson()).toList(),
    };
  }

  factory ListaProductos.fromJson(Map<String, dynamic> json) {
    return ListaProductos(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      nombre: json['nombre'] as String,
      productos: (json['productos'] as List<dynamic>?)
              ?.map((p) => Producto.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ListaProductos copyWith({
    String? id,
    String? userId,
    String? nombre,
    List<Producto>? productos,
  }) {
    return ListaProductos(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      productos: productos ?? this.productos,
    );
  }
}

