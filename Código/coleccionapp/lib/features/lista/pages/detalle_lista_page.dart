import 'package:coleccionapp/features/lista/models/lista_productos.dart';
import 'package:coleccionapp/features/lista/models/producto.dart';
import 'package:coleccionapp/features/lista/services/lista_service.dart';
import 'package:coleccionapp/features/repositorio/models/figura_accion.dart';
import 'package:coleccionapp/features/repositorio/services/repositorio_service.dart';
import 'package:coleccionapp/features/seleccionador/pages/seleccionar_figura_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DetalleListaScreen extends StatefulWidget {
  final ListaProductos lista;

  const DetalleListaScreen({
    super.key,
    required this.lista,
  });

  @override
  State<DetalleListaScreen> createState() => _DetalleListaScreenState();
}

class _DetalleListaScreenState extends State<DetalleListaScreen> {
  final ListaService _listaService = ListaService();
  final RepositorioService _repositorioService = RepositorioService();
  late ListaProductos _lista;
  bool _cargando = false;
  Map<String, FiguraAccion?> _figurasCache = {};

  @override
  void initState() {
    super.initState();
    _lista = widget.lista;
    _cargarLista();
  }

  Future<void> _cargarLista() async {
    setState(() {
      _cargando = true;
    });
    final listas = await _listaService.obtenerListas();
    final listaActualizada = listas.firstWhere(
      (l) => l.id == _lista.id,
      orElse: () => _lista,
    );
    
    // Cargar información de figuras del repositorio
    _figurasCache.clear();
    for (final producto in listaActualizada.productos) {
      if (producto.figuraId != null) {
        final figura = await _repositorioService.obtenerFiguraPorId(producto.figuraId!);
        _figurasCache[producto.id] = figura;
      }
    }
    
    setState(() {
      _lista = listaActualizada;
      _cargando = false;
    });
  }

  Future<void> _agregarProducto() async {
    // Obtener IDs de figuras ya agregadas a la lista
    final figuraIdsExistentes = _lista.productos
        .where((p) => p.figuraId != null)
        .map((p) => p.figuraId!)
        .toList();

    // Abrir pantalla de selección de figuras
    final figuraSeleccionada = await Navigator.push<FiguraAccion>(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionarFiguraScreen(
          figuraIdsExistentes: figuraIdsExistentes,
        ),
      ),
    );

    if (figuraSeleccionada != null) {
      // Crear producto con referencia a la figura del repositorio
      final nuevoProducto = Producto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: figuraSeleccionada.producto,
        figuraId: figuraSeleccionada.id,
      );
      await _listaService.agregarProducto(_lista.id, nuevoProducto);
      _cargarLista();
    }
  }

  Future<void> _eliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${producto.nombre}"?',
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
      await _listaService.eliminarProducto(_lista.id, producto.id);
      _cargarLista();
    }
  }

  Future<void> _tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    
    // Mostrar opciones: Cámara o Galería
    final opcion = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar fuente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (opcion == null) return;

    try {
      // Tomar/seleccionar la foto
      final XFile? foto = await picker.pickImage(
        source: opcion,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (foto != null && mounted) {
        // Mostrar la foto tomada
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Foto tomada'),
                  automaticallyImplyLeading: false,
                ),
                Flexible(
                  child: Image.file(
                    File(foto.path),
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Foto guardada exitosamente'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // Aquí podrías implementar la lógica para guardar la foto
                          // Por ejemplo, guardarla en el almacenamiento local o asociarla a la lista
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar la foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lista.nombre),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _lista.productos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos en esta lista',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar productos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarLista,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _lista.productos.length,
                    itemBuilder: (context, index) {
                      final producto = _lista.productos[index];
                      final figura = producto.figuraId != null 
                          ? _figurasCache[producto.id] 
                          : null;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: figura != null
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                            child: Icon(
                              figura != null ? Icons.toys : Icons.shopping_bag,
                              color: figura != null
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          title: Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: figura != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (figura.marca.isNotEmpty)
                                      Text('Marca: ${figura.marca}'),
                                    if (figura.lineaExpansion.isNotEmpty)
                                      Text('Línea: ${figura.lineaExpansion}'),
                                  ],
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () => _eliminarProducto(producto),
                            tooltip: 'Eliminar producto',
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _tomarFoto,
            tooltip: 'Tomar Foto',
            heroTag: 'camera',
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _agregarProducto,
            tooltip: 'Agregar Producto',
            heroTag: 'add',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

