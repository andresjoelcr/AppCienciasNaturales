import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

import '../../services/unity_return_service.dart';
import '../../services/marcador_download_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flutter_3d_viewer_interactivo.dart';
import '../../widgets/marcador_action_dialog.dart';

/// Una parte de la celula con una funcion interesante que se muestra junto al
/// modelo 3D.
class ParteCelula {
  final IconData icono;
  final String nombre;
  final String funcion;

  const ParteCelula(this.icono, this.nombre, this.funcion);
}

// ---------- Celula vegetal ----------

const String introCelulaVegetal =
    'La célula vegetal es la unidad básica de las plantas. '
    'Es autótrofa (fabrica su propio alimento) y se distingue '
    'por su pared celular, sus cloroplastos y su gran vacuola central.';

const List<ParteCelula> partesCelulaVegetal = [
  ParteCelula(
    Icons.crop_square_rounded,
    'Pared celular',
    'Capa rígida de celulosa que le da forma, soporte y protección. Solo la tienen las células vegetales.',
  ),
  ParteCelula(
    Icons.blur_on_rounded,
    'Membrana plasmática',
    'Controla qué sustancias entran y salen de la célula.',
  ),
  ParteCelula(
    Icons.wb_sunny_rounded,
    'Cloroplastos',
    'Realizan la fotosíntesis: capturan la luz del sol para fabricar el alimento de la planta.',
  ),
  ParteCelula(
    Icons.water_drop_rounded,
    'Vacuola central',
    'Almacena agua y nutrientes y mantiene la célula firme. Puede ocupar hasta el 90% de su volumen.',
  ),
  ParteCelula(
    Icons.spa_rounded,
    'Núcleo',
    'Guarda el ADN y dirige todas las actividades de la célula.',
  ),
  ParteCelula(
    Icons.bolt_rounded,
    'Mitocondrias',
    'Producen la energía que la célula necesita mediante la respiración celular.',
  ),
  ParteCelula(
    Icons.grain_rounded,
    'Citoplasma',
    'Medio gelatinoso donde ocurren las reacciones y se ubican los organelos.',
  ),
];

const List<String> curiosidadesCelulaVegetal = [
  'La célula vegetal es autótrofa: fabrica su propio alimento con luz solar, agua y dióxido de carbono.',
  'Una sola célula vegetal puede tener decenas de cloroplastos.',
  'La pared celular es la razón por la que las plantas se mantienen erguidas y no tienen huesos.',
  'La clorofila de los cloroplastos es lo que da el color verde a las hojas.',
];

// ---------- Celula animal ----------

const String introCelulaAnimal =
    'La célula animal es la unidad básica que forma a todos los animales, '
    'incluidos los seres humanos. Es eucariota (tiene núcleo definido) y se '
    'distingue por no tener pared celular ni cloroplastos, y por poseer '
    'centriolos y lisosomas.';

const List<ParteCelula> partesCelulaAnimal = [
  ParteCelula(
    Icons.blur_on_rounded,
    'Membrana plasmática',
    'Rodea la célula y regula qué sustancias entran y salen. Es el único límite, pues no hay pared celular.',
  ),
  ParteCelula(
    Icons.spa_rounded,
    'Núcleo',
    'Centro de control que guarda el ADN y dirige todas las actividades de la célula.',
  ),
  ParteCelula(
    Icons.grain_rounded,
    'Citoplasma',
    'Medio gelatinoso donde flotan los organelos y ocurren las reacciones.',
  ),
  ParteCelula(
    Icons.bolt_rounded,
    'Mitocondrias',
    'Producen la energía que la célula necesita mediante la respiración celular.',
  ),
  ParteCelula(
    Icons.scatter_plot_rounded,
    'Ribosomas',
    'Fabrican las proteínas que la célula necesita para funcionar y crecer.',
  ),
  ParteCelula(
    Icons.inventory_2_rounded,
    'Aparato de Golgi',
    'Empaqueta y distribuye las sustancias que produce la célula.',
  ),
  ParteCelula(
    Icons.settings_rounded,
    'Centriolos',
    'Organizan las fibras durante la división celular. Solo están en las células animales.',
  ),
  ParteCelula(
    Icons.delete_sweep_rounded,
    'Lisosomas',
    'Digieren y reciclan los materiales de desecho dentro de la célula.',
  ),
];

const List<String> curiosidadesCelulaAnimal = [
  'La célula animal no tiene pared celular, por eso puede adoptar formas muy variadas: redondas, alargadas o estrelladas.',
  'No tiene cloroplastos, así que no realiza fotosíntesis: obtiene su energía de los alimentos.',
  'Sus vacuolas son pequeñas y numerosas, a diferencia de la gran vacuola central de la célula vegetal.',
  'El cuerpo humano tiene aproximadamente 37 billones de células animales trabajando juntas.',
];

/// Visor del modelo 3D de una celula. Permite girar el modelo con el dedo y
/// hacer zoom con el gesto de pellizcar, usando el paquete
/// `flutter_3d_controller` (motor model-viewer), y muestra informacion (intro,
/// partes y datos curiosos) debajo.
class Modelo3DScreen extends StatefulWidget {
  /// Titulo que aparece en la barra superior.
  final String titulo;

  /// Ruta del asset (.glb/.gltf) que se va a mostrar.
  final String modeloAsset;

  /// Texto introductorio que aparece en la tarjeta superior de informacion.
  final String intro;

  /// Lista de partes principales y sus funciones.
  final List<ParteCelula> partes;

  /// Lista de datos curiosos.
  final List<String> curiosidades;

  /// Escena de Unity que abre el boton de realidad aumentada.
  final String escenaAR;

  /// Subtema al que se vuelve si Android recrea la Activity al salir de Unity.
  final String subtemaId;

  const Modelo3DScreen({
    super.key,
    required this.titulo,
    required this.modeloAsset,
    required this.intro,
    required this.partes,
    required this.curiosidades,
    required this.escenaAR,
    required this.subtemaId,
  });

  @override
  State<Modelo3DScreen> createState() => _Modelo3DScreenState();
}

class _Modelo3DScreenState extends State<Modelo3DScreen>
    with WidgetsBindingObserver {
  final Flutter3DController _controller = Flutter3DController();

  bool _cargando = true;
  String? _error;
  bool _autoRotar = false;
  bool _esperandoRetornoUnity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.onModelLoaded.addListener(_onModelLoaded);
  }

  void _onModelLoaded() {
    if (!mounted) return;
    if (_controller.onModelLoaded.value) {
      setState(() => _cargando = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _esperandoRetornoUnity) {
      _esperandoRetornoUnity = false;
      unawaited(UnityReturnService.limpiar());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.onModelLoaded.removeListener(_onModelLoaded);
    // El visor recibe este controlador desde afuera, por lo que liberamos aqui
    // el notifier que le pertenece.
    _controller.onModelLoaded.dispose();
    super.dispose();
  }

  void _recentrar() {
    _controller.resetCameraOrbit();
    _controller.resetCameraTarget();
  }

  void _toggleAutoRotar() {
    setState(() => _autoRotar = !_autoRotar);
    if (_autoRotar) {
      _controller.startRotation(rotationSpeed: 20);
    } else {
      _controller.stopRotation();
    }
  }

  Future<void> _abrirEscenaAR() async {
    try {
      _esperandoRetornoUnity = true;
      await UnityReturnService.guardarSubtema(widget.subtemaId);
      await UnityNativeProcess.open(scene: widget.escenaAR);
    } catch (_) {
      _esperandoRetornoUnity = false;
      await UnityReturnService.limpiar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir la realidad aumentada. Intentalo de nuevo.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _mostrarOpcionesAR() async {
    final opcion = await MarcadorActionDialog.show(
      context,
      title: 'Prepara tu experiencia AR',
      description:
          'Ten el marcador a mano para explorar este modelo en realidad aumentada.',
    );
    if (!mounted || opcion == null) return;
    if (opcion == 'continuar') {
      await _abrirEscenaAR();
      return;
    }
    try {
      await MarcadorDownloadService.descargar(
        'assets/marcadores/Marcador_Celula_Animal_Vegetal.pdf',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marcador descargado.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo descargar el marcador.')),
      );
    }
  }

  Widget _buildARButton() {
    return Tooltip(
      message: 'Abrir realidad aumentada',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _mostrarOpcionesAR,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.view_in_ar_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'AR',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloudWhite,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.view_in_ar_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Explora el modelo en 3D',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildARButton(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.48,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _buildViewer(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _buildControls(),
              ),
              const SizedBox(height: 24),
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                      SizedBox(height: 14),
                      Text('Cargando modelo 3D...'),
                    ],
                  ),
                ),
              ),
            ),
          if (!_cargando && _error == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Arrastra para girar y pellizca para zoom',
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
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _cargando || _error != null ? null : _recentrar,
            icon: const Icon(Icons.center_focus_strong_rounded),
            label: const Text('Recentrar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: AppColors.primaryGreen.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _cargando || _error != null ? null : _toggleAutoRotar,
            icon: Icon(
              _autoRotar
                  ? Icons.pause_circle_outline_rounded
                  : Icons.threed_rotation_rounded,
            ),
            label: Text(_autoRotar ? 'Detener giro' : 'Girar solo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunYellow,
              foregroundColor: AppColors.primaryGreen,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.sunYellow.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.intro,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkText,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Partes principales y sus funciones',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 17,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.partes.map(_buildParteCard),
          const SizedBox(height: 22),
          Text(
            'Datos curiosos',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 17,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.curiosidades.map(_buildCuriosidad),
        ],
      ),
    );
  }

  Widget _buildParteCard(ParteCelula parte) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.sunYellow.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(parte.icono, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parte.nombre,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  parte.funcion,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.greyText,
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

  Widget _buildCuriosidad(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.sunOrange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkText,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.sunOrange,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              'No se pudo cargar el modelo 3D',
              style: AppTextStyles.heading3.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Verifica que el archivo del modelo esté disponible e inténtalo de nuevo.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _error = null;
                _cargando = true;
              }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
