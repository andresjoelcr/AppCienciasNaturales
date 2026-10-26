import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../theme/app_theme.dart';

/// Reproductor de YouTube con la misma presentacion usada en el resto de la
/// app: encabezado rojo con el titulo y el player debajo.
class VideoYoutubeCard extends StatefulWidget {
  final String url;
  final String titulo;

  const VideoYoutubeCard({
    super.key,
    required this.url,
    required this.titulo,
  });

  @override
  State<VideoYoutubeCard> createState() => _VideoYoutubeCardState();
}

class _VideoYoutubeCardState extends State<VideoYoutubeCard> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _inicializarControlador();
  }

  void _inicializarControlador() {
    final videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (videoId == null) return;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant VideoYoutubeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller?.dispose();
      _controller = null;
      _inicializarControlador();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.red.shade600,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.titulo,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          child: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red.shade600,
            progressColors: ProgressBarColors(
              playedColor: Colors.red.shade600,
              handleColor: Colors.red.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
