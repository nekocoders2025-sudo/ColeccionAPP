/*

UI PÁGINA DE LGIN

Usuario puede iniciar sesión con:
  -Email
  -Contraseña
--------------------------------------------------------------------------------

Cuando se inicia sesión se redirige a página de Inicio

Si usuario no tiene cuenta puede Registrarse

*/

import 'package:coleccionapp/features/auth/presentation/components/google_sign_in_button.dart';
import 'package:coleccionapp/features/auth/presentation/components/my_button.dart';
import 'package:coleccionapp/features/auth/presentation/components/my_textfield.dart';
import 'package:coleccionapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores de texto
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  // Auth cubit
  late final authCubit = context.read<AuthCubit>();

  // Botón inicio de sesión presionado
  void login() {
    // Preparar Email y Contraseña
    final String email = emailController.text;
    final String pw = pwController.text;

    // Verificar campos llenados
    if (email.isNotEmpty && pw.isNotEmpty) {
      // Inicio de sesión
      authCubit.login(email, pw);
    }

    // Campos vacíos
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debe ingresar Email y Contraseña.")));
    }
  }

  // Ventana Olvisaste contraseña
  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reiniciar Contraseña?"),
        content: MyTextfield(
          controller: emailController,
          hintText: "Ingresar Email",
          obscureText: false,
        ),
        actions: [
          // Botón Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),

          // Botón Aceptar
          TextButton(
            onPressed: () async {
              String message =
                  await authCubit.forgotPassword(emailController.text);

              if (message == "Correo de Reinicio enviado! Revisa tu Email") {
                Navigator.pop(context);
                emailController.clear();
              }

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      // BODY
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Logo
                  Container(
                    height: 180,
                    color: Theme.of(context).colorScheme.primary,
                    child: Image.asset('lib/assets/icon.png'),
                  ),

                  const SizedBox(height: 25),

                  // Nombre de la App
                  Text(
                    "C O L E C C I O N  A P P",
                    style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Campo de texto Email
                  MyTextfield(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // Campo de texto Contraseña
                  MyTextfield(
                    controller: pwController,
                    hintText: "Contraseña",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // Olvidaste tu contraseña
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => openForgotPasswordBox(),
                        child: Text(
                          "Olvidaste tu Contraseña?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Botón Iniciar Sesión
                  MyButton(
                    onTap: login,
                    text: "INICIAR SESIÓN",
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          "O inicia sesión con",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Inicio Google
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      MyGoogleSignInButton(
                        onTap: () async {
                          authCubit.signInWithGoogle();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Registrar cuenta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No tienes cuenta?",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Registrate ahora",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}