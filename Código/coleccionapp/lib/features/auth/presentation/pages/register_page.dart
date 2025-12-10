import 'package:coleccionapp/features/auth/presentation/components/my_button.dart';
import 'package:coleccionapp/features/auth/presentation/components/my_textfield.dart';
import 'package:coleccionapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de Texto
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  // Botón Registrar Presionado
  void register() async {
    // Preparar info de registro
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    // Auth cubit
    final authCubit = context.read<AuthCubit>();

    // Validar que los campos no están vacíos
    if (email.isNotEmpty &&
        name.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {
      // Validar que las contraseñas coincidan
      if (pw == confirmPw) {
        authCubit.register(name, email, pw);
      }

      // Contraseñas No coinciden
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Las Contraseñas NO coinciden!")));
      }
    }
    // Campos vacíos
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debe llenar todos los campos!")));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      // BODY
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 225,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Image.asset('lib/assets/icon.png'),
                ),

                const SizedBox(height: 25),

                // Nombre de pantalla
                Text(
                  "Crea tu nueva cuenta",
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 25),

                // Campo Nombre
                MyTextfield(
                  controller: nameController,
                  hintText: "Nombre",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Campo Email
                MyTextfield(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Campo Contraseña
                MyTextfield(
                  controller: pwController,
                  hintText: "Contraseña",
                  obscureText: true,
                  showTogglePassword: true,
                ),

                const SizedBox(height: 10),

                // Campo Confirmar Contraseña
                MyTextfield(
                  controller: confirmPwController,
                  hintText: "Confirmar Contraseña",
                  obscureText: true,
                  showTogglePassword: true,
                ),

                const SizedBox(height: 25),

                // Botón Registrar
                MyButton(
                  onTap: register,
                  text: "REGISTRARSE",
                ),

                const SizedBox(height: 25),


                // Volver a Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ya tienes cuenta?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        " Iniciar Sesión",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}