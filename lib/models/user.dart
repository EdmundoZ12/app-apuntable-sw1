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
    return User(
      id: json['id'] ?? 0,
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
}