import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Panel de decisión reutilizable para descargar un marcador o abrir Unity.
class MarcadorActionDialog extends StatelessWidget {
  const MarcadorActionDialog({
    required this.title,
    required this.description,
    this.downloadLabel = 'Descargar marcador',
    super.key,
  });

  final String title;
  final String description;
  final String downloadLabel;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String description,
    String downloadLabel = 'Descargar marcador',
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => MarcadorActionDialog(
        title: title,
        description: description,
        downloadLabel: downloadLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cloudWhite,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
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
              title,
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
            description,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText),
          ),
          const SizedBox(height: 18),
          _ActionButton(
            label: downloadLabel,
            icon: Icons.download_rounded,
            background: AppColors.sunYellow,
            foreground: AppColors.primaryGreen,
            onPressed: () => Navigator.pop(context, 'descargar'),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            label: 'Continuar',
            icon: Icons.arrow_forward_rounded,
            background: AppColors.primaryGreen,
            foreground: Colors.white,
            onPressed: () => Navigator.pop(context, 'continuar'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
