class Usuario {
  final String usuarioId;
  final String nombre;
  final String correo;
  final String rol;

  Usuario({
    required this.usuarioId,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuarioId: json['usuarioId'] as String,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      rol: json['rol'] as String,
    );
  }

  Usuario copyWith({
    String? usuarioId,
    String? nombre,
    String? correo,
    String? rol,
  }) {
    return Usuario(
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
    );
  }
}

