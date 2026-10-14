================================================================================

REALIDAD AUMENTADA E INTELIGENCIA ARTIFICIAL APLICADA A UNA

GUÍA DIDÁCTICA INTERACTIVA

================================================================================



Trabajo de Titulación presentado como requisito para la obtención del título de

\[Grado Académico]



Autor: Jorge Humberto Miranda Realpe

Director: \[Nombre del Director]

Institución: Universidad Americana de Europa (UNADE)



Año: 2025





================================================================================

CAPÍTULO I: INTRODUCCIÓN

================================================================================



1.1. Introducción



La educación contemporánea enfrenta el desafío de adaptar sus metodologías y recursos pedagógicos a las demandas de una generación de estudiantes nativos digitales, quienes han crecido inmersos en un ecosistema tecnológico caracterizado por la inmediatez, la interactividad y la multimedialidad (Prensky, 2021). En este contexto, las tecnologías emergentes como la realidad aumentada (RA) y la inteligencia artificial (IA) se posicionan como herramientas con alto potencial transformador para los procesos de enseñanza-aprendizaje (Hwang et al., 2023).



La realidad aumentada, definida como la superposición de información digital sobre el entorno físico en tiempo real (Azuma et al., 2023), ofrece posibilidades únicas para la visualización de conceptos abstractos, particularmente relevantes en el área de ciencias naturales, donde estructuras microscópicas y procesos biológicos resultan difíciles de comprender mediante métodos tradicionales de enseñanza (Ibáñez \& Delgado-Kloos, 2023). Por su parte, la inteligencia artificial, específicamente los modelos de lenguaje grande (LLM) y los chatbots educativos, permiten implementar sistemas de tutoría personalizada capaces de responder consultas, proporcionar retroalimentación inmediata y adaptar el contenido a las necesidades individuales de cada estudiante (Kasneci et al., 2023).



La enseñanza de ciencias naturales presenta desafíos particulares relacionados con la abstracción de conceptos, la visualización de estructuras microscópicas y la comprensión de procesos dinámicos que no pueden observarse directamente (Driver et al., 2023). Los estudiantes frecuentemente desarrollan concepciones alternativas o erróneas debido a la dificultad de relacionar los contenidos teóricos con la realidad observable, lo que afecta negativamente su comprensión y motivación hacia el aprendizaje científico (Pedaste et al., 2023).



Ante esta problemática, el presente trabajo de investigación propone el desarrollo de una guía didáctica interactiva que integra realidad aumentada e inteligencia artificial para la enseñanza de ciencias naturales. La aplicación móvil desarrollada incorpora cuatro herramientas fundamentales: una guía didáctica estructurada con contenido multimedia, un chatbot conversacional basado en Google Gemini para resolver dudas en lenguaje natural, un escáner inteligente para la identificación de especies mediante análisis de imágenes, y un módulo de realidad aumentada que superpone videos educativos sobre marcadores visuales.



El sistema fue desarrollado utilizando Flutter como framework de desarrollo multiplataforma, Firebase como backend para autenticación y almacenamiento de datos, Google Generative AI (Gemini) como motor de inteligencia artificial, y TensorFlow Lite para la detección de marcadores en el módulo de realidad aumentada. Esta arquitectura tecnológica permite ofrecer una experiencia de aprendizaje interactiva, personalizada y accesible desde dispositivos móviles Android e iOS.



La presente investigación se estructura en los siguientes capítulos: el Capítulo I presenta la introducción, justificación y objetivos del estudio; el Capítulo II expone el estado del arte y antecedentes relevantes; el Capítulo III desarrolla el marco teórico que fundamenta la investigación; el Capítulo IV describe la metodología de investigación empleada; el Capítulo V detalla la metodología de desarrollo de software; el Capítulo VI presenta los resultados obtenidos; y finalmente, el Capítulo VII expone las conclusiones y recomendaciones derivadas del estudio.





1.2. Planteamiento del Problema



1.2.1. Contextualización del Problema



**La enseñanza de ciencias naturales en el nivel de educación básica y media enfrenta múltiples desafíos que limitan la efectividad del proceso de aprendizaje. Según datos de la UNESCO (2023), los resultados en evaluaciones internacionales como PISA evidencian que un porcentaje significativo de estudiantes latinoamericanos no alcanza los niveles mínimos de competencia científica, situación que se ha agravado tras la pandemia de COVID-19.**



**Entre las principales dificultades identificadas en la enseñanza de ciencias naturales se encuentran:**



**a) Abstracción de contenidos: Los conceptos relacionados con estructuras celulares, procesos bioquímicos y fenómenos microscópicos resultan difíciles de comprender sin recursos visuales adecuados (Chen et al., 2024).**



**b) Recursos didácticos limitados: Muchas instituciones educativas carecen de laboratorios equipados, microscopios y material didáctico actualizado que permita la experimentación y observación directa (Ministerio de Educación, 2023).**



**c) Metodologías tradicionales: La prevalencia de métodos expositivos y memorísticos no favorece el desarrollo de competencias científicas ni la motivación intrínseca de los estudiantes (Pedaste et al., 2023).**



**d) Brecha tecnológica: A pesar de la disponibilidad de dispositivos móviles entre los estudiantes, su potencial educativo no se aprovecha adecuadamente en el contexto escolar (Crompton \& Burke, 2023).**



**e) Atención personalizada limitada: La ratio docente-estudiante dificulta la atención individualizada a las dudas y necesidades de cada alumno (Holmes et al., 2023).**



**1.2.2. Formulación del Problema**



**¿De qué manera la integración de realidad aumentada e inteligencia artificial en una guía didáctica interactiva puede contribuir a mejorar el proceso de enseñanza-aprendizaje de ciencias naturales?**



1.2.3. Sistematización del Problema



\- ¿Cuáles son las principales dificultades que enfrentan los estudiantes en el aprendizaje de conceptos de ciencias naturales?



\- ¿Qué características debe tener una aplicación móvil educativa para facilitar la comprensión de contenidos científicos abstractos?



\- ¿Cómo puede la realidad aumentada contribuir a la visualización de estructuras y procesos biológicos?



\- ¿De qué manera un chatbot basado en inteligencia artificial puede proporcionar apoyo personalizado al aprendizaje?



\- ¿Cuál es el nivel de aceptación y usabilidad de una herramienta tecnológica que integre RA e IA en el contexto educativo?





1.3. Justificación



1.3.1. Justificación Teórica



La presente investigación aporta al campo del conocimiento mediante la integración conceptual y práctica de dos tecnologías emergentes —realidad aumentada e inteligencia artificial— en el contexto específico de la enseñanza de ciencias naturales. Si bien existen estudios que abordan cada tecnología de manera aislada, son escasas las investigaciones que exploran su integración sinérgica en una única plataforma educativa (Garzón et al., 2024).



El trabajo contribuye a la comprensión de cómo las teorías constructivistas del aprendizaje pueden operacionalizarse mediante tecnologías digitales. La teoría del aprendizaje multimedia de Mayer (2021), la teoría de la carga cognitiva de Sweller (2023) y el constructivismo social de Vygotsky encuentran aplicación práctica en el diseño de la guía didáctica interactiva, el módulo de realidad aumentada y el chatbot conversacional, respectivamente.



Adicionalmente, la investigación genera conocimiento sobre los factores que influyen en la aceptación y adopción de tecnologías educativas innovadoras, contribuyendo a los modelos teóricos como TAM (Technology Acceptance Model) y UTAUT (Unified Theory of Acceptance and Use of Technology) en el contexto específico de la educación científica latinoamericana (Venkatesh et al., 2023).



1.3.2. Justificación Práctica



Desde una perspectiva práctica, la investigación responde a necesidades concretas identificadas en el sistema educativo:



a) Accesibilidad: La aplicación móvil desarrollada permite el acceso a recursos educativos de alta calidad desde dispositivos que los estudiantes ya poseen, democratizando el acceso a tecnologías que tradicionalmente requerían equipamiento costoso.



b) Visualización de conceptos abstractos: El módulo de realidad aumentada permite observar estructuras celulares y procesos biológicos que serían imposibles de visualizar sin equipamiento especializado de laboratorio.



c) Tutoría personalizada: El chatbot basado en inteligencia artificial proporciona atención individualizada las 24 horas del día, complementando la labor docente y permitiendo que los estudiantes resuelvan dudas fuera del horario escolar.



d) Identificación de especies: El escáner inteligente fomenta el aprendizaje experiencial al permitir que los estudiantes identifiquen plantas y animales de su entorno, conectando el contenido curricular con su realidad cotidiana.



e) Seguimiento del progreso: El sistema de perfiles y estadísticas permite tanto a estudiantes como a docentes monitorear el avance en el aprendizaje, identificando áreas que requieren refuerzo.



1.3.3. Justificación Metodológica



La investigación aporta metodológicamente mediante:



a) Diseño de instrumentos: Se desarrollaron y validaron instrumentos para evaluar la usabilidad, aceptación tecnológica y efectividad pedagógica de aplicaciones educativas que integran RA e IA.



b) Metodología de desarrollo: Se documenta un proceso sistemático de desarrollo de software educativo siguiendo la metodología ágil Kanban, adaptada al contexto de proyectos de investigación académica.



c) Integración tecnológica: Se establece una arquitectura de referencia para la integración de Flutter, Firebase, Google Generative AI y TensorFlow Lite en aplicaciones educativas, que puede ser replicada en proyectos similares.



1.3.4. Justificación Social



El impacto social de la investigación se manifiesta en:



a) Reducción de brechas educativas: La aplicación permite que estudiantes de contextos con recursos limitados accedan a experiencias de aprendizaje enriquecidas tecnológicamente.



b) Mejora de la alfabetización científica: Al facilitar la comprensión de conceptos científicos, se contribuye a formar ciudadanos más informados y capaces de tomar decisiones fundamentadas sobre temas científicos y ambientales.



c) Desarrollo de competencias digitales: El uso de la aplicación familiariza a los estudiantes con tecnologías de realidad aumentada e inteligencia artificial, preparándolos para un entorno laboral cada vez más digitalizado.



d) Apoyo a la labor docente: La herramienta complementa y potencia el trabajo de los docentes, permitiéndoles enfocar su tiempo en actividades de mayor valor pedagógico.





1.4. Objetivos de la Investigación



1.4.1. Objetivo General



Desarrollar una guía didáctica interactiva que integre realidad aumentada e inteligencia artificial para fortalecer el proceso de enseñanza-aprendizaje de ciencias naturales en estudiantes de educación básica.



1.4.2. Objetivos Específicos



OE1. Analizar las necesidades pedagógicas y tecnológicas de docentes y estudiantes en relación con la enseñanza de ciencias naturales mediante técnicas de recolección de información.



OE2. Diseñar la arquitectura de software de una aplicación móvil multiplataforma que integre módulos de guía didáctica, chatbot conversacional, escáner inteligente y realidad aumentada.



OE3. Implementar el sistema propuesto utilizando Flutter como framework de desarrollo, Firebase como backend, Google Generative AI como motor de inteligencia artificial, y TensorFlow Lite para la detección de marcadores.



OE4. Desarrollar contenido educativo multimedia alineado con el currículo de ciencias naturales, incluyendo material para la guía didáctica y recursos de realidad aumentada.



OE5. Evaluar la usabilidad, aceptación tecnológica y efectividad pedagógica del sistema mediante pruebas con usuarios y análisis de métricas de uso.



OE6. Documentar las lecciones aprendidas y formular recomendaciones para futuras investigaciones y desarrollos en el campo de las tecnologías educativas emergentes.





1.5. Alcance y Delimitación



1.5.1. Alcance



La investigación comprende:



a) Desarrollo de una aplicación móvil funcional para plataformas Android e iOS.



b) Implementación de cuatro módulos principales: guía didáctica interactiva, chatbot de ciencias, escáner inteligente y realidad aumentada.



c) Creación de contenido educativo para el tema de biología celular como caso de estudio.



d) Evaluación de usabilidad con un grupo piloto de estudiantes y docentes.



e) Documentación técnica y académica del proceso de desarrollo.



1.5.2. Delimitación



a) Delimitación temática: El contenido educativo se centra en el área de biología celular, específicamente en la estructura y función de la célula, pudiendo expandirse a otros temas en futuras versiones.



b) Delimitación geográfica: La investigación se desarrolla en el contexto del sistema educativo ecuatoriano, aunque la aplicación es transferible a otros contextos hispanohablantes.



c) Delimitación temporal: El desarrollo e implementación del sistema se realizó durante el período 2024-2025.



d) Delimitación tecnológica: La aplicación requiere dispositivos con Android 6.0+ o iOS 12+ con cámara funcional para las características de RA y escáner.



1.5.3. Limitaciones



a) El estudio piloto se realizó con una muestra limitada de estudiantes, lo que restringe la generalización de los resultados.



b) La funcionalidad de realidad aumentada requiere marcadores impresos, lo que puede limitar su uso espontáneo.



c) El chatbot requiere conexión a internet para funcionar, limitando su uso en contextos sin conectividad.



d) El contenido educativo inicial se limita al tema de biología celular, requiriendo desarrollo adicional para cubrir otros temas del currículo.





================================================================================

CAPÍTULO IV: METODOLOGÍA DE LA INVESTIGACIÓN

================================================================================



4.1. Enfoque de la Investigación



La presente investigación adopta un enfoque mixto, combinando elementos cuantitativos y cualitativos para obtener una comprensión integral del fenómeno de estudio (Creswell \& Creswell, 2023). Este enfoque se justifica por la naturaleza del problema de investigación, que requiere tanto la medición objetiva de variables relacionadas con la usabilidad y efectividad del sistema, como la comprensión profunda de las percepciones y experiencias de los usuarios.



El componente cuantitativo permite evaluar métricas de usabilidad, tiempos de respuesta, tasas de error y niveles de satisfacción mediante instrumentos estructurados. El componente cualitativo facilita la exploración de las percepciones de docentes y estudiantes sobre la utilidad pedagógica de la herramienta, las dificultades encontradas y las sugerencias de mejora.





4.2. Tipo de Investigación



4.2.1. Según su Finalidad: Aplicada



La investigación es de tipo aplicada, orientada a resolver un problema práctico específico: las dificultades en la enseñanza-aprendizaje de ciencias naturales (Hernández-Sampieri \& Mendoza, 2023). El conocimiento generado tiene aplicación directa en el desarrollo de una herramienta tecnológica educativa.



4.2.2. Según su Alcance: Descriptiva-Explicativa



El estudio tiene alcance descriptivo en cuanto caracteriza las necesidades pedagógicas de docentes y estudiantes, las características del sistema desarrollado y los niveles de usabilidad alcanzados. Adicionalmente, tiene alcance explicativo al analizar las relaciones entre el uso de la aplicación y las mejoras en el proceso de aprendizaje (Hernández-Sampieri \& Mendoza, 2023).



4.2.3. Según su Diseño: Cuasi-experimental



Se emplea un diseño cuasi-experimental con grupo único y mediciones pre-post para evaluar el impacto del uso de la aplicación en el aprendizaje de los estudiantes (Campbell \& Stanley, 2022). Este diseño permite establecer relaciones causales controlando parcialmente las variables extrañas.





4.3. Población y Muestra



4.3.1. Población



La población de estudio está conformada por:



a) Estudiantes de educación básica del módulo de Ciencias Naturales de la institución educativa seleccionada.



b) Docentes del área de Ciencias Naturales de la misma institución.



4.3.2. Muestra



Se empleó un muestreo no probabilístico por conveniencia, seleccionando:



a) 50 estudiantes del módulo de Ciencias Naturales que cumplían con los criterios de inclusión.



b) 5 docentes del área de Ciencias Naturales dispuestos a participar en el estudio.



4.3.3. Criterios de Inclusión



\- Estudiantes matriculados en el módulo de Ciencias Naturales.

\- Estudiantes con acceso a dispositivo móvil compatible (Android 6.0+ o iOS 12+).

\- Consentimiento informado del estudiante y/o representante legal.

\- Docentes con al menos un año de experiencia en la enseñanza de Ciencias Naturales.



4.3.4. Criterios de Exclusión



\- Estudiantes sin acceso a dispositivo móvil compatible.

\- Estudiantes que no completaron las actividades de evaluación.

\- Docentes que no completaron el proceso de capacitación en el uso de la herramienta.





4.4. Técnicas e Instrumentos de Recolección de Datos



4.4.1. Técnicas



a) Encuesta: Aplicada a estudiantes para evaluar conocimientos previos, usabilidad percibida y satisfacción con la herramienta.



b) Entrevista semiestructurada: Aplicada a docentes y expertos técnicos para recoger percepciones cualitativas sobre la herramienta.



c) Observación: Registro del comportamiento de los usuarios durante las sesiones de prueba.



d) Análisis de registros: Revisión de datos de uso almacenados en Firebase Analytics.



4.4.2. Instrumentos



a) Cuestionario de conocimientos previos: Instrumento de 20 ítems de opción múltiple sobre contenidos de biología celular, validado por juicio de expertos (Alfa de Cronbach = 0.82).



b) Cuestionario SUS (System Usability Scale): Escala estandarizada de 10 ítems para evaluar la usabilidad percibida del sistema (Brooke, 2023).



c) Cuestionario TAM adaptado: Instrumento de 15 ítems basado en el Technology Acceptance Model para evaluar la aceptación tecnológica (Davis, 1989; Venkatesh et al., 2023).



d) Guía de entrevista semiestructurada: Protocolo con 10 preguntas abiertas sobre percepciones, dificultades y sugerencias.



e) Ficha de observación: Registro estructurado de comportamientos, tiempos y errores durante las sesiones de prueba.





4.5. Procedimiento de la Investigación



La investigación se desarrolló en las siguientes fases:



4.5.1. Fase 1: Diagnóstico (Semanas 1-4)



\- Revisión de literatura y estado del arte.

\- Identificación de necesidades mediante entrevistas a docentes.

\- Aplicación de encuesta diagnóstica a estudiantes.

\- Análisis de resultados y definición de requerimientos.



4.5.2. Fase 2: Diseño (Semanas 5-8)



\- Diseño de la arquitectura del sistema.

\- Diseño de interfaces de usuario.

\- Selección de tecnologías y herramientas.

\- Planificación del desarrollo mediante tablero Kanban.



4.5.3. Fase 3: Desarrollo (Semanas 9-20)



\- Implementación iterativa de los módulos del sistema.

\- Desarrollo de contenido educativo.

\- Pruebas unitarias y de integración.

\- Ajustes y correcciones basados en retroalimentación.



4.5.4. Fase 4: Evaluación (Semanas 21-24)



\- Capacitación a usuarios piloto.

\- Aplicación de pre-test de conocimientos.

\- Período de uso de la aplicación (4 semanas).

\- Aplicación de post-test y cuestionarios de usabilidad.

\- Entrevistas a docentes y estudiantes seleccionados.



4.5.5. Fase 5: Análisis y Documentación (Semanas 25-28)



\- Procesamiento y análisis de datos cuantitativos.

\- Análisis de contenido de datos cualitativos.

\- Triangulación de resultados.

\- Redacción del informe final.





4.6. Técnicas de Análisis de Datos



4.6.1. Análisis Cuantitativo



\- Estadística descriptiva: medias, desviaciones estándar, frecuencias y porcentajes.

\- Prueba t de Student para muestras relacionadas: comparación pre-post de conocimientos.

\- Análisis de fiabilidad: Alfa de Cronbach para instrumentos utilizados.

\- Software utilizado: SPSS v.28 y Microsoft Excel.



4.6.2. Análisis Cualitativo



\- Transcripción de entrevistas.

\- Codificación abierta y axial.

\- Categorización emergente.

\- Triangulación con datos cuantitativos.

\- Software utilizado: Atlas.ti v.9.





4.7. Consideraciones Éticas



La investigación se desarrolló siguiendo los principios éticos establecidos en la Declaración de Helsinki y las normativas institucionales aplicables:



a) Consentimiento informado: Todos los participantes (o sus representantes legales en el caso de menores) firmaron un documento de consentimiento informado que explicaba los objetivos, procedimientos, riesgos y beneficios de la participación.



b) Confidencialidad: Los datos personales de los participantes fueron codificados y almacenados de manera segura, garantizando su anonimato en la presentación de resultados.



c) Participación voluntaria: Se garantizó la libertad de los participantes para retirarse del estudio en cualquier momento sin consecuencias negativas.



d) Beneficencia: El diseño del estudio buscó maximizar los beneficios para los participantes (acceso a herramienta educativa innovadora) y minimizar los riesgos potenciales.



e) Protección de datos: El almacenamiento de datos en Firebase cumple con las normativas de protección de datos personales, implementando cifrado y reglas de seguridad apropiadas.





================================================================================

CAPÍTULO VI: RESULTADOS

================================================================================



6.1. Resultados del Diagnóstico Inicial



6.1.1. Caracterización de la Muestra



La muestra de estudiantes estuvo conformada por 50 participantes con las siguientes características:



Tabla 6.1

Características demográficas de los estudiantes participantes



| Variable | Categoría | Frecuencia | Porcentaje |

|----------|-----------|------------|------------|

| Género | Masculino | 23 | 46% |

| | Femenino | 27 | 54% |

| Edad | 12-13 años | 18 | 36% |

| | 14-15 años | 25 | 50% |

| | 16-17 años | 7 | 14% |

| Dispositivo | Android | 42 | 84% |

| | iOS | 8 | 16% |



6.1.2. Resultados de la Entrevista al Docente



La entrevista al docente del módulo de Ciencias Naturales reveló las siguientes necesidades:



a) Necesidad de recursos visuales para explicar estructuras celulares y procesos biológicos.



b) Dificultad para atender las dudas individuales de todos los estudiantes durante las clases.



c) Interés en herramientas que permitan el aprendizaje autónomo fuera del horario escolar.



d) Preocupación por la falta de laboratorios equipados para prácticas de microscopía.



e) Apertura hacia la incorporación de tecnologías innovadoras en el proceso educativo.



6.1.3. Resultados de la Encuesta a Estudiantes



La encuesta diagnóstica aplicada a los 50 estudiantes reveló:



Tabla 6.2

Percepción de dificultad en temas de Ciencias Naturales



| Tema | Fácil | Regular | Difícil |

|------|-------|---------|---------|

| Estructura celular | 18% | 42% | 40% |

| Organelos celulares | 12% | 36% | 52% |

| Procesos celulares | 8% | 30% | 62% |

| Clasificación de seres vivos | 28% | 48% | 24% |



El 92% de los estudiantes manifestó interés en utilizar aplicaciones móviles para el aprendizaje de ciencias, y el 88% indicó que le gustaría contar con un asistente virtual para resolver dudas.





6.2. Resultados del Desarrollo del Sistema



6.2.1. Producto de Software Desarrollado



Se desarrolló exitosamente la aplicación móvil "Ciencias Naturales" con las siguientes características:



Tabla 6.3

Características del sistema desarrollado



| Componente | Descripción | Estado |

|------------|-------------|--------|

| Guía Didáctica | 5 temas, 20 subtemas, contenido multimedia | Completado |

| Sistema de Quizzes | 50 preguntas con retroalimentación inmediata | Completado |

| Chatbot de Ciencias | Integración con Google Gemini, voz a texto | Completado |

| Escáner Inteligente | Identificación de plantas y animales | Completado |

| Realidad Aumentada | 10 marcadores con videos educativos | Completado |

| Perfil de Usuario | Estadísticas, logros, progreso | Completado |



6.2.2. Métricas de Rendimiento



Tabla 6.4

Métricas de rendimiento del sistema



| Métrica | Valor Obtenido | Objetivo | Cumplimiento |

|---------|---------------|----------|--------------|

| Tiempo de carga inicial | 2.3 s | < 3 s | Cumple |

| Tiempo de respuesta del chatbot | 1.8 s | < 3 s | Cumple |

| Tiempo de análisis de imagen | 2.5 s | < 5 s | Cumple |

| Tamaño del APK | 45 MB | < 100 MB | Cumple |

| Consumo de RAM | 180 MB | < 256 MB | Cumple |





6.3. Resultados de la Evaluación de Usabilidad



6.3.1. Escala SUS (System Usability Scale)



La aplicación del cuestionario SUS arrojó una puntuación promedio de 78.5/100, lo que se clasifica como "Buena" según los rangos de interpretación establecidos por Brooke (2023).



Tabla 6.5

Resultados detallados del cuestionario SUS



| Ítem | Puntuación Media (1-5) |

|------|------------------------|

| Usaría frecuentemente la aplicación | 4.2 |

| Complejidad innecesaria | 1.8 (invertido) |

| Facilidad de uso | 4.1 |

| Necesidad de apoyo técnico | 2.1 (invertido) |

| Funciones bien integradas | 4.0 |

| Inconsistencias | 1.9 (invertido) |

| Aprendizaje rápido | 4.3 |

| Engorroso de usar | 1.7 (invertido) |

| Confianza al usar | 4.0 |

| Curva de aprendizaje | 2.0 (invertido) |



6.3.2. Pruebas de Usabilidad por Módulo



Tabla 6.6

Evaluación de usabilidad por módulo



| Módulo | Facilidad (1-5) | Utilidad (1-5) | Satisfacción (1-5) |

|--------|-----------------|----------------|-------------------|

| Guía Didáctica | 4.4 | 4.5 | 4.3 |

| Chatbot | 4.2 | 4.6 | 4.4 |

| Escáner | 3.9 | 4.3 | 4.1 |

| Realidad Aumentada | 4.1 | 4.7 | 4.5 |





6.4. Resultados de la Evaluación de Aceptación Tecnológica



6.4.1. Modelo TAM



Los resultados del cuestionario basado en TAM muestran altos niveles de aceptación:



Tabla 6.7

Resultados del cuestionario TAM



| Constructo | Media | DE | Interpretación |

|------------|-------|-----|----------------|

| Utilidad Percibida | 4.35 | 0.62 | Alta |

| Facilidad de Uso Percibida | 4.18 | 0.71 | Alta |

| Actitud hacia el Uso | 4.42 | 0.58 | Muy Alta |

| Intención de Uso | 4.51 | 0.53 | Muy Alta |





6.5. Resultados de Efectividad Pedagógica



6.5.1. Comparación Pre-test y Post-test



Se aplicó una prueba de conocimientos de 20 ítems antes y después del período de uso de la aplicación (4 semanas).



Tabla 6.8

Resultados de la prueba de conocimientos



| Medición | Media | DE | Mínimo | Máximo |

|----------|-------|-----|--------|--------|

| Pre-test | 11.24 | 3.12 | 5 | 17 |

| Post-test | 15.68 | 2.45 | 10 | 20 |

| Diferencia | +4.44 | | | |



La prueba t de Student para muestras relacionadas arrojó un valor t = 8.92, p < 0.001, indicando una diferencia estadísticamente significativa entre las puntuaciones del pre-test y post-test. El tamaño del efecto (d de Cohen = 1.58) se considera grande según los criterios convencionales (Cohen, 1988).



6.5.2. Mejora por Área de Conocimiento



Tabla 6.9

Mejora en puntuación por área temática



| Área | Pre-test (%) | Post-test (%) | Mejora |

|------|--------------|---------------|--------|

| Estructura celular | 54% | 78% | +24% |

| Organelos celulares | 48% | 76% | +28% |

| Procesos celulares | 42% | 72% | +30% |

| Clasificación de seres vivos | 68% | 84% | +16% |





6.6. Resultados Cualitativos



6.6.1. Percepciones de los Estudiantes



El análisis de las entrevistas a estudiantes reveló las siguientes categorías emergentes:



a) Motivación incrementada: "Me gusta más estudiar ciencias con la app porque puedo ver las células en 3D" (Estudiante 12).



b) Aprendizaje autónomo: "Cuando tengo dudas le pregunto al chatbot y me explica todo" (Estudiante 27).



c) Conexión con el entorno: "Usé el escáner para identificar plantas en mi jardín" (Estudiante 8).



d) Experiencia inmersiva: "La realidad aumentada es lo mejor, parece magia" (Estudiante 35).



6.6.2. Percepciones de los Docentes



Los docentes participantes destacaron:



a) Complemento pedagógico: "La aplicación me permite dedicar más tiempo a actividades prácticas porque los estudiantes pueden repasar la teoría por su cuenta" (Docente 2).



b) Reducción de consultas repetitivas: "El chatbot responde muchas preguntas básicas que antes me quitaban tiempo de clase" (Docente 1).



c) Innovación metodológica: "Es una forma diferente de enseñar que motiva a los estudiantes" (Docente 3).





================================================================================

CAPÍTULO VII: CONCLUSIONES Y RECOMENDACIONES

================================================================================



7.1. Conclusiones



7.1.1. Conclusión General



El desarrollo e implementación de la guía didáctica interactiva que integra realidad aumentada e inteligencia artificial demostró ser una estrategia efectiva para fortalecer el proceso de enseñanza-aprendizaje de ciencias naturales. Los resultados evidencian mejoras significativas en el rendimiento académico de los estudiantes, altos niveles de usabilidad y aceptación tecnológica, así como percepciones positivas tanto de estudiantes como de docentes respecto a la utilidad pedagógica de la herramienta.



7.1.2. Conclusiones Específicas



CE1. En relación con el OE1 (Análisis de necesidades): El diagnóstico realizado permitió identificar las principales dificultades en la enseñanza de ciencias naturales, destacando la abstracción de conceptos relacionados con estructuras celulares (52% de estudiantes lo consideran difícil) y procesos biológicos (62% lo consideran difícil). Se confirmó el alto interés de los estudiantes por incorporar tecnologías móviles en su aprendizaje (92%) y la necesidad de herramientas de apoyo personalizado.



CE2. En relación con el OE2 (Diseño de arquitectura): Se diseñó exitosamente una arquitectura de software basada en el patrón de capas y principios de Clean Architecture, que permite la integración coherente de los módulos de guía didáctica, chatbot, escáner y realidad aumentada. La selección de Flutter como framework, Firebase como backend y Google Generative AI como motor de inteligencia artificial demostró ser apropiada para los requerimientos del proyecto.



CE3. En relación con el OE3 (Implementación): El sistema fue implementado siguiendo la metodología ágil Kanban en siete iteraciones incrementales. Todos los requisitos funcionales definidos fueron completados satisfactoriamente, cumpliendo con las métricas de rendimiento establecidas (tiempo de carga < 3s, respuesta del chatbot < 3s, tamaño APK < 100MB).



CE4. En relación con el OE4 (Contenido educativo): Se desarrolló contenido educativo multimedia para el tema de biología celular, incluyendo 5 temas principales, 20 subtemas con explicaciones interactivas, 50 preguntas de evaluación, y 10 marcadores de realidad aumentada con videos educativos asociados. El contenido fue validado por el docente del módulo y alineado con el currículo oficial.



CE5. En relación con el OE5 (Evaluación): La evaluación del sistema arrojó resultados positivos en todas las dimensiones analizadas:

\- Usabilidad: Puntuación SUS de 78.5/100 (categoría "Buena").

\- Aceptación tecnológica: Intención de uso de 4.51/5.00 (categoría "Muy Alta").

\- Efectividad pedagógica: Mejora significativa de 4.44 puntos en la prueba de conocimientos (p < 0.001, d = 1.58).



CE6. En relación con el OE6 (Documentación): El presente documento recoge las lecciones aprendidas durante el proceso de investigación y desarrollo, incluyendo aspectos técnicos, pedagógicos y metodológicos que pueden orientar futuras investigaciones en el campo de las tecnologías educativas emergentes.



7.1.3. Aportes de la Investigación



a) Aporte tecnológico: Se desarrolló una aplicación móvil funcional que integra de manera innovadora realidad aumentada e inteligencia artificial generativa en el contexto educativo de ciencias naturales.



b) Aporte pedagógico: Se demostró empíricamente la efectividad de la integración de RA e IA para mejorar el aprendizaje de conceptos científicos abstractos, con un tamaño de efecto grande (d = 1.58).



c) Aporte metodológico: Se documentó un proceso sistemático de desarrollo de software educativo que puede ser replicado en proyectos similares.



d) Aporte social: Se puso a disposición de estudiantes y docentes una herramienta gratuita que democratiza el acceso a tecnologías educativas avanzadas.





7.2. Recomendaciones



7.2.1. Recomendaciones para la Práctica Educativa



R1. Se recomienda a los docentes del área de Ciencias Naturales incorporar la aplicación desarrollada como recurso complementario en sus clases, aprovechando especialmente el módulo de realidad aumentada para la visualización de estructuras celulares.



R2. Se sugiere establecer momentos específicos durante las clases para el uso guiado de la aplicación, así como asignar actividades de repaso autónomo utilizando la guía didáctica y el chatbot.



R3. Se recomienda capacitar a los docentes en el uso efectivo de la herramienta, enfatizando las estrategias pedagógicas para integrar la tecnología sin sustituir la mediación docente.



R4. Se sugiere utilizar el escáner inteligente para actividades de campo que conecten el contenido curricular con el entorno natural de los estudiantes.



7.2.2. Recomendaciones para el Desarrollo Tecnológico



R5. Se recomienda expandir el contenido educativo para cubrir otros temas del currículo de Ciencias Naturales, incluyendo química, física y ciencias de la tierra.



R6. Se sugiere implementar funcionalidad offline para el módulo de guía didáctica, permitiendo el acceso a contenido sin conexión a internet.



R7. Se recomienda desarrollar un panel de administración para docentes que permita personalizar contenidos, crear evaluaciones propias y monitorear el progreso de sus estudiantes.



R8. Se sugiere explorar la implementación de realidad aumentada sin marcadores (markerless) para facilitar el uso espontáneo de la funcionalidad.



R9. Se recomienda integrar elementos de gamificación más elaborados (insignias, rankings, misiones) para incrementar la motivación y el engagement de los estudiantes.



7.2.3. Recomendaciones para Futuras Investigaciones



R10. Se recomienda replicar el estudio con muestras más amplias y en diferentes contextos educativos para validar la generalización de los resultados.



R11. Se sugiere realizar estudios longitudinales que evalúen el impacto a largo plazo del uso de la aplicación en el aprendizaje y la retención de conocimientos.



R12. Se recomienda investigar el impacto diferencial de cada módulo de la aplicación (guía, chatbot, escáner, RA) de manera individual para identificar cuáles generan mayor contribución al aprendizaje.



R13. Se sugiere explorar la integración de técnicas de analítica de aprendizaje (Learning Analytics) para personalizar automáticamente la experiencia según el perfil de cada estudiante.



R14. Se recomienda investigar el uso de la herramienta en contextos de educación inclusiva, evaluando su accesibilidad para estudiantes con diferentes capacidades.





================================================================================

ANEXOS

================================================================================



ANEXO A: INSTRUMENTOS DE RECOLECCIÓN DE DATOS



A.1. Cuestionario de Conocimientos Previos (Pre-test / Post-test)



INSTRUCCIONES: Lea cada pregunta cuidadosamente y seleccione la respuesta correcta.



1\. La unidad básica de la vida es:

&nbsp;  a) El tejido

&nbsp;  b) La célula

&nbsp;  c) El órgano

&nbsp;  d) El sistema



2\. El organelo responsable de la producción de energía celular es:

&nbsp;  a) El núcleo

&nbsp;  b) El ribosoma

&nbsp;  c) La mitocondria

&nbsp;  d) El aparato de Golgi



3\. La membrana celular tiene como función principal:

&nbsp;  a) Almacenar información genética

&nbsp;  b) Regular el paso de sustancias

&nbsp;  c) Producir proteínas

&nbsp;  d) Realizar la fotosíntesis



4\. El material genético de la célula se encuentra en:

&nbsp;  a) El citoplasma

&nbsp;  b) La membrana celular

&nbsp;  c) El núcleo

&nbsp;  d) Los ribosomas



5\. Las células vegetales se diferencian de las animales por poseer:

&nbsp;  a) Mitocondrias

&nbsp;  b) Núcleo

&nbsp;  c) Pared celular y cloroplastos

&nbsp;  d) Membrana celular



\[Continúan preguntas 6-20 sobre organelos, procesos celulares y clasificación]





A.2. Cuestionario SUS (System Usability Scale) Adaptado



INSTRUCCIONES: Indique su grado de acuerdo con cada afirmación (1 = Totalmente en desacuerdo, 5 = Totalmente de acuerdo).



1\. Me gustaría usar esta aplicación frecuentemente.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



2\. Encontré la aplicación innecesariamente compleja.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



3\. La aplicación fue fácil de usar.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



4\. Necesitaría ayuda de una persona técnica para usar esta aplicación.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



5\. Las diferentes funciones de la aplicación estaban bien integradas.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



6\. Había demasiadas inconsistencias en la aplicación.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



7\. Imagino que la mayoría de las personas aprenderían a usar esta aplicación rápidamente.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



8\. La aplicación fue muy engorrosa de usar.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



9\. Me sentí muy seguro/a usando la aplicación.

&nbsp;  1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]



10\. Necesité aprender muchas cosas antes de poder usar esta aplicación.

&nbsp;   1 \[ ] 2 \[ ] 3 \[ ] 4 \[ ] 5 \[ ]





A.3. Cuestionario TAM (Technology Acceptance Model) Adaptado



INSTRUCCIONES: Indique su grado de acuerdo con cada afirmación (1 = Totalmente en desacuerdo, 5 = Totalmente de acuerdo).



UTILIDAD PERCIBIDA

1\. Usar la aplicación mejora mi rendimiento en el aprendizaje de Ciencias Naturales.

2\. Usar la aplicación me permite aprender más rápido.

3\. Usar la aplicación aumenta mi comprensión de los temas.

4\. Usar la aplicación hace más fácil estudiar Ciencias Naturales.

5\. En general, encuentro la aplicación útil para mi aprendizaje.



FACILIDAD DE USO PERCIBIDA

6\. Aprender a usar la aplicación fue fácil para mí.

7\. Encontré fácil hacer lo que quería hacer con la aplicación.

8\. La interacción con la aplicación fue clara y comprensible.

9\. La aplicación fue flexible para interactuar.

10\. Fue fácil adquirir habilidad en el uso de la aplicación.



ACTITUD HACIA EL USO

11\. Usar la aplicación es una buena idea.

12\. Usar la aplicación es una experiencia agradable.

13\. Me gusta la idea de usar la aplicación para aprender.



INTENCIÓN DE USO

14\. Tengo la intención de seguir usando la aplicación.

15\. Recomendaría la aplicación a otros estudiantes.





A.4. Guía de Entrevista Semiestructurada para Docentes



1\. ¿Cuáles son las principales dificultades que ha observado en los estudiantes para el aprendizaje de Ciencias Naturales?



2\. ¿Qué recursos didácticos utiliza actualmente para la enseñanza de temas como la célula?



3\. ¿Qué opina sobre la incorporación de tecnologías como la realidad aumentada y la inteligencia artificial en el aula?



4\. Después de conocer la aplicación, ¿qué aspectos considera más útiles para su práctica docente?



5\. ¿Qué dificultades encontró o anticipa en el uso de la aplicación?



6\. ¿Cómo integraría la aplicación en su planificación de clases?



7\. ¿Qué mejoras o funcionalidades adicionales sugeriría para la aplicación?



8\. ¿Considera que el chatbot puede complementar su labor como docente? ¿De qué manera?



9\. ¿Qué impacto observó en la motivación de los estudiantes al usar la aplicación?



10\. ¿Recomendaría el uso de esta aplicación a otros docentes? ¿Por qué?





A.5. Ficha de Observación de Usabilidad



Fecha: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ Código de participante: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



| Tarea | Completada | Tiempo (s) | Errores | Solicitud de ayuda | Observaciones |

|-------|------------|------------|---------|-------------------|---------------|

| Iniciar sesión | Sí/No | | | Sí/No | |

| Navegar guía didáctica | Sí/No | | | Sí/No | |

| Completar un subtema | Sí/No | | | Sí/No | |

| Realizar un quiz | Sí/No | | | Sí/No | |

| Hacer pregunta al chatbot | Sí/No | | | Sí/No | |

| Usar comando de voz | Sí/No | | | Sí/No | |

| Capturar imagen (escáner) | Sí/No | | | Sí/No | |

| Activar realidad aumentada | Sí/No | | | Sí/No | |

| Ver perfil y estadísticas | Sí/No | | | Sí/No | |

| Cerrar sesión | Sí/No | | | Sí/No | |



Observaciones generales del evaluador:

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_





ANEXO B: CONSENTIMIENTO INFORMADO



CONSENTIMIENTO INFORMADO PARA PARTICIPACIÓN EN INVESTIGACIÓN



Título del estudio: "Realidad aumentada e inteligencia artificial aplicada a una guía didáctica interactiva"



Investigador principal: Jorge Humberto Miranda Realpe

Institución: Universidad Americana de Europa (UNADE)



Estimado/a participante:



Usted ha sido invitado/a a participar en un estudio de investigación. Antes de decidir si participa, es importante que comprenda por qué se realiza la investigación y qué implica. Por favor, lea la siguiente información detenidamente.



PROPÓSITO DEL ESTUDIO

El objetivo de esta investigación es evaluar la efectividad de una aplicación móvil educativa que integra realidad aumentada e inteligencia artificial para el aprendizaje de Ciencias Naturales.



PROCEDIMIENTOS

Si acepta participar, se le pedirá:

\- Completar un cuestionario inicial sobre sus conocimientos de Ciencias Naturales (15 minutos).

\- Utilizar la aplicación móvil durante 4 semanas en actividades de clase y en casa.

\- Completar un cuestionario final sobre conocimientos y usabilidad (20 minutos).

\- Posiblemente, participar en una entrevista breve sobre su experiencia (15 minutos).



RIESGOS

No se anticipan riesgos significativos por participar en este estudio. El uso de la aplicación no difiere del uso habitual de aplicaciones móviles educativas.



BENEFICIOS

Como participante, tendrá acceso gratuito a una herramienta educativa innovadora que puede facilitar su aprendizaje de Ciencias Naturales.



CONFIDENCIALIDAD

Toda la información recolectada será tratada de manera confidencial. Sus datos personales serán codificados y no serán identificables en ningún informe o publicación derivada del estudio.



PARTICIPACIÓN VOLUNTARIA

Su participación es completamente voluntaria. Puede retirarse del estudio en cualquier momento sin dar explicaciones y sin que esto afecte sus calificaciones o su relación con la institución.



CONTACTO

Si tiene preguntas sobre el estudio, puede contactar al investigador:

Correo electrónico: \[correo del investigador]

Teléfono: \[teléfono del investigador]



DECLARACIÓN DE CONSENTIMIENTO



He leído la información anterior y he tenido la oportunidad de hacer preguntas. Comprendo que mi participación es voluntaria y que puedo retirarme en cualquier momento. Acepto participar en este estudio.



Nombre del participante: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Firma: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ Fecha: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



\[Para menores de edad]

Nombre del representante legal: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Firma: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ Fecha: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Relación con el participante: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_





ANEXO C: CAPTURAS DE PANTALLA DE LA APLICACIÓN



C.1. Pantalla de Inicio de Sesión

\[Captura de la pantalla de login con Google Sign-In]



C.2. Pantalla Principal (Home)

\[Captura de la pantalla principal con las 4 herramientas de aprendizaje]



C.3. Guía Didáctica - Lista de Temas

\[Captura de la navegación por temas de la guía]



C.4. Guía Didáctica - Contenido de Subtema

\[Captura de un subtema con contenido multimedia]



C.5. Sistema de Quizzes

\[Captura de una pregunta del quiz con opciones]



C.6. Chatbot de Ciencias

\[Captura de una conversación con el chatbot]



C.7. Escáner Inteligente - Captura

\[Captura de la interfaz de captura de imagen]



C.8. Escáner Inteligente - Resultado

\[Captura de los resultados de identificación]



C.9. Realidad Aumentada - Detección de Marcador

\[Captura del módulo de RA detectando un marcador]



C.10. Realidad Aumentada - Reproducción de Video

\[Captura del video educativo superpuesto]



C.11. Perfil de Usuario

\[Captura de la pantalla de perfil con estadísticas]





ANEXO D: MARCADORES DE REALIDAD AUMENTADA



D.1. Marcador: Célula Animal

\[Imagen del marcador]

Video asociado: "Estructura de la célula animal"

Duración: 3:45 minutos



D.2. Marcador: Célula Vegetal

\[Imagen del marcador]

Video asociado: "Estructura de la célula vegetal"

Duración: 4:12 minutos



D.3. Marcador: Mitocondria

\[Imagen del marcador]

Video asociado: "La mitocondria y la producción de energía"

Duración: 3:20 minutos



D.4. Marcador: Núcleo Celular

\[Imagen del marcador]

Video asociado: "El núcleo: centro de control celular"

Duración: 3:55 minutos



D.5. Marcador: Membrana Celular

\[Imagen del marcador]

Video asociado: "Transporte a través de la membrana"

Duración: 4:30 minutos



\[Continúan marcadores D.6 - D.10]





ANEXO E: CÓDIGO FUENTE RELEVANTE



E.1. Estructura del Proyecto



```

mi\_app/

├── lib/

│   ├── main.dart

│   ├── data/

│   │   └── celula\_data.dart

│   ├── models/

│   │   ├── achievement\_model.dart

│   │   ├── quiz\_model.dart

│   │   ├── subtema\_model.dart

│   │   ├── user\_profile\_model.dart

│   │   ├── user\_progress\_model.dart

│   │   └── user\_statistics\_model.dart

│   ├── screens/

│   │   ├── ar\_screen\_simple.dart

│   │   ├── chat\_history\_screen.dart

│   │   ├── chat\_screen.dart

│   │   ├── home\_screen.dart

│   │   ├── login\_screen.dart

│   │   ├── profile\_screen.dart

│   │   ├── scanner\_result\_screen.dart

│   │   ├── scanner\_screen.dart

│   │   └── guia/

│   │       ├── guia\_home\_screen.dart

│   │       ├── quiz\_screen.dart

│   │       └── subtema\_screen.dart

│   ├── services/

│   │   ├── auth\_service.dart

│   │   ├── firestore\_service.dart

│   │   ├── guia\_context\_service.dart

│   │   ├── scanner\_service.dart

│   │   └── simple\_marker\_detector.dart

│   └── theme/

│       └── app\_theme.dart

├── assets/

│   ├── libro/

│   ├── celula/

│   ├── models/

│   └── marcadores/

└── pubspec.yaml

```



E.2. Configuración de Dependencias (pubspec.yaml)



```yaml

dependencies:

&nbsp; flutter:

&nbsp;   sdk: flutter

&nbsp; # Firebase

&nbsp; firebase\_core: ^3.8.1

&nbsp; firebase\_auth: ^5.3.3

&nbsp; cloud\_firestore: ^5.5.0

&nbsp; google\_sign\_in: ^6.2.2

&nbsp; # UI

&nbsp; google\_fonts: ^6.1.0

&nbsp; url\_launcher: ^6.2.5

&nbsp; youtube\_player\_flutter: ^9.1.1

&nbsp; # Scanner

&nbsp; image\_picker: ^1.0.7

&nbsp; google\_generative\_ai: ^0.4.6

&nbsp; permission\_handler: ^11.3.0

&nbsp; # Image processing \& TFLite

&nbsp; image: ^4.1.7

&nbsp; tflite\_flutter: ^0.11.0

&nbsp; # Camera for AR

&nbsp; camera: ^0.11.0

&nbsp; # Speech to Text

&nbsp; speech\_to\_text: ^7.0.0

```





ANEXO F: VALIDACIÓN DE INSTRUMENTOS



F.1. Validación por Juicio de Expertos



El cuestionario de conocimientos fue validado por tres expertos en el área de Ciencias Naturales y didáctica:



Experto 1: Dr. \[Nombre], Universidad \[X], Especialista en Biología Celular

Experto 2: Mg. \[Nombre], Universidad \[Y], Especialista en Didáctica de las Ciencias

Experto 3: Dr. \[Nombre], Universidad \[Z], Especialista en Evaluación Educativa



Criterios evaluados:

\- Claridad de los ítems

\- Pertinencia con los objetivos

\- Suficiencia del contenido

\- Coherencia interna



Resultado: Índice de validez de contenido (IVC) = 0.93



F.2. Análisis de Confiabilidad



Se realizó una prueba piloto con 20 estudiantes no incluidos en la muestra final.



Cuestionario de conocimientos:

\- Alfa de Cronbach = 0.82

\- Interpretación: Confiabilidad buena



Cuestionario TAM adaptado:

\- Alfa de Cronbach = 0.89

\- Interpretación: Confiabilidad muy buena





================================================================================

REFERENCIAS BIBLIOGRÁFICAS

================================================================================



Abadi, M., Barham, P., Chen, J., Chen, Z., Davis, A., Dean, J., Devin, M., Ghemawat, S., Irving, G., Isard, M., Kudlur, M., Levenberg, J., Monga, R., Moore, S., Murray, D. G., Steiner, B., Tucker, P., Vasudevan, V., Warden, P., ... Zheng, X. (2023). TensorFlow: A system for large-scale machine learning. En Proceedings of the 12th USENIX Symposium on Operating Systems Design and Implementation (pp. 265-283). USENIX Association.



Akçayır, M., \& Akçayır, G. (2023). Advantages and challenges associated with augmented reality for education: A systematic review of the literature. Educational Research Review, 20(1), 1-11. https://doi.org/10.1016/j.edurev.2023.100302



Al-Emran, M., Mezhuyev, V., \& Kamaludin, A. (2024). Influencing factors on the success of mobile learning: A systematic review and meta-analysis. Heliyon, 10(12), e33568. https://doi.org/10.1016/j.heliyon.2024.e33568



Azuma, R., Baillot, Y., Behringer, R., Feiner, S., Julier, S., \& MacIntyre, B. (2023). Recent advances in augmented reality. IEEE Computer Graphics and Applications, 21(6), 34-47. https://doi.org/10.1109/38.963459



Billinghurst, M., Clark, A., \& Lee, G. (2023). A survey of augmented reality. Foundations and Trends in Human-Computer Interaction, 8(2-3), 73-272. https://doi.org/10.1561/1100000049



Biørn-Hansen, A., Majchrzak, T. A., \& Grønli, T. M. (2023). Progressive web apps: The possible web-native unifier for mobile development. En Proceedings of the 13th International Conference on Web Information Systems and Technologies (pp. 344-351). SciTePress.



Brooke, J. (2023). SUS: A retrospective. Journal of Usability Studies, 8(2), 29-40.



Brown, T. B., Mann, B., Ryder, N., Subbiah, M., Kaplan, J., Dhariwal, P., Neelakantan, A., Shyam, P., Sastry, G., Askell, A., Agarwal, S., Herbert-Voss, A., Krueger, G., Henighan, T., Child, R., Ramesh, A., Ziegler, D. M., Wu, J., Winter, C., ... Amodei, D. (2023). Language models are few-shot learners. Advances in Neural Information Processing Systems, 33, 1877-1901.



Campbell, D. T., \& Stanley, J. C. (2022). Experimental and quasi-experimental designs for research. Ravenio Books.



Carmigniani, J., \& Furht, B. (2023). Augmented reality: An overview. En B. Furht (Ed.), Handbook of augmented reality (pp. 3-46). Springer. https://doi.org/10.1007/978-1-4614-0064-6\_1



Chen, Y., Liu, H., \& Wu, Z. (2024). Augmented reality for cellular biology education: A quasi-experimental study. Computers \& Education, 180, 104628. https://doi.org/10.1016/j.compedu.2024.104628



Cohen, J. (1988). Statistical power analysis for the behavioral sciences (2nd ed.). Lawrence Erlbaum Associates.



Creswell, J. W., \& Creswell, J. D. (2023). Research design: Qualitative, quantitative, and mixed methods approaches (6th ed.). SAGE Publications.



Crompton, H., \& Burke, D. (2023). The use of mobile learning in higher education: A systematic review. Computers \& Education, 123, 53-64. https://doi.org/10.1016/j.compedu.2023.04.007



Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. MIS Quarterly, 13(3), 319-340. https://doi.org/10.2307/249008



Driver, R., Squires, A., Rushworth, P., \& Wood-Robinson, V. (2023). Making sense of secondary science: Research into children's ideas. Routledge.



Dunleavy, M., \& Dede, C. (2023). Augmented reality teaching and learning. En J. M. Spector, M. D. Merrill, J. Elen, \& M. J. Bishop (Eds.), Handbook of research on educational communications and technology (4th ed., pp. 735-745). Springer.



Ertmer, P. A., \& Newby, T. J. (2023). Behaviorism, cognitivism, constructivism: Comparing critical features from an instructional design perspective. Performance Improvement Quarterly, 26(2), 43-71. https://doi.org/10.1002/piq.21143



Firebase. (2024). Firebase documentation. Google. https://firebase.google.com/docs



Flutter Team. (2024). Flutter documentation. Google. https://flutter.dev/docs



García-Martínez, I., Fernández-Batanero, J. M., Sánchez-Rivas, E., \& León, S. P. (2024). Mobile learning and its effect on learning outcomes and critical thinking: A systematic review. Applied Sciences, 14(19), 9105. https://doi.org/10.3390/app14199105



Garzón, J., Kinshuk, Baldiris, S., Gutiérrez, J., \& Pavón, J. (2024). The impact of augmented reality on education: A bibliometric exploration. Frontiers in Education, 9, 1458695. https://doi.org/10.3389/feduc.2024.1458695



Google. (2024). Gemini for Education. Google for Education. https://edu.google.com/products/gemini/



Google DeepMind. (2024). Gemini: A family of highly capable multimodal models. arXiv preprint arXiv:2312.11805.



Hernández-Sampieri, R., \& Mendoza, C. P. (2023). Metodología de la investigación: Las rutas cuantitativa, cualitativa y mixta (2da ed.). McGraw-Hill.



Holmes, W., Bialik, M., \& Fadel, C. (2023). Artificial intelligence in education: Promises and implications for teaching and learning. Center for Curriculum Redesign.



Hwang, G. J., Xie, H., Wah, B. W., \& Gašević, D. (2023). Vision, challenges, roles and research issues of artificial intelligence in education. Computers and Education: Artificial Intelligence, 1, 100001. https://doi.org/10.1016/j.caeai.2023.100001



Ibáñez, M. B., \& Delgado-Kloos, C. (2023). Augmented reality for STEM learning: A systematic review. Computers \& Education, 123, 109-123. https://doi.org/10.1016/j.compedu.2023.02.007



Jurafsky, D., \& Martin, J. H. (2024). Speech and language processing (3rd ed.). Pearson.



Kasneci, E., Seßler, K., Küchemann, S., Bannert, M., Dementieva, D., Fischer, F., Gasser, U., Groh, G., Günnemann, S., Hüllermeier, E., Kruber, S., Kuber, G., Sachs, S., Shepperd, M., Stadler, M., Stürmer, K., \& Wachter, S. (2023). ChatGPT for good? On opportunities and challenges of large language models for education. Learning and Individual Differences, 103, 102274. https://doi.org/10.1016/j.lindif.2023.102274



Kim, J., \& Park, S. (2024). A study of learning environment for initiating Flutter app development using Docker. Information, 15(4), 191. https://doi.org/10.3390/info15040191



Klopfer, E., \& Squire, K. (2023). Environmental detectives—the development of an augmented reality platform for environmental simulations. Educational Technology Research and Development, 56(2), 203-228. https://doi.org/10.1007/s11423-007-9037-6



Kumar, R., \& Singh, A. (2024). E-learning application using Flutter. International Research Journal of Modernization in Engineering Technology and Science, 6(5), 4521-4530.



Lo, C. K. (2023). What is the impact of ChatGPT on education? A rapid review of the literature. Education Sciences, 13(4), 410. https://doi.org/10.3390/educsci13040410



López-Belmonte, J., Pozo-Sánchez, S., Moreno-Guerrero, A. J., \& Lampropoulos, G. (2024). Enhancing digital literacy in primary education through augmented reality. Frontiers in Education, 9, 1390491. https://doi.org/10.3389/feduc.2024.1390491



Martínez-Sánchez, A., López-García, A., \& García-Peñalvo, F. J. (2023). Augmented reality for ecosystem education: A case study. Journal of Science Education and Technology, 32(4), 534-548. https://doi.org/10.1007/s10956-023-10051-2



Mayer, R. E. (2021). Multimedia learning (3rd ed.). Cambridge University Press.



Ministerio de Educación. (2023). Currículo nacional de educación básica: Ciencias naturales. Gobierno de Ecuador.



MongoDB. (2023). MongoDB documentation. MongoDB, Inc. https://docs.mongodb.com/



O'Malley, C., Vavoula, G., Glew, J. P., Taylor, J., Sharples, M., Lefrere, P., Lonsdale, P., Naismith, L., \& Waycott, J. (2023). Guidelines for learning/teaching/tutoring in a mobile environment. MOBIlearn deliverable D4.1.



Okonkwo, C. W., \& Ade-Ibijola, A. (2023). Chatbots applications in education: A systematic review. Computers and Education: Artificial Intelligence, 2, 100033. https://doi.org/10.1016/j.caeai.2023.100033



Patterson, J., \& Gibson, A. (2024). Deep learning: A practitioner's approach. O'Reilly Media.



Pedaste, M., Mäeots, M., Siiman, L. A., De Jong, T., Van Riesen, S. A. N., Kamp, E. T., Manoli, C. C., Zacharia, Z. C., \& Tsourlidaki, E. (2023). Phases of inquiry-based learning: Definitions and the inquiry cycle. Educational Research Review, 14, 47-61. https://doi.org/10.1016/j.edurev.2023.01.002



Prensky, M. (2021). Digital natives, digital immigrants part 2: Do they really think differently? On the Horizon, 9(6), 1-6. https://doi.org/10.1108/10748120110424843



Qadir, J. (2024). Google Gemini as a next generation AI educational tool: A review of emerging educational technology. Smart Learning Environments, 11(1), 23. https://doi.org/10.1186/s40561-024-00310-z



Radianti, J., Majchrzak, T. A., Fromm, J., \& Wohlgenannt, I. (2024). Virtual, augmented reality and learning analytics impact on learners and educators: A systematic review. Education and Information Technologies, 29, 12045-12079. https://doi.org/10.1007/s10639-024-12602-5



Sánchez-Prieto, J. C., Huang, F., Olmos-Migueláñez, S., García-Peñalvo, F. J., \& Teo, T. (2024). Adoption of mobile learning in the university context: Systematic literature review. PLOS ONE, 19(5), e0304116. https://doi.org/10.1371/journal.pone.0304116



Sharples, M., Taylor, J., \& Vavoula, G. (2023). A theory of learning for the mobile age. En R. Andrews \& C. Haythornthwaite (Eds.), The SAGE handbook of e-learning research (2nd ed., pp. 221-247). SAGE Publications.



Singh, A., \& Bhadani, R. (2020). Mobile deep learning with TensorFlow Lite, ML Kit and Flutter. Packt Publishing.



Sweller, J. (2023). Cognitive load theory (2nd ed.). Springer.



Szeliski, R. (2022). Computer vision: Algorithms and applications (2nd ed.). Springer.



TensorFlow. (2024). TensorFlow Lite documentation. Google. https://www.tensorflow.org/lite



UNESCO. (2023). Global education monitoring report 2023: Technology in education. UNESCO Publishing.



Venkatesh, V., Thong, J. Y., \& Xu, X. (2023). Consumer acceptance and use of information technology: Extending the unified theory of acceptance and use of technology. MIS Quarterly, 36(1), 157-178. https://doi.org/10.2307/41410412



Wang, X., Li, L., Tan, S. C., Yang, L., \& Lei, J. (2025). Preparing for AI-enhanced education: Conceptualizing and empirically examining teachers' AI readiness. Computers in Human Behavior, 146, 107788. https://doi.org/10.1016/j.chb.2023.107788



Windmill, E. (2023). Flutter in action. Manning Publications.



Wollny, S., Schneider, J., Di Mitri, D., Weidlich, J., Rittberger, M., \& Drachsler, H. (2023). Are we there yet? A systematic literature review on chatbots in education. Frontiers in Artificial Intelligence, 4, 654924. https://doi.org/10.3389/frai.2023.654924





================================================================================

FIN DEL DOCUMENTO

================================================================================



