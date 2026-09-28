import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

import '../theme/app_theme.dart';

/// Pantalla que embebe Unity dentro de Flutter.
///
/// Unity arranca en la escena que este en el indice 0 de Build Settings.
/// Ese indice es `EscanearTarjetas`, asi que no hace falta pedirle a Unity
/// que cargue ninguna escena: solo hay que mostrarlo.
class UnityEscaneoScreen extends StatefulWidget {
  const UnityEscaneoScreen({super.key});

  @override
  State<UnityEscaneoScreen> createState() => _UnityEscaneoScreenState();
}

class _UnityEscaneoScreenState extends State<UnityEscaneoScreen> {
  UnityWidgetController? _unityWidgetController;

  /// Unity + Vuforia tardan en arrancar. Se muestra encima para que no se vea
  /// un rectangulo negro mientras carga.
  bool _unityListo = false;
  bool _unityFallo = false;
  String _nombreEscena = '';

  /// Si Unity no levanta en este tiempo, se avisa en vez de dejar el spinner
  /// girando para siempre. Lo mas comun es que Vuforia no tenga la licencia
  /// configurada en la maquina donde se compilo.
  static const _timeout = Duration(seconds: 40);
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(_timeout, () {
      if (!mounted || _unityListo) return;
      setState(() => _unityFallo = true);
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _unityWidgetController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Unity se dibuja detras de todo.
          Positioned.fill(
            child: UnityWidget(
              onUnityCreated: (controller) {
                _unityWidgetController = controller;
                if (mounted) setState(() => _unityListo = true);
              },
              onUnitySceneLoaded: (scene) {
                if (scene == null || !mounted) return;
                setState(() {
                  _unityListo = true;
                  _nombreEscena = scene.name ?? '';
                });
              },
              onUnityMessage: _alRecibirMensaje,
              // Necesario en Android: sin esto Unity no recibe toques ni
              // se dibuja bien sobre la textura de la plataforma.
              useAndroidViewSurface: true,
            ),
          ),

          if (!_unityListo || _unityFallo) _buildCapaCarga(),

          // Salir a Flutter. Va aparte del boton de Unity porque la pantalla
          // de Unity se queda encima de toda la vista.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _BotonVolver(onTap: () => Navigator.of(context).pop()),
          ),

          if (_unityListo && !_unityFallo && _nombreEscena.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: Center(child: _buildChip(_nombreEscena)),
            ),
        ],
      ),
    );
  }

  /// Unity pide volver con {"accion":"volver", ...}, que manda
  /// VolverAFlutter.cs desde el boton de PanelEscaner.
  void _alRecibirMensaje(dynamic mensaje) {
    if (!mounted) return;
    final texto = mensaje?.toString() ?? '';
    if (texto.contains('volver')) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildCapaCarga() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(32),
      child:
          _unityFallo
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo iniciar Unity',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unity no respondio en 40 s. Suele ser la licencia de Vuforia '
                    'sin configurar en el equipo donde se compilo el APK.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ],
              )
              : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.leafGreen),
                  SizedBox(height: 20),
                  Text(
                    'Iniciando camara AR...',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Apunta el telefono a un marcador de color',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
    );
  }

  Widget _buildChip(String escena) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        escena,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _BotonVolver extends StatelessWidget {
  final VoidCallback onTap;

  const _BotonVolver({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
