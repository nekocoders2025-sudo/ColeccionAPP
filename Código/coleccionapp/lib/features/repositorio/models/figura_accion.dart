class FiguraAccion {
  String id;
  String categoria;
  String marca;
  String lineaExpansion;
  String producto;
  String serie;
  String edicion;
  String exclusividad;
  String annoLanz;

  FiguraAccion({
    required this.id,
    required this.categoria,
    required this.marca,
    required this.lineaExpansion,
    required this.producto,
    required this.serie,
    required this.edicion,
    required this.exclusividad,
    required this.annoLanz,
  });

  //Distinto al del video, no usa factory, usa Object en vez de dynamic, usa : this en lugar de return
  FiguraAccion.fromJson(Map<String, dynamic> json) : this(
      id: json['id'] as String,
      categoria: json['categoria'] as String,
      marca: json['marca'] as String,
      lineaExpansion: json['lineaExpansion'] as String,
      producto: json['producto'] as String,
      serie: json['serie'] as String,
      edicion: json['edicion'] as String,
      exclusividad: json['exclusividad'] as String,
      annoLanz: json['annoLanz'] as String,
    );

  FiguraAccion copyWith({
    String? id,
    String? categoria,
    String? marca,
    String? lineaExpansion,
    String? producto,
    String? serie,
    String? edicion,
    String? exclusividad,
    String? annoLanz,
  }) {
    return FiguraAccion(
      id: id ?? this.id,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      lineaExpansion: lineaExpansion ?? this.lineaExpansion,
      producto: producto ?? this.producto,
      serie: serie ?? this.serie,
      edicion: edicion ?? this.edicion,
      exclusividad: exclusividad ?? this.exclusividad,
      annoLanz: annoLanz ?? this.annoLanz,
    );
  }

  //Distinto al del video, usa Object en lugar de Dynamic
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'marca': marca,
      'lineaExpansion': lineaExpansion,
      'producto': producto,
      'serie': serie,
      'edicion': edicion,
      'exclusividad': exclusividad,
      'annoLanz': annoLanz,
    };
  }

}

