/*

BACKEND FIREBASE -- Puede ser cambiado desde aquí

*/

import 'package:coleccionapp/features/auth/domain/entities/app_user.dart';
import 'package:coleccionapp/features/auth/domain/repos/auth_repos.dart';
import 'package:coleccionapp/features/auth/models/usuario.dart';
import 'package:coleccionapp/features/auth/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';


class FirebaseAuthRepo implements AuthRepo {
  // Acceso a firebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // INICIO DE SESIÓN: Email & Contraseña
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // Intento inicio de sesión
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // cCrear usuario
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
      );

      // retornar usuario
      return user;
    }

    // Errores
    catch (e) {
      throw Exception('Inicio de Sesión fallido: $e');
    }
  }

  // REGISTRAR: Email & Contraseña
  @override
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      // Intento de Registro
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Crear Usuario
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      // Guardar datos del usuario en Firestore
      final usuario = Usuario(
        usuarioId: userCredential.user!.uid,
        nombre: name,
        correo: email,
        rol: 'User',
      );
      
      try {
        await _userService.crearUsuario(usuario);
      } catch (e) {
        // Si falla guardar en Firestore, no fallar el registro completo
        // pero registrar el error para debugging
        debugPrint('Error al guardar usuario en Firestore: $e');
      }

      // Retornar usuario
      return user;
    }

    // Errores
    catch (e) {
      throw Exception('Registro fallido: $e');
    }
  }

  // BORRAR CUENTA
  @override
  Future<void> deleteAccount() async {
    try {
      // Obtener Current User
      final user = firebaseAuth.currentUser;

      // Revisar si está logeado el usuario
      if (user == null) throw Exception('No hay usuario conectado');

      // Borrar cuenta
      await user.delete();

      // cerrar sesión
      await logout();
    } catch (e) {
      throw Exception('Borrado de Cuenta fallido: $e');
    }
  }

  // GET CURRENT USER
  @override
  Future<AppUser?> getCurrentUser() async {
    // Obtener usuario logeado desde Firebase
    final firebaseUser = firebaseAuth.currentUser;

    // Sin usuario logeado
    if (firebaseUser == null) return null;

    // Usuario logeado
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  // CERRAR SESIÓN
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  // REINICIO DE CONTRASEÑA
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Correo de Reinicio enviado! Revisa tu Email";
    } catch (e) {
      return "Ocurrió un error: $e";
    }
  }

  
  // INICIO DE SESIÓN CON GOOGLE
  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Inicio sesión co Google
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // Usuario cancela login con Google
      if (gUser == null) return null;

      // Obtener detalles de autenticación desde el request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Crear credenciales para el usuario
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken
      );

      // Iniciar sesión con estas credenciales
      UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);

      // Usuario Firebase
      final firebaseUser = userCredential.user;

      // Usuario cancela inicio de sesión en proceso
      if (firebaseUser == null) return null;

      AppUser appUser = AppUser(
        uid: firebaseUser.uid, 
        email: firebaseUser.email ?? '',
      );

      return appUser;
    } 
    
    catch (e) {
      print(e);
      return null;
    }
  }
  
}