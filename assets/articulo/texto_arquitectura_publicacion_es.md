# Arquitectura del Sistema Inteligente de Tutoría con IA para la Enseñanza de Ciencias Naturales

## 2.1. Diseño y Arquitectura del Sistema

mi_app fue diseñada como un Sistema Inteligente de Tutoría (SIT) basado en agentes, orientado a apoyar procesos de enseñanza y tutoría inteligente en educación de Ciencias Naturales, específicamente enfocado en contenidos de biología celular, considerando principios de Interacción Humano-IA (IH-IA), monitoreo académico y metodologías activas de enseñanza-aprendizaje. El diseño arquitectónico adopta un enfoque orientado a servicios basado en microservicios, con el objetivo de facilitar la interoperabilidad con plataformas móviles, el despliegue flexible y la escalabilidad del sistema en contextos educativos reales.

La arquitectura fue implementada utilizando Flutter 3.7.2+ como framework multiplataforma, lo que permite que los componentes principales del sistema—gestión de datos, orquestación, interacción y analítica—se ejecuten de manera independiente en plataformas Android, iOS y web, permitiendo replicar el despliegue del sistema en diferentes instituciones educativas que trabajan bajo entornos de aprendizaje móvil.

Bajo esta arquitectura, se presentan las capas de interacción, orquestación, Sistema Multi-Agente (SMA), aprendizaje adaptativo y gestión de datos, estableciendo canales de comunicación bien definidos entre ellas. Este esquema es particularmente relevante en un SIT que integra tecnologías como plataformas móviles, servicios en la nube (Firebase), modelos de IA generativa (Google Generative AI) y frameworks de aprendizaje automático (TensorFlow Lite), ya que minimiza el acoplamiento entre estas tecnologías mediante flujos de servicios automatizados (Figura 2).

### 2.1.1. Capa de Interfaz de Usuario

La arquitectura incorpora una capa de interacción móvil implementada en Flutter, que permite la comunicación bidireccional entre estudiantes y el sistema inteligente de tutoría. La interacción es gestionada por servicios en Dart, que exponen APIs REST para autenticación, gestión de sesiones y sincronización de información académica, asegurando una integración segura a través de Firebase Authentication con soporte para Google Sign-In.

La aplicación móvil actúa como un proveedor de contexto educativo, suministrando datos reales sobre actividades de aprendizaje, progreso del estudiante y patrones de interacción. Las principales pantallas de la aplicación incluyen:

**Tabla 1.** Pantallas de la aplicación y sus funciones educativas.

| Pantalla | Función | Tecnología |
|----------|---------|------------|
| ChatScreen | Diálogo interactivo con chatbot educativo | Google Generative AI |
| ScannerScreen | Captura de imagen y análisis de células | TensorFlow Lite, Camera |
| ARScreen | Visualización de realidad aumentada de estructuras celulares | SimpleMarkerDetector |
| GuíaScreen | Lecciones estructuradas sobre biología celular | GuiaContextService |
| QuizScreen | Evaluación del conocimiento adquirido | Quiz Models |

### 2.1.2. Capa de Orquestación de Servicios

Esta capa constituye el núcleo operacional del sistema y está implementada mediante servicios Dart como motor de orquestación, responsable de coordinar los flujos de comunicación y control entre la interfaz de usuario, el sistema multi-agente (SMA), el módulo de aprendizaje adaptativo, la base de datos y los servicios externos de IA. La selección de una arquitectura orientada a servicios permite modelar pipelines de interacción complejos de manera flexible y transparente.

Dentro de esta capa, cada interacción de tutoría se gestiona como un ciclo de ejecución bien definido que incluye: la recepción de la consulta del usuario, el enriquecimiento contextual utilizando datos académicos e históricos, la evaluación por el Enrutador Inteligente de Servicios, la activación de los agentes especializados apropiados, y la validación de la respuesta generada previa a su entrega.

### 2.1.3. Enrutador Inteligente de Servicios

El Enrutador Inteligente de Servicios está implementado dentro de la capa de orquestación, actuando como un nodo de decisión central. Este enrutador opera como un agente de decisión, analizando cada solicitud entrante considerando múltiples dimensiones: tipo de consulta, contexto académico, historial de interacciones y señales derivadas del comportamiento del estudiante.

Los siguientes servicios son coordinados por el Enrutador Inteligente:

- **AuthService**: Gestiona la autenticación de usuarios mediante Firebase Auth y Google Sign-In
- **FirestoreService**: Maneja el acceso a datos en tiempo real para perfiles, historiales de interacción y gestión de sesiones
- **ScannerService**: Procesa imágenes de células utilizando modelos TensorFlow Lite para reconocimiento y clasificación
- **GuiaContextService**: Proporciona contenido educativo adaptativo basado en el progreso del estudiante
- **ChatService**: Coordina las interacciones con el modelo de IA generativa para el diálogo educativo

### 2.1.4. Sistema Multi-Agente

Este constituye el núcleo inteligente del sistema global y está compuesto por múltiples agentes especializados que cooperan de manera integrada dentro de la arquitectura del sistema. Este diseño enfatiza que la tutoría es el resultado de la colaboración interna entre agentes, en lugar de la activación aislada de componentes independientes.

**Tabla 2.** Agentes especializados en el Sistema Multi-Agente.

| Agente | Tecnología | Función | Salida |
|--------|------------|---------|--------|
| Agente Generativo | Google Generative AI | Chatbot educativo para consultas conceptuales | Respuestas en lenguaje natural sobre biología celular |
| Agente de Visión | TensorFlow Lite | Reconocimiento y clasificación de imágenes de células | Identificación de estructuras celulares |
| Agente Pedagógico | GuiaContextService | Entrega de contenido adaptativo | Rutas de aprendizaje personalizadas |
| Agente de RA | SimpleMarkerDetector | Visualización de realidad aumentada | Modelos 3D de estructuras celulares |

El SMA es responsable de interpretar las solicitudes del usuario, generar respuestas contextualizadas, proponer recursos de aprendizaje y ofrecer retroalimentación adaptativa. El componente de **Salida UI** consolida las salidas producidas por los diferentes agentes y ajusta la profundidad y estilo de la respuesta según el perfil del estudiante.

El módulo de **Gamificación** proporciona señales de recompensa a través de un sistema basado en puntos que incluye: puntos por interacciones exitosas, Puntos de Experiencia (XP) por actividades completadas, progresión de nivel basada en aprendizaje acumulado, e insignias de logros por hitos alcanzados.

### 2.1.5. Integración de Aprendizaje Adaptativo

Una característica distintiva de la arquitectura de mi_app es la incorporación explícita de mecanismos de aprendizaje adaptativo como sistema de personalización continua (Figura 2). Esta capa introduce capacidades meta-cognitivas que permiten al sistema aprender de la experiencia acumulada y optimizar progresivamente sus estrategias de tutoría.

El **Meta-Agente Coordinador de IA** actúa como un controlador de alto nivel, observando las interacciones del sistema, evaluando resultados y seleccionando dinámicamente estrategias que maximizan los resultados de aprendizaje, permitiendo que mi_app se adapte a patrones emergentes más allá de reglas estáticas. El aprendizaje es soportado por:

- **Modelo de Progreso (UserProgressModel)**: Rastrea el avance del estudiante a través de los objetivos de aprendizaje, almacenando tasas de completación, subtemas actuales y porcentajes de progreso general
- **Calculador de Recompensas**: Transforma las señales de interacción en valores numéricos que informan al sistema de gamificación y guían la selección de contenido adaptativo
- **Estadísticas de Usuario y Logros**: Mantiene métricas acumulativas sobre rendimiento en quizzes, tiempo invertido y logros desbloqueados

La arquitectura implementa una lógica de decisión híbrida, donde el Enrutador Inteligente prioriza estrategias basadas en métricas de rendimiento del estudiante cuando existe confianza suficiente; en caso contrario, recurre a heurísticas o inferencia basada en modelos de lenguaje.

**Tabla 3.** Matriz de asignación de recompensas para aprendizaje adaptativo.

| Tipo de Refuerzo | Entrada del Usuario | Valor Asignado | Impacto en el Sistema |
|------------------|---------------------|----------------|----------------------|
| Positivo (Recompensa) | Respuestas correctas en quiz, escaneo exitoso de célula, lección completada | +XP, +Puntos, Logro | Validación de estrategia: el enfoque seleccionado abordó exitosamente la necesidad del usuario |
| Negativo (Penalización) | Respuestas incorrectas, reconocimiento fallido, sesión abandonada | Sin recompensa o -Puntos | Corrección de error: la estrategia fue inefectiva o la selección del agente fue inapropiada |
| Neutro | Navegación de contenido, navegación sin interacción explícita | Sin cambio | Mantenimiento de estado: evidencia insuficiente para modificar el comportamiento del sistema |

### 2.1.6. Capa de Gestión de Datos y Base de Conocimiento

La Capa de Gestión de Datos y Conocimiento soporta el SMA y el módulo de aprendizaje adaptativo a través de Firebase Firestore como base de datos principal que almacena perfiles de usuario, historiales de interacción y métricas relevantes. Integra una base de conocimiento híbrida con recursos educativos locales y servicios externos, asegurando información relevante, trazable y contextualizada.

**Tabla 4.** Componentes de la capa de datos y sus funciones.

| Componente | Contenido | Tecnología |
|------------|-----------|------------|
| Firebase Firestore | Perfiles de usuario, historial de sesiones, mensajes de chat, registros de progreso | Cloud Firestore |
| Base de Conocimiento | Contenido educativo estructurado sobre biología celular | celula_data.dart |
| Memoria | Historial de conversaciones, registros de sesión | ChatHistoryScreen |
| Modelos ML | Modelos pre-entrenados para reconocimiento de células | TensorFlow Lite (assets/models/) |

**Recursos Externos** integrados en el sistema:
- Google Generative AI API para funcionalidad del chatbot educativo
- YouTube Player para contenido de video educativo
- Speech to Text para características de accesibilidad
- Image Picker y Camera para captura de imágenes de células

**Assets Educativos** almacenados localmente:
- `assets/libro/` - Contenido de texto estructurado
- `assets/CELULA/` - Imágenes y recursos visuales relacionados con células
- `assets/marcadores/` - Marcadores QR para realidad aumentada
- `assets/models/` - Archivos de modelos TensorFlow Lite

### 2.1.7. Consideraciones para el Diseño de la Arquitectura

La arquitectura propuesta se fundamenta en un conjunto de principios transversales que guían su diseño y operación como SIT. Los objetivos educativos guían la definición de estrategias de enseñanza alineadas con teorías constructivistas del aprendizaje, asegurando que cada recomendación, retroalimentación o explicación contribuya directamente al logro de resultados de aprendizaje en educación de biología celular.

**Tabla 5.** Alineación entre la arquitectura de mi_app y principios de diseño ético.

| Principio | Criterio Aplicado | Implementación en mi_app | Componente Arquitectónico |
|-----------|-------------------|-------------------------|--------------------------|
| Bienestar Humano | Tutoría centrada en el estudiante | Se priorizan el apoyo académico y el engagement | SMA |
| Sesgo y Equidad | Equidad en el acceso | Todos los usuarios tienen acceso a las mismas funcionalidades | Flutter UI |
| | Adaptación basada en rendimiento | La personalización se fundamenta en indicadores académicos y de interacción | Enrutador Inteligente |
| Transparencia | Trazabilidad de decisiones | Cada decisión es registrada y trazable | Firestore, Modelo de Progreso |
| | Separación entre toma de decisiones y generación | El LLM genera lenguaje pero no decide estrategias pedagógicas | Orquestación, Enrutador |
| Responsabilidad | Control del flujo de decisiones | La lógica de tutoría se implementa mediante flujos explícitos y servicios auditables | Capa de Orquestación |
| Confianza y Fiabilidad | Consistencia en la tutoría | Estudiantes con antecedentes académicos similares reciben estrategias coherentes | SMA |
| Privacidad | Minimización de datos | El sistema utiliza solo los datos académicos necesarios para la tutoría | Firebase, Servicios |
| Robustez y Seguridad | Resiliencia arquitectónica | El uso de servicios y despliegue multiplataforma permite aislar fallos | Flutter, Firebase |

---

## Leyenda de Figura

**Figura 2.** Arquitectura del sistema inteligente de tutoría con IA propuesto para la enseñanza de Ciencias Naturales (mi_app). El sistema está estructurado en capas claramente desacopladas: Interfaz de Usuario (Flutter), Orquestación de Servicios (Servicios Dart), Sistema Multi-Agente (Agentes Generativo, Visión, Pedagógico, RA), Aprendizaje Adaptativo (Meta-Agente, Modelo de Progreso, Calculador de Recompensas), y Capa de Datos y Conocimiento (Firestore, Base de Conocimiento, Memoria, Modelos ML). Los principios transversales enmarcan la operación asegurando alineación educativa, privacidad, confianza y equidad.

---

## Tecnologías Utilizadas

**Tabla 6.** Principales tecnologías implementadas en mi_app.

| Categoría | Tecnología | Versión | Propósito |
|-----------|------------|---------|-----------|
| Framework | Flutter | 3.7.2+ | Desarrollo móvil multiplataforma |
| Lenguaje | Dart | SDK ^3.7.2 | Lógica de aplicación |
| Backend | Firebase Core | 3.8.1 | Infraestructura en la nube |
| Autenticación | Firebase Auth | 5.3.3 | Autenticación de usuarios |
| Base de Datos | Cloud Firestore | 5.5.0 | Almacenamiento de datos en tiempo real |
| IA Generativa | Google Generative AI | 0.4.6 | Chatbot educativo |
| Aprendizaje Automático | TensorFlow Lite | 0.11.0 | Modelos de reconocimiento de células |
| Autenticación | Google Sign-In | 6.2.2 | Autenticación OAuth |
| Cámara | Camera | 0.11.0 | Captura de imágenes |
| Accesibilidad | Speech to Text | 7.0.0 | Entrada de voz |
| Multimedia | YouTube Player | 9.1.1 | Videos educativos |

---

*Documento preparado para publicación científica - mi_app: Sistema Inteligente de Tutoría para la Enseñanza de Ciencias Naturales*
