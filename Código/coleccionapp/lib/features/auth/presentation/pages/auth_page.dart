/*

Página Autenticación - Determina si mostrar Login o Registrar

*/

import 'package:coleccionapp/features/auth/presentation/pages/login_page.dart';
import 'package:coleccionapp/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Inicialmente mostrar LOGIN
  bool showLoginPage = true;

  // Cmabiar entre páginas
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        togglePages: togglePages,
      );
    } else {
      return RegisterPage(
        togglePages: togglePages,
      );
    }
  }
}