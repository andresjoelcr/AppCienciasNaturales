import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/glosario_model.dart';
import '../../data/glosario_data.dart';
import 'termino_detalle_screen.dart';

class GlosarioScreen extends StatefulWidget {
  const GlosarioScreen({super.key});

  @override
  State<GlosarioScreen> createState() => _GlosarioScreenState();
}

class _GlosarioScreenState extends State<GlosarioScreen> {
  final TextEditingController _searchController = TextEditingController();
  CategoriaTermino? _categoriaSeleccionada;
  List<TerminoGlosario> _terminosFiltrados = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _terminosFiltrados = GlosarioData.obtenerTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarTerminos() {
    setState(() {
      if (_categoriaSeleccionada != null) {
        _terminosFiltrados = GlosarioData.obtenerPorCategoria(_categoriaSeleccionada!)
            .where((t) =>
                _busqueda.isEmpty ||
                t.termino.toLowerCase().contains(_busqueda.toLowerCase()) ||
                t.definicion.toLowerCase().contains(_busqueda.toLowerCase()))
            .toList();
      } else {
        _terminosFiltrados = GlosarioData.buscar(_busqueda);
      }
    });
  }

  void _onBusquedaChanged(String value) {
    _busqueda = value;
    _filtrarTerminos();
  }

  void _onCategoriaChanged(CategoriaTermino? categoria) {
    _categoriaSeleccionada = categoria;
    _filtrarTerminos();
  }

  @override
  Widget build(BuildContext context) {
    final terminosAgrupados = _agruparPorLetra(_terminosFiltrados);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diccionario',
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${GlosarioData.terminos.length} terminos',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de busqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                // Campo de busqueda
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onBusquedaChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar termino...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.greyText.withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryGreen,
                      ),
                      suffixIcon: _busqueda.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.greyText,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onBusquedaChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkText,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Chips de categorias
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoriaChip(null, 'Todos'),
                      ...CategoriaTermino.values.map(
                        (cat) => _buildCategoriaChip(cat, cat.nombre),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de terminos
          Expanded(
            child: _terminosFiltrados.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: terminosAgrupados.length,
                    itemBuilder: (context, index) {
                      final letra = terminosAgrupados.keys.elementAt(index);
                      final terminos = terminosAgrupados[letra]!;
                      return _buildSeccionLetra(letra, terminos);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaChip(CategoriaTermino? categoria, String label) {
    final isSelected = _categoriaSeleccionada == categoria;
    final color = categoria?.color ?? AppColors.primaryGreen;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCategoriaChanged(categoria),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.greyText.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (categoria != null) ...[
                  Icon(
                    categoria.icono,
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.darkText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionLetra(String letra, List<TerminoGlosario> terminos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de letra
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: AppColors.lightGreen.withOpacity(0.5),
          child: Text(
            letra,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryGreen,
              fontSize: 18,
            ),
          ),
        ),
        // Terminos
        ...terminos.map((termino) => _buildTerminoItem(termino)),
      ],
    );
  }

  Widget _buildTerminoItem(TerminoGlosario termino) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TerminoDetalleScreen(termino: termino),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.greyText.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              // Imagen del termino
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: termino.categoria.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: termino.imagenAsset != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          termino.imagenAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            termino.categoria.icono,
                            color: termino.categoria.color,
                            size: 22,
                          ),
                        ),
                      )
                    : Icon(
                        termino.categoria.icono,
                        color: termino.categoria.color,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      termino.termino,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      termino.definicion,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.greyText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.greyText.withOpacity(0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.primaryGreen.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No se encontraron terminos',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otra busqueda o categoria',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.greyText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<TerminoGlosario>> _agruparPorLetra(
      List<TerminoGlosario> terminos) {
    final Map<String, List<TerminoGlosario>> agrupados = {};

    for (final termino in terminos) {
      final letra = termino.letraInicial;
      if (!agrupados.containsKey(letra)) {
        agrupados[letra] = [];
      }
      agrupados[letra]!.add(termino);
    }

    return agrupados;
  }
}
