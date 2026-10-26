import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';
import '../../theme/app_theme.dart';
import '../../models/subtema_model.dart';
import '../../services/firestore_service.dart';
import '../../services/unity_return_service.dart';
import '../../services/marcador_download_service.dart';
import '../../services/quiz_generator_service.dart';
import '../../widgets/quiz_type_selector.dart';
import '../../widgets/quiz_loading_screen.dart';
import 'quiz_screen.dart';
import 'modelo_3d_screen.dart';
import '../../widgets/organelo_3d_card.dart';
import '../../widgets/tarjeta_funcion_vital.dart';
import '../../widgets/tarjetas_aprendizaje.dart';
import '../../widgets/video_youtube_card.dart';
import '../chat_screen.dart';
import '../../widgets/marcador_action_dialog.dart';

class SubtemaScreen extends StatefulWidget {
  final Subtema subtema;

  const SubtemaScreen({super.key, required this.subtema});

  @override
  State<SubtemaScreen> createState() => _SubtemaScreenState();
}

class _SubtemaScreenState extends State<SubtemaScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showFloatingButton = false;
  bool _esperandoRetornoUnity = false;

  /// Asset del organelo cuyo modelo 3D esta activo (solo uno a la vez).
  String? _organeloActivo;
  final FirestoreService _firestoreService = FirestoreService();

  /// Los subtemas de celula animal (1.2) y celula vegetal (1.3) cuentan con un
  /// modelo 3D interactivo.
  bool get _tieneModelo3D =>
      widget.subtema.id == '1.2' || widget.subtema.id == '1.3';

  /// El subtema de organelos (1.4) ofrece acceso directo a las escenas AR de
  /// Unity para explorar la celula animal o vegetal.
  bool get _tieneAROrganelos => widget.subtema.id == '1.4';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Marcar contenido como visto
    _marcarContenidoVisto();
  }

  Future<void> _marcarContenidoVisto() async {
    await _firestoreService.markContenidoVisto(
      widget.subtema.id,
      widget.subtema.titulo,
    );
  }

  void _onScroll() {
    final showButton =
        _scrollController.offset > 200 &&
        _scrollController.position.extentAfter > 500;
    if (showButton != _showFloatingButton) {
      setState(() => _showFloatingButton = showButton);
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
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subtema ${widget.subtema.numero}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              widget.subtema.titulo,
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              tooltip: 'Preguntar al asistente',
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Deja espacio para los botones anclados arriba (Modelo 3D / AR)
                // y que no tapen la descripcion del subtema.
                if (_tieneModelo3D || _tieneAROrganelos)
                  const SizedBox(height: 56),
                // Header con descripcion
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.lightGreen.withOpacity(0.5),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: AppColors.primaryGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.subtema.descripcion,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Contenido
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...widget.subtema.contenido.asMap().entries.map((entry) {
                        final index = entry.key;
                        final seccion = entry.value;
                        return _buildSeccionContenido(seccion, index);
                      }),

                      const SizedBox(height: 24),

                      // Boton para preguntar al chatbot
                      _buildChatbotButton(),

                      const SizedBox(height: 16),

                      // Boton para ir al quiz
                      _buildQuizButton(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_tieneModelo3D)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(child: _buildModelo3DButton()),
            ),
          if (_tieneAROrganelos)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(child: _buildARButton()),
            ),
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton.extended(
              onPressed: _navegarAlQuiz,
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.quiz_rounded, color: Colors.white),
              label: Text(
                'Ir al Quiz',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildSeccionContenido(ContenidoSeccion seccion, int index) {
    final delay = 0.1 + (index * 0.05);
    final endDelay = delay + 0.4;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                delay.clamp(0.0, 0.9),
                endDelay.clamp(0.1, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay.clamp(0.0, 0.9), endDelay.clamp(0.1, 1.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          // Aísla el repintado de cada sección (imágenes, videos, modelos 3D)
          // para que animar o desplazar no repinte el contenido estático.
          child: RepaintBoundary(child: _buildSeccionWidget(seccion, index)),
        ),
      ),
    );
  }

  /// Ancho de decodificación máximo para las imágenes, en píxeles reales.
  ///
  /// Limitar `cacheWidth` evita mantener en memoria las imágenes a resolución
  /// completa cuando se muestran más pequeñas, reduciendo el uso de memoria y
  /// el costo de decodificación al desplazarse.
  int _imageCacheWidth(double fraction) {
    final mq = MediaQuery.of(context);
    final logical = mq.size.width * fraction;
    return (logical * mq.devicePixelRatio).round().clamp(1, 2400);
  }

  Widget _buildSeccionWidget(ContenidoSeccion seccion, int index) {
    switch (seccion.tipo) {
      case 'titulo':
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            seccion.contenido,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primaryGreen,
            ),
          ),
        );

      case 'subtitulo':
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Text(
            seccion.contenido,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryGreen,
              fontSize: 16,
            ),
          ),
        );

      case 'texto':
        return Text(
          seccion.contenido,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.darkText,
            height: 1.6,
          ),
        );

      case 'lista':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (seccion.contenido.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  seccion.contenido,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ...?seccion.items?.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.leafGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case 'destacado':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.skyBlue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.oceanBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  seccion.contenido,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.oceanBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'sabias_que':
        final imagen = (seccion.items != null && seccion.items!.isNotEmpty)
            ? seccion.items!.first
            : null;
        final caption = (seccion.items != null && seccion.items!.length > 1)
            ? seccion.items![1]
            : null;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.sunOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.sunOrange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.sunOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sabias que...?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.sunOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (imagen != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagen,
                      height: 160,
                      fit: BoxFit.contain,
                      cacheWidth: _imageCacheWidth(0.85),
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    caption,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.greyText,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
              const SizedBox(height: 10),
              Text(
                seccion.contenido,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );

      case 'imagen':
        final caption = (seccion.items != null && seccion.items!.isNotEmpty)
            ? seccion.items!.first
            : null;
        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  seccion.contenido,
                  fit: BoxFit.cover,
                  cacheWidth: _imageCacheWidth(0.92),
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 10),
              Text(
                caption,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.greyText,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );

      case 'imagen_comparativa':
        final paths = seccion.contenido.split('|');
        final labels = seccion.items ?? [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < paths.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      if (i < labels.length)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            labels[i],
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            paths[i].trim(),
                            fit: BoxFit.cover,
                            cacheWidth: _imageCacheWidth(0.42),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );

      case 'imagen_grid':
        final paths = seccion.contenido.split('|');
        final labels = seccion.items ?? [];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: paths.length,
          itemBuilder: (context, i) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        paths[i].trim(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        cacheWidth: _imageCacheWidth(0.42),
                      ),
                    ),
                  ),
                  if (i < labels.length)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        labels[i],
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            );
          },
        );

      case 'video':
        final videoTitle = (seccion.items != null && seccion.items!.isNotEmpty)
            ? seccion.items!.first
            : 'Video explicativo';
        return VideoYoutubeCard(url: seccion.contenido, titulo: videoTitle);

      case 'tarjeta_funcion':
        return TarjetaFuncionVital(seccion: seccion);

      case 'tarjeta_desplegable':
        return TarjetaDesplegable(
          titulo: seccion.titulo ?? '',
          contenido: seccion.contenido,
          items: seccion.items ?? const [],
        );

      case 'cuadro':
        return CuadroPartes(
          titulo: seccion.titulo ?? '',
          contenido: seccion.contenido,
          items: seccion.items ?? const [],
        );

      case 'mapa_conceptual':
        return MapaConceptual(
          titulo: seccion.titulo ?? '',
          etiquetas: seccion.contenido.split('|'),
          descripciones: seccion.items ?? const [],
        );

      case 'modelo3d':
        final asset = seccion.contenido;
        return Organelo3DCard(
          modeloAsset: asset,
          activo: _organeloActivo == asset,
          onVer: () => setState(() => _organeloActivo = asset),
        );

      default:
        return Text(seccion.contenido);
    }
  }

  Widget _buildChatbotButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.skyBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.oceanBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes dudas?',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.oceanBlue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pregunta al asistente sobre este tema',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.oceanBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Pon a prueba tus conocimientos!',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuizBadge(
                Icons.list_alt_rounded,
                '${widget.subtema.quiz.preguntas.length} preguntas',
              ),
              const SizedBox(width: 12),
              _buildQuizBadge(Icons.auto_awesome_rounded, 'Quiz con IA'),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navegarAlQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded),
                const SizedBox(width: 8),
                Text(
                  'Comenzar Quiz',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarSelectorAR() async {
    final escena = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.view_in_ar_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Realidad aumentada',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primaryGreen,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Explora los organelos: elige un tipo de célula.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 16),
            _buildAROption(
              icon: Icons.spa_rounded,
              titulo: 'Celula vegetal',
              subtitulo: 'Cloroplastos, pared celular y vacuola',
              onTap: () =>
                  Navigator.pop(dialogContext, 'CelulaVegetalOrganelos'),
            ),
            const SizedBox(height: 12),
            _buildAROption(
              icon: Icons.pets_rounded,
              titulo: 'Celula animal',
              subtitulo: 'Nucleo, mitocondrias y organelos',
              onTap: () =>
                  Navigator.pop(dialogContext, 'CelulaAnimalOrganelos'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, 'descargar'),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Descargar marcadores PDF'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sunYellow,
                foregroundColor: AppColors.primaryGreen,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (escena == 'descargar') {
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
      return;
    }
    if (escena == null) return;
    await _abrirEscenaUnity(escena);
  }

  Widget _buildAROption({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cloudWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greyText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirEscenaUnity(String escena) async {
    try {
      _esperandoRetornoUnity = true;
      await UnityReturnService.guardarSubtema(widget.subtema.id);
      await UnityNativeProcess.open(scene: escena);
    } catch (_) {
      _esperandoRetornoUnity = false;
      await UnityReturnService.limpiar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Unity. Intentalo de nuevo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildARButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _mostrarSelectorAR,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.sunYellow.withValues(alpha: 0.88),
                AppColors.sunYellow.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.view_in_ar_rounded,
                color: AppColors.primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                'AR',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirModelo3D() {
    final esAnimal = widget.subtema.id == '1.2';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Modelo3DScreen(
          titulo: esAnimal ? 'La célula animal' : 'La célula vegetal',
          modeloAsset: esAnimal
              ? 'assets/modelos3d/CelulaAnimalPartes.glb'
              : 'assets/modelos3d/CelulaVegetalPartes.glb',
          intro: esAnimal ? introCelulaAnimal : introCelulaVegetal,
          partes: esAnimal ? partesCelulaAnimal : partesCelulaVegetal,
          curiosidades: esAnimal
              ? curiosidadesCelulaAnimal
              : curiosidadesCelulaVegetal,
          escenaAR: esAnimal ? 'CelulaAnimalRACopea' : 'CelulaVegetalRACopea',
          subtemaId: widget.subtema.id,
        ),
      ),
    );
  }

  Widget _buildModelo3DButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _abrirModelo3D,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.sunYellow.withValues(alpha: 0.88),
                AppColors.sunYellow.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.view_in_ar_rounded,
                color: AppColors.primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                'Modelo 3D',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navegarAlQuiz() async {
    // Mostrar dialog de seleccion de tipo de quiz
    final resultado = await showDialog(
      context: context,
      builder: (context) => QuizTypeSelectorDialog(
        preguntasQuizEstatico: widget.subtema.quiz.preguntas.length,
      ),
    );

    if (resultado == null) return;

    if (resultado == QuizType.estatico) {
      // Usar quiz estatico existente
      _iniciarQuizEstatico();
    } else if (resultado is IAQuizConfig) {
      // Generar quiz con IA
      _generarQuizConIA(resultado);
    }
  }

  void _iniciarQuizEstatico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quiz: widget.subtema.quiz,
          subtemaNumero: widget.subtema.numero,
          subtemaId: widget.subtema.id,
          subtemaTitulo: widget.subtema.titulo,
        ),
      ),
    );
  }

  Future<void> _generarQuizConIA(IAQuizConfig config) async {
    // Mostrar pantalla de carga
    bool cancelado = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => QuizLoadingScreen(
        subtemaTitulo: widget.subtema.titulo,
        onCancel: () {
          cancelado = true;
          Navigator.pop(dialogContext);
        },
      ),
    );

    // Generar quiz
    final resultado = await QuizGeneratorService.generarQuiz(
      subtemaId: widget.subtema.id,
      subtemaTitulo: widget.subtema.titulo,
      numeroPreguntas: config.numeroPreguntas,
      dificultad: config.dificultad,
    );

    // Cerrar dialog de carga si aun esta abierto
    if (mounted && !cancelado) {
      Navigator.pop(context);
    }

    if (cancelado) return;

    if (resultado.success && resultado.quiz != null) {
      // Navegar al quiz generado
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              quiz: resultado.quiz!,
              subtemaNumero: widget.subtema.numero,
              subtemaId: widget.subtema.id,
              subtemaTitulo: widget.subtema.titulo,
              esGeneradoPorIA: true,
            ),
          ),
        );
      }
    } else {
      // Mostrar pantalla de error con opciones
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizErrorScreen(
              error: resultado.error ?? 'Error desconocido',
              onRetry: () {
                Navigator.pop(context);
                _generarQuizConIA(config);
              },
              onUseStatic: () {
                Navigator.pop(context);
                _iniciarQuizEstatico();
              },
            ),
          ),
        );
      }
    }
  }
}
