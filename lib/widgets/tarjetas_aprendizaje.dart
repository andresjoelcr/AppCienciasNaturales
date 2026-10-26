import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tarjeta desplegable con una lista de conceptos etiquetados.
///
/// Cada elemento de [items] puede tener el formato "Etiqueta: descripcion";
/// la etiqueta se resalta en negrita y el resto se muestra como detalle.
class TarjetaDesplegable extends StatefulWidget {
  final String titulo;
  final String contenido;
  final List<String> items;
  final IconData icono;
  final Color acento;

  const TarjetaDesplegable({
    super.key,
    required this.titulo,
    required this.contenido,
    required this.items,
    this.icono = Icons.groups_rounded,
    this.acento = AppColors.primaryGreen,
  });

  @override
  State<TarjetaDesplegable> createState() => _TarjetaDesplegableState();
}

class _TarjetaDesplegableState extends State<TarjetaDesplegable> {
  bool _expandida = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.acento.withOpacity(0.18)),
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
              color: widget.acento.withOpacity(0.06),
              child: InkWell(
                onTap: () => setState(() => _expandida = !_expandida),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.acento.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icono,
                          color: widget.acento,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.titulo,
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
                          color: widget.acento,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.contenido.isNotEmpty) ...[
                              Text(
                                widget.contenido,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.darkText,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            for (int i = 0; i < widget.items.length; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              _itemEtiquetado(widget.items[i]),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _imageCacheWidth(double fraction) {
    final mq = MediaQuery.of(context);
    return ((mq.size.width * fraction) * mq.devicePixelRatio)
        .round()
        .clamp(1, 1600);
  }

  Widget _itemEtiquetado(String item) {
    final partes = item.split('|');
    final texto = partes.first;
    final imagen = partes.length > 1 ? partes[1].trim() : '';
    final separador = texto.indexOf(':');
    final etiqueta = separador > 0 ? texto.substring(0, separador) : texto;
    final detalle = separador > 0 ? texto.substring(separador + 1).trim() : '';

    final contenido = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.acento.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.acento.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.acento,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: etiqueta,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: widget.acento,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (detalle.isNotEmpty)
                        TextSpan(
                          text: ': $detalle',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkText,
                            height: 1.45,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (imagen.isNotEmpty) ...[
            const SizedBox(height: 10),
            Image.asset(
              imagen,
              width: double.infinity,
              height: 160,
              fit: BoxFit.contain,
              cacheWidth: _imageCacheWidth(0.7),
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );

    return contenido;
  }
}

/// Cuadro que resalta las partes basicas comunes de una celula.
class CuadroPartes extends StatelessWidget {
  final String titulo;
  final String contenido;
  final List<String> items;

  const CuadroPartes({
    super.key,
    required this.titulo,
    required this.contenido,
    required this.items,
  });

  static const List<IconData> _iconos = [
    Icons.shield_outlined,
    Icons.water_drop_outlined,
    Icons.gesture_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.widgets_rounded,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryGreen,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (contenido.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              contenido,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkText,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _filaParte(items[i], _iconos[i % _iconos.length]),
          ],
        ],
      ),
    );
  }

  Widget _filaParte(String item, IconData icono) {
    final separador = item.indexOf(':');
    final etiqueta = separador > 0 ? item.substring(0, separador) : item;
    final detalle = separador > 0 ? item.substring(separador + 1).trim() : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: AppColors.primaryGreen, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: etiqueta,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (detalle.isNotEmpty)
                    TextSpan(
                      text: ': $detalle',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkText,
                        height: 1.45,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mapa conceptual que parte de un nodo raiz ("Estructura") y conecta con
/// lineas sus clasificaciones.
class MapaConceptual extends StatelessWidget {
  final String titulo;
  final List<String> etiquetas;
  final List<String> descripciones;

  static const double _separacion = 12;
  static const double _altoConector = 36;

  const MapaConceptual({
    super.key,
    required this.titulo,
    required this.etiquetas,
    required this.descripciones,
  });

  @override
  Widget build(BuildContext context) {
    const colores = [AppColors.primaryGreen, AppColors.sunOrange];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.darkText,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: _buildNodoRaiz()),
          SizedBox(
            height: _altoConector,
            width: double.infinity,
            child: CustomPaint(
              painter: _ConectorMapaConceptual(
                color: AppColors.primaryGreen.withOpacity(0.45),
                separacion: _separacion,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < etiquetas.length; i++) ...[
                if (i > 0) const SizedBox(width: _separacion),
                Expanded(
                  child: _buildNodoClasificacion(
                    etiquetas[i].trim(),
                    i < descripciones.length ? descripciones[i] : '',
                    colores[i % colores.length],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNodoRaiz() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Estructura',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodoClasificacion(
    String etiqueta,
    String descripcion,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
                ),
              ),
              if (descripcion.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
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
      ],
    );
  }
}

/// Dibuja las lineas que unen el nodo "Estructura" con sus clasificaciones.
class _ConectorMapaConceptual extends CustomPainter {
  final Color color;
  final double separacion;

  const _ConectorMapaConceptual({
    required this.color,
    required this.separacion,
  });

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
  bool shouldRepaint(covariant _ConectorMapaConceptual oldDelegate) {
    return oldDelegate.color != color || oldDelegate.separacion != separacion;
  }
}
