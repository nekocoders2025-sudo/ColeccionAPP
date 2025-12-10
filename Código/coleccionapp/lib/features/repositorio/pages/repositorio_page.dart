import 'package:coleccionapp/features/auth/services/user_service.dart';
import 'package:coleccionapp/features/buscador/pages/buscar_figuras_page.dart';
import 'package:coleccionapp/features/repositorio/models/figura_accion.dart';
import 'package:coleccionapp/features/repositorio/services/repositorio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class RepositorioScreen extends StatefulWidget {
  const RepositorioScreen({super.key});

  @override
  State<RepositorioScreen> createState() => _RepositorioScreenState();
}

class _RepositorioScreenState extends State<RepositorioScreen> {
  final RepositorioService _repositorioService = RepositorioService();
  final UserService _userService = UserService();
  List<FiguraAccion> _figuras = [];
  bool _cargando = true;
  bool _esAdmin = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _verificarRolAdmin();
    _cargarFiguras();
  }

  Future<void> _verificarRolAdmin() async {
    final esAdmin = await _userService.esAdmin();
    setState(() {
      _esAdmin = esAdmin;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarFiguras() async {
    setState(() {
      _cargando = true;
    });
    try {
      final figuras = await _repositorioService.obtenerFiguras();
      setState(() {
        _figuras = figuras;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _agregarFigura() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarFiguraScreen(),
      ),
    );

    if (resultado == true) {
      _cargarFiguras();
    }
  }

  Future<void> _editarFigura(FiguraAccion figura) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarFiguraScreen(figura: figura),
      ),
    );

    if (resultado == true) {
      _cargarFiguras();
    }
  }

  Future<void> _eliminarFigura(FiguraAccion figura) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Figura'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${figura.producto}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _repositorioService.eliminarFigura(figura.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Figura eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarFiguras();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositorio de Figuras'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar Figuras',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuscarFigurasScreen(),
                ),
              );
              _cargarFiguras();
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _figuras.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.collections,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay figuras registradas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar una figura',
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
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          const DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('CATEGORIA', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('MARCA', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('LINEA_EXPANSION', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('SERIE', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('EDICION', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('EXCLUSIVIDAD', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('ANNO_LANZ', style: TextStyle(fontWeight: FontWeight.bold))),
                          if (_esAdmin)
                            const DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _figuras.map((figura) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SelectableText(figura.id),
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: figura.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ID copiado al portapapeles')),
                                  );
                                },
                              ),
                              DataCell(SelectableText(figura.categoria)),
                              DataCell(SelectableText(figura.marca)),
                              DataCell(SelectableText(figura.lineaExpansion)),
                              DataCell(
                                SelectableText(figura.producto),
                                showEditIcon: _esAdmin,
                                onTap: _esAdmin ? () => _editarFigura(figura) : null,
                              ),
                              DataCell(SelectableText(figura.serie)),
                              DataCell(SelectableText(figura.edicion)),
                              DataCell(SelectableText(figura.exclusividad)),
                              DataCell(SelectableText(figura.annoLanz)),
                              if (_esAdmin)
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _editarFigura(figura),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () => _eliminarFigura(figura),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: _esAdmin
          ? FloatingActionButton(
              onPressed: _agregarFigura,
              tooltip: 'Agregar Figura',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class EditarFiguraScreen extends StatefulWidget {
  final FiguraAccion? figura;

  const EditarFiguraScreen({super.key, this.figura});

  @override
  State<EditarFiguraScreen> createState() => _EditarFiguraScreenState();
}

class _EditarFiguraScreenState extends State<EditarFiguraScreen> {
  final _formKey = GlobalKey<FormState>();
  final RepositorioService _repositorioService = RepositorioService();
  
  // Opciones para los dropdowns
  static const List<String> _categorias = [
    'Figura Coleccionable',
    'Carta Coleccionable',
  ];
  
  static const List<String> _marcas = [
    'Storm Collectibles',
    'Jada Toys',
    'Tamashii Nations',
  ];
  
  static const List<String> _lineasExpansion = [
    'Figuras de Acción',
    'Storm Arena',
    'SH Figuarts',
  ];
  
  static const List<String> _series = [
    'Street Fighter Alpha 3',
    'Ultra Street Fighter 2',
    'The King of Fighters 98',
    'Gamerverse',
    'Dragon Ball',
    'Dragon Ball Z',
    'Dragon Ball Super',
  ];
  
  static const List<String> _ediciones = [
    'Regular',
    'Exclusiva',
    'Version 1',
    'Version 2',
    'Version 3',
    'Version 4',
  ];
  
  static const List<String> _exclusividades = [
    'Normal',
    'Exclusivo de Tienda',
    'Exclusivo de Evento',
    'Foil',
    'Arte Alternativo',
  ];
  
  // Variables para los dropdowns
  String? _categoriaSeleccionada;
  String? _marcaSeleccionada;
  String? _lineaExpansionSeleccionada;
  String? _serieSeleccionada;
  String? _edicionSeleccionada;
  String? _exclusividadSeleccionada;
  
  late TextEditingController _productoController;
  late TextEditingController _annoLanzController;

  @override
  void initState() {
    super.initState();
    // Inicializar valores solo si están en las listas de opciones
    final categoriaExistente = widget.figura?.categoria;
    _categoriaSeleccionada = categoriaExistente != null && _categorias.contains(categoriaExistente)
        ? categoriaExistente
        : null;
    
    final marcaExistente = widget.figura?.marca;
    _marcaSeleccionada = marcaExistente != null && _marcas.contains(marcaExistente)
        ? marcaExistente
        : null;
    
    final lineaExistente = widget.figura?.lineaExpansion;
    _lineaExpansionSeleccionada = lineaExistente != null && _lineasExpansion.contains(lineaExistente)
        ? lineaExistente
        : null;
    
    final serieExistente = widget.figura?.serie;
    _serieSeleccionada = serieExistente != null && _series.contains(serieExistente)
        ? serieExistente
        : null;
    
    final edicionExistente = widget.figura?.edicion;
    _edicionSeleccionada = edicionExistente != null && _ediciones.contains(edicionExistente)
        ? edicionExistente
        : null;
    
    final exclusividadExistente = widget.figura?.exclusividad;
    _exclusividadSeleccionada = exclusividadExistente != null && _exclusividades.contains(exclusividadExistente)
        ? exclusividadExistente
        : null;
    
    _productoController = TextEditingController(text: widget.figura?.producto ?? '');
    _annoLanzController = TextEditingController(text: widget.figura?.annoLanz ?? '');
  }

  @override
  void dispose() {
    _productoController.dispose();
    _annoLanzController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final figura = widget.figura != null
          ? widget.figura!.copyWith(
              categoria: _categoriaSeleccionada ?? '',
              marca: _marcaSeleccionada ?? '',
              lineaExpansion: _lineaExpansionSeleccionada ?? '',
              producto: _productoController.text.trim(),
              serie: _serieSeleccionada ?? '',
              edicion: _edicionSeleccionada ?? '',
              exclusividad: _exclusividadSeleccionada ?? '',
              annoLanz: _annoLanzController.text.trim(),
            )
          : FiguraAccion(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              categoria: _categoriaSeleccionada ?? '',
              marca: _marcaSeleccionada ?? '',
              lineaExpansion: _lineaExpansionSeleccionada ?? '',
              producto: _productoController.text.trim(),
              serie: _serieSeleccionada ?? '',
              edicion: _edicionSeleccionada ?? '',
              exclusividad: _exclusividadSeleccionada ?? '',
              annoLanz: _annoLanzController.text.trim(),
            );

      try {
        if (widget.figura != null) {
          await _repositorioService.actualizarFigura(figura);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Figura actualizada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await _repositorioService.agregarFigura(figura);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Figura agregada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.figura != null ? 'Editar Figura' : 'Nueva Figura'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'CATEGORIA',
                border: OutlineInputBorder(),
              ),
              items: _categorias.map((String categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _categoriaSeleccionada = nuevoValor;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _marcaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'MARCA',
                border: OutlineInputBorder(),
              ),
              items: _marcas.map((String marca) {
                return DropdownMenuItem<String>(
                  value: marca,
                  child: Text(marca),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _marcaSeleccionada = nuevoValor;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una marca';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _lineaExpansionSeleccionada,
              decoration: const InputDecoration(
                labelText: 'LINEA_EXPANSION',
                border: OutlineInputBorder(),
              ),
              items: _lineasExpansion.map((String linea) {
                return DropdownMenuItem<String>(
                  value: linea,
                  child: Text(linea),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _lineaExpansionSeleccionada = nuevoValor;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una línea de expansión';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productoController,
              decoration: const InputDecoration(
                labelText: 'PRODUCTO *',
                border: OutlineInputBorder(),
                hintText: 'Ej: Spider-Man, Darth Vader',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El producto es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _serieSeleccionada,
              decoration: const InputDecoration(
                labelText: 'SERIE',
                border: OutlineInputBorder(),
              ),
              items: _series.map((String serie) {
                return DropdownMenuItem<String>(
                  value: serie,
                  child: Text(serie),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _serieSeleccionada = nuevoValor;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _edicionSeleccionada,
              decoration: const InputDecoration(
                labelText: 'EDICION',
                border: OutlineInputBorder(),
              ),
              items: _ediciones.map((String edicion) {
                return DropdownMenuItem<String>(
                  value: edicion,
                  child: Text(edicion),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _edicionSeleccionada = nuevoValor;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _exclusividadSeleccionada,
              decoration: const InputDecoration(
                labelText: 'EXCLUSIVIDAD',
                border: OutlineInputBorder(),
              ),
              items: _exclusividades.map((String exclusividad) {
                return DropdownMenuItem<String>(
                  value: exclusividad,
                  child: Text(exclusividad),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _exclusividadSeleccionada = nuevoValor;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _annoLanzController,
              decoration: const InputDecoration(
                labelText: 'ANNO_LANZ',
                border: OutlineInputBorder(),
                hintText: 'Ej: 2024',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.figura != null ? 'Guardar Cambios' : 'Agregar Figura'),
            ),
          ],
        ),
      ),
    );
  }
}

