import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

/// Categorias de terminos del glosario
enum CategoriaTermino { organelo, proceso, estructura, tipoCelula, molecula }

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
        return 'Tipos de célula';
      case CategoriaTermino.molecula:
        return 'Moléculas';
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
        return BrandColors.forest;
      case CategoriaTermino.proceso:
        return BrandColors.forest;
      case CategoriaTermino.estructura:
        return BrandColors.forest;
      case CategoriaTermino.tipoCelula:
        return BrandColors.forest;
      case CategoriaTermino.molecula:
        return BrandColors.forest;
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
