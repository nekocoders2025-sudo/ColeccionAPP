import 'package:coleccionapp/features/auth/services/user_service.dart';
import 'package:coleccionapp/features/buscador/pages/buscar_figuras_page.dart';
import 'package:coleccionapp/features/lista/models/lista_productos.dart';
import 'package:coleccionapp/features/lista/pages/detalle_lista_page.dart';
import 'package:coleccionapp/features/lista/services/lista_service.dart';
import 'package:coleccionapp/features/repositorio/pages/repositorio_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ListaListasScreen extends StatefulWidget {
  const ListaListasScreen({super.key});

  @override
  State<ListaListasScreen> createState() => _ListaListasScreenState();
}

class _ListaListasScreenState extends State<ListaListasScreen> {
  final ListaService _listaService = ListaService();
  final UserService _userService = UserService();
  List<ListaProductos> _listas = [];
  bool _cargando = true;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _verificarRolAdmin();
    _cargarListas();
  }

  Future<void> _verificarRolAdmin() async {
    final esAdmin = await _userService.esAdmin();
    setState(() {
      _esAdmin = esAdmin;
    });
  }

  Future<void> _cargarListas() async {
    setState(() {
      _cargando = true;
    });
    try {
      final listas = await _listaService.obtenerListas();
      setState(() {
        _listas = listas;
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

  Future<void> _crearNuevaLista() async {
    final TextEditingController nombreController = TextEditingController();
    
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Lista'),
        content: TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la lista',
            hintText: 'Ej: Lista de compras',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.trim().isNotEmpty) {
                Navigator.pop(context, nombreController.text.trim());
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (resultado != null && resultado.isNotEmpty) {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario no autenticado. Por favor, inicia sesión.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final nuevaLista = ListaProductos(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          nombre: resultado,
        );
        await _listaService.agregarLista(nuevaLista);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lista creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarListas();
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

  Future<void> _editarNombreLista(ListaProductos lista) async {
    final TextEditingController nombreController = 
        TextEditingController(text: lista.nombre);
    
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nombre'),
        content: TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la lista',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.trim().isNotEmpty) {
                Navigator.pop(context, nombreController.text.trim());
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null && resultado.isNotEmpty) {
      try {
        final listaActualizada = lista.copyWith(nombre: resultado);
        await _listaService.actualizarLista(listaActualizada);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lista actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarListas();
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

  // Calcular porcentaje de completitud
  double _calcularPorcentajeCompletitud(ListaProductos lista) {
    if (lista.productos.isEmpty) return 0.0;
    final productosObtenidos = lista.productos.where((p) => p.obtenida).length;
    return (productosObtenidos / lista.productos.length) * 100;
  }

  // Obtener color según el porcentaje de completitud
  Color _obtenerColorPorcentaje(double porcentaje) {
    if (porcentaje >= 0 && porcentaje <= 25) {
      return Colors.red;
    } else if (porcentaje > 25 && porcentaje < 100) {
      return Colors.orange;
    } else if (porcentaje == 100) {
      return Colors.green;
    }
    return Colors.grey; // Fallback
  }

  Future<void> _eliminarLista(ListaProductos lista) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la lista "${lista.nombre}"?',
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
        await _listaService.eliminarLista(lista.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lista eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarListas();
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
        title: const Text('Mis Colecciones'),
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
            },
          ),
          if (_esAdmin)
            IconButton(
              icon: const Icon(Icons.collections),
              tooltip: 'Repositorio de Figuras',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RepositorioScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _listas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay listas creadas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para crear una nueva lista',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarListas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _listas.length,
                    itemBuilder: (context, index) {
                      final lista = _listas[index];
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
                              Icons.list,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          title: Text(
                            lista.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${lista.productos.length} producto${lista.productos.length != 1 ? 's' : ''}',
                              ),
                              const SizedBox(height: 8),
                              // Porcentaje de completitud
                              Builder(
                                builder: (context) {
                                  final porcentaje = _calcularPorcentajeCompletitud(lista);
                                  final color = _obtenerColorPorcentaje(porcentaje);
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${porcentaje.toStringAsFixed(0)}% completado',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // Barra de progreso
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: lista.productos.isEmpty 
                                                    ? 0.0 
                                                    : porcentaje / 100,
                                                minHeight: 6,
                                                backgroundColor: Colors.grey[300],
                                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Editar nombre'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'eliminar',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar lista', 
                                      style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'editar') {
                                _editarNombreLista(lista);
                              } else if (value == 'eliminar') {
                                _eliminarLista(lista);
                              }
                            },
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleListaScreen(
                                  lista: lista,
                                ),
                              ),
                            );
                            _cargarListas();
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearNuevaLista,
        tooltip: 'Nueva Lista',
        child: const Icon(Icons.add),
      ),
    );
  }
}

