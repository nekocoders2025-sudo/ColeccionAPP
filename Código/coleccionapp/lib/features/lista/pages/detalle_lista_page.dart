import 'package:coleccionapp/features/lista/models/lista_productos.dart';
import 'package:coleccionapp/features/lista/models/producto.dart';
import 'package:coleccionapp/features/lista/services/lista_service.dart';
import 'package:coleccionapp/features/repositorio/models/figura_accion.dart';
import 'package:coleccionapp/features/repositorio/services/repositorio_service.dart';
import 'package:coleccionapp/features/seleccionador/pages/seleccionar_figura_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
 
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
    try {
      final listas = await _listaService.obtenerListas();
      final listaActualizada = listas.firstWhere(
        (l) => l.id == _lista.id,
        orElse: () => _lista,
      );

      // Cargar información de figuras del repositorio
      _figurasCache.clear();
      for (final producto in listaActualizada.productos) {
        if (producto.figuraId != null) {
          try {
            final figura = await _repositorioService.obtenerFiguraPorId(producto.figuraId!);
            _figurasCache[producto.id] = figura;
          } catch (e) {
            // Si hay error al cargar una figura, continuar con las demás
            debugPrint('Error al cargar figura ${producto.figuraId}: $e');
          }
        }
      }

      setState(() {
        _lista = listaActualizada;
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
 
  Future<bool?> _preguntarEstadoProducto() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado del Producto'),
        content: const Text('¿Cómo deseas agregar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Deseado
            child: const Text('Deseado'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Obtenido
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Obtenido'),
          ),
        ],
      ),
    );
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
      // Preguntar si es Deseado u Obtenido
      final esObtenida = await _preguntarEstadoProducto();
      if (esObtenida == null) return; // Usuario canceló

      try {
        // Crear producto con referencia a la figura del repositorio
        final nuevoProducto = Producto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nombre: figuraSeleccionada.producto,
          figuraId: figuraSeleccionada.id,
          obtenida: esObtenida,
        );
        await _listaService.agregarProducto(_lista.id, nuevoProducto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto agregado como ${esObtenida ? "Obtenido" : "Deseado"}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarLista();
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
 
  Future<void> _buscarYAgregarProductoPorNombre(String nombreProducto) async {
    try {
      // Obtener todas las figuras del repositorio
      final todasLasFiguras = await _repositorioService.obtenerFiguras();
      
      // Buscar figura que coincida con el nombre del producto (búsqueda case-insensitive)
      final figuraEncontrada = todasLasFiguras.firstWhere(
        (figura) => figura.producto.toLowerCase().trim() == nombreProducto.toLowerCase().trim(),
        orElse: () => throw Exception('No se encontró ninguna figura con el nombre "$nombreProducto"'),
      );

      // Verificar que la figura no esté ya en la lista
      final figuraIdsExistentes = _lista.productos
          .where((p) => p.figuraId != null)
          .map((p) => p.figuraId!)
          .toList();
      
      if (figuraIdsExistentes.contains(figuraEncontrada.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta figura ya está en la lista'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Preguntar si es Deseado u Obtenido
      final esObtenida = await _preguntarEstadoProducto();
      if (esObtenida == null) return; // Usuario canceló

      // Crear producto con referencia a la figura del repositorio
      final nuevoProducto = Producto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: figuraEncontrada.producto,
        figuraId: figuraEncontrada.id,
        obtenida: esObtenida,
      );
      
      await _listaService.agregarProducto(_lista.id, nuevoProducto);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto agregado como ${esObtenida ? "Obtenido" : "Deseado"}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      _cargarLista();
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

  Future<void> _cambiarEstadoProducto(Producto producto, bool nuevoEstado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Text(
          '¿Deseas cambiar el estado de "${producto.nombre}" a ${nuevoEstado ? "Obtenido" : "Deseado"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: nuevoEstado ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(nuevoEstado ? 'Marcar como Obtenido' : 'Marcar como Deseado'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final productoActualizado = producto.copyWith(obtenida: nuevoEstado);
        await _listaService.actualizarProducto(_lista.id, productoActualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Estado cambiado a ${nuevoEstado ? "Obtenido" : "Deseado"}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarLista();
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
      try {
        await _listaService.eliminarProducto(_lista.id, producto.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarLista();
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

    // Verificar y solicitar permisos según la opción seleccionada
    bool tienePermiso = false;
    
    if (opcion == ImageSource.camera) {
      // Verificar permiso de cámara
      var estado = await Permission.camera.status;
      if (estado.isDenied) {
        estado = await Permission.camera.request();
      }
      
      if (estado.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El permiso de cámara fue denegado permanentemente. Por favor, habilítalo en la configuración de la aplicación.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      tienePermiso = estado.isGranted;
    } else if (opcion == ImageSource.gallery) {
      // Verificar permiso de galería (photos para Android 13+, storage para versiones anteriores)
      // Intentar con photos primero (Android 13+)
      var estadoPhotos = await Permission.photos.status;
      if (estadoPhotos.isDenied) {
        estadoPhotos = await Permission.photos.request();
      }
      
      if (estadoPhotos.isGranted) {
        tienePermiso = true;
      } else {
        // Si photos no está disponible o fue denegado, intentar con storage
        var estadoStorage = await Permission.storage.status;
        if (estadoStorage.isDenied) {
          estadoStorage = await Permission.storage.request();
        }
        
        if (estadoStorage.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El permiso de galería fue denegado permanentemente. Por favor, habilítalo en la configuración de la aplicación.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }
        
        tienePermiso = estadoStorage.isGranted;
      }
    }

    if (!tienePermiso) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se requiere permiso de ${opcion == ImageSource.camera ? 'cámara' : 'galería'} para continuar.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

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
                        onPressed: () async {
                          // Mostrar indicador de carga
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
 
                          try {
                            // Convertir imagen a base64
                            final bytes = await File(foto.path).readAsBytes();
                            final base64Image = base64Encode(bytes);
 
                            // Enviar a Roboflow
                            final response = await http.post(
                              Uri.parse('https://detect.roboflow.com/infer/workflows/card-bwqhq/coleccionapp'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                "api_key": "vE4Kq3O7BDClEx0K9F2p",
                                "inputs": {
                                  "image": {"type": "base64", "value": base64Image}
                                }
                              }),
                            );
 
                            if (context.mounted) {
                              Navigator.pop(context); // Cerrar loading
 
                              if (response.statusCode == 200) {
                                final data = jsonDecode(response.body);
                                // Navegar de forma segura por la estructura del JSON
                                String? predictionClass;
                                try {
                                  final outputs = data['outputs'] as List;
                                  if (outputs.isNotEmpty) {
                                    final firstOutput = outputs[0];
                                    final predictions = firstOutput['predictions'];
                                    // predictions puede ser un mapa con una clave 'predictions' que es una lista
                                    // o directamente una lista, dependiendo de la estructura exacta.
                                    // Basado en el prompt: .outputs[0]?.predictions.predictions.class
                                    // Asumimos que 'predictions' es un objeto que contiene una lista 'predictions'
 
                                    if (predictions is Map && predictions.containsKey('predictions')) {
                                       final innerPredictions = predictions['predictions'] as List;
                                       if (innerPredictions.isNotEmpty) {
                                         predictionClass = innerPredictions[0]['class'];
                                       }
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('Error parsing response: $e');
                                }
 
                                if (predictionClass != null) {
                                  // Mostrar resultado
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Resultado del análisis'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Predicción: $predictionClass'),
                                          const SizedBox(height: 16),
                                          const Text('¿Es correcta esta predicción?'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('No'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context); // Cerrar diálogo de resultado
                                            Navigator.pop(context); // Cerrar diálogo de foto
                                            
                                            // Buscar y agregar el producto a la lista
                                            final nombreProducto = predictionClass;
                                            if (context.mounted && nombreProducto != null) {
                                              await _buscarYAgregarProductoPorNombre(nombreProducto);
                                            }
                                          },
                                          child: const Text('Sí'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No se pudo identificar el objeto')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error del servidor: ${response.statusCode}')),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Cerrar loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Analizar y Guardar'),
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
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
                              figura != null ? Icons.smart_toy_outlined : Icons.shopping_bag,
                              color: figura != null
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Estado del producto (Deseado/Obtenido)
                              Row(
                                children: [
                                  Icon(
                                    producto.obtenida ? Icons.check_circle : Icons.favorite,
                                    size: 16,
                                    color: producto.obtenida ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    producto.obtenida ? 'Obtenido' : 'Deseado',
                                    style: TextStyle(
                                      color: producto.obtenida ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // Información de la figura si existe
                              if (figura != null) ...[
                                if (figura.marca.isNotEmpty)
                                  Text('Marca: ${figura.marca}'),
                                if (figura.lineaExpansion.isNotEmpty)
                                  Text('Línea: ${figura.lineaExpansion}'),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Checkbox para cambiar estado
                              Checkbox(
                                value: producto.obtenida,
                                onChanged: (bool? nuevoValor) {
                                  if (nuevoValor != null) {
                                    _cambiarEstadoProducto(producto, nuevoValor);
                                  }
                                },
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                              ),
                              // Botón eliminar
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _eliminarProducto(producto),
                                tooltip: 'Eliminar producto',
                              ),
                            ],
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
 
 