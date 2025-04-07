class User {
  final int id;
  final String email;
  final String nombre;
  final String apellido;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Imprimir el JSON para depuración
    print('⚙️ Parseando User.fromJson:');
    print(json);

    // Manejar casos donde el id podría venir como string o ser nulo
    var userId = json['id'];
    if (userId is String) {
      userId = int.tryParse(userId) ?? 0;
    } else if (userId == null) {
      userId = 0;
    }

    return User(
      id: userId,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, nombre: $nombre, apellido: $apellido, email: $email)';
  }
}
