import 'package:coleccionapp/components/drawer.dart';
import 'package:coleccionapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coleccion App'),
        actions: [
          // Botón Cerrar Sesión
          IconButton(
            onPressed: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            }, 
            icon: const Icon(Icons.logout))
        ],
      ),
      
      // DRAWER
      drawer: const MyDrawer(),

    );
  }
}