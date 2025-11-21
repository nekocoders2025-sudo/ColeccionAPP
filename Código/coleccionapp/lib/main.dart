import 'package:coleccionapp/features/auth/data/firebase_auth_repo.dart';
import 'package:coleccionapp/features/auth/presentation/components/loading.dart';
import 'package:coleccionapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:coleccionapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:coleccionapp/features/auth/presentation/pages/auth_page.dart';
import 'package:coleccionapp/features/home/presentation/pages/home_page.dart';
import 'package:coleccionapp/firebase_options.dart';
import 'package:coleccionapp/themes/dark_mode.dart';
import 'package:coleccionapp/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  //Setup de Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //Iniciar la App
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //Auth Repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //Proveer Cubits a la App
      providers: [
        //Auth Cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()
        )
      ],

      //App
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,

        /*
        BLOC CONSUMER - Auth
        */
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            print(state);

            // No autenticado -- Auth (Login - Registro)
            if (state is Unauthenticated) {
              return const AuthPage();
            }

            // Autenticado -- Inicio
            if (state is Authenticated) {
              return const HomePage();
            }

            // Cargando
            else {
              return const LoadingScreen();
            } 
          }, 

          // Listener para cambios de estado
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          }
        ),
      ),
    );
  }
}