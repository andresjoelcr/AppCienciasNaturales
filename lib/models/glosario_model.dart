import 'package:flutter/material.dart';

/// Categorias de terminos del glosario
enum CategoriaTermino {
  organelo,
  proceso,
  estructura,
  tipoCelula,
  molecula,
}

extension CategoriaTerminoExtension on CategoriaTermino {
  String get nombre {
    switch (this) {
      case CategoriaTermino.organelo:
        return 'Organelos';
      case CategoriaTermino.proceso:
        return 'Procesos';
      case CategoriaTermino.estructura:
        return 'Estructuras';
      case CategoriaTermino.tipoCelula:
        return 'Tipos de Celula';
      case CategoriaTermino.molecula:
        return 'Moleculas';
    }
  }

  IconData get icono {
    switch (this) {
      case CategoriaTermino.organelo:
        return Icons.blur_circular;
      case CategoriaTermino.proceso:
        return Icons.sync;
      case CategoriaTermino.estructura:
        return Icons.account_tree;
      case CategoriaTermino.tipoCelula:
        return Icons.category;
      case CategoriaTermino.molecula:
        return Icons.science;
    }
  }

  Color get color {
    switch (this) {
      case CategoriaTermino.organelo:
        return Colors.purple;
      case CategoriaTermino.proceso:
        return Colors.orange;
      case CategoriaTermino.estructura:
        return Colors.blue;
      case CategoriaTermino.tipoCelula:
        return Colors.green;
      case CategoriaTermino.molecula:
        return Colors.red;
    }
  }
}

/// Modelo para un termino del glosario
class TerminoGlosario {
  final String id;
  final String termino;
  final String definicion;
  final CategoriaTermino categoria;
  final String? imagenAsset;
  final String? datoCurioso;
  final List<String> subtemasRelacionados;
  final String? pronunciacion;

  const TerminoGlosario({
    required this.id,
    required this.termino,
    required this.definicion,
    required this.categoria,
    this.imagenAsset,
    this.datoCurioso,
    this.subtemasRelacionados = const [],
    this.pronunciacion,
  });

  /// Obtiene la primera letra del termino (para agrupacion A-Z)
  String get letraInicial => termino[0].toUpperCase();
}
