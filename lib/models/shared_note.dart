// lib/models/shared_note.dart

class SharedNote {
  final int id;
  final String nombreApunte;
  final String url;
  final Usuario usuario;

  SharedNote({
    required this.id,
    required this.nombreApunte,
    required this.url,
    required this.usuario,
  });

  factory SharedNote.fromJson(Map<String, dynamic> json) {
    return SharedNote(
      id: json['id'],
      nombreApunte: json['nombreApunte'],
      url: json['url'],
      usuario: Usuario.fromJson(json['usuario']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreApunte': nombreApunte,
      'url': url,
      'usuario': usuario.toJson(),
    };
  }
}

class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
    };
  }
}
