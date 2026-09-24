# Guía Didáctica Interactiva y Chatbot Integrado en una Aplicación Móvil: Un Estudio de Caso en la Enseñanza de Ciencias Naturales

## Resumen

Los Sistemas Inteligentes de Tutoría son cada vez más utilizados en la educación para apoyar el aprendizaje personalizado y el monitoreo académico en entornos digitales a gran escala. Sin embargo, los sistemas existentes se basan predominantemente en arquitecturas estáticas y mecanismos basados en reglas rígidas, lo que limita la escalabilidad y dificulta la adaptación efectiva a estudiantes heterogéneos, comportamientos de aprendizaje evolutivos y contextos educativos del mundo real. Este trabajo presenta mi_app, una arquitectura multi-agente auto-adaptativa diseñada para el despliegue en aplicaciones móviles educativas, a través de la integración de modelos de lenguaje grandes (Google Generative AI), modelos de aprendizaje automático (TensorFlow Lite), y mecanismos de toma de decisiones adaptativos. La arquitectura está compuesta por agentes especializados con responsabilidades funcionales diferenciadas (generativo, visión, pedagógico y realidad aumentada), coordinados centralmente para asegurar la consistencia del sistema, la continuidad operacional y la coherencia en la toma de decisiones a lo largo del proceso de interacción.

**Palabras clave:** Inteligencia Artificial Generativa; Sistemas Inteligentes de Tutoría; Aplicaciones Móviles Educativas; Sistemas Multi-Agente; Aprendizaje Adaptativo.

---

## 2. Materiales y Métodos

Este estudio sigue un enfoque de investigación aplicada, centrado en la construcción y evaluación de una arquitectura inteligente de tutoría adaptativa implementada en una aplicación móvil Flutter dentro de un entorno educativo de producción. La metodología combina diseño arquitectónico, modelado de decisiones basado en aprendizaje adaptativo, y validación empírica a través de la implementación de casos de estudio reales y simulados. El sistema propuesto se evalúa utilizando una estrategia de métodos mixtos.

### 2.1. Diseño y Arquitectura del Sistema

mi_app fue diseñada como un Sistema Inteligente de Tutoría (SIT) basado en agentes, orientado a apoyar procesos de enseñanza y tutoría inteligente en educación de Ciencias Naturales, específicamente enfocado en contenidos de biología celular, considerando principios de Interacción Humano-IA (IH-IA), monitoreo académico y metodologías activas de enseñanza-aprendizaje. El diseño arquitectónico adopta un enfoque orientado a servicios basado en microservicios, con el objetivo de facilitar la interoperabilidad con plataformas móviles, el despliegue flexible y la escalabilidad del sistema en contextos educativos reales.

La arquitectura fue implementada utilizando Flutter 3.7.2+ como framework multiplataforma, lo que permite que los componentes principales del sistema—gestión de datos, orquestación, interacción y analítica—se ejecuten de manera independiente en plataformas Android, iOS y web, permitiendo replicar el despliegue del sistema en diferentes instituciones educativas que trabajan bajo entornos de aprendizaje móvil.

Bajo esta arquitectura, se presentan las capas de interacción, orquestación, Sistema Multi-Agente (SMA), aprendizaje adaptativo y gestión de datos, estableciendo canales de comunicación bien definidos entre ellas. Este esquema es particularmente relevante en un SIT que integra tecnologías como plataformas móviles, servicios en la nube (Firebase), modelos de IA generativa (Google Generative AI) y frameworks de aprendizaje automático (TensorFlow Lite), ya que minimiza el acoplamiento entre estas tecnologías mediante flujos de servicios automatizados (Figura 2). El despliegue basado en servicios permite actualizaciones incrementales, permitiendo que componentes específicos sean mejorados o reemplazados sin interrumpir la operación general del sistema.

#### 2.1.1. Capa de Interacción y Comunicación – Interfaz de Usuario

La arquitectura incorpora una capa de interacción móvil integrada en Flutter, que permite la comunicación bidireccional entre estudiantes y mi_app. La interacción es gestionada por servicios en Dart, que exponen APIs REST para autenticación, gestión de sesiones y sincronización de información académica, asegurando una integración segura a través de Firebase Authentication con soporte para Google Sign-In. La aplicación móvil actúa como un proveedor de contexto educativo, suministrando datos reales sobre cursos, actividades y progreso del estudiante, lo que permite la generación de respuestas adaptativas basadas en el proceso de formación.

#### 2.1.2. Capa de Orquestación y Automatización

Esta capa constituye el núcleo operacional del sistema y está implementada mediante servicios Dart como motor de orquestación, responsable de coordinar los flujos de comunicación y control entre la interfaz de usuario, el sistema multi-agente (SMA), el módulo de aprendizaje adaptativo, la base de datos y los servicios externos de IA. La selección de esta arquitectura orientada a servicios permite modelar pipelines de interacción complejos de manera flexible y transparente, combinando flujos de trabajo orientados a eventos con lógica condicional.

Dentro de esta capa, cada interacción de tutoría se gestiona como un ciclo de ejecución bien definido que incluye: la recepción de la consulta del usuario, el enriquecimiento contextual utilizando datos académicos e históricos, la evaluación por el Enrutador Inteligente de Servicios, la activación de los agentes especializados apropiados, y la validación de la respuesta generada previa a su entrega. La lógica de orquestación asegura que estos procesos se ejecuten de manera controlada y secuencial, preservando la consistencia entre interacciones mientras permite la adaptación dinámica de las estrategias de tutoría.

#### 2.1.3. Enrutador Inteligente de Servicios

El Enrutador Inteligente de Servicios está implementado dentro de la capa de orquestación, actuando como un nodo de decisión central. Este enrutador opera como un agente de decisión, analizando cada solicitud entrante considerando múltiples dimensiones: tipo de consulta, contexto académico, historial de interacciones y señales derivadas del comportamiento del estudiante. Basado en este análisis, determina cómo debe procesarse la solicitud y qué estrategias deben priorizarse. El enrutador representa una abstracción fundamental para la arquitectura, ya que permite desacoplar la lógica de decisión del funcionamiento interno del SMA. mi_app puede gestionar diversos escenarios educativos sin depender de flujos rígidos, permitiendo una tutoría dinámica que combina explicación conceptual, soporte práctico mediante reconocimiento de células, visualización de realidad aumentada y retroalimentación gamificada.

#### 2.1.4. Sistema Multi-Agente

Este constituye el núcleo inteligente del sistema global y está compuesto por múltiples agentes especializados: Agente Generativo, Agente de Visión, Agente Pedagógico y Agente de RA, que cooperan de manera integrada dentro de la arquitectura del sistema. Esta decisión de diseño simplifica la representación del sistema y enfatiza que la tutoría es el resultado de la colaboración interna entre agentes, en lugar de la activación aislada de componentes independientes.

El SMA es responsable de interpretar las solicitudes del usuario, generar respuestas contextualizadas, proponer recursos de aprendizaje y ofrecer retroalimentación adaptativa. Su diseño refleja la complejidad inherente de la tutoría en educación de ciencias, donde las necesidades del estudiante pueden variar significativamente dependiendo del conocimiento del dominio, los estilos de aprendizaje y los niveles de engagement. Al centralizar estas capacidades, la arquitectura promueve la consistencia pedagógica y facilita la evolución futura del sistema.

#### 2.1.5. Integración de Aprendizaje Adaptativo

Una característica distintiva de la arquitectura de mi_app es la incorporación explícita de mecanismos de aprendizaje adaptativo como sistema de adaptación continua (Figura 1). Esta capa introduce capacidades meta-cognitivas que permiten al sistema aprender de la experiencia acumulada y optimizar progresivamente sus estrategias de tutoría. Como se muestra en la Figura 2, el aprendizaje adaptativo se implementa como un módulo aislado, claramente separado del flujo principal de interacción.

El **Meta-Agente Coordinador de IA** actúa como un controlador de alto nivel, observando las interacciones del sistema, evaluando resultados y seleccionando estrategias que maximizan la recompensa acumulada, permitiendo que mi_app se adapte a patrones emergentes más allá de reglas estáticas. El aprendizaje es soportado por un **Sistema de Gamificación** (Rewards), que transforma las señales de interacción en valores numéricos representados como puntos, experiencia (XP) y logros, almacenados junto con el progreso del usuario en Firebase Firestore, constituyendo la memoria experiencial del sistema.

La arquitectura implementa una lógica de decisión híbrida, donde el **Enrutador Inteligente de Servicios** prioriza las estrategias basadas en el rendimiento del usuario cuando existe confianza suficiente y, en caso contrario, recurre a heurísticas o inferencia basada en modelos de lenguaje (Google Generative AI).

**Tabla 1.** Componentes del Ciclo de Aprendizaje Adaptativo en mi_app.

| Componente | Descripción | Implementación en mi_app |
|------------|-------------|--------------------------|
| **Política y Función de Valor** | Estrategias y predicciones que guían al agente | TensorFlow Lite (clasificación de células) + Google Generative AI (respuestas del chatbot) |
| **Meta-Agente IA** | Toma de decisiones con servicios especializados y enrutamiento inteligente | ScannerService, GuiaContextService, ChatService orquestados desde main.dart |
| **Recompensas** | Evalúa resultados de aprendizaje y señales de retroalimentación | Quiz correctos (+XP), escáner exitoso (+puntos), progreso en lecciones, logros desbloqueados |
| **Entorno** | El mundo externo donde operan los agentes de IA | Flutter App + Firebase (Auth, Firestore) + Contenido educativo (La Célula) |
| **Acciones** | Las opciones disponibles para el sistema de IA | Analizar célula, generar respuesta educativa, adaptar contenido, evaluar quiz, personalizar feedback |

**Tabla 2.** Matriz de Asignación de Recompensas (Aprendizaje Adaptativo).

| Tipo de Refuerzo | Entrada del Usuario | Valor Asignado (R) | Impacto en el Sistema |
|------------------|---------------------|-------------------|----------------------|
| Positivo (Recompensa) | Palabras clave: "Gracias", "Excelente", "Funciona", "Bien hecho" | +1.0 | Validación de éxito: la estrategia seleccionada abordó exitosamente la necesidad del usuario |
| Negativo (Penalización) | Palabras clave: "No entiendo", "Mal", "Error", "Confuso" | -1.0 | Corrección de error: la estrategia fue inefectiva o el agente seleccionado no fue apropiado |
| Neutral | Ausencia de retroalimentación explícita o interacciones fáticas simples | 0.0 | Mantenimiento de estado: no hay evidencia suficiente para modificar el comportamiento del sistema |

#### 2.1.6. Capa de Gestión de Datos y Base de Conocimiento

La Capa de Gestión de Datos y Conocimiento soporta el SMA y el módulo de aprendizaje adaptativo a través de Firebase Firestore como base de datos principal que almacena perfiles de usuario, historiales de interacción y métricas relevantes. Integra una base de conocimiento híbrida con recursos educativos locales y servicios externos, asegurando información relevante, trazable y contextualizada, así como facilitando el análisis y evaluación del sistema.

La Figura 2 ilustra la arquitectura general del sistema inteligente de tutoría de mi_app, estructurada en capas claramente desacopladas que soportan escalabilidad, seguridad y adaptación pedagógica. En la parte superior, un conjunto de principios transversales—objetivos educativos, diseño instruccional, estilos de aprendizaje, privacidad y seguridad, confianza y fiabilidad, y sesgo y equidad—enmarcan la operación del SIT.

La interacción del usuario comienza con estudiantes a través de una interfaz basada en **Flutter**, que sirve como aplicación móvil multiplataforma. La comunicación es gestionada mediante **Firebase Authentication** para la autenticación segura con Google Sign-In. Las pantallas principales incluyen:

**Tabla 3.** Pantallas de la aplicación y sus funciones educativas.

| Pantalla | Función | Tecnología |
|----------|---------|------------|
| ChatScreen | Diálogo interactivo con chatbot educativo | Google Generative AI |
| ScannerScreen | Captura de imagen y análisis de células | TensorFlow Lite, Camera |
| ARScreen | Visualización de realidad aumentada de estructuras celulares | SimpleMarkerDetector |
| GuíaScreen | Lecciones estructuradas sobre biología celular | GuiaContextService |
| QuizScreen | Evaluación del conocimiento adquirido | Quiz Models |

**Tabla 4.** Componentes de la Capa de Datos y sus funciones.

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

#### 2.1.7. Consideraciones para el Diseño de la Arquitectura

La arquitectura propuesta se fundamenta en un conjunto de principios transversales que guían su diseño y operación como SIT. Primero, los objetivos educativos guían la definición de estrategias de enseñanza y teorías educativas como el constructivismo, asegurando que cada recomendación, retroalimentación o explicación contribuya directamente al logro de resultados de aprendizaje.

**Tabla 5.** Criterios éticos para el diseño de mi_app alineados con principios de diseño ético IEEE.

| Principio | Criterio Aplicado | Implementación en mi_app | Componente Arquitectónico |
|-----------|-------------------|-------------------------|--------------------------|
| Bienestar Humano | Tutoría centrada en el estudiante | Se priorizan el apoyo académico y el acompañamiento emocional | SMA |
| Sesgo y Equidad | Equidad en el acceso | Los estudiantes registrados tienen acceso a las mismas funcionalidades | Flutter UI |
| | Adaptación basada en rendimiento | La personalización se fundamenta en indicadores académicos y de interacción | Enrutador Inteligente |
| Transparencia | Trazabilidad de decisiones | Cada decisión es registrada y trazable | Firebase Firestore, Modelo de Progreso |
| | Separación entre toma de decisiones y generación | El LLM genera lenguaje pero no decide estrategias pedagógicas | Orquestación, Enrutador |
| Responsabilidad | Control del flujo de decisiones | La lógica de tutoría se implementa mediante flujos explícitos y servicios auditables | Capa de Orquestación |
| Confianza y Fiabilidad | Consistencia en la tutoría | Estudiantes con antecedentes académicos similares reciben estrategias coherentes | SMA |
| | Aprendizaje validado por experiencia | El sistema ajusta su comportamiento solo cuando existe evidencia explícita de retroalimentación positiva o negativa | Meta-Agente, Calculador de Recompensas |
| Privacidad y Gobernanza de Datos | Minimización de datos | El sistema utiliza solo los datos académicos necesarios para la tutoría | Firebase, Servicios |
| | Aislamiento de información sensible | Los datos se almacenan en capas separadas con acceso controlado | Firestore, Auth |
| Robustez y Seguridad | Resiliencia arquitectónica | El uso de servicios y despliegue multiplataforma permite aislar fallos | Flutter, Firebase |

---

### 2.2. Sistema Multi-Agente y Mecanismo de Control Inteligente

mi_app se basa en una arquitectura multi-agente (SMA) diseñada para gestionar eficientemente la complejidad inherente en entornos de aprendizaje dinámicos, heterogéneos y basados en dispositivos móviles. Este enfoque permite descomponer el proceso de tutoría inteligente en componentes especializados que cooperan de manera coordinada, promoviendo la escalabilidad, adaptabilidad y trazabilidad del sistema.

El flujo de interacción comienza con el **Agente de Recepción y Preprocesamiento**, que actúa como punto de entrada del sistema. Este agente recibe las solicitudes del usuario a través de la interfaz Flutter, realiza procesos de normalización textual y ejecuta una clasificación inicial de intención utilizando heurísticas y técnicas ligeras de procesamiento de lenguaje natural. Las consultas se categorizan en diferentes tipos: solicitudes conceptuales, resolución de problemas prácticos, retroalimentación sobre rendimiento académico o solicitudes de soporte motivacional. Al mismo tiempo, el sistema recupera el contexto académico relevante desde Firebase, incluyendo información del progreso del estudiante, e identifica el idioma de interacción para activar mecanismos de traducción cuando sea necesario.

La toma de decisiones centralizada se lleva a cabo en el **Enrutador Inteligente**, que opera como el nodo de control cognitivo del SMA. Este componente evalúa cada interacción considerando tres factores principales: el tipo de consulta detectada, el perfil del estudiante inferido de su historial de interacción, y el nivel de complejidad cognitiva requerido. Basado en esta evaluación, el enrutador determina dinámicamente qué agente o combinación de agentes debe ser activado, evitando flujos conversacionales rígidos y permitiendo una gestión flexible y contextualizada del proceso tutorial.

Los agentes de soporte pedagógico y tutoría operan de manera coordinada para abordar las diferentes necesidades del estudiante. El **Agente Generativo** genera explicaciones teóricas estructuradas alineadas con los objetivos de aprendizaje del contenido, apoyándose en modelos de lenguaje a gran escala y fuentes académicas previamente curadas. El **Agente de Visión** se centra en el reconocimiento de células, generando ejemplos aplicados mediante el escáner de imágenes. Por su parte, el **Agente Pedagógico** examina patrones de interacción y evolución del rendimiento académico para producir retroalimentación formativa, mientras que el **Agente de RA** ofrece visualizaciones 3D de estructuras celulares para reforzar la comprensión.

La Figura 3 presenta el flujo de trabajo completo de los agentes, conceptualizado como un sistema de entrada-proceso-salida, que demuestra la coordinación entre los componentes del SMA y su integración con el entorno de aprendizaje virtual.

**Tabla 6.** Agentes especializados en el Sistema Multi-Agente de mi_app.

| Agente | Tecnología | Función | Salida |
|--------|------------|---------|--------|
| Agente Generativo | Google Generative AI | Chatbot educativo para consultas conceptuales | Respuestas en lenguaje natural sobre biología celular |
| Agente de Visión | TensorFlow Lite | Reconocimiento y clasificación de imágenes de células | Identificación de estructuras celulares |
| Agente Pedagógico | GuiaContextService | Entrega de contenido adaptativo y seguimiento del progreso | Rutas de aprendizaje personalizadas |
| Agente de RA | SimpleMarkerDetector | Visualización de realidad aumentada | Modelos 3D de estructuras celulares |

---

### 2.3. Meta-Agente y Aprendizaje Adaptativo

mi_app incorpora un **Meta-Agente Coordinador** que integra un ciclo de aprendizaje adaptativo como mecanismo de control adaptativo. Este componente supervisa la selección de estrategias tutoriales dentro del sistema multi-agente, aprendiendo de la experiencia acumulada sin interactuar directamente con el estudiante. El aprendizaje adaptativo se implementa utilizando una formulación simplificada inspirada en Q-learning tabular, donde el estado combina el nivel de conocimiento del estudiante y su progreso inferido, y las acciones corresponden a estrategias tutoriales.

El Meta-Agente consulta una memoria experiencial persistente y prioriza la política aprendida cuando existe confianza suficiente; en caso contrario, recurre a reglas o inferencia basada en LLM. Después de cada interacción, un promedio incremental de recompensas actualiza los valores, asegurando estabilidad e interpretabilidad. Este ciclo, mostrado en la Figura 4, permite la adaptación progresiva del comportamiento del sistema en contextos reales.

El proceso de toma de decisiones del Meta-Agente basado en aprendizaje adaptativo se formaliza como una política de enrutamiento que selecciona la estrategia de tutoría con la mayor utilidad estimada para un estado contextual dado:

**Ecuación 1.** Política de selección de estrategia:
```
a* = arg max Q(s, a)
     a ∈ A
```

donde `s` denota el estado contextual del estudiante, definido como una combinación del nivel de conocimiento inferido y el estado de progreso. El conjunto `A` representa el espacio de estrategias tutoriales disponibles, cada una correspondiente a la activación de uno o más agentes especializados dentro del sistema multi-agente.

**Ecuación 2.** Regla de actualización de utilidad:
```
Q_n+1 = (Q_n · n + R) / (n + 1)
```

donde `Q_n` es la estimación de utilidad actual después de `n` observaciones, `R` es la recompensa obtenida de la interacción más reciente, y `n` denota el número de veces que la estrategia correspondiente ha sido previamente seleccionada bajo el mismo estado contextual.

El espacio de estados se define como la combinación del **nivel de conocimiento inferido** del usuario (básico, intermedio, avanzado) y su **progreso en la guía didáctica**, generando estados contextuales compuestos que caracterizan cada interacción. Esta abstracción permite al sistema distinguir entre situaciones pedagógicas recurrentes, como solicitudes de aclaración conceptual, escenarios de resolución exitosa de quizzes, o casos de alerta asociados con dificultades de comprensión en estudiantes novatos.

---

### 2.4. Programación y Lógica Funcional de Agentes

Las Tablas 7-10 describen la arquitectura funcional y lógica de los agentes inteligentes del sistema. Cada agente cumple un rol específico dentro del flujo de interacción, y su comportamiento se modela utilizando pseudocódigo, permitiendo una representación transparente de los procesos de entrada, decisión y salida que sustentan la tutoría personalizada y ética del sistema.

**Tabla 7.** Lógica funcional del Agente de Recepción.

| Elemento | Descripción | Pseudocódigo |
|----------|-------------|--------------|
| Entrada | Mensaje + historial de conversación + datos del estudiante | `START` |
| Proceso | Clasificación semántica y contextual | `read current_message` |
| Salida | JSON con tipo, urgencia, tema y complejidad | `read conversation_history` |
| Agente | Agente Receptor/Clasificador | `analyze context` |
| | | `classify request_type` |
| | | `determine urgency_level` |
| | | `identify academic_topic` |
| | | `return {type, urgency, topic, complexity}` |
| | | `END` |

**Tabla 8.** Lógica funcional del Agente Generativo (Chatbot).

| Elemento | Descripción | Pseudocódigo |
|----------|-------------|--------------|
| Entrada | Datos de solicitud clasificada | `START` |
| Proceso | Generación de explicación académica | `read classified_data` |
| Salida | Respuesta teórica | `set response_language` |
| Agente | Agente Generativo (Google Gen AI) | `generate theoretical_explanation` |
| | | `return response` |
| | | `END` |

**Tabla 9.** Lógica funcional del Agente de Visión (Scanner).

| Elemento | Descripción | Pseudocódigo |
|----------|-------------|--------------|
| Entrada | Imagen de célula capturada | `START` |
| Proceso | Clasificación con TensorFlow Lite | `read captured_image` |
| Salida | Identificación de estructura celular | `preprocess_image` |
| Agente | Agente de Visión | `classify_with_model` |
| | | `generate_explanation` |
| | | `return {cell_type, confidence, description}` |
| | | `END` |

**Tabla 10.** Lógica funcional del Agente Pedagógico.

| Elemento | Descripción | Pseudocódigo |
|----------|-------------|--------------|
| Entrada | Estado del progreso del estudiante | `START` |
| Proceso | Evaluación y adaptación del contenido | `read user_progress` |
| Salida | Ruta de aprendizaje personalizada | `evaluate current_level` |
| Agente | Agente Pedagógico | `determine next_content` |
| | | `adapt difficulty_level` |
| | | `return {next_lesson, recommendations}` |
| | | `END` |

---

## Leyendas de Figuras

**Figura 1.** Ciclo de Aprendizaje Adaptativo del Meta-Agente Coordinador en mi_app. El diagrama muestra los cinco componentes principales del ciclo: Política y Función de Valor (TensorFlow Lite + Google Generative AI), Meta-Agente IA (coordinación de servicios), Recompensas (sistema de gamificación), Entorno (Flutter App + Firebase), y Acciones (opciones disponibles para el sistema).

**Figura 2.** Arquitectura del sistema inteligente de tutoría con IA propuesto para la enseñanza de Ciencias Naturales (mi_app). El sistema está estructurado en capas claramente desacopladas: Interfaz de Usuario (Flutter), Orquestación de Servicios (Servicios Dart), Sistema Multi-Agente (Agentes Generativo, Visión, Pedagógico, RA), Aprendizaje Adaptativo (Meta-Agente, Modelo de Progreso, Calculador de Recompensas), y Capa de Datos y Conocimiento (Firestore, Base de Conocimiento, Memoria, Modelos ML).

**Figura 3.** Flujo de Trabajo Multi-Agente y Flujo de Decisión de la Arquitectura de mi_app. El diagrama presenta el flujo completo conceptualizado como un sistema de entrada-proceso-salida, mostrando la coordinación entre los componentes del SMA y su integración con la capa de datos y el módulo de aprendizaje adaptativo.

**Figura 4.** Ciclo de Decisión Simplificado para la Orquestación del Meta-Agente en mi_app. El diagrama de flujo muestra el proceso de toma de decisiones desde la ingesta de contexto, definición del estado, análisis semántico de retroalimentación, hasta la generación de la salida de aprendizaje adaptativo con la tupla [Estado, Acción, Recompensa].

---

## Tecnologías Utilizadas

**Tabla 11.** Principales tecnologías implementadas en mi_app.

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
