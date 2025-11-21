class Producto {
  final String id;
  final String nombre;
  final String? figuraId; // ID de la figura del repositorio si existe

  Producto({
    required this.id,
    required this.nombre,
    this.figuraId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      if (figuraId != null) 'figuraId': figuraId,
    };
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      figuraId: json['figuraId'] as String?,
    );
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? figuraId,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      figuraId: figuraId ?? this.figuraId,
    );
  }
}


