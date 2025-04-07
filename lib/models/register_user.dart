class RegisterUser {
  final int id;
  final String email;
  final String nombre;
  final String apellido;
  final String telefono;
  final String? tokenDevice;
  final String? password; // Solo incluido en la petición, no en la respuesta

  RegisterUser({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    this.tokenDevice,
    this.password,
  });

  // Constructor para crear una instancia para el registro
  factory RegisterUser.forRegistration({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String telefono,
  }) {
    return RegisterUser(
      id: 0, // ID temporal, se actualizará con la respuesta del servidor
      nombre: nombre,
      apellido: apellido,
      email: email,
      telefono: telefono,
      password: password,
    );
  }

  // Constructor desde JSON para la respuesta del servidor
  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    // Imprimir el JSON recibido para depuración
    print('⚙️ Parseando RegisterUser.fromJson:');
    print(json);

    // Manejar casos donde el id podría venir como string
    var userId = json['id'];
    if (userId is String) {
      userId = int.tryParse(userId) ?? 0;
    } else if (userId == null) {
      userId = 0;
    }

    return RegisterUser(
      id: userId,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      telefono: json['telefono'] ?? '',
      tokenDevice: json['tokenDevice'],
      // No incluimos la contraseña en fromJson ya que no viene en la respuesta
    );
  }

  // Convertir a JSON para enviar al servidor
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
    };

    // Solo incluimos la contraseña si está definida
    if (password != null) {
      data['password'] = password;
    }

    return data;
  }

  // Convertir a User después del registro exitoso
  User toUser() {
    return User(
      id: id,
      email: email,
      nombre: nombre,
      apellido: apellido,
    );
  }

  @override
  String toString() {
    return 'RegisterUser(id: $id, nombre: $nombre, apellido: $apellido, email: $email, telefono: $telefono)';
  }
}

// Modelo User existente para mantener compatibilidad
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
    // Manejar casos donde el id podría venir como string
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
