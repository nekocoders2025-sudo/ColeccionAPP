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
  List<FiguraAccion> _figuras = [];
  bool _cargando = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarFiguras();
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
    final figuras = await _repositorioService.obtenerFiguras();
    setState(() {
      _figuras = figuras;
      _cargando = false;
    });
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
      await _repositorioService.eliminarFigura(figura.id);
      _cargarFiguras();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositorio de Figuras'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                        columns: const [
                          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('CATEGORIA', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('MARCA', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('LINEA_EXPANSION', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('SERIE', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('EDICION', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('EXCLUSIVIDAD', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('ANNO_LANZ', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                showEditIcon: true,
                                onTap: () => _editarFigura(figura),
                              ),
                              DataCell(SelectableText(figura.serie)),
                              DataCell(SelectableText(figura.edicion)),
                              DataCell(SelectableText(figura.exclusividad)),
                              DataCell(SelectableText(figura.annoLanz)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarFigura,
        tooltip: 'Agregar Figura',
        child: const Icon(Icons.add),
      ),
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
  
  late TextEditingController _categoriaController;
  late TextEditingController _marcaController;
  late TextEditingController _lineaExpansionController;
  late TextEditingController _productoController;
  late TextEditingController _serieController;
  late TextEditingController _edicionController;
  late TextEditingController _exclusividadController;
  late TextEditingController _annoLanzController;

  @override
  void initState() {
    super.initState();
    _categoriaController = TextEditingController(text: widget.figura?.categoria ?? '');
    _marcaController = TextEditingController(text: widget.figura?.marca ?? '');
    _lineaExpansionController = TextEditingController(text: widget.figura?.lineaExpansion ?? '');
    _productoController = TextEditingController(text: widget.figura?.producto ?? '');
    _serieController = TextEditingController(text: widget.figura?.serie ?? '');
    _edicionController = TextEditingController(text: widget.figura?.edicion ?? '');
    _exclusividadController = TextEditingController(text: widget.figura?.exclusividad ?? '');
    _annoLanzController = TextEditingController(text: widget.figura?.annoLanz ?? '');
  }

  @override
  void dispose() {
    _categoriaController.dispose();
    _marcaController.dispose();
    _lineaExpansionController.dispose();
    _productoController.dispose();
    _serieController.dispose();
    _edicionController.dispose();
    _exclusividadController.dispose();
    _annoLanzController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final figura = widget.figura != null
          ? widget.figura!.copyWith(
              categoria: _categoriaController.text.trim(),
              marca: _marcaController.text.trim(),
              lineaExpansion: _lineaExpansionController.text.trim(),
              producto: _productoController.text.trim(),
              serie: _serieController.text.trim(),
              edicion: _edicionController.text.trim(),
              exclusividad: _exclusividadController.text.trim(),
              annoLanz: _annoLanzController.text.trim(),
            )
          : FiguraAccion(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              categoria: _categoriaController.text.trim(),
              marca: _marcaController.text.trim(),
              lineaExpansion: _lineaExpansionController.text.trim(),
              producto: _productoController.text.trim(),
              serie: _serieController.text.trim(),
              edicion: _edicionController.text.trim(),
              exclusividad: _exclusividadController.text.trim(),
              annoLanz: _annoLanzController.text.trim(),
            );

      if (widget.figura != null) {
        await _repositorioService.actualizarFigura(figura);
      } else {
        await _repositorioService.agregarFigura(figura);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.figura != null ? 'Editar Figura' : 'Nueva Figura'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _categoriaController,
              decoration: const InputDecoration(
                labelText: 'CATEGORIA',
                border: OutlineInputBorder(),
                hintText: 'Ej: Figura de acción',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _marcaController,
              decoration: const InputDecoration(
                labelText: 'MARCA',
                border: OutlineInputBorder(),
                hintText: 'Ej: Hasbro, Bandai',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lineaExpansionController,
              decoration: const InputDecoration(
                labelText: 'LINEA_EXPANSION',
                border: OutlineInputBorder(),
                hintText: 'Ej: Marvel Legends, Star Wars Black Series',
              ),
              textCapitalization: TextCapitalization.words,
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
            TextFormField(
              controller: _serieController,
              decoration: const InputDecoration(
                labelText: 'SERIE',
                border: OutlineInputBorder(),
                hintText: 'Ej: Serie 1, Wave 2',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _edicionController,
              decoration: const InputDecoration(
                labelText: 'EDICION',
                border: OutlineInputBorder(),
                hintText: 'Ej: Edición especial, Variante',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exclusividadController,
              decoration: const InputDecoration(
                labelText: 'EXCLUSIVIDAD',
                border: OutlineInputBorder(),
                hintText: 'Ej: Exclusivo de tienda, Internacional',
              ),
              textCapitalization: TextCapitalization.words,
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

