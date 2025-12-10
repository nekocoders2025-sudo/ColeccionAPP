import 'package:coleccionapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:coleccionapp/features/auth/services/user_service.dart';
import 'package:coleccionapp/features/buscador/pages/buscar_figuras_page.dart';
import 'package:coleccionapp/features/lista/pages/lista_listas_page.dart';
import 'package:coleccionapp/features/profile/profile_page.dart';
import 'package:coleccionapp/features/repositorio/pages/repositorio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  
  // logout
  void logout(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    authCubit.logout();
  }

  /*
  // confirm logout
  void confirmLogout(BuildContext context) {
    // pop drawer first
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // yes button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
  */

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // DRAWER
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // header icon
            Container(
              height: 130,
              color: Theme.of(context).colorScheme.secondary,
              child: Image.asset('lib/assets/icon.png'),
            ),

            Divider(
              color: Theme.of(context).colorScheme.tertiary,
              indent: 25,
              endIndent: 25,
            ),

            const SizedBox(height: 25),

            // Inicio
            MyDrawerTile(
              text: "Inicio",
              icon: Icons.home,
              onTap: () => Navigator.pop(context),
            ),

            // Perfil
            MyDrawerTile(
              text: "Perfil",
              icon: Icons.person,
              //onTap: () => Navigator.pop(context), //Eliminar luego de rutear correctamente
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),

            // Mis Colecciones
            MyDrawerTile(
              text: "Mis Colecciones",
              icon: Icons.catching_pokemon,
              //onTap: () => Navigator.pop(context), //Eliminar luego de rutear correctamente
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaListasScreen(),
                  ),
                );
              },
            ),

            // Buscador
            MyDrawerTile(
              text: "Buscar Productos",
              icon: Icons.search,
              //onTap: () => Navigator.pop(context), //Eliminar luego de rutear correctamente
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BuscarFigurasScreen(),
                  ),
                );
              },
            ),

            // Configuración
            MyDrawerTile(
              text: "Configuración",
              icon: Icons.settings,
              onTap: () => Navigator.pop(context), //Eliminar luego de rutear correctamente
              /*onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },*/
            ),

            // Repositorio (solo visible para Admin)
            FutureBuilder<bool>(
              future: UserService().esAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return MyDrawerTile(
                    text: "Repositorio Productos",
                    icon: Icons.storage,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RepositorioScreen(),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const Spacer(),

            // logout tile
            MyDrawerTile(
              text: "Cerrar Sesión",
              icon: Icons.logout,
              onTap: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
              }, 
            
              //icon: Icons.logout,
              //onTap: () => confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}