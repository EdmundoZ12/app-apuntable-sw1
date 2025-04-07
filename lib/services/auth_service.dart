import 'package:dio/dio.dart';
import '../models/user.dart';
import 'dio_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final DioClient _dioClient = DioClient();

  Future<void> saveTokenDevice({
    required String email,
    required String? tokenDevice,
  }) async {
    try {
      print('🔄 Actualizando token del dispositivo');
      print('Email: $email');
      print('Token: $tokenDevice');

      final response = await _dioClient.dio.post(
        '/auth/update-token',
        data: {
          'email': email,
          'tokenDevice': tokenDevice,
        },
      );

      print('✅ Token actualizado correctamente');
      print('Status code: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Error al actualizar token:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Error al actualizar token');
    } catch (e) {
      print('❌ Error inesperado al actualizar token: $e');
      rethrow;
    }
  }

  Future<User> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      print('🚀 Iniciando registro con datos:');
      print({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
      });

      // Asegurar que todos los valores estén limpios antes de enviar
      final Map<String, dynamic> requestData = {
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'email': email.trim(),
        'password': password,
        'telefono': telefono.trim(),
      };

      print('📤 Enviando datos al servidor:');
      print(requestData);

      final response = await _dioClient.dio.post(
        '/usuarios/register',
        data: requestData,
      );

      print('✅ Registro exitoso:');
      print('Status code: ${response.statusCode}');
      print('Data: ${response.data}');

      // Crear un objeto User a partir de la respuesta
      final user = User.fromJson(response.data);
      print(
          '👤 Usuario creado: ${user.nombre} ${user.apellido} (ID: ${user.id})');

      // Intentar obtener y guardar el token FCM
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          print('🔔 Guardando token FCM para el nuevo usuario: $fcmToken');
          await saveTokenDevice(
            email: email,
            tokenDevice: fcmToken,
          );
        }
      } catch (e) {
        print('⚠️ No se pudo guardar el token FCM: $e');
        // No lanzamos excepción aquí para que no falle el registro
      }

      return user;
    } on DioException catch (e) {
      print('❌ Error DioException en registro:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Datos inválidos');
      } else if (e.response?.statusCode == 409) {
        throw Exception('El usuario ya existe');
      } else {
        throw Exception(e.response?.data['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      print('❌ Error general en registro: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Iniciando login');
      print('Email: $email');

      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ Respuesta del servidor:');
      print(response.data);

      if (response.data['payload'] == null || response.data['token'] == null) {
        throw Exception('Formato de respuesta inválido');
      }

      final User user = User.fromJson(response.data['payload']);
      final String token = response.data['token'];

      // Obtener y guardar token FCM después del login exitoso
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('🔔 Token FCM:');
      print(fcmToken);

      // Guardar el token del dispositivo en el servidor
      if (fcmToken != null) {
        await saveTokenDevice(
          email: email,
          tokenDevice: fcmToken,
        );
      }

      return {
        'user': user,
        'token': token,
      };
    } on DioException catch (e) {
      print('❌ Error en login:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Email o contraseña incorrectos');
      } else {
        throw Exception(e.response?.data['message'] ?? 'Error en el servidor');
      }
    } catch (e) {
      print('❌ Error inesperado: $e');
      rethrow;
    }
  }

  Future<void> logout(String email) async {
    try {
      // Eliminar el token del dispositivo en el servidor
      await saveTokenDevice(
        email: email,
        tokenDevice: null,
      );

      print('✅ Logout exitoso');
    } catch (e) {
      print('❌ Error al hacer logout: $e');
      rethrow;
    }
  }
}
