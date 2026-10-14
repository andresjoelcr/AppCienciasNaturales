import '../models/glosario_model.dart';

/// Datos del glosario de terminos de ciencias naturales
class GlosarioData {
  static const List<TerminoGlosario> terminos = [
    // === A ===
    TerminoGlosario(
      id: 'adn',
      termino: 'ADN',
      definicion:
          'Acido desoxirribonucleico. Molecula que contiene la informacion genetica de los seres vivos. Se encuentra en el nucleo de las celulas y tiene forma de doble helice.',
      categoria: CategoriaTermino.molecula,
      imagenAsset: 'assets/glosario/adn.png',
      datoCurioso:
          'Si estiraras todo el ADN de una sola celula humana, mediria aproximadamente 2 metros de largo.',
      subtemasRelacionados: ['1.2', '1.4'],
      pronunciacion: 'a-de-ene',
    ),
    TerminoGlosario(
      id: 'atp',
      termino: 'ATP',
      definicion:
          'Adenosin trifosfato. Es la principal molecula de energia de las celulas. Se produce principalmente en las mitocondrias y es utilizada para realizar todas las funciones celulares.',
      categoria: CategoriaTermino.molecula,
      imagenAsset: 'assets/glosario/atp.png',
      datoCurioso:
          'Tu cuerpo produce y consume aproximadamente tu peso corporal en ATP cada dia.',
      subtemasRelacionados: ['1.4'],
      pronunciacion: 'a-te-pe',
    ),
    TerminoGlosario(
      id: 'aparato_golgi',
      termino: 'Aparato de Golgi',
      definicion:
          'Organelo celular formado por sacos aplanados. Su funcion es modificar, empaquetar y distribuir proteinas y lipidos producidos por la celula.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/aparato_golgi.png',
      datoCurioso:
          'Fue descubierto por Camillo Golgi en 1898, quien gano el Premio Nobel por sus estudios sobre el sistema nervioso.',
      subtemasRelacionados: ['1.4'],
    ),

    // === C ===
    TerminoGlosario(
      id: 'celula',
      termino: 'Celula',
      definicion:
          'Unidad basica estructural y funcional de todos los seres vivos. Es la parte mas pequena que puede realizar todas las funciones vitales como nutricion, reproduccion y relacion con el medio.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/celula.png',
      datoCurioso:
          'El cuerpo humano tiene aproximadamente 37 billones de celulas.',
      subtemasRelacionados: ['1.1', '1.2', '1.3'],
    ),
    TerminoGlosario(
      id: 'celula_animal',
      termino: 'Celula Animal',
      definicion:
          'Tipo de celula eucariota que forma parte de los tejidos animales. No tiene pared celular ni cloroplastos, pero posee centriolos y lisosomas bien desarrollados.',
      categoria: CategoriaTermino.tipoCelula,
      imagenAsset: 'assets/glosario/celula_animal.png',
      datoCurioso:
          'Las celulas animales pueden tener formas muy variadas: redondas, alargadas, estrelladas, dependiendo de su funcion.',
      subtemasRelacionados: ['1.2', '1.3'],
    ),
    TerminoGlosario(
      id: 'celula_vegetal',
      termino: 'Celula Vegetal',
      definicion:
          'Tipo de celula eucariota que forma parte de los tejidos de las plantas. Tiene pared celular de celulosa, cloroplastos para la fotosintesis y una gran vacuola central.',
      categoria: CategoriaTermino.tipoCelula,
      imagenAsset: 'assets/glosario/celula_vegetal.png',
      datoCurioso:
          'La pared celular de las plantas esta hecha de celulosa, el compuesto organico mas abundante en la Tierra.',
      subtemasRelacionados: ['1.2', '1.3'],
    ),
    TerminoGlosario(
      id: 'celula_procariota',
      termino: 'Celula Procariota',
      definicion:
          'Tipo de celula simple que no tiene nucleo definido ni organelos membranosos. El material genetico esta libre en el citoplasma. Las bacterias son ejemplos de celulas procariotas.',
      categoria: CategoriaTermino.tipoCelula,
      imagenAsset: 'assets/glosario/celula_procariota.png',
      datoCurioso:
          'Las celulas procariotas fueron las primeras formas de vida en la Tierra, aparecieron hace unos 3.500 millones de anos.',
      subtemasRelacionados: ['1.1', '1.2'],
    ),
    TerminoGlosario(
      id: 'celula_eucariota',
      termino: 'Celula Eucariota',
      definicion:
          'Tipo de celula compleja que tiene un nucleo definido donde se encuentra el ADN, y organelos membranosos como mitocondrias y reticulo endoplasmatico. Plantas, animales y hongos tienen celulas eucariotas.',
      categoria: CategoriaTermino.tipoCelula,
      imagenAsset: 'assets/glosario/celula_eucariota.png',
      datoCurioso:
          'La palabra eucariota viene del griego y significa "nucleo verdadero".',
      subtemasRelacionados: ['1.1', '1.2'],
    ),
    TerminoGlosario(
      id: 'centriolos',
      termino: 'Centriolos',
      definicion:
          'Estructuras cilindricas presentes en celulas animales. Participan en la division celular organizando las fibras del huso mitotico que separan los cromosomas.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/centriolos.png',
      datoCurioso:
          'Los centriolos siempre aparecen en pares perpendiculares entre si.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),
    TerminoGlosario(
      id: 'citoplasma',
      termino: 'Citoplasma',
      definicion:
          'Sustancia gelatinosa que llena el interior de la celula entre la membrana y el nucleo. Contiene agua, sales, moleculas organicas y los organelos celulares.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/citoplasma.png',
      datoCurioso:
          'El citoplasma esta compuesto por aproximadamente 80% de agua.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),
    TerminoGlosario(
      id: 'cloroplasto',
      termino: 'Cloroplasto',
      definicion:
          'Organelo presente solo en celulas vegetales y algunos protistas. Contiene clorofila y es donde ocurre la fotosintesis, transformando la luz solar en energia quimica.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/cloroplasto.png',
      datoCurioso:
          'Los cloroplastos tienen su propio ADN y se cree que antiguamente fueron bacterias independientes.',
      subtemasRelacionados: ['1.3', '1.4'],
    ),
    TerminoGlosario(
      id: 'clorofila',
      termino: 'Clorofila',
      definicion:
          'Pigmento de color verde presente en los cloroplastos. Es esencial para la fotosintesis porque absorbe la luz solar necesaria para convertir el dioxido de carbono y agua en glucosa.',
      categoria: CategoriaTermino.molecula,
      imagenAsset: 'assets/glosario/clorofila.png',
      datoCurioso:
          'La clorofila absorbe la luz roja y azul, pero refleja la verde, por eso las plantas se ven de ese color.',
      subtemasRelacionados: ['1.3', '1.4'],
    ),
    TerminoGlosario(
      id: 'cromosoma',
      termino: 'Cromosoma',
      definicion:
          'Estructura formada por ADN muy compactado que contiene los genes. Los humanos tienen 46 cromosomas (23 pares) en cada celula.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/cromosoma.png',
      datoCurioso:
          'Los cromosomas solo son visibles durante la division celular cuando el ADN se compacta al maximo.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),

    // === D ===
    TerminoGlosario(
      id: 'division_celular',
      termino: 'Division Celular',
      definicion:
          'Proceso por el cual una celula madre se divide para formar celulas hijas. Puede ser mitosis (celulas identicas) o meiosis (celulas sexuales con la mitad de cromosomas).',
      categoria: CategoriaTermino.proceso,
      imagenAsset: 'assets/glosario/division_celular.png',
      datoCurioso:
          'Tu cuerpo produce aproximadamente 300 millones de celulas nuevas cada minuto.',
      subtemasRelacionados: ['1.4'],
    ),

    // === F ===
    TerminoGlosario(
      id: 'fotosintesis',
      termino: 'Fotosintesis',
      definicion:
          'Proceso realizado por plantas y otros organismos para convertir la luz solar, agua y dioxido de carbono en glucosa (alimento) y oxigeno. Ocurre en los cloroplastos.',
      categoria: CategoriaTermino.proceso,
      imagenAsset: 'assets/glosario/fotosintesis.png',
      datoCurioso:
          'Las plantas producen todo el oxigeno que respiramos gracias a la fotosintesis.',
      subtemasRelacionados: ['1.3', '1.4'],
    ),

    // === G ===
    TerminoGlosario(
      id: 'gen',
      termino: 'Gen',
      definicion:
          'Segmento de ADN que contiene la informacion para producir una proteina especifica. Los genes determinan las caracteristicas hereditarias de los seres vivos.',
      categoria: CategoriaTermino.molecula,
      imagenAsset: 'assets/glosario/gen.png',
      datoCurioso:
          'Los humanos tenemos aproximadamente 20,000 genes, menos que una planta de arroz que tiene cerca de 40,000.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),

    // === L ===
    TerminoGlosario(
      id: 'lisosoma',
      termino: 'Lisosoma',
      definicion:
          'Organelo que contiene enzimas digestivas. Su funcion es degradar y reciclar moleculas danadas, organelos viejos y sustancias que entran a la celula.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/lisosoma.png',
      datoCurioso:
          'Los lisosomas son como el "sistema de reciclaje" de la celula.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),

    // === M ===
    TerminoGlosario(
      id: 'membrana_celular',
      termino: 'Membrana Celular',
      definicion:
          'Capa delgada y flexible que rodea a todas las celulas. Controla que sustancias entran y salen de la celula, protegiendola del medio externo.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/membrana_celular.png',
      datoCurioso:
          'La membrana celular es tan delgada que se necesitarian 10,000 membranas apiladas para igualar el grosor de una hoja de papel.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),
    TerminoGlosario(
      id: 'mitocondria',
      termino: 'Mitocondria',
      definicion:
          'Organelo conocido como la "central energetica" de la celula. Produce ATP (energia) a partir de los nutrientes mediante la respiracion celular.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/mitocondria.png',
      datoCurioso:
          'Las mitocondrias tienen su propio ADN y se heredan solo de la madre.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),
    TerminoGlosario(
      id: 'mitosis',
      termino: 'Mitosis',
      definicion:
          'Tipo de division celular donde una celula madre produce dos celulas hijas identicas, con el mismo numero de cromosomas. Sirve para el crecimiento y reparacion de tejidos.',
      categoria: CategoriaTermino.proceso,
      imagenAsset: 'assets/glosario/mitosis.png',
      datoCurioso:
          'Una celula humana puede completar la mitosis en aproximadamente 1 hora.',
      subtemasRelacionados: ['1.4'],
    ),

    // === N ===
    TerminoGlosario(
      id: 'nucleo',
      termino: 'Nucleo',
      definicion:
          'Centro de control de la celula eucariota. Contiene el ADN organizado en cromosomas y esta rodeado por una doble membrana llamada envoltura nuclear.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/nucleo.png',
      datoCurioso:
          'El nucleo fue el primer organelo celular en ser descubierto, en 1831 por Robert Brown.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),
    TerminoGlosario(
      id: 'nucleolo',
      termino: 'Nucleolo',
      definicion:
          'Estructura densa dentro del nucleo donde se fabrican los ribosomas. Una celula puede tener uno o varios nucleolos.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/nucleolo.png',
      datoCurioso:
          'El nucleolo desaparece durante la division celular y vuelve a formarse despues.',
      subtemasRelacionados: ['1.4'],
    ),

    // === O ===
    TerminoGlosario(
      id: 'organelo',
      termino: 'Organelo',
      definicion:
          'Estructura especializada dentro de la celula que realiza una funcion especifica. Ejemplos: mitocondrias, ribosomas, nucleo, cloroplastos.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/organelo.png',
      datoCurioso:
          'La palabra organelo significa "pequeno organo", porque funcionan como los organos en un cuerpo.',
      subtemasRelacionados: ['1.2', '1.4'],
    ),

    // === P ===
    TerminoGlosario(
      id: 'pared_celular',
      termino: 'Pared Celular',
      definicion:
          'Capa rigida y resistente que rodea a las celulas vegetales, hongos y bacterias. En plantas esta hecha de celulosa y da soporte estructural a la celula.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/pared_celular.png',
      datoCurioso:
          'La madera de los arboles esta formada principalmente por paredes celulares de celulas muertas.',
      subtemasRelacionados: ['1.3', '1.4'],
    ),
    TerminoGlosario(
      id: 'proteina',
      termino: 'Proteina',
      definicion:
          'Molecula grande formada por aminoacidos. Las proteinas realizan casi todas las funciones celulares: enzimas, transporte, estructura, defensa, y mas.',
      categoria: CategoriaTermino.molecula,
      imagenAsset: 'assets/glosario/proteina.png',
      datoCurioso:
          'El cuerpo humano tiene mas de 100,000 tipos diferentes de proteinas.',
      subtemasRelacionados: ['1.4'],
    ),

    // === R ===
    TerminoGlosario(
      id: 'reticulo_endoplasmatico',
      termino: 'Reticulo Endoplasmatico',
      definicion:
          'Sistema de membranas conectadas al nucleo. El RE rugoso (con ribosomas) produce proteinas, y el RE liso produce lipidos y desintoxica la celula.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/reticulo_endoplasmatico.png',
      datoCurioso:
          'Si extendieras todo el reticulo endoplasmatico de una celula del higado, cubriria la mitad de un campo de futbol.',
      subtemasRelacionados: ['1.4'],
    ),
    TerminoGlosario(
      id: 'respiracion_celular',
      termino: 'Respiracion Celular',
      definicion:
          'Proceso por el cual las celulas obtienen energia (ATP) a partir de la glucosa usando oxigeno. Ocurre principalmente en las mitocondrias.',
      categoria: CategoriaTermino.proceso,
      imagenAsset: 'assets/glosario/respiracion_celular.png',
      datoCurioso:
          'La respiracion celular produce dioxido de carbono y agua como productos de desecho.',
      subtemasRelacionados: ['1.4'],
    ),
    TerminoGlosario(
      id: 'ribosoma',
      termino: 'Ribosoma',
      definicion:
          'Pequena estructura celular donde se fabrican las proteinas. Puede estar libre en el citoplasma o unido al reticulo endoplasmatico.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/ribosoma.png',
      datoCurioso:
          'Una celula puede tener millones de ribosomas trabajando al mismo tiempo.',
      subtemasRelacionados: ['1.4'],
    ),

    // === T ===
    TerminoGlosario(
      id: 'tejido',
      termino: 'Tejido',
      definicion:
          'Conjunto de celulas similares que trabajan juntas para realizar una funcion especifica. Ejemplos: tejido muscular, tejido nervioso, tejido epitelial.',
      categoria: CategoriaTermino.estructura,
      imagenAsset: 'assets/glosario/tejido.png',
      datoCurioso:
          'El cuerpo humano tiene cuatro tipos principales de tejidos: epitelial, conectivo, muscular y nervioso.',
      subtemasRelacionados: ['1.1'],
    ),

    // === V ===
    TerminoGlosario(
      id: 'vacuola',
      termino: 'Vacuola',
      definicion:
          'Organelo en forma de saco lleno de liquido. En celulas vegetales hay una vacuola central grande que almacena agua, nutrientes y desechos, y mantiene la rigidez de la celula.',
      categoria: CategoriaTermino.organelo,
      imagenAsset: 'assets/glosario/vacuola.png',
      datoCurioso:
          'La vacuola central de una celula vegetal puede ocupar hasta el 90% del volumen de la celula.',
      subtemasRelacionados: ['1.3', '1.4'],
    ),
  ];

  /// Obtiene todos los terminos ordenados alfabeticamente
  static List<TerminoGlosario> obtenerTodos() {
    final lista = List<TerminoGlosario>.from(terminos);
    lista.sort((a, b) => a.termino.compareTo(b.termino));
    return lista;
  }

  /// Obtiene terminos por categoria
  static List<TerminoGlosario> obtenerPorCategoria(CategoriaTermino categoria) {
    return terminos
        .where((t) => t.categoria == categoria)
        .toList()
      ..sort((a, b) => a.termino.compareTo(b.termino));
  }

  /// Busca terminos por texto
  static List<TerminoGlosario> buscar(String query) {
    if (query.isEmpty) return obtenerTodos();

    final queryLower = query.toLowerCase();
    return terminos
        .where((t) =>
            t.termino.toLowerCase().contains(queryLower) ||
            t.definicion.toLowerCase().contains(queryLower))
        .toList()
      ..sort((a, b) => a.termino.compareTo(b.termino));
  }

  /// Obtiene un termino por ID
  static TerminoGlosario? obtenerPorId(String id) {
    try {
      return terminos.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene terminos agrupados por letra inicial
  static Map<String, List<TerminoGlosario>> obtenerAgrupadosPorLetra() {
    final todos = obtenerTodos();
    final Map<String, List<TerminoGlosario>> agrupados = {};

    for (final termino in todos) {
      final letra = termino.letraInicial;
      if (!agrupados.containsKey(letra)) {
        agrupados[letra] = [];
      }
      agrupados[letra]!.add(termino);
    }

    return agrupados;
  }
}
