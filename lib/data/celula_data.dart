import '../models/subtema_model.dart';
import '../models/quiz_model.dart';

/// Clase para acceder a los datos de la unidad sobre la célula
class CelulaData {
  static List<Subtema> get subtemas => subtemascelula;

  static Subtema? getSubtemaById(String id) {
    try {
      return subtemascelula.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static String get nombreUnidad => 'La Celula - Unidad Basica de la Vida';
}

final List<Subtema> subtemascelula = [
  // 1.1 ¿Qué es la célula?
  Subtema(
    id: '1.1',
    numero: '1.1',
    titulo: '¿Que es la celula?',
    descripcion: 'Descubre la unidad basica de todos los seres vivos',
    contenido: [
      const ContenidoSeccion(
        tipo: 'titulo',
        contenido: '¿Que es la celula?',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'La celula es la unidad mas pequena que forma a todos los seres vivos, como plantas, animales y personas.',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Aunque es muy pequena, la celula realiza todas las funciones vitales necesarias para la vida.',
      ),
      const ContenidoSeccion(
        tipo: 'imagen',
        contenido: 'assets/celula/celula.png',
        items: ['Estructura general de la celula'],
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Todas las celulas contienen informacion genetica, que permite que los seres vivos crezcan, se desarrollen y transmitan sus caracteristicas.',
      ),
      const ContenidoSeccion(
        tipo: 'sabias_que',
        contenido:
            'En 1665, el cientifico Robert Hooke fue el primero en observar celulas utilizando un microscopio al estudiar el corcho.',
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido:
            'La celula es considerada la unidad estructural, funcional y de origen de todos los seres vivos.',
      ),
      const ContenidoSeccion(
        tipo: 'video',
        contenido: 'https://youtu.be/aoj9oTvVJ8o?si=gucycuhJG3OtTUW0',
        items: ['¿Que es la celula? - Video explicativo'],
      ),
    ],
    quiz: const Quiz(
      titulo: 'Quiz: ¿Que es la celula?',
      preguntas: [
        Pregunta(
          pregunta: '¿Que es la celula?',
          opciones: [
            'Una parte del cuerpo humano',
            'La unidad mas pequena que forma a todos los seres vivos',
            'Un tipo de bacteria',
            'Una molecula de agua',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'La celula es la unidad basica y mas pequena que compone a todos los seres vivos.',
        ),
        Pregunta(
          pregunta: '¿Quien fue el primero en observar celulas?',
          opciones: [
            'Isaac Newton',
            'Albert Einstein',
            'Robert Hooke',
            'Charles Darwin',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'Robert Hooke en 1665 fue el primero en observar celulas usando un microscopio.',
        ),
        Pregunta(
          pregunta: '¿Que contienen todas las celulas?',
          opciones: [
            'Solo agua',
            'Informacion genetica',
            'Unicamente proteinas',
            'Minerales',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'Todas las celulas contienen informacion genetica que permite el crecimiento y desarrollo.',
        ),
        Pregunta(
          pregunta: '¿Que funciones realiza la celula?',
          opciones: [
            'Solo respiracion',
            'Ninguna funcion',
            'Todas las funciones vitales para la vida',
            'Solo movimiento',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'La celula realiza todas las funciones vitales necesarias para mantener la vida.',
        ),
      ],
    ),
  ),

  // 1.2 Célula Animal
  Subtema(
    id: '1.2',
    numero: '1.2',
    titulo: 'La Celula Animal',
    descripcion: 'Conoce la celula que forma a los animales y humanos',
    contenido: [
      const ContenidoSeccion(
        tipo: 'titulo',
        contenido: 'La Celula Animal',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'La celula animal es la unidad basica que forma a todos los animales, incluyendo a los seres humanos.',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Es una celula eucariota, lo que significa que tiene un nucleo bien definido donde se guarda la informacion genetica.',
      ),
      const ContenidoSeccion(
        tipo: 'imagen',
        contenido: 'assets/celula/celulaanimal.jpg',
        items: ['Estructura de la celula animal'],
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Caracteristicas principales',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'La celula animal se caracteriza por:',
        items: [
          'No tiene pared celular, solo membrana plasmatica',
          'No tiene cloroplastos (no realiza fotosintesis)',
          'Tiene vacuolas pequenas',
          'Posee centriolos para la division celular',
          'Tiene forma irregular o redondeada',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Partes de la celula animal',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'Principales componentes:',
        items: [
          'Membrana plasmatica: Protege y regula el paso de sustancias',
          'Nucleo: Centro de control con el ADN',
          'Citoplasma: Liquido donde flotan los organelos',
          'Mitocondrias: Producen energia para la celula',
          'Ribosomas: Fabrican proteinas',
          'Aparato de Golgi: Empaqueta y distribuye sustancias',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido:
            'La celula animal obtiene su energia de los alimentos que consume el organismo.',
      ),
      const ContenidoSeccion(
        tipo: 'sabias_que',
        contenido:
            'El cuerpo humano tiene aproximadamente 37 billones de celulas animales trabajando juntas.',
      ),
      const ContenidoSeccion(
        tipo: 'video',
        contenido: 'https://youtu.be/s0HzvQiqwpk?si=pr3j3WZ5gEIZ0d0f',
        items: ['La celula animal - Video explicativo'],
      ),
    ],
    quiz: const Quiz(
      titulo: 'Quiz: La Celula Animal',
      preguntas: [
        Pregunta(
          pregunta: '¿Que tipo de celula forma a los seres humanos?',
          opciones: [
            'Celula vegetal',
            'Celula procariota',
            'Celula animal',
            'Celula bacteriana',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'Los seres humanos y todos los animales estan formados por celulas animales.',
        ),
        Pregunta(
          pregunta: '¿Que caracteristica NO tiene la celula animal?',
          opciones: [
            'Membrana plasmatica',
            'Pared celular',
            'Nucleo',
            'Mitocondrias',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'La celula animal no tiene pared celular, solo membrana plasmatica.',
        ),
        Pregunta(
          pregunta: '¿Por que la celula animal no realiza fotosintesis?',
          opciones: [
            'Porque es muy pequena',
            'Porque no tiene cloroplastos',
            'Porque no tiene nucleo',
            'Porque no tiene membrana',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'La celula animal no tiene cloroplastos, que son necesarios para la fotosintesis.',
        ),
        Pregunta(
          pregunta: '¿Que organelo produce energia en la celula animal?',
          opciones: [
            'El nucleo',
            'La vacuola',
            'La mitocondria',
            'El ribosoma',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'Las mitocondrias son las encargadas de producir energia en la celula.',
        ),
      ],
    ),
  ),

  // 1.3 Célula Vegetal
  Subtema(
    id: '1.3',
    numero: '1.3',
    titulo: 'La Celula Vegetal',
    descripcion: 'Conoce la celula que forma a las plantas',
    contenido: [
      const ContenidoSeccion(
        tipo: 'titulo',
        contenido: 'La Celula Vegetal',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'La celula vegetal es la unidad basica que forma a todas las plantas, desde el pasto hasta los arboles mas grandes.',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Al igual que la celula animal, es eucariota, pero tiene estructuras especiales que le permiten producir su propio alimento.',
      ),
      const ContenidoSeccion(
        tipo: 'imagen',
        contenido: 'assets/celula/celulavegetal.jpg',
        items: ['Estructura de la celula vegetal'],
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Caracteristicas principales',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'La celula vegetal se caracteriza por:',
        items: [
          'Tiene pared celular rigida (hecha de celulosa)',
          'Posee cloroplastos para realizar fotosintesis',
          'Tiene una vacuola central grande',
          'Tiene forma rectangular o cuadrada',
          'Puede producir su propio alimento',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Partes exclusivas de la celula vegetal',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'Estructuras especiales:',
        items: [
          'Pared celular: Capa rigida que da forma y proteccion',
          'Cloroplastos: Contienen clorofila para la fotosintesis',
          'Vacuola central: Almacena agua y da rigidez a la planta',
          'Plastos: Almacenan pigmentos y sustancias',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido:
            'La celula vegetal puede producir su propio alimento usando luz solar, agua y dioxido de carbono.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'La Fotosintesis',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Los cloroplastos contienen clorofila, un pigmento verde que captura la luz del sol. Con esta energia, la planta convierte agua y CO2 en glucosa (alimento) y libera oxigeno.',
      ),
      const ContenidoSeccion(
        tipo: 'sabias_que',
        contenido:
            'Gracias a la fotosintesis de las plantas, tenemos el oxigeno que respiramos. Una sola hoja puede producir oxigeno para varias personas.',
      ),
      const ContenidoSeccion(
        tipo: 'video',
        contenido: 'https://youtu.be/ezNvi_71iEk?si=mJHjT3zx4mQ0E_KJ',
        items: ['La celula vegetal - Video explicativo'],
      ),
    ],
    quiz: const Quiz(
      titulo: 'Quiz: La Celula Vegetal',
      preguntas: [
        Pregunta(
          pregunta: '¿Que tipo de celula forma a las plantas?',
          opciones: [
            'Celula animal',
            'Celula vegetal',
            'Celula bacteriana',
            'Celula procariota',
          ],
          respuestaCorrecta: 1,
          explicacion: 'Las plantas estan formadas por celulas vegetales.',
        ),
        Pregunta(
          pregunta: '¿Que estructura permite a la celula vegetal producir su alimento?',
          opciones: [
            'Mitocondria',
            'Nucleo',
            'Cloroplasto',
            'Vacuola',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'El cloroplasto contiene clorofila y permite realizar la fotosintesis.',
        ),
        Pregunta(
          pregunta: '¿De que esta hecha la pared celular de las plantas?',
          opciones: [
            'Proteinas',
            'Celulosa',
            'Grasa',
            'Agua',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'La pared celular esta hecha de celulosa, que le da rigidez a la celula.',
        ),
        Pregunta(
          pregunta: '¿Que produce la celula vegetal durante la fotosintesis?',
          opciones: [
            'Solo agua',
            'Dioxido de carbono',
            'Glucosa y oxigeno',
            'Solo energia',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'Durante la fotosintesis, la celula produce glucosa (alimento) y libera oxigeno.',
        ),
        Pregunta(
          pregunta: '¿Cual es la funcion de la vacuola central en la celula vegetal?',
          opciones: [
            'Producir energia',
            'Realizar fotosintesis',
            'Almacenar agua y dar rigidez',
            'Guardar el ADN',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'La vacuola central almacena agua y nutrientes, y ayuda a mantener la rigidez de la planta.',
        ),
      ],
    ),
  ),

  // 1.4 Organelos y sus funciones
  Subtema(
    id: '1.4',
    numero: '1.4',
    titulo: 'Organelos y sus funciones',
    descripcion: 'Aprende sobre las partes internas de la celula',
    contenido: [
      const ContenidoSeccion(
        tipo: 'titulo',
        contenido: 'Organelos y sus funciones',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Las celulas tienen partes internas llamadas organelos, y cada uno cumple una funcion importante.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Membrana Celular',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'Funciones de la membrana celular:',
        items: [
          'Es la capa que rodea y protege la celula',
          'Controla que sustancias entran y salen de la celula',
          'Mantiene el equilibrio interno celular',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'Funcion clave: Proteccion y regulacion.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Nucleo',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'Funciones del nucleo:',
        items: [
          'Es el centro de control de la celula',
          'Guarda la informacion genetica',
          'Coordina las actividades celulares como el crecimiento y la reproduccion',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'Funcion clave: Direccion y control.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Mitocondrias',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'Funciones de las mitocondrias:',
        items: [
          'Son las encargadas de producir energia para la celula',
          'Transforman los nutrientes en energia utilizable',
          'Son fundamentales para el movimiento y las funciones vitales',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'Funcion clave: Produccion de energia.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Citoplasma',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'Funciones del citoplasma:',
        items: [
          'Es un liquido gelatinoso que llena el interior de la celula',
          'En el se encuentran suspendidos los organelos',
          'Permite que ocurran reacciones quimicas necesarias para la vida',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'Funcion clave: Medio donde ocurren los procesos celulares.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Vacuolas',
      ),
      const ContenidoSeccion(
        tipo: 'lista',
        contenido: 'Funciones de las vacuolas:',
        items: [
          'Almacenan agua, nutrientes y desechos',
          'Ayudan a mantener la forma y el equilibrio de la celula',
          'En las celulas vegetales, la vacuola es mas grande',
        ],
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'Funcion clave: Almacenamiento y regulacion.',
      ),
      const ContenidoSeccion(
        tipo: 'imagen',
        contenido: 'assets/celula/organelos.png',
        items: ['Principales organelos celulares'],
      ),
      const ContenidoSeccion(
        tipo: 'video',
        contenido: 'https://youtu.be/kE5wdEncrm8?si=Nzb6u469MnNs1TGw',
        items: ['Organelos y sus funciones - Video explicativo'],
      ),
    ],
    quiz: const Quiz(
      titulo: 'Quiz: Organelos y sus funciones',
      preguntas: [
        Pregunta(
          pregunta: '¿Cual es la funcion principal de las mitocondrias?',
          opciones: [
            'Almacenar agua',
            'Producir energia',
            'Proteger la celula',
            'Guardar informacion genetica',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'Las mitocondrias son las encargadas de producir energia para la celula.',
        ),
        Pregunta(
          pregunta: '¿Que organelo es el centro de control de la celula?',
          opciones: [
            'Citoplasma',
            'Vacuola',
            'Nucleo',
            'Membrana celular',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'El nucleo es el centro de control que guarda la informacion genetica.',
        ),
        Pregunta(
          pregunta: '¿Que funcion cumple la membrana celular?',
          opciones: [
            'Producir energia',
            'Almacenar nutrientes',
            'Proteger y regular que entra y sale de la celula',
            'Realizar la fotosintesis',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'La membrana celular protege la celula y controla el paso de sustancias.',
        ),
        Pregunta(
          pregunta: '¿Donde se encuentran suspendidos los organelos?',
          opciones: [
            'En el nucleo',
            'En la membrana',
            'En el citoplasma',
            'En las vacuolas',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'El citoplasma es el liquido gelatinoso donde se encuentran los organelos.',
        ),
        Pregunta(
          pregunta: '¿Que almacenan las vacuolas?',
          opciones: [
            'Solo proteinas',
            'Agua, nutrientes y desechos',
            'Unicamente energia',
            'Informacion genetica',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'Las vacuolas almacenan agua, nutrientes y desechos de la celula.',
        ),
      ],
    ),
  ),

  // 1.5 La célula en acción
  Subtema(
    id: '1.5',
    numero: '1.5',
    titulo: 'La celula en accion',
    descripcion: 'Nutricion, reproduccion y relacion celular',
    contenido: [
      const ContenidoSeccion(
        tipo: 'titulo',
        contenido: 'La celula en accion: Nutricion, reproduccion y relacion',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido: 'Las celulas estan vivas y realizan funciones vitales:',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Nutricion',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Las celulas obtienen energia y materiales del ambiente para poder funcionar y mantenerse vivas.',
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'La nutricion permite obtener energia y materiales.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Reproduccion',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Las celulas tienen la capacidad de formar nuevas celulas, permitiendo el crecimiento y la reparacion de los tejidos.',
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'La reproduccion permite formar nuevas celulas.',
      ),
      const ContenidoSeccion(
        tipo: 'subtitulo',
        contenido: 'Relacion',
      ),
      const ContenidoSeccion(
        tipo: 'texto',
        contenido:
            'Las celulas pueden responder a estimulos del entorno, como cambios de temperatura, luz o presencia de sustancias.',
      ),
      const ContenidoSeccion(
        tipo: 'destacado',
        contenido: 'La relacion permite responder a estimulos del entorno.',
      ),
      const ContenidoSeccion(
        tipo: 'sabias_que',
        contenido:
            'Gracias a estas tres funciones vitales, los seres vivos pueden crecer, desarrollarse y mantenerse saludables.',
      ),
      const ContenidoSeccion(
        tipo: 'video',
        contenido: 'https://youtu.be/O18lUFI5OJc?si=AGUbrVPlYGVdFHLC',
        items: ['La celula en accion - Video explicativo'],
      ),
    ],
    quiz: const Quiz(
      titulo: 'Quiz: La celula en accion',
      preguntas: [
        Pregunta(
          pregunta: '¿Cuales son las tres funciones vitales de la celula?',
          opciones: [
            'Comer, dormir y jugar',
            'Nutricion, reproduccion y relacion',
            'Crecer, moverse y pensar',
            'Respirar, comer y beber',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'Las tres funciones vitales son nutricion, reproduccion y relacion.',
        ),
        Pregunta(
          pregunta: '¿Que permite la funcion de nutricion?',
          opciones: [
            'Formar nuevas celulas',
            'Responder al ambiente',
            'Obtener energia y materiales',
            'Moverse rapidamente',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'La nutricion permite que las celulas obtengan energia y materiales.',
        ),
        Pregunta(
          pregunta: '¿Que funcion permite a las celulas responder a estimulos?',
          opciones: [
            'Nutricion',
            'Reproduccion',
            'Relacion',
            'Respiracion',
          ],
          respuestaCorrecta: 2,
          explicacion:
              'La funcion de relacion permite a las celulas responder a estimulos del entorno.',
        ),
        Pregunta(
          pregunta: '¿Por que es importante la reproduccion celular?',
          opciones: [
            'Para obtener energia',
            'Para formar nuevas celulas y permitir el crecimiento',
            'Para responder al ambiente',
            'Para almacenar agua',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'La reproduccion celular es importante porque permite formar nuevas celulas para el crecimiento y reparacion.',
        ),
        Pregunta(
          pregunta: '¿Que pueden hacer los seres vivos gracias a las funciones vitales?',
          opciones: [
            'Solo moverse',
            'Crecer, desarrollarse y mantenerse saludables',
            'Unicamente respirar',
            'Solo alimentarse',
          ],
          respuestaCorrecta: 1,
          explicacion:
              'Gracias a las funciones vitales, los seres vivos pueden crecer, desarrollarse y mantenerse saludables.',
        ),
      ],
    ),
  ),
];
