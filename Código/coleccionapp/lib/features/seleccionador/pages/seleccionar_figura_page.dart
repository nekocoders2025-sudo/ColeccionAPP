import 'package:coleccionapp/features/repositorio/models/figura_accion.dart';
import 'package:coleccionapp/features/repositorio/services/repositorio_service.dart';
import 'package:flutter/material.dart';
import 'package:coleccionapp/features/buscador/pages/buscar_figuras_page.dart' show BuscarFigurasScreen;

class SeleccionarFiguraScreen extends StatefulWidget {
  final List<String> figuraIdsExistentes; // IDs de figuras ya agregadas

  const SeleccionarFiguraScreen({
    super.key,
    this.figuraIdsExistentes = const [],
  });

  @override
  State<SeleccionarFiguraScreen> createState() => _SeleccionarFiguraScreenState();
}

class _SeleccionarFiguraScreenState extends State<SeleccionarFiguraScreen> {
  final RepositorioService _repositorioService = RepositorioService();
  final TextEditingController _busquedaController = TextEditingController();
  
  List<FiguraAccion> _todasLasFiguras = [];
  List<FiguraAccion> _figurasFiltradas = [];
  bool _cargando = true;
  bool _mostrarFiltros = false;

  // Filtros
  String? _filtroCategoria;
  String? _filtroMarca;
  String? _filtroLineaExpansion;
  String? _filtroSerie;
  String? _filtroEdicion;
  String? _filtroExclusividad;

  // Opciones únicas para los filtros
  List<String> _categorias = [];
  List<String> _marcas = [];
  List<String> _lineasExpansion = [];
  List<String> _series = [];
  List<String> _ediciones = [];
  List<String> _exclusividades = [];

  @override
  void initState() {
    super.initState();
    _cargarFiguras();
    _busquedaController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarFiguras() async {
    setState(() {
      _cargando = true;
    });
    final figuras = await _repositorioService.obtenerFiguras();
    
    // Filtrar figuras que ya están en la lista
    final figurasDisponibles = figuras.where((f) => 
      !widget.figuraIdsExistentes.contains(f.id)
    ).toList();
    
    // Extraer valores únicos para los filtros
    _categorias = figurasDisponibles.map((f) => f.categoria).where((c) => c.isNotEmpty).toSet().toList()..sort();
    _marcas = figurasDisponibles.map((f) => f.marca).where((m) => m.isNotEmpty).toSet().toList()..sort();
    _lineasExpansion = figurasDisponibles.map((f) => f.lineaExpansion).where((l) => l.isNotEmpty).toSet().toList()..sort();
    _series = figurasDisponibles.map((f) => f.serie).where((s) => s.isNotEmpty).toSet().toList()..sort();
    _ediciones = figurasDisponibles.map((f) => f.edicion).where((e) => e.isNotEmpty).toSet().toList()..sort();
    _exclusividades = figurasDisponibles.map((f) => f.exclusividad).where((e) => e.isNotEmpty).toSet().toList()..sort();

    setState(() {
      _todasLasFiguras = figurasDisponibles;
      _cargando = false;
    });
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    final busquedaTexto = _busquedaController.text.toLowerCase().trim();
    
    List<FiguraAccion> resultado = List.from(_todasLasFiguras);

    // Filtro por texto
    if (busquedaTexto.isNotEmpty) {
      resultado = resultado.where((figura) {
        return figura.producto.toLowerCase().contains(busquedaTexto) ||
               figura.categoria.toLowerCase().contains(busquedaTexto) ||
               figura.marca.toLowerCase().contains(busquedaTexto) ||
               figura.lineaExpansion.toLowerCase().contains(busquedaTexto) ||
               figura.serie.toLowerCase().contains(busquedaTexto) ||
               figura.edicion.toLowerCase().contains(busquedaTexto) ||
               figura.exclusividad.toLowerCase().contains(busquedaTexto) ||
               figura.annoLanz.toLowerCase().contains(busquedaTexto);
      }).toList();
    }

    // Filtros por columnas específicas
    if (_filtroCategoria != null && _filtroCategoria!.isNotEmpty) {
      resultado = resultado.where((f) => f.categoria == _filtroCategoria).toList();
    }
    if (_filtroMarca != null && _filtroMarca!.isNotEmpty) {
      resultado = resultado.where((f) => f.marca == _filtroMarca).toList();
    }
    if (_filtroLineaExpansion != null && _filtroLineaExpansion!.isNotEmpty) {
      resultado = resultado.where((f) => f.lineaExpansion == _filtroLineaExpansion).toList();
    }
    if (_filtroSerie != null && _filtroSerie!.isNotEmpty) {
      resultado = resultado.where((f) => f.serie == _filtroSerie).toList();
    }
    if (_filtroEdicion != null && _filtroEdicion!.isNotEmpty) {
      resultado = resultado.where((f) => f.edicion == _filtroEdicion).toList();
    }
    if (_filtroExclusividad != null && _filtroExclusividad!.isNotEmpty) {
      resultado = resultado.where((f) => f.exclusividad == _filtroExclusividad).toList();
    }

    setState(() {
      _figurasFiltradas = resultado;
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroCategoria = null;
      _filtroMarca = null;
      _filtroLineaExpansion = null;
      _filtroSerie = null;
      _filtroEdicion = null;
      _filtroExclusividad = null;
      _busquedaController.clear();
    });
    _aplicarFiltros();
  }

  void _seleccionarFigura(FiguraAccion figura) {
    Navigator.pop(context, figura);
  }

  void _verDetalles(FiguraAccion figura) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(figura.producto),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID', figura.id),
              _buildDetalleItem('CATEGORIA', figura.categoria),
              _buildDetalleItem('MARCA', figura.marca),
              _buildDetalleItem('LINEA_EXPANSION', figura.lineaExpansion),
              _buildDetalleItem('PRODUCTO', figura.producto),
              _buildDetalleItem('SERIE', figura.serie),
              _buildDetalleItem('EDICION', figura.edicion),
              _buildDetalleItem('EXCLUSIVIDAD', figura.exclusividad),
              _buildDetalleItem('ANNO_LANZ', figura.annoLanz),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _seleccionarFigura(figura);
            },
            child: const Text('Seleccionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroDropdown(
    String label,
    String? valorActual,
    List<String> opciones,
    Function(String?) onChanged,
  ) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: valorActual,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Todos'),
          ),
          ...opciones.map((opcion) => DropdownMenuItem<String>(
                value: opcion,
                child: Text(opcion),
              )),
        ],
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Figura'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_mostrarFiltros ? Icons.filter_alt : Icons.filter_alt_outlined),
            tooltip: 'Mostrar/Ocultar Filtros',
            onPressed: () {
              setState(() {
                _mostrarFiltros = !_mostrarFiltros;
              });
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Campo de búsqueda
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      labelText: 'Buscar figuras',
                      hintText: 'Buscar por nombre, marca, categoría...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _busquedaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _busquedaController.clear();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),

                // Filtros
                if (_mostrarFiltros)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filtros',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _limpiarFiltros,
                              child: const Text('Limpiar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFiltroDropdown(
                              'CATEGORIA',
                              _filtroCategoria,
                              _categorias,
                              (value) {
                                setState(() {
                                  _filtroCategoria = value;
                                });
                                _aplicarFiltros();
                              },
                            ),
                            _buildFiltroDropdown(
                              'MARCA',
                              _filtroMarca,
                              _marcas,
                              (value) {
                                setState(() {
                                  _filtroMarca = value;
                                });
                                _aplicarFiltros();
                              },
                            ),
                            _buildFiltroDropdown(
                              'LINEA_EXPANSION',
                              _filtroLineaExpansion,
                              _lineasExpansion,
                              (value) {
                                setState(() {
                                  _filtroLineaExpansion = value;
                                });
                                _aplicarFiltros();
                              },
                            ),
                            _buildFiltroDropdown(
                              'SERIE',
                              _filtroSerie,
                              _series,
                              (value) {
                                setState(() {
                                  _filtroSerie = value;
                                });
                                _aplicarFiltros();
                              },
                            ),
                            _buildFiltroDropdown(
                              'EDICION',
                              _filtroEdicion,
                              _ediciones,
                              (value) {
                                setState(() {
                                  _filtroEdicion = value;
                                });
                                _aplicarFiltros();
                              },
                            ),
                            _buildFiltroDropdown(
                              'EXCLUSIVIDAD',
                              _filtroExclusividad,
                              _exclusividades,
                              (value) {
                                setState(() {
                                  _filtroExclusividad = value;
                                });
                                _aplicarFiltros();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Contador de resultados
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  width: double.infinity,
                  child: Text(
                    '${_figurasFiltradas.length} figura${_figurasFiltradas.length != 1 ? 's' : ''} disponible${_figurasFiltradas.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Lista de resultados
                Expanded(
                  child: _todasLasFiguras.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay figuras en el repositorio',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Se deben agregar figuras al repositorio',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : _figurasFiltradas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron figuras',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Intenta ajustando los filtros o texto de búsqueda',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _cargarFiguras,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _figurasFiltradas.length,
                                itemBuilder: (context, index) {
                                  final figura = _figurasFiltradas[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    elevation: 2,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Icon(
                                          Icons.smart_toy_outlined,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                      title: Text(
                                        figura.producto,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (figura.marca.isNotEmpty)
                                            Text('Marca: ${figura.marca}'),
                                          if (figura.lineaExpansion.isNotEmpty)
                                            Text('Línea: ${figura.lineaExpansion}'),
                                          if (figura.categoria.isNotEmpty)
                                            Text('Categoría: ${figura.categoria}'),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.info_outline),
                                            onPressed: () => _verDetalles(figura),
                                            tooltip: 'Ver detalles',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle),
                                            color: Theme.of(context).colorScheme.primary,
                                            onPressed: () => _seleccionarFigura(figura),
                                            tooltip: 'Seleccionar',
                                          ),
                                        ],
                                      ),
                                      onTap: () => _seleccionarFigura(figura),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }
}

