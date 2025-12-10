class Producto {
  final String id;
  final String nombre;
  final String? figuraId; // ID de la figura del repositorio si existe
  final bool obtenida; // true si está obtenida, false si es deseada

  Producto({
    required this.id,
    required this.nombre,
    this.figuraId,
    this.obtenida = false, // Por defecto es "Deseado"
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      if (figuraId != null) 'figuraId': figuraId,
      'obtenida': obtenida,
    };
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      figuraId: json['figuraId'] as String?,
      obtenida: json['obtenida'] as bool? ?? false,
    );
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? figuraId,
    bool? obtenida,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      figuraId: figuraId ?? this.figuraId,
      obtenida: obtenida ?? this.obtenida,
    );
  }
}


