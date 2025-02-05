import 'package:dio/dio.dart';
import '../models/personal_note.dart';
import 'dio_client.dart';

class PersonalNotesService {
  final DioClient _dioClient = DioClient();

  Future<List<PersonalNote>> getPersonalNotes(String email) async {
    try {
      print('🔄 Obteniendo apuntes personales');
      print('Email: $email');

      final response = await _dioClient.dio.get(
        '/apunte/by-user/$email',
      );

      print('✅ Apuntes personales obtenidos:');
      print('Status code: ${response.statusCode}');

      if (response.data != null) {
        List<dynamic> notesData = response.data;
        return notesData.map((noteData) {
          // No necesitamos transformar la estructura, usamos directamente el noteData
          return PersonalNote.fromJson(noteData);
        }).toList();
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } on DioException catch (e) {
      print('❌ Error al obtener apuntes personales:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      throw Exception(
          e.response?.data['message'] ?? 'Error al obtener apuntes personales');
    } catch (e) {
      print('❌ Error inesperado al obtener apuntes: $e');
      rethrow;
    }
  }
}
