# Abstract / Resumen

---

## Abstract (English)

**Background:** The integration of artificial intelligence in educational applications represents an emerging opportunity to personalize learning and provide intelligent tutoring at scale. However, significant challenges remain in designing AI architectures that are pedagogically effective, technically robust, and accessible in contexts with variable connectivity.

**Objective:** This study presents the design, implementation, and evaluation of a mobile educational application that integrates a multi-model AI architecture to support the teaching of Natural Sciences, specifically cell biology, for secondary education students.

**Methods:** The system implements three AI subsystems: (i) an educational chatbot based on LLaMA 3.3 70B with curricular context injection, (ii) an adaptive quiz generation system using prompt engineering with pedagogical directives, and (iii) a multi-stage image recognition pipeline with graceful degradation combining Google Gemini 1.5 Flash, TensorFlow Lite MobileNet V2, and Groq API. A case study was conducted with 45 eighth-grade students (ages 12-14) over a four-week period, collecting technical performance metrics, pedagogical validity assessments, and user experience data.

**Results:** The system achieved 99.2% global availability and success rates above 94% for all AI components. The chatbot demonstrated 97% scientific accuracy and 98.9% effectiveness in domain restriction. AI-generated quizzes achieved 93.3% pedagogical validity, with 78.5% of items within optimal difficulty range and 82% with acceptable discrimination. Image recognition reached 89.5% accuracy with the graceful degradation strategy. Students showed a knowledge gain of 23.6 percentage points (d = 1.75), SUS score of 78.4 (Grade B), and significant positive correlations between gamification metrics and academic performance (r = 0.72).

**Conclusions:** The multi-model AI architecture proves technically viable and pedagogically promising for mobile educational applications. The curricular context injection strategy effectively mitigates LLM hallucinations, while graceful degradation ensures service continuity in variable connectivity contexts. Results suggest that AI-generated quizzes can achieve adequate psychometric properties for formative assessment when combined with structured pedagogical directives.

**Keywords:** Artificial Intelligence in Education, Educational Chatbot, Large Language Models, Automatic Item Generation, Mobile Learning, Intelligent Tutoring Systems, Gamification, Natural Sciences Education

---

## Resumen (Español)

**Contexto:** La integración de inteligencia artificial en aplicaciones educativas representa una oportunidad emergente para personalizar el aprendizaje y proporcionar tutoría inteligente a escala. Sin embargo, persisten desafíos significativos en el diseño de arquitecturas de IA que sean pedagógicamente efectivas, técnicamente robustas y accesibles en contextos con conectividad variable.

**Objetivo:** Este estudio presenta el diseño, implementación y evaluación de una aplicación móvil educativa que integra una arquitectura de IA multi-modelo para apoyar la enseñanza de Ciencias Naturales, específicamente biología celular, dirigida a estudiantes de educación secundaria.

**Métodos:** El sistema implementa tres subsistemas de IA: (i) un chatbot educativo basado en LLaMA 3.3 70B con inyección de contexto curricular, (ii) un sistema de generación adaptativa de quizzes mediante ingeniería de prompts con directivas pedagógicas, y (iii) un pipeline de reconocimiento de imágenes multi-etapa con degradación elegante que combina Google Gemini 1.5 Flash, TensorFlow Lite MobileNet V2 y Groq API. Se realizó un estudio de caso con 45 estudiantes de octavo grado (12-14 años) durante un período de cuatro semanas, recopilando métricas de rendimiento técnico, evaluaciones de validez pedagógica y datos de experiencia de usuario.

**Resultados:** El sistema alcanzó una disponibilidad global del 99.2% y tasas de éxito superiores al 94% para todos los componentes de IA. El chatbot demostró una precisión científica del 97% y una efectividad del 98.9% en la restricción de dominio. Los quizzes generados por IA alcanzaron un 93.3% de validez pedagógica, con el 78.5% de los ítems en rango óptimo de dificultad y el 82% con discriminación aceptable. El reconocimiento de imágenes logró una precisión del 89.5% con la estrategia de degradación elegante. Los estudiantes mostraron una ganancia de conocimientos de 23.6 puntos porcentuales (d = 1.75), una puntuación SUS de 78.4 (Grado B) y correlaciones positivas significativas entre las métricas de gamificación y el rendimiento académico (r = 0.72).

**Conclusiones:** La arquitectura de IA multi-modelo demuestra ser técnicamente viable y pedagógicamente prometedora para aplicaciones educativas móviles. La estrategia de inyección de contexto curricular mitiga efectivamente las alucinaciones de los LLMs, mientras que la degradación elegante garantiza la continuidad del servicio en contextos de conectividad variable. Los resultados sugieren que los quizzes generados por IA pueden alcanzar propiedades psicométricas adecuadas para evaluación formativa cuando se combinan con directivas pedagógicas estructuradas.

**Palabras clave:** Inteligencia Artificial en Educación, Chatbot Educativo, Modelos de Lenguaje Grande, Generación Automática de Ítems, Aprendizaje Móvil, Sistemas de Tutoría Inteligente, Gamificación, Enseñanza de Ciencias Naturales

---

## Resumen Gráfico (Graphical Abstract)

### Componentes Principales del Sistema

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ARQUITECTURA DE IA MULTI-MODELO                          │
│                  Aplicación Móvil Educativa - Ciencias Naturales            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   CHATBOT       │  │  GENERADOR      │  │   ESCÁNER       │             │
│  │   EDUCATIVO     │  │  DE QUIZZES     │  │   DE IMÁGENES   │             │
│  │                 │  │                 │  │                 │             │
│  │  LLaMA 3.3 70B  │  │  LLaMA 3.3 70B  │  │  Gemini 1.5     │             │
│  │  + Contexto     │  │  + Directivas   │  │  + TFLite       │             │
│  │    Curricular   │  │    Pedagógicas  │  │  + Groq         │             │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘             │
│           │                    │                    │                       │
│           ▼                    ▼                    ▼                       │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │                    SISTEMA DE GAMIFICACIÓN                   │           │
│  │              XP • Niveles • Logros • Rachas                  │           │
│  └─────────────────────────────────────────────────────────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Resultados Clave

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         MÉTRICAS PRINCIPALES                              │
├───────────────────┬───────────────────┬───────────────────────────────────┤
│   RENDIMIENTO     │    PEDAGÓGICO     │         IMPACTO                   │
│   TÉCNICO         │                   │                                   │
├───────────────────┼───────────────────┼───────────────────────────────────┤
│                   │                   │                                   │
│  Disponibilidad   │  Precisión        │  Ganancia de                      │
│     99.2%         │  Científica 97%   │  Conocimientos                    │
│                   │                   │     +23.6 pp                      │
│  Tasa de Éxito    │  Validez          │                                   │
│     >94%          │  Pedagógica       │  Tamaño del Efecto                │
│                   │     93.3%         │     d = 1.75                      │
│  Latencia         │                   │                                   │
│  Chatbot <1s      │  Restricción      │  Puntuación SUS                   │
│                   │  Dominio 98.9%    │     78.4 (Grado B)                │
│  Precisión        │                   │                                   │
│  Imágenes 89.5%   │  Ítems Óptimos    │  Correlación                      │
│                   │     78.5%         │  Gamificación                     │
│                   │                   │     r = 0.72                      │
└───────────────────┴───────────────────┴───────────────────────────────────┘
```

### Contribuciones del Estudio

| # | Contribución | Tipo |
|---|--------------|------|
| C1 | Arquitectura de IA multi-modelo para apps educativas móviles | Arquitectónica |
| C2 | Patrón de degradación elegante para IA educativa | Arquitectónica |
| C3 | Estrategia de especialización por contexto curricular | Metodológica |
| C4 | Framework de evaluación integral (técnico + pedagógico + UX) | Metodológica |
| C5 | Evidencia de efectividad de quizzes generados por IA | Empírica |
| C6 | Validación del impacto de gamificación en contextos de IA | Empírica |

---

## Highlights

- Se propone una arquitectura de IA multi-modelo que integra chatbot, generación de quizzes y reconocimiento de imágenes en una aplicación móvil educativa.

- La inyección de contexto curricular en prompts de LLMs alcanza 97% de precisión científica sin requerir fine-tuning costoso.

- La estrategia de degradación elegante eleva la disponibilidad del sistema del 85% al 97% combinando servicios cloud con capacidades on-device.

- Los quizzes generados por IA alcanzan validez pedagógica del 93.3% cuando se combinan con directivas estructuradas.

- Se observa una ganancia de conocimientos de 23.6 puntos porcentuales (d = 1.75) y correlación significativa entre gamificación y rendimiento (r = 0.72).

---

## Información del Estudio

| Aspecto | Detalle |
|---------|---------|
| **Tipo de estudio** | Estudio de caso con métodos mixtos |
| **Participantes** | 45 estudiantes de 8° grado (12-14 años) |
| **Duración** | 4 semanas |
| **Dominio** | Ciencias Naturales - Biología Celular |
| **Tecnologías IA** | LLaMA 3.3 70B, Gemini 1.5 Flash, TFLite MobileNet V2 |
| **Framework** | Flutter 3.7.2 (multiplataforma) |
| **Backend** | Firebase (Auth, Firestore) |
| **APIs** | Groq API, Google Generative AI |

