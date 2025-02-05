class PersonalNote {
  final int id;
  final String titulo;
  final Map<String, dynamic> contenido;

  PersonalNote({
    required this.id,
    required this.titulo,
    required this.contenido,
  });

  factory PersonalNote.fromJson(Map<String, dynamic> json) {
    return PersonalNote(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? {},
    );
  }
}
