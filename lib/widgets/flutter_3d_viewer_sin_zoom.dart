import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
// Se importan archivos internos del paquete flutter_3d_controller porque su
// widget publico `Flutter3DViewer` no expone la opcion `disableZoom`. Este
// wrapper replica su comportamiento, pero construye el `ModelViewer` interno
// con `disableZoom: true` para permitir girar el modelo sin poder hacer zoom.
// ignore: implementation_imports
import 'package:flutter_3d_controller/src/core/modules/model_viewer/model_viewer.dart';
// ignore: implementation_imports
import 'package:flutter_3d_controller/src/utils/utils.dart';
// ignore: implementation_imports
import 'package:flutter_3d_controller/src/data/repositories/flutter_3d_repository.dart';
// ignore: implementation_imports
import 'package:flutter_3d_controller/src/data/datasources/i_flutter_3d_datasource.dart';

/// Igual que [Flutter3DViewer] pero con el zoom desactivado: el usuario puede
/// girar el modelo arrastrando el dedo, pero no puede acercarlo ni alejarlo con
/// el gesto de pellizcar.
///
/// La rotacion, el recentrado de camara y la rotacion automatica siguen siendo
/// controlables mediante el [controller].
class Flutter3DViewerSinZoom extends StatefulWidget {
  /// Ruta del modelo 3D (.glb/.gltf), ya sea asset, url o archivo local.
  final String src;

  /// Controlador para animaciones, camara y rotacion del modelo.
  final Flutter3DController? controller;

  /// Color de la barra de carga predeterminada. Usa [Colors.transparent] para
  /// ocultarla.
  final Color? progressBarColor;

  /// Si es true agrega la capa interceptora de gestos del paquete (necesaria
  /// para un correcto funcionamiento del tactil en iOS y algunos Android).
  final bool activeGestureInterceptor;

  /// Se llama en cada paso del progreso de carga (valor entre 0 y 1).
  final Function(double progressValue)? onProgress;

  /// Se llama cuando el modelo termino de cargar correctamente.
  final Function(String modelAddress)? onLoad;

  /// Se llama cuando el modelo no pudo cargarse.
  final Function(String error)? onError;

  const Flutter3DViewerSinZoom({
    super.key,
    required this.src,
    this.controller,
    this.progressBarColor,
    this.activeGestureInterceptor = true,
    this.onProgress,
    this.onLoad,
    this.onError,
  });

  @override
  State<Flutter3DViewerSinZoom> createState() => _Flutter3DViewerSinZoomState();
}

class _Flutter3DViewerSinZoomState extends State<Flutter3DViewerSinZoom> {
  late Flutter3DController _controller;
  late String _id;

  /// El controlador solo lo liberamos nosotros si lo creamos aqui: cuando el
  /// padre nos pasa uno, la responsabilidad de disponerlo es suya.
  late bool _ownsController;

  /// El JS inyectado no cambia, asi que se calcula una sola vez en lugar de en
  /// cada build.
  late String _relatedJs;

  final Utils _utils = Utils();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _id = _utils.generateId();
    _controller = widget.controller ?? Flutter3DController();
    _relatedJs = _utils.injectedJS(_id, 'flutter-3d-controller');
    if (kIsWeb) {
      _controller.init(
        Flutter3DRepository(IFlutter3DDatasource(_id, null, false)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary aísla el repintado continuo del WebView (model-viewer)
    // del resto del arbol de widgets, evitando repintados innecesarios en la
    // pantalla y en el scroll.
    return RepaintBoundary(
      child: ModelViewer(
        id: _id,
        src: widget.src,
        progressBarColor: widget.progressBarColor,
        relatedJs: _relatedJs,
        interactionPrompt: InteractionPrompt.none,
        activeGestureInterceptor: widget.activeGestureInterceptor,
        cameraControls: true,
        ar: false,
        autoPlay: false,
        autoRotate: false,
        debugLogging: false,
        disableTap: true,
        disableZoom: true,
        onProgress: widget.onProgress,
        onLoad: (modelAddress) {
          _controller.onModelLoaded.value = true;
          widget.onLoad?.call(modelAddress);
        },
        onError: (error) {
          _controller.onModelLoaded.value = false;
          widget.onError?.call(error);
        },
        onWebViewCreated: kIsWeb
            ? null
            : (value) {
                _controller.init(
                  Flutter3DRepository(
                    IFlutter3DDatasource(
                      _id,
                      value,
                      widget.activeGestureInterceptor,
                    ),
                  ),
                );
              },
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.onModelLoaded.dispose();
    }
    super.dispose();
  }
}
