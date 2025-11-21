import 'package:coleccionapp/features/buscador/pages/buscar_figuras_page.dart';
import 'package:coleccionapp/features/lista/models/lista_productos.dart';
import 'package:coleccionapp/features/lista/pages/detalle_lista_page.dart';
import 'package:coleccionapp/features/lista/services/lista_service.dart';
import 'package:coleccionapp/features/repositorio/pages/repositorio_page.dart';
import 'package:flutter/material.dart';


class ListaListasScreen extends StatefulWidget {
  const ListaListasScreen({super.key});

  @override
  State<ListaListasScreen> createState() => _ListaListasScreenState();
}

class _ListaListasScreenState extends State<ListaListasScreen> {
  final ListaService _listaService = ListaService();
  List<ListaProductos> _listas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarListas();
  }

  Future<void> _cargarListas() async {
    setState(() {
      _cargando = true;
    });
    final listas = await _listaService.obtenerListas();
    setState(() {
      _listas = listas;
      _cargando = false;
    });
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
      final nuevaLista = ListaProductos(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: resultado,
      );
      await _listaService.agregarLista(nuevaLista);
      _cargarListas();
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
      final listaActualizada = lista.copyWith(nombre: resultado);
      await _listaService.actualizarLista(listaActualizada);
      _cargarListas();
    }
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
      await _listaService.eliminarLista(lista.id);
      _cargarListas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ColeccionApp'),
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
            },
          ),
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            lista.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${lista.productos.length} producto${lista.productos.length != 1 ? 's' : ''}',
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

