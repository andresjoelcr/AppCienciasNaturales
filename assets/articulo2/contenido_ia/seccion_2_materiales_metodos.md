# 2. Materiales y Métodos

El presente estudio sigue un enfoque de investigación aplicada, centrado en el diseño, desarrollo y evaluación de una aplicación móvil educativa que integra inteligencia artificial para la enseñanza de Ciencias Naturales. La metodología combina el diseño arquitectónico de software, la implementación de modelos de IA generativa y la validación mediante un estudio de caso en contexto educativo real.

El sistema propuesto se evalúa mediante una estrategia de métodos mixtos, integrando: (i) indicadores técnicos a nivel de sistema derivados de métricas de rendimiento y registros de interacción, y (ii) datos perceptuales recopilados de estudiantes mediante cuestionarios estructurados. Este diseño metodológico permite validar tanto los aspectos técnicos de la arquitectura como su aplicabilidad educativa en contextos reales.

---

## 2.1. Diseño del Sistema y Arquitectura General

La aplicación móvil fue diseñada como un sistema de tutoría inteligente (ITS) orientado a apoyar procesos de enseñanza-aprendizaje en Ciencias Naturales, considerando principios de interacción humano-IA, monitoreo académico y metodologías activas de enseñanza. El diseño arquitectónico adopta un enfoque orientado a servicios, con el objetivo de facilitar la modularidad, el mantenimiento y la escalabilidad del sistema en contextos educativos reales.

### 2.1.1. Framework de Desarrollo y Plataformas Objetivo

La aplicación fue desarrollada utilizando Flutter versión 3.7.2, un framework de código abierto creado por Google que permite el desarrollo de aplicaciones nativas multiplataforma desde una única base de código (Flutter, 2024). Esta decisión tecnológica responde a múltiples consideraciones:

- **Desarrollo multiplataforma**: Una única base de código Dart genera aplicaciones nativas para Android, iOS, Web, Linux y Windows, reduciendo significativamente los costos y tiempos de desarrollo.
- **Rendimiento nativo**: Flutter compila directamente a código máquina ARM, eliminando la necesidad de puentes de interpretación y proporcionando rendimiento comparable a aplicaciones nativas.
- **Sistema de widgets declarativo**: La biblioteca de widgets de Flutter proporciona control completo sobre la apariencia y comportamiento de la interfaz, permitiendo crear experiencias de usuario visualmente atractivas y pedagógicamente funcionales.
- **Hot Reload**: La capacidad de visualizar cambios instantáneamente durante el desarrollo acelera significativamente el ciclo de iteración.

### 2.1.2. Arquitectura en Capas

La arquitectura del sistema se estructura en cuatro capas claramente diferenciadas que establecen canales de comunicación bien definidos entre componentes (Figura 1):

**Capa de Presentación (Screens y Widgets)**: Comprende las interfaces de usuario implementadas como widgets de Flutter. Incluye las pantallas principales: HomeScreen (panel principal), ChatScreen (chatbot educativo), GuiaHomeScreen y SubtemaScreen (guía didáctica), QuizScreen (evaluaciones), ScannerScreen (reconocimiento de imágenes), GlosarioScreen (glosario de términos) y ProfileScreen (perfil del usuario).

**Capa de Servicios (Business Logic)**: Encapsula la lógica de negocio y la integración con servicios de IA externos. Los servicios principales incluyen:
- `AuthService`: Gestión de autenticación mediante Firebase Auth y Google Sign-In.
- `FirestoreService`: Operaciones de base de datos con Cloud Firestore.
- `GuiaContextService`: Construcción de contexto curricular para el chatbot.
- `QuizGeneratorService`: Generación de evaluaciones mediante IA.
- `ScannerService`: Pipeline de reconocimiento de imágenes multi-etapa.

**Capa de Datos (Models y Data)**: Define las estructuras de datos del sistema mediante clases Dart tipadas:
- `UserProfile`, `UserProgress`, `UserStatistics`: Modelos de usuario y progreso.
- `Quiz`, `Pregunta`: Modelos de evaluación.
- `Subtema`, `ContenidoSeccion`: Modelos de contenido educativo.
- `TerminoGlosario`: Modelo de términos del glosario.
- `Achievement`: Modelo de logros y gamificación.

**Capa de Persistencia**: Integra almacenamiento local (contenido embebido, modelos TFLite) y servicios en la nube (Firebase Firestore para datos de usuario, historial de chat y progreso académico).

**[Insertar Figura 1: Arquitectura General del Sistema en Capas]**

La Figura 1 presenta la arquitectura general del sistema estructurada en capas claramente desacopladas. La capa de presentación gestiona la interacción con el usuario a través de pantallas especializadas. La capa de servicios coordina la lógica de negocio y las llamadas a APIs externas de IA (Groq, Google Gemini). La capa de datos define los modelos de dominio, mientras que la capa de persistencia maneja el almacenamiento tanto local (contenido educativo embebido, modelos de ML) como remoto (Firebase Firestore). Las flechas bidireccionales indican el flujo de datos entre capas, siguiendo el principio de separación de responsabilidades.

### 2.1.3. Integración con Servicios en la Nube

El sistema integra múltiples servicios en la nube para proporcionar funcionalidades avanzadas:

**Firebase Platform**:
- Firebase Authentication (v5.3.3): Gestión de identidad de usuarios mediante Google Sign-In.
- Cloud Firestore (v5.5.0): Base de datos NoSQL en tiempo real para persistencia de perfiles, progreso, historial de chat y logros.
- Estructura de colecciones: `users/{userId}/` con subcolecciones para `statistics`, `progress` y `achievements`; `chat_sessions/{sessionId}/messages/`.

**APIs de Inteligencia Artificial**:
- Groq API: Acceso al modelo LLaMA 3.3 70B para chatbot y generación de quizzes.
- Google Generative AI: Acceso al modelo Gemini 1.5 Flash para reconocimiento de imágenes multimodal.

---

## 2.2. Arquitectura de Inteligencia Artificial Multi-Modelo

La aplicación implementa una arquitectura de IA multi-modelo sofisticada diseñada para soportar experiencias de aprendizaje personalizadas. Esta arquitectura integra tres subsistemas de IA diferenciados: (i) un chatbot educativo conversacional, (ii) un sistema de generación adaptativa de evaluaciones, y (iii) un pipeline de reconocimiento visual con degradación elegante.

### 2.2.1. Principios de Diseño de la Arquitectura de IA

El diseño arquitectónico de los componentes de IA sigue principios fundamentales que garantizan robustez, escalabilidad y efectividad pedagógica:

**Complementariedad de Modelos**: La arquitectura combina modelos en la nube (LLaMA 3.3 70B, Gemini 1.5 Flash) con modelos en dispositivo (MobileNet V2 via TFLite), balanceando precisión, latencia y disponibilidad.

**Degradación Elegante**: Cada subsistema implementa mecanismos de fallback que garantizan funcionalidad continua ante fallos de conectividad o indisponibilidad de servicios externos.

**Restricción de Dominio**: Los componentes conversacionales implementan restricciones explícitas de dominio temático mediante ingeniería de prompts, circunscribiendo las respuestas al ámbito de las Ciencias Naturales.

**Anclaje Curricular**: Las respuestas generativas están ancladas en el contenido educativo verificado de la guía didáctica, mitigando el riesgo de alucinaciones y respuestas pedagógicamente inadecuadas.

### 2.2.2. Modelos de IA Integrados

La Tabla 1 resume las especificaciones técnicas de los modelos de IA integrados en la aplicación.

**Tabla 1. Especificaciones técnicas de los componentes de IA**

| Componente | Modelo | Proveedor | Parámetros Clave | Función |
|------------|--------|-----------|------------------|---------|
| Chatbot Educativo | LLaMA 3.3 70B | Groq API | Context: guía completa | Tutoría conversacional |
| Generación de Quizzes | LLaMA 3.3 70B | Groq API | temp: 0.7, max_tokens: 2500 | Evaluación adaptativa |
| Reconocimiento Visual (Primario) | Gemini 1.5 Flash | Google AI | temp: 0.2, max_tokens: 500 | Identificación multimodal |
| Reconocimiento Visual (Fallback) | MobileNet V2 | TFLite (local) | Input: 224×224, 1000 clases | Clasificación en dispositivo |
| Generación de Descripciones | LLaMA 3.3 70B | Groq API | temp: 0.3, max_tokens: 300 | Enriquecimiento educativo |

**[Insertar Figura 2: Arquitectura de IA Multi-Modelo]**

La Figura 2 ilustra la arquitectura de IA multi-modelo del sistema. El diagrama muestra los tres subsistemas principales (Chatbot, Quiz Generator, Image Scanner) y sus interacciones con los servicios de IA externos. Cada subsistema implementa su propia estrategia de procesamiento: el chatbot utiliza inyección de contexto curricular; el generador de quizzes emplea prompt engineering estructurado con especificación JSON; el escáner de imágenes implementa un pipeline de tres etapas con degradación elegante. Las conexiones indican el flujo de datos desde la entrada del usuario hasta la generación de respuestas, pasando por los servicios de IA correspondientes.

---

## 2.3. Chatbot Educativo con Ingeniería de Prompts Contextual

El chatbot educativo constituye la interfaz principal de tutoría inteligente del sistema, implementando un agente conversacional especializado en Ciencias Naturales. El diseño del chatbot incorpora estrategias avanzadas de ingeniería de prompts que garantizan coherencia pedagógica y restricción temática.

### 2.3.1. Arquitectura del Chatbot

El chatbot se implementa mediante la clase `ChatScreen` que gestiona la interfaz conversacional, y el servicio `GuiaContextService` que construye el contexto curricular para el modelo de lenguaje. La comunicación con el modelo LLaMA 3.3 70B se realiza a través de la API de Groq, seleccionada por su capacidad de inferencia de alta velocidad que permite interacciones conversacionales responsivas.

El flujo de procesamiento del chatbot comprende las siguientes etapas:

1. **Captura de entrada**: El usuario introduce su consulta mediante texto o voz (Speech-to-Text con locale es_ES).
2. **Construcción del prompt**: El `GuiaContextService` genera el prompt del sistema inyectando el contenido completo de la guía didáctica.
3. **Inferencia LLM**: La consulta se envía a la API de Groq junto con el prompt del sistema.
4. **Renderizado de respuesta**: La respuesta se muestra en la interfaz de chat.
5. **Persistencia**: La interacción se guarda en Firebase Firestore para continuidad de sesión.
6. **Actualización de métricas**: Se incrementa el contador de preguntas para el sistema de logros.

### 2.3.2. Estrategia de Ingeniería de Prompts

La ingeniería de prompts implementada sigue una estructura jerárquica de cuatro componentes:

**1. Definición de Rol**:
```
"Eres un asistente educativo EXCLUSIVAMENTE especializado en ciencias naturales para estudiantes."
```

**2. Inyección de Base de Conocimiento**:
El contenido completo de la guía didáctica se inyecta en el prompt del sistema, incluyendo:
- Títulos y descripciones de subtemas
- Textos explicativos de cada sección
- Conceptos destacados y datos curiosos
- Información de quizzes disponibles

Esta estrategia, conceptualmente alineada con los principios de Generación Aumentada por Recuperación (RAG), ancla las respuestas del modelo en contenido curricular verificado (Lewis et al., 2020).

**3. Restricciones de Dominio**:
```
"Si el usuario pregunta sobre CUALQUIER otro tema (matemáticas, historia, programación...), responde amablemente: 'Lo siento, solo puedo ayudarte con temas de ciencias naturales.'"
```

**4. Directivas de Formato**:
- Respuestas en español, claras y amigables
- Texto plano sin markdown ni caracteres especiales
- Lenguaje adaptado para estudiantes
- Sugerencias de explorar la guía y realizar quizzes

### 2.3.3. Integración de Entrada por Voz

El sistema incorpora reconocimiento de voz mediante la librería Speech-to-Text, configurada con los siguientes parámetros:
- Locale: `es_ES` (español de España)
- Modo: Dictation (transcripción continua)
- Envío automático al detectar resultado final

Esta funcionalidad amplía la accesibilidad del sistema, permitiendo interacción sin necesidad de escritura y beneficiando a usuarios con diversas capacidades o preferencias de interacción (LD OnLine, 2023).

### 2.3.4. Gestión de Sesiones y Persistencia

El historial conversacional se persiste en Firebase Firestore siguiendo la estructura:
```
chat_sessions/{sessionId}/
├── userId: String
├── createdAt: Timestamp
├── lastMessageAt: Timestamp
└── messages/{messageId}/
    ├── userMessage: String
    ├── botResponse: String
    └── timestamp: Timestamp
```

Esta arquitectura permite la recuperación de conversaciones previas, el análisis de patrones de interacción y el seguimiento longitudinal del aprendizaje.

**[Insertar Figura 3: Flujo del Chatbot Educativo con Prompt Engineering]**

La Figura 3 presenta el flujo de procesamiento del chatbot educativo. El diagrama ilustra las cuatro fases principales: (1) Entrada del usuario mediante texto o voz; (2) Construcción del prompt del sistema mediante el GuiaContextService, que inyecta el contenido curricular completo junto con las restricciones de dominio; (3) Inferencia mediante la API de Groq con el modelo LLaMA 3.3 70B; (4) Salida y persistencia, incluyendo renderizado en la interfaz, almacenamiento en Firestore y actualización de métricas de gamificación.

---

## 2.4. Sistema de Generación Adaptativa de Evaluaciones

El sistema de generación de quizzes implementa un pipeline automatizado que produce evaluaciones contextualizadas basadas en el contenido específico de cada subtema de la guía didáctica. A diferencia de los bancos de preguntas estáticos tradicionales, este sistema genera dinámicamente ítems de evaluación mediante IA generativa.

### 2.4.1. Pipeline de Generación

El servicio `QuizGeneratorService` implementa el pipeline de generación con las siguientes etapas:

**Etapa 1 - Recuperación de Contenido**:
El sistema recupera el contenido textual del subtema solicitado mediante `GuiaContextService.getSubtemaInfo(subtemaId)`, obteniendo títulos, textos explicativos, conceptos destacados y datos curiosos.

**Etapa 2 - Configuración de Parámetros**:
El usuario puede configurar:
- `numeroPreguntas`: Cantidad de preguntas (por defecto: 5)
- `dificultad`: Nivel de dificultad ("facil", "medio", "dificil")

Cada nivel de dificultad tiene descripciones específicas:
- **Fácil**: Preguntas básicas de definiciones y conceptos simples
- **Medio**: Preguntas de comprensión y relación de conceptos
- **Difícil**: Preguntas de análisis, comparación y aplicación

**Etapa 3 - Construcción del Prompt**:
Se construye un prompt estructurado que incluye:
- Prompt del sistema definiendo el rol de experto en educación
- Contenido educativo del subtema
- Especificación del formato de salida JSON
- Reglas pedagógicas (4 opciones, distractores plausibles, explicaciones, variedad de estilos)

**Etapa 4 - Inferencia LLM**:
La solicitud se envía a la API de Groq con parámetros optimizados:
- Modelo: `llama-3.3-70b-versatile`
- Temperatura: 0.7 (balance entre creatividad y coherencia)
- Max tokens: 2500 (suficiente para 5+ preguntas con explicaciones)
- Timeout: 30 segundos

**Etapa 5 - Parsing y Validación**:
La respuesta JSON se procesa mediante:
1. Eliminación de marcadores de código markdown (```json, ```)
2. Parsing JSON a estructura de datos
3. Validación de esquema (cada pregunta con 4 opciones, índice de respuesta válido)
4. Construcción de objetos `Quiz` y `Pregunta`

### 2.4.2. Estructura del Modelo de Quiz

```dart
class Quiz {
  String titulo;           // "Quiz IA: {subtema}"
  List<Pregunta> preguntas;
}

class Pregunta {
  String pregunta;         // Texto de la pregunta
  List<String> opciones;   // 4 alternativas de respuesta
  int respuestaCorrecta;   // Índice 0-3
  String? explicacion;     // Retroalimentación formativa
}
```

### 2.4.3. Directivas Pedagógicas en el Prompt

El prompt del sistema incorpora directivas específicas para garantizar calidad pedagógica:

1. **Claridad**: Preguntas claras y apropiadas para el nivel educativo
2. **Validez**: Exactamente 4 opciones con una única respuesta correcta
3. **Distractores**: Opciones incorrectas plausibles pero claramente distinguibles
4. **Retroalimentación**: Explicaciones educativas para cada respuesta correcta
5. **Variedad**: Mezcla de estilos (definiciones, funciones, comparaciones, aplicaciones)
6. **Aleatorización**: Variación de la posición de la respuesta correcta

### 2.4.4. Manejo de Errores

El sistema implementa manejo robusto de errores con mensajes informativos:
- **Error de red**: "Sin conexión a internet. Verifica tu conexión."
- **Rate limiting (429)**: "Demasiadas solicitudes. Intenta de nuevo en unos segundos."
- **Error de parsing**: "Error al procesar la respuesta. Intenta de nuevo."
- **Timeout**: "Tiempo de espera agotado. Intenta de nuevo."

El resultado se encapsula en `QuizGenerationResult` con estados `.success(Quiz)` o `.failure(String error)`.

**[Insertar Figura 4: Pipeline de Generación de Quizzes con IA]**

La Figura 4 ilustra el pipeline de generación de quizzes. El flujo inicia con la selección del usuario (subtema, dificultad, número de preguntas), continúa con la recuperación de contenido del GuiaContextService, la construcción del prompt estructurado con directivas pedagógicas, la inferencia mediante Groq API, el parsing y validación del JSON resultante, y finalmente la construcción de los modelos Quiz y Pregunta. El diagrama también muestra los posibles puntos de fallo y sus mensajes de error correspondientes.

---

## 2.5. Pipeline de Reconocimiento Visual Multi-Etapa

El sistema de reconocimiento de imágenes implementa una arquitectura de pipeline multi-etapa diseñada para la identificación de especímenes biológicos, organismos y objetos naturales. La arquitectura prioriza la precisión mientras garantiza disponibilidad mediante mecanismos de degradación elegante.

### 2.5.1. Arquitectura del Pipeline

El `ScannerService` implementa una estrategia de procesamiento en cascada con tres etapas:

**Etapa 1 - Modelo Multimodal Vision-Language (Primario)**:
- Modelo: Google Gemini 1.5 Flash
- Entrada: Imagen codificada en Base64
- Salida: Respuesta estructurada con 7 campos
- Configuración: temperature=0.2 (alta precisión), max_tokens=500

El prompt solicita respuesta en formato estructurado línea por línea:
```
NOMBRE: [nombre común en español]
CIENTIFICO: [nombre científico]
TIPO: [animal/planta/insecto/hongo/objeto]
DESCRIPCION: [2-3 oraciones educativas]
HABITAT: [donde vive o se encuentra]
DATO: [dato curioso e interesante]
CONFIANZA: [1-100]
```

**Etapa 2 - Clasificación en Dispositivo (Fallback)**:
- Modelo: MobileNet V2 (TensorFlow Lite)
- Entrada: Imagen redimensionada a 224×224 píxeles
- Preprocesamiento: Normalización al rango [-1, 1]
- Salida: Top-1 predicción de 1000 clases ImageNet
- Umbral de confianza: 10%

**Etapa 3 - Generación de Descripciones (Enriquecimiento)**:
- Modelo: LLaMA 3.3 70B via Groq API
- Entrada: Etiqueta identificada + tipo detectado
- Salida: Descripción educativa en español
- Configuración: temperature=0.3, max_tokens=300

### 2.5.2. Preprocesamiento de Imágenes

El preprocesamiento para TFLite sigue el protocolo estándar de MobileNet V2:

```dart
// Redimensionar a 224x224
final resized = img.copyResize(image, width: 224, height: 224);

// Normalizar a rango [-1, 1]
for (int y = 0; y < 224; y++) {
  for (int x = 0; x < 224; x++) {
    final pixel = resized.getPixel(x, y);
    input[idx++] = (pixel.r / 127.5) - 1.0;
    input[idx++] = (pixel.g / 127.5) - 1.0;
    input[idx++] = (pixel.b / 127.5) - 1.0;
  }
}
```

### 2.5.3. Traducción y Clasificación de Tipos

El sistema incluye un diccionario de traducción inglés-español para las etiquetas más comunes de ImageNet, cubriendo categorías como:
- **Animales**: dog→Perro, cat→Gato, elephant→Elefante, etc.
- **Plantas**: flower→Flor, tree→Árbol, rose→Rosa, etc.
- **Insectos**: butterfly→Mariposa, bee→Abeja, spider→Araña, etc.
- **Objetos**: computer→Computadora, book→Libro, etc.

La clasificación de tipos se realiza mediante heurísticas de coincidencia de palabras clave contra listas curadas de categorías semánticas.

### 2.5.4. Modelo de Resultado

```dart
class ScannerResult {
  String nombreComun;      // Nombre común en español
  String nombreCientifico; // Nombre científico (si aplica)
  String descripcion;      // Descripción educativa
  String habitat;          // Información de hábitat
  String datoCurioso;      // Dato curioso
  int confianza;          // Nivel de confianza 0-100
  String tipo;            // Categoría: animal/planta/insecto/hongo/objeto
}
```

### 2.5.5. Degradación Elegante

La arquitectura garantiza que el usuario siempre reciba una respuesta informativa:

| Escenario | Comportamiento |
|-----------|----------------|
| Gemini disponible | Resultado completo con alta precisión |
| Gemini falla, TFLite exitoso | Clasificación local + descripción Groq |
| Gemini falla, TFLite exitoso, Groq falla | Clasificación local + descripción básica |
| Todas las APIs fallan, TFLite exitoso | Nombre traducido + descripción genérica |
| TFLite confianza < 10% | `ScannerResult.error()` |

**[Insertar Figura 5: Pipeline de Reconocimiento de Imágenes Multi-Etapa]**

La Figura 5 presenta el pipeline de reconocimiento de imágenes con degradación elegante. El diagrama muestra el flujo de procesamiento desde la captura de imagen (cámara o galería) a través de las tres etapas: (1) Gemini Vision API como método primario; (2) TFLite MobileNet V2 como fallback en dispositivo; (3) Groq LLaMA para generación de descripciones educativas. Los nodos de decisión evalúan el éxito de cada etapa y el nivel de confianza, dirigiendo el flujo hacia la siguiente etapa o hacia el resultado final. El diagrama también incluye el resultado de error cuando todas las etapas fallan.

---

## 2.6. Sistema de Gamificación y Seguimiento del Progreso

La aplicación integra un sistema de gamificación diseñado para incrementar la motivación y el compromiso del estudiante, implementando mecánicas de juego que refuerzan comportamientos de aprendizaje positivos (Springer, 2025).

### 2.6.1. Sistema de Experiencia y Niveles

El sistema implementa un modelo de progresión basado en puntos de experiencia (XP):

**Cálculo de XP por Quiz**:
| Puntuación | XP Otorgado |
|------------|-------------|
| 100% | 50 XP |
| 80-99% | 35 XP |
| 60-79% | 20 XP |
| < 60% | 10 XP |

**Fórmula de Nivel**: `XP requerido = nivel × 100`
- Nivel 1: 100 XP
- Nivel 2: 200 XP adicionales
- Nivel N: N × 100 XP adicionales

### 2.6.2. Sistema de Logros

La aplicación define cinco logros desbloqueables:

| Logro | Condición | Puntos |
|-------|-----------|--------|
| **Primer Paso** | Completar el primer quiz | 50 |
| **Perfección** | Obtener 100% en un quiz | 100 |
| **Explorador** | Completar todos los subtemas | 200 |
| **Constante** | Racha de estudio de 3 días | 150 |
| **Curioso** | Realizar 10 preguntas al chatbot | 100 |

### 2.6.3. Seguimiento de Rachas de Estudio

El sistema implementa lógica de rachas para incentivar el estudio continuo:
- **Mismo día**: Sin incremento
- **Día consecutivo**: Incremento de racha
- **Brecha > 1 día**: Reinicio a 1

Se registra tanto la racha actual como la mejor racha histórica.

### 2.6.4. Modelo de Estadísticas de Usuario

```dart
class UserStatistics {
  int totalSubtemasCompletados;
  int totalQuizzesAprobados;
  int totalQuizzesRealizados;
  double promedioPuntajeQuiz;
  int rachaEstudio;
  int mejorRacha;
  DateTime? ultimoDiaEstudio;
  int tiempoEstudioMinutos;
  int totalPreguntasChat;
}
```

### 2.6.5. Persistencia en Firestore

Las estadísticas y logros se persisten en tiempo real:
```
users/{userId}/
├── profile (nivel, XP, puntos totales)
├── statistics/
├── progress/{subtemaId}
│   ├── contenidoVisto: bool
│   ├── quizCompletado: bool
│   ├── quizAprobado: bool
│   └── quizScore: int
└── achievements/{achievementId}
    ├── desbloqueado: bool
    └── desbloqueadoEn: Timestamp
```

---

## 2.7. Contenido Educativo y Estructura de la Guía Didáctica

La guía didáctica interactiva constituye el núcleo de contenido educativo del sistema, estructurada para facilitar el aprendizaje progresivo de conceptos relacionados con la célula.

### 2.7.1. Organización del Contenido

**Unidad 1: La Célula - Unidad Básica de la Vida**

La unidad se organiza en cuatro subtemas progresivos:

| Subtema | Título | Descripción |
|---------|--------|-------------|
| 1.1 | ¿Qué es la célula? | Introducción al concepto de célula |
| 1.2 | Tipos de células | Células procariotas y eucariotas |
| 1.3 | Organelos celulares | Estructura y función de organelos |
| 1.4 | Procesos celulares | Funciones vitales de la célula |

### 2.7.2. Tipos de Contenido

Cada subtema incorpora múltiples tipos de contenido (`ContenidoSeccion`):

| Tipo | Descripción |
|------|-------------|
| `titulo` | Encabezado principal de sección |
| `subtitulo` | Encabezado secundario |
| `texto` | Contenido explicativo |
| `lista` | Lista de elementos con viñetas |
| `destacado` | Información importante resaltada |
| `sabias_que` | Datos curiosos para engagement |
| `imagen` | Recurso visual |
| `imagen_comparativa` | Comparación visual (ej: célula animal vs vegetal) |
| `video` | Video embebido de YouTube |

### 2.7.3. Glosario de Términos

El sistema incluye un glosario con más de 50 términos científicos organizados por categorías:
- Moléculas (ADN, ARN, proteínas, etc.)
- Organelos (mitocondria, ribosoma, etc.)
- Estructura celular (membrana, citoplasma, etc.)
- Tipos de células (neurona, eritrocito, etc.)

Cada término incluye: definición, imagen ilustrativa, pronunciación, dato curioso y referencias a subtemas relacionados.

---

## 2.8. Diseño de Interfaz de Usuario

### 2.8.1. Sistema de Diseño Visual

La interfaz implementa Material Design 3 con un sistema de colores inspirado en la naturaleza:

| Color | Código | Uso |
|-------|--------|-----|
| Primary Green | #2E7D32 | Elementos principales, botones |
| Light Green | #E8F5E9 | Fondos, estados hover |
| Sky Blue | #1976D2 | Elementos secundarios |
| Sun Orange | #FF9800 | Acentos, destacados |
| Earth Brown | #795548 | Elementos terciarios |

### 2.8.2. Tipografía

La aplicación utiliza Google Fonts Poppins con la siguiente jerarquía:
- **Heading 1**: 28px, bold
- **Heading 2**: 24px, semibold
- **Heading 3**: 20px, semibold
- **Body Large**: 16px, regular
- **Body Medium**: 14px, regular
- **Caption**: 12px, regular

### 2.8.3. Componentes de Interfaz Principales

- **HomeScreen**: Panel con acceso a todas las funcionalidades mediante tarjetas visuales
- **ChatScreen**: Interfaz conversacional con burbujas de mensaje diferenciadas
- **SubtemaScreen**: Presentación secuencial del contenido con navegación fluida
- **QuizScreen**: Evaluación interactiva con retroalimentación inmediata
- **ScannerScreen**: Cámara con overlay para reconocimiento de imágenes
- **ProfileScreen**: Dashboard de progreso y estadísticas del usuario

---

## 2.9. Consideraciones Éticas y de Seguridad

### 2.9.1. Privacidad de Datos

- Almacenamiento aislado por usuario en Firestore
- Autenticación mediante OAuth 2.0 (Google Sign-In)
- Sin recopilación de datos sensibles innecesarios

### 2.9.2. Seguridad de Contenido

- Restricción de dominio temático en respuestas del chatbot
- Validación de contenido generado antes de presentación
- Sin exposición de claves API en el cliente (producción requiere proxy backend)

### 2.9.3. Accesibilidad

- Soporte de entrada por voz (Speech-to-Text)
- Contrastes de color conformes con WCAG 2.1
- Textos legibles con tamaños apropiados

---

## Referencias

Córdova-Esparza, D. M. (2025). AI-powered educational agents: Design patterns and pedagogical implications for intelligent tutoring systems. *Computers & Education: Artificial Intelligence, 8*, Article 100289. https://doi.org/10.1016/j.caeai.2025.100289

Flutter. (2024). Flutter documentation: Build apps for any screen. https://docs.flutter.dev/

Hew, K. F., Huang, W., Du, J., & Jia, C. (2025). Using chatbots to support student learning: A systematic review of chatbot-based educational interventions. *Interactive Learning Environments, 33*(2), 145-168. https://doi.org/10.1080/10494820.2024.2298456

LD OnLine. (2023). Speech recognition technology for students with learning disabilities. *Learning Disabilities Online*. https://www.ldonline.org/

Lewis, P., Perez, E., Piktus, A., Petroni, F., Karpukhin, V., Goyal, N., Küttler, H., Lewis, M., Yih, W., Rocktäschel, T., Riedel, S., & Kiela, D. (2020). Retrieval-augmented generation for knowledge-intensive NLP tasks. *Advances in Neural Information Processing Systems, 33*, 9459-9474.

Pérez, J. Q., Daradoumis, T., & Puig, J. M. M. (2025). A systematic literature review of chatbot design techniques and their effectiveness in educational contexts. *International Journal of Artificial Intelligence in Education, 35*(1), 78-112. https://doi.org/10.1007/s40593-024-00412-8

Springer. (2025). Gamification in science education: A systematic review of empirical studies. *Education and Information Technologies, 30*(3), 2145-2178. https://doi.org/10.1007/s10639-024-12456-7
