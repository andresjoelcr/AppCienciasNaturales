# Documentación de la Arquitectura de IA - mi_app
## Aplicación Móvil para la Enseñanza de Ciencias Naturales

---

## 2.1.5. Integración de Aprendizaje por Refuerzo (RL)

Una característica distintiva de la arquitectura de **mi_app** es la incorporación explícita de mecanismos de aprendizaje adaptativo como sistema de adaptación continua (Figura 1 - diagrama_ia_mi_app.drawio). Esta capa introduce capacidades meta-cognitivas que permiten al sistema aprender de la experiencia acumulada y optimizar progresivamente sus estrategias de tutoría en la enseñanza de Ciencias Naturales. Como se muestra en la Figura 1, el aprendizaje adaptativo se implementa como un módulo aislado, claramente separado del flujo principal de interacción.

El **Meta-Agente de IA** actúa como un controlador de alto nivel, observando las interacciones del sistema, evaluando resultados y seleccionando estrategias que maximizan la recompensa acumulada, permitiendo que mi_app se adapte a patrones emergentes más allá de reglas estáticas. El aprendizaje es soportado por un **Sistema de Gamificación** (Rewards), que transforma las señales de interacción en valores numéricos representados como puntos, experiencia (XP) y logros, almacenados junto con el progreso del usuario en Firebase Firestore, constituyendo la memoria experiencial del sistema.

La arquitectura implementa una lógica de decisión híbrida, donde el **Enrutador Inteligente de Servicios** prioriza las estrategias basadas en el rendimiento del usuario cuando existe confianza suficiente y, en caso contrario, recurre a heurísticas o inferencia basada en modelos de lenguaje (Google Generative AI).

### Componentes del Ciclo RL en mi_app

| Componente | Descripción | Implementación en mi_app |
|------------|-------------|--------------------------|
| **Policy & Value Function** | Estrategias y predicciones que guían al agente | TensorFlow Lite (clasificación de células) + Google Generative AI (respuestas del chatbot) |
| **Meta-Agente IA** | Toma de decisiones con servicios especializados y enrutamiento inteligente | ScannerService, GuiaContextService, ChatService orquestados desde main.dart |
| **Rewards (Recompensas)** | Evalúa resultados de aprendizaje y señales de retroalimentación que indican la calidad de las acciones | Quiz correctos (+XP), escáner exitoso (+puntos), progreso en lecciones, logros desbloqueados |
| **Environment (Entorno)** | El mundo externo donde operan los agentes de IA. Registra datos académicos y estado del usuario | Flutter App + Firebase (Auth, Firestore) + Contenido educativo (La Célula) |
| **Actions (Acciones)** | Las opciones disponibles para el sistema de IA | Analizar célula, generar respuesta educativa, adaptar contenido, evaluar quiz, personalizar feedback |

### Mecanismo de Recompensa

El mecanismo de recompensa se basa en un esquema de gamificación que transforma las interacciones del usuario en señales de retroalimentación:

| Tipo de Refuerzo | Entrada del Usuario | Valor Asignado | Impacto en el Sistema |
|------------------|---------------------|----------------|----------------------|
| Positivo (Reward) | Quiz correcto, interacción exitosa con el chatbot, escaneo de célula completado | +XP, +Puntos, Logro desbloqueado | Validación de éxito: la estrategia seleccionada abordó exitosamente la necesidad del usuario |
| Negativo (Penalty) | Quiz incorrecto, respuesta no comprendida, escaneo fallido | -Puntos o sin recompensa | Corrección de error: la estrategia fue inefectiva o el agente seleccionado no fue apropiado |
| Neutro | Navegación sin interacción explícita, lectura de contenido | Sin cambio | Mantenimiento de estado: no hay evidencia suficiente para modificar el comportamiento del sistema |

### Espacio de Estados

El espacio de estados se define como la combinación del **nivel de conocimiento inferido** del usuario (básico, intermedio, avanzado) y su **progreso en la guía didáctica**, generando estados contextuales compuestos que caracterizan cada interacción. Esta abstracción permite al sistema distinguir entre situaciones pedagógicas recurrentes, como solicitudes de aclaración conceptual, escenarios de resolución exitosa de quizzes, o casos de alerta asociados con dificultades de comprensión en estudiantes novatos.

### Modelos de Datos para el Aprendizaje Adaptativo

```dart
// UserProgressModel - Seguimiento del progreso
class UserProgressModel {
  String odaId;
  String odaName;
  int currentSubtema;
  int totalSubtemas;
  double progressPercentage;
  bool isCompleted;
}

// UserStatisticsModel - Métricas de desempeño
class UserStatisticsModel {
  int totalQuizzesCompleted;
  int totalCorrectAnswers;
  double averageScore;
  int totalTimeSpent;
}

// AchievementModel - Sistema de logros
class AchievementModel {
  String id;
  String title;
  String description;
  bool isUnlocked;
  DateTime? unlockedAt;
}
```

### Flujo de Decisión del Meta-Agente

El proceso de toma de decisiones del Meta-Agente basado en aprendizaje adaptativo se formaliza como una política de enrutamiento que selecciona la estrategia de tutoría con la mayor utilidad estimada para un estado contextual dado:

1. **Inicio**: El usuario interactúa con la aplicación (chat, escáner, quiz, guía)
2. **Ingesta de Contexto**: Se recopilan metadatos del enrutador, mensaje del usuario y progreso actual
3. **Definición del Estado**: Se determina el estado actual (nivel de conocimiento, progreso en ODA)
4. **Identificación de Acción**: Se selecciona el agente apropiado según el tipo de consulta
5. **Análisis de Retroalimentación**: Se evalúa si la respuesta fue positiva, negativa o neutral
6. **Asignación de Recompensa**: Se actualiza el sistema de gamificación (puntos, XP, logros)
7. **Actualización de Política**: Se ajusta el comportamiento del sistema basado en la experiencia acumulada

Este ciclo, ilustrado en la Figura 1, permite la adaptación progresiva del comportamiento del sistema en contextos educativos reales, asegurando que el contenido sobre la célula se presente de manera personalizada según las necesidades individuales de cada estudiante.

---

## 2.1.6. Capa de Gestión de Datos y Base de Conocimiento

La Figura 2 (diagrama_arquitectura_ia_mi_app.drawio) ilustra la arquitectura general del sistema inteligente de tutoría de **mi_app**, estructurada en capas claramente desacopladas que soportan escalabilidad, seguridad y adaptación pedagógica para la enseñanza de Ciencias Naturales.

### Principios Transversales

En la parte superior, un conjunto de principios transversales enmarcan la operación del sistema: **objetivos educativos**, **diseño instruccional**, **estilos de aprendizaje**, **privacidad y seguridad**, **confianza y fiabilidad**, y **sesgo y equidad**. Estos principios guían el comportamiento de todos los componentes de IA.

### Capa de Interfaz de Usuario (UI)

La interacción del usuario comienza con el **Estudiante** a través de una interfaz basada en **Flutter**, que sirve como aplicación móvil multiplataforma. La comunicación es gestionada mediante **Firebase Authentication** para la autenticación segura con Google Sign-In. Las pantallas principales incluyen:

| Screen | Función |
|--------|---------|
| **ChatScreen** | Interacción con el chatbot educativo |
| **ScannerScreen** | Captura y análisis de imágenes de células |
| **ARScreen** | Visualización de realidad aumentada |
| **GuíaScreen** | Lecciones estructuradas sobre la célula |
| **QuizScreen** | Evaluación del conocimiento adquirido |

### Capa de Orquestación de Servicios

Esta capa constituye el núcleo operacional del sistema y está implementada en **Dart** mediante servicios REST que coordinan los flujos de comunicación y control entre la interfaz de usuario, el sistema multi-agente (MAS), el módulo de aprendizaje adaptativo y la base de datos.

El **Enrutador Inteligente de Servicios** es responsable de seleccionar dinámicamente los componentes apropiados para cada solicitud:

- **AuthService**: Gestiona autenticación con Firebase + Google Sign-In
- **FirestoreService**: Acceso a datos en tiempo real (perfiles, historial, sesiones)
- **ScannerService**: Procesamiento de imágenes con TensorFlow Lite
- **GuiaContextService**: Contexto educativo y contenido adaptativo

### Sistema Multi-Agente de IA (MAS)

En el núcleo del sistema se encuentra el **Sistema Multi-Agente**, compuesto por agentes especializados que cooperan para producir respuestas contextualizadas:

| Agente | Tecnología | Función |
|--------|-----------|---------|
| **Agente Generativo** | Google Generative AI | Chatbot educativo que responde consultas sobre la célula |
| **Agente de Visión** | TensorFlow Lite | Reconocimiento y clasificación de imágenes de células |
| **Agente Pedagógico** | GuiaContextService | Adaptación del contenido según el nivel del estudiante |
| **Agente de AR** | SimpleMarkerDetector | Visualización 3D de estructuras celulares |

La **Salida UI** incluye personalización de respuestas, resultados de análisis y feedback adaptativo. El componente de **Evaluación y Gamificación** (puntos, niveles, logros) proporciona señales de recompensa al sistema.

### Capa de Aprendizaje Adaptativo

Operando de manera desacoplada, el **Meta-Agente** supervisa el sistema a nivel estratégico, evaluando resultados a través de los modelos de progreso y actualizando las políticas de decisión:

- **UserProgressModel**: Seguimiento del avance en lecciones
- **AchievementModel**: Sistema de logros y recompensas
- **UserStatisticsModel**: Métricas de desempeño del estudiante

### Capa de Gestión de Datos y Base de Conocimiento

La capa de datos soporta el MAS y el módulo de aprendizaje adaptativo a través de múltiples fuentes:

| Componente | Contenido |
|------------|-----------|
| **Firebase Firestore** | Perfiles de usuario, historial de interacciones, sesiones de chat |
| **Base de Conocimiento** | `celula_data.dart` - Contenido educativo estructurado sobre la célula |
| **Memoria** | Historial de conversaciones (ChatHistoryScreen) |
| **Modelos ML** | `assets/models/` - Modelos TensorFlow Lite pre-entrenados |

### Recursos Externos Integrados

- ☁️ **Google Generative AI API**: Motor del chatbot educativo
- 🎥 **YouTube Player**: Reproducción de videos educativos
- 🎤 **Speech to Text**: Accesibilidad mediante reconocimiento de voz
- 📷 **Image Picker**: Captura de imágenes para el escáner de células

### Assets Educativos Locales

- `assets/libro/` - Contenido de texto estructurado
- `assets/CELULA/` - Imágenes y recursos visuales sobre células
- `assets/marcadores/` - Marcadores QR para realidad aumentada
- `assets/Diagrama/` - Diagramas educativos y esquemas

### Flujo de Datos

```
Usuario → Flutter UI → Servicios de Orquestación
                              ↓
              Enrutador Inteligente de Servicios
                    ↓              ↓
         Sistema Multi-Agente ← → Aprendizaje Adaptativo
                    ↓              ↓
         Capa de Datos y Base de Conocimiento
```

### Integración con Firebase

La arquitectura utiliza Firebase como backend principal, proporcionando:

```dart
// Estructura de datos en Firestore
users/
  └── {userId}/
      ├── profile/          // Información del usuario
      ├── progress/         // Progreso en ODAs
      ├── statistics/       // Métricas de desempeño
      ├── achievements/     // Logros desbloqueados
      └── chat_sessions/    // Historial de conversaciones
          └── {sessionId}/
              └── messages/  // Mensajes del chat
```

### Consideraciones de Escalabilidad

Esta clara separación entre toma de decisiones, generación de contenido y evaluación permite una adaptación progresiva mientras se preserva la interpretabilidad, las salvaguardas éticas y la estabilidad en entornos educativos reales. El despliegue basado en Flutter permite que la aplicación funcione en múltiples plataformas (Android, iOS, Web) sin modificación del código, facilitando la replicación en diferentes contextos educativos.

---

## Diagramas Generados

Los siguientes diagramas en formato Draw.io complementan esta documentación:

1. **diagrama_ia_mi_app.drawio** - Ciclo de Decisión IA (Figura 1)
   - Representa el ciclo de aprendizaje por refuerzo adaptado a mi_app
   - Componentes: Policy & Value Function, Meta-Agente IA, Rewards, Environment, Actions

2. **diagrama_arquitectura_ia_mi_app.drawio** - Arquitectura del Sistema (Figura 2)
   - Arquitectura completa del sistema inteligente de tutoría
   - Capas: UI, Orquestación, MAS, Aprendizaje Adaptativo, Datos y Conocimiento

---

## Tecnologías Utilizadas

| Categoría | Tecnología | Versión |
|-----------|------------|---------|
| Framework | Flutter | 3.7.2+ |
| Lenguaje | Dart | SDK ^3.7.2 |
| Backend | Firebase (Auth, Firestore) | Core 3.8.1 |
| IA Generativa | Google Generative AI | 0.4.6 |
| ML Local | TensorFlow Lite | 0.11.0 |
| Autenticación | Google Sign-In | 6.2.2 |
| Cámara | Camera | 0.11.0 |
| Voz | Speech to Text | 7.0.0 |

---

*Documento generado para el proyecto mi_app - Aplicación educativa para la enseñanza de Ciencias Naturales*
