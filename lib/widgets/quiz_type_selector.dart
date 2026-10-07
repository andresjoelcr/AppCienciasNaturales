import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enumeracion para tipos de quiz
enum QuizType { estatico, iaGenerado }

/// Configuracion para quiz generado por IA
class IAQuizConfig {
  final int numeroPreguntas;
  final String dificultad;

  const IAQuizConfig({this.numeroPreguntas = 5, this.dificultad = 'medio'});
}

/// Dialog para seleccionar el tipo de quiz
class QuizTypeSelectorDialog extends StatefulWidget {
  final int preguntasQuizEstatico;

  const QuizTypeSelectorDialog({
    super.key,
    required this.preguntasQuizEstatico,
  });

  @override
  State<QuizTypeSelectorDialog> createState() => _QuizTypeSelectorDialogState();
}

class _QuizTypeSelectorDialogState extends State<QuizTypeSelectorDialog> {
  QuizType _selectedType = QuizType.estatico;
  int _numeroPreguntas = 5;
  String _dificultad = 'medio';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titulo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Tipo de Quiz', style: AppTextStyles.heading3),
                ],
              ),

              const SizedBox(height: 24),

              // Opcion: Quiz Estatico
              _buildQuizOption(
                type: QuizType.estatico,
                icon: Icons.list_alt_rounded,
                title: 'Quiz del Tema',
                subtitle:
                    '${widget.preguntasQuizEstatico} preguntas predefinidas',
                color: AppColors.skyBlue,
              ),

              const SizedBox(height: 12),

              // Opcion: Quiz IA
              _buildQuizOption(
                type: QuizType.iaGenerado,
                icon: Icons.auto_awesome_rounded,
                title: 'Quiz con IA',
                subtitle: 'Preguntas generadas por inteligencia artificial',
                color: AppColors.sunOrange,
              ),

              // Opciones adicionales para Quiz IA
              if (_selectedType == QuizType.iaGenerado) ...[
                const SizedBox(height: 20),
                _buildIAOptions(),
              ],

              const SizedBox(height: 24),

              // Botones de accion
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: AppColors.greyText.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedType == QuizType.estatico) {
                          Navigator.pop(context, QuizType.estatico);
                        } else {
                          Navigator.pop(
                            context,
                            IAQuizConfig(
                              numeroPreguntas: _numeroPreguntas,
                              dificultad: _dificultad,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Comenzar',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizOption({
    required QuizType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : AppColors.greyText.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? color.withOpacity(0.2)
                          : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : AppColors.greyText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : AppColors.darkText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<QuizType>(
                value: type,
                groupValue: _selectedType,
                onChanged: (value) => setState(() => _selectedType = value!),
                activeColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIAOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sunOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sunOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numero de preguntas
          Text(
            'Numero de preguntas',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children:
                [3, 5, 7, 10].map((num) {
                  final isSelected = _numeroPreguntas == num;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _numeroPreguntas = num),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.sunOrange
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.sunOrange
                                        : AppColors.greyText.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$num',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.darkText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),

          // Dificultad
          Text(
            'Dificultad',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDificultadChip('facil', 'Facil', AppColors.leafGreen),
              const SizedBox(width: 8),
              _buildDificultadChip('medio', 'Medio', AppColors.sunOrange),
              const SizedBox(width: 8),
              _buildDificultadChip('dificil', 'Difícil', AppColors.darkText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDificultadChip(String value, String label, Color color) {
    final isSelected = _dificultad == value;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _dificultad = value),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : AppColors.greyText.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.darkText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
