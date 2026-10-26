import 'package:flutter/material.dart';
import '../models/subtema_model.dart';
import '../theme/app_theme.dart';
import 'video_youtube_card.dart';

/// Tarjeta interactiva para presentar una funcion vital de la celula.
///
/// Muestra un concepto base, bloques internos (comparativos o secuencias) y
/// una nota importante enmarcada. El encabezado permite contraer o expandir
/// el contenido manteniendo la linea visual de la guia.
class TarjetaFuncionVital extends StatefulWidget {
  final ContenidoSeccion seccion;

  const TarjetaFuncionVital({super.key, required this.seccion});

  @override
  State<TarjetaFuncionVital> createState() => _TarjetaFuncionVitalState();
}

class _TarjetaFuncionVitalState extends State<TarjetaFuncionVital> {
  bool _expandida = true;

  String get _titulo => widget.seccion.titulo ?? '';

  Color get _acento {
    switch (_titulo.toLowerCase()) {
      case 'reproduccion':
      case 'reproducción':
        return AppColors.sunOrange;
      case 'relacion':
      case 'relación':
        return AppColors.earthBrown;
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData get _icono {
    switch (_titulo.toLowerCase()) {
      case 'reproduccion':
      case 'reproducción':
        return Icons.biotech_rounded;
      case 'relacion':
      case 'relación':
        return Icons.sensors_rounded;
      default:
        return Icons.bubble_chart_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _acento.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: _acento.withOpacity(0.06),
              child: InkWell(
                onTap: () => setState(() => _expandida = !_expandida),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _acento.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_icono, color: _acento, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _titulo,
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.darkText,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expandida ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _acento,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _expandida
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildContenido(),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildConceptoBase(),
        ...?widget.seccion.bloques?.map(_buildBloque),
        if ((widget.seccion.notaImportante ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildNotaImportante(widget.seccion.notaImportante!),
        ],
      ],
    );
  }

  Widget _buildConceptoBase() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _acento.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: _acento, size: 18),
              const SizedBox(width: 6),
              Text(
                'Concepto base',
                style: AppTextStyles.caption.copyWith(
                  color: _acento,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.seccion.contenido,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloque(ContenidoSeccion bloque) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: switch (bloque.tipo) {
        'comparativo' => _buildComparativo(bloque),
        'mapa_conceptual' => _buildMapaConceptual(bloque),
        'pasos' => _buildPasos(bloque),
        'titulo' => _buildTituloSeccion(bloque),
        'texto' => _buildTexto(bloque),
        'video' => _buildVideo(bloque),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildTituloSeccion(ContenidoSeccion bloque) {
    return Text(
      bloque.contenido,
      textAlign: TextAlign.center,
      style: AppTextStyles.heading3.copyWith(color: _acento, fontSize: 16),
    );
  }

  Widget _buildTexto(ContenidoSeccion bloque) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBloqueTitulo(bloque),
        if (bloque.contenido.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _acento.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _acento.withOpacity(0.28)),
            ),
            child: Text(
              bloque.contenido,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkText,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideo(ContenidoSeccion bloque) {
    final titulo = (bloque.items != null && bloque.items!.isNotEmpty)
        ? bloque.items!.first
        : (bloque.titulo ?? 'Video explicativo');
    return VideoYoutubeCard(url: bloque.contenido, titulo: titulo);
  }

  Widget _buildBloqueTitulo(ContenidoSeccion bloque) {
    final titulo = bloque.titulo ?? '';
    if (titulo.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _acento, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapaConceptual(ContenidoSeccion bloque) {
    final etiquetas = bloque.contenido.split('|');
    final descripciones = bloque.items ?? [];
    const colores = [AppColors.primaryGreen, AppColors.sunOrange];
    const separacion = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBloqueTitulo(bloque),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: _acento,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _acento.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nutrición',
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 32,
          width: double.infinity,
          child: CustomPaint(
            painter: _ConectorMapaNutricion(
              color: _acento.withOpacity(0.45),
              separacion: separacion,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < etiquetas.length; i++) ...[
              if (i > 0) const SizedBox(width: separacion),
              Expanded(
                child: _buildNodoMapa(
                  etiquetas[i].trim(),
                  i < descripciones.length ? descripciones[i] : '',
                  colores[i % colores.length],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNodoMapa(String etiqueta, String descripcion, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                etiqueta,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              if (descripcion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkText,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparativo(ContenidoSeccion bloque) {
    final titulos = bloque.contenido.split('|');
    final descripciones = bloque.items ?? [];
    final colores = [AppColors.primaryGreen, AppColors.sunOrange];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBloqueTitulo(bloque),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < titulos.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colores[i % colores.length].withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colores[i % colores.length].withOpacity(0.28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulos[i].trim(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colores[i % colores.length],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (i < descripciones.length) ...[
                        const SizedBox(height: 6),
                        Text(
                          descripciones[i],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkText,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPasos(ContenidoSeccion bloque) {
    final pasos = bloque.items ?? [];
    const iconos = [
      Icons.wb_sunny_rounded,
      Icons.blur_on_rounded,
      Icons.directions_run_rounded,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBloqueTitulo(bloque),
        for (int i = 0; i < pasos.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: _acento.withOpacity(0.7),
                  size: 18,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _acento.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _acento.withOpacity(0.28)),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _acento,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextoPaso(pasos[i]),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _acento.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconos[i % iconos.length],
                      color: _acento,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextoPaso(String paso) {
    final corte = paso.indexOf(' (');
    final etiqueta = corte > 0 ? paso.substring(0, corte) : paso;
    final detalle = corte > 0 ? paso.substring(corte) : '';
    final estilo = AppTextStyles.bodyMedium.copyWith(
      color: AppColors.darkText,
      fontSize: 13,
      height: 1.4,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: etiqueta,
            style: estilo.copyWith(fontWeight: FontWeight.bold),
          ),
          if (detalle.isNotEmpty) TextSpan(text: detalle, style: estilo),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNotaImportante(String texto) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sunYellow.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.sunOrange.withOpacity(0.55),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.priority_high_rounded,
            color: AppColors.sunOrange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota Importante',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.sunOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dibuja las lineas del mapa conceptual de la clasificacion por nutricion.
class _ConectorMapaNutricion extends CustomPainter {
  final Color color;
  final double separacion;

  const _ConectorMapaNutricion({required this.color, required this.separacion});

  @override
  void paint(Canvas canvas, Size size) {
    final trazo = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final anchoHijo = (size.width - separacion) / 2;
    final izquierdaX = anchoHijo / 2;
    final derechaX = size.width - anchoHijo / 2;
    final centroX = size.width / 2;
    final medioY = size.height / 2;

    canvas.drawLine(Offset(centroX, 0), Offset(centroX, medioY), trazo);
    canvas.drawLine(
      Offset(izquierdaX, medioY),
      Offset(derechaX, medioY),
      trazo,
    );
    canvas.drawLine(
      Offset(izquierdaX, medioY),
      Offset(izquierdaX, size.height),
      trazo,
    );
    canvas.drawLine(
      Offset(derechaX, medioY),
      Offset(derechaX, size.height),
      trazo,
    );

    final nodo = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centroX, medioY), 3.5, nodo);
    canvas.drawCircle(Offset(izquierdaX, medioY), 3, nodo);
    canvas.drawCircle(Offset(derechaX, medioY), 3, nodo);
  }

  @override
  bool shouldRepaint(covariant _ConectorMapaNutricion oldDelegate) {
    return oldDelegate.color != color || oldDelegate.separacion != separacion;
  }
}
