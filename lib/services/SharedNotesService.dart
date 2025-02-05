// lib/services/shared_notes_service.dart

import 'package:dio/dio.dart';
import '../models/shared_note.dart';
import 'dio_client.dart';

class SharedNotesService {
  final DioClient _dioClient = DioClient();

  Future<List<SharedNote>> getSharedNotes(String email) async {
    try {
      print('🔄 Obteniendo notas compartidas');
      print('Email: $email');

      final response = await _dioClient.dio.get(
        '/apuntescompartido/user/email/$email',
      );

      print('✅ Notas compartidas obtenidas:');
      print('Status code: ${response.statusCode}');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> notesData = response.data['data'];
        return notesData.map((note) => SharedNote.fromJson(note)).toList();
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } on DioException catch (e) {
      print('❌ Error al obtener notas compartidas:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      throw Exception(
          e.response?.data['message'] ?? 'Error al obtener notas compartidas');
    } catch (e) {
      print('❌ Error inesperado al obtener notas: $e');
      rethrow;
    }
  }

  // Método para compartir una nueva nota
  Future<SharedNote> shareNote({
    required String nombreApunte,
    required String url,
    required String userEmail,
  }) async {
    try {
      print('🔄 Compartiendo nueva nota');
      print('Nombre: $nombreApunte');
      print('URL: $url');
      print('Email: $userEmail');

      final response = await _dioClient.dio.post(
        '/apuntescompartido/create',
        data: {
          'nombreApunte': nombreApunte,
          'url': url,
          'userEmail': userEmail,
        },
      );

      print('✅ Nota compartida exitosamente');
      print('Status code: ${response.statusCode}');

      return SharedNote.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('❌ Error al compartir nota:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      throw Exception(e.response?.data['message'] ?? 'Error al compartir nota');
    } catch (e) {
      print('❌ Error inesperado al compartir nota: $e');
      rethrow;
    }
  }

  // Método para eliminar una nota compartida
  Future<void> deleteSharedNote(int noteId) async {
    try {
      print('🔄 Eliminando nota compartida');
      print('ID: $noteId');

      final response = await _dioClient.dio.delete(
        '/apuntescompartido/delete/$noteId',
      );

      print('✅ Nota eliminada exitosamente');
      print('Status code: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Error al eliminar nota:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      throw Exception(e.response?.data['message'] ?? 'Error al eliminar nota');
    } catch (e) {
      print('❌ Error inesperado al eliminar nota: $e');
      rethrow;
    }
  }
}
