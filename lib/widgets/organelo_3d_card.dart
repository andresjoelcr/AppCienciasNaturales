import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../theme/app_theme.dart';
import 'flutter_3d_viewer_interactivo.dart';

/// Muestra un organelo en 3D dentro de una tarjeta.
///
/// Inicialmente no carga ningun modelo: muestra un boton "Ver en 3D". Al
/// pulsarlo, se activa este organelo y se construye el visor (que permite
/// girarlo con el dedo y hacer zoom con el gesto de pellizcar). El padre
/// controla cual organelo esta activo para que solo haya un modelo cargado a la
/// vez.
class Organelo3DCard extends StatefulWidget {
  /// Ruta del asset (.glb) del organelo.
  final String modeloAsset;

  /// Indica si esta tarjeta es la que debe mostrar el visor 3D.
  final bool activo;

  /// Se llama cuando el usuario pulsa "Ver en 3D".
  final VoidCallback onVer;

  /// Etiqueta opcional que aparece sobre el visor.
  final String? nombre;

  const Organelo3DCard({
    super.key,
    required this.modeloAsset,
    required this.activo,
    required this.onVer,
    this.nombre,
  });

  @override
  State<Organelo3DCard> createState() => _Organelo3DCardState();
}

class _Organelo3DCardState extends State<Organelo3DCard> {
  final Flutter3DController _controller = Flutter3DController();

  bool _cargando = true;
  String? _error;

  @override
  void didUpdateWidget(covariant Organelo3DCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al activarse de nuevo, se vuelve a cargar el modelo desde cero.
    if (widget.activo && !oldWidget.activo) {
      _cargando = true;
      _error = null;
    }
  }

  @override
  void dispose() {
    // El visor recibe este controlador desde afuera, por lo que liberamos aqui
    // el notifier que le pertenece.
    _controller.onModelLoaded.dispose();
    super.dispose();
  }

  void _recentrar() {
    if (_cargando || _error != null) return;
    _controller.resetCameraOrbit();
    _controller.resetCameraTarget();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.lightGreen,
            child: Row(
              children: [
                const Icon(
                  Icons.view_in_ar_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.nombre == null
                        ? 'Observa este organelo en 3D'
                        : '${widget.nombre} en 3D',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: widget.activo ? _buildViewer() : _buildBotonVer(),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonVer() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: widget.onVer,
        icon: const Icon(Icons.view_in_ar_rounded, size: 20),
        label: const Text('Ver en 3D'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sunYellow,
          foregroundColor: AppColors.primaryGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildViewer() {
    return Stack(
      children: [
        Positioned.fill(
          child: _error != null
              ? _buildError()
              : Flutter3DViewerInteractivo(
                  controller: _controller,
                  src: widget.modeloAsset,
                  progressBarColor: AppColors.primaryGreen,
                  onLoad: (_) {
                    if (mounted && _cargando) {
                      setState(() => _cargando = false);
                    }
                  },
                  onError: (error) {
                    if (mounted) {
                      setState(() {
                        _error = error;
                        _cargando = false;
                      });
                    }
                  },
                ),
        ),
        if (_cargando && _error == null)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            ),
          ),
        if (!_cargando && _error == null)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _recentrar,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.center_focus_strong_rounded,
                        color: AppColors.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Recentrar',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (!_cargando && _error == null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Gira y pellizca para zoom',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.sunOrange,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No se pudo cargar el modelo 3D',
              style: AppTextStyles.caption.copyWith(color: AppColors.greyText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _error = null;
                _cargando = true;
              }),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
