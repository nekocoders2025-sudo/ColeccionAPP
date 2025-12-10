import 'package:coleccionapp/components/drawer.dart';
import 'package:coleccionapp/features/buscador/pages/buscar_figuras_page.dart';
import 'package:coleccionapp/features/lista/models/lista_productos.dart';
import 'package:coleccionapp/features/lista/pages/detalle_lista_page.dart';
import 'package:coleccionapp/features/lista/pages/lista_listas_page.dart';
import 'package:coleccionapp/features/lista/services/lista_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ListaService _listaService = ListaService();
  List<ListaProductos> _listas = [];
  bool _cargandoListas = true;

  @override
  void initState() {
    super.initState();
    _cargarListas();
  }

  Future<void> _cargarListas() async {
    setState(() {
      _cargandoListas = true;
    });
    try {
      final listas = await _listaService.obtenerListas();
      setState(() {
        _listas = listas;
        _cargandoListas = false;
      });
    } catch (e) {
      setState(() {
        _cargandoListas = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [],
      ),

      // DRAWER
      drawer: const MyDrawer(),

      // BODY
      body: RefreshIndicator(
        onRefresh: _cargarListas,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de bienvenida
              Center(
                child: Text(
                  'Bienvenido a Coleccion APP',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Botón Buscar Figuras
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuscarFigurasScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search, size: 32),
                  label: const Text(
                    'Buscar Figuras',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 80),

              // Sección Mis Colecciones
              Text(
                'Mis Colecciones',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Carrusel de colecciones
              _cargandoListas
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _listas.isEmpty
                      ? Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.collections_bookmark_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No tienes colecciones aún',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _listas.length,
                            itemBuilder: (context, index) {
                              final lista = _listas[index];
                              return Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 16),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
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
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                child: Icon(
                                                  Icons.list,
                                                  color: Theme.of(context).colorScheme.secondary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  lista.nombre,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '${lista.productos.length} producto${lista.productos.length != 1 ? 's' : ''}',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Porcentaje de completitud
                                          Builder(
                                            builder: (context) {
                                              final porcentaje = _calcularPorcentajeCompletitud(lista);
                                              final color = _obtenerColorPorcentaje(porcentaje);
                                              return Column(
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
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 24),

              // Botón Ver Todas las Colecciones
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListaListasScreen(),
                      ),
                    ).then((_) => _cargarListas());
                  },
                  icon: const Icon(Icons.collections_bookmark, size: 24),
                  label: const Text(
                    'Ver Todas mis Colecciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}