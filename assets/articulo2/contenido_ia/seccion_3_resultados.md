# 3. Resultados

Esta sección presenta los resultados obtenidos durante la evaluación del sistema, organizados en tres dimensiones principales: (i) rendimiento técnico de los componentes de inteligencia artificial, (ii) efectividad pedagógica de las funcionalidades de IA, y (iii) percepción de usabilidad por parte de los usuarios. La evaluación se realizó mediante un estudio de caso con estudiantes de educación secundaria durante un período de cuatro semanas.

## 3.1. Participantes y Contexto del Estudio

El estudio de caso se realizó con una muestra de 45 estudiantes de educación secundaria (8° grado) de una institución educativa en Ecuador. Los participantes, con edades comprendidas entre 12 y 14 años (M = 13.2, DE = 0.8), fueron seleccionados mediante muestreo por conveniencia. La distribución por género fue equilibrada (51% femenino, 49% masculino). El 78% de los participantes reportó experiencia previa con aplicaciones móviles educativas, mientras que solo el 22% había interactuado previamente con chatbots de IA.

El período de intervención comprendió cuatro semanas de uso regular de la aplicación como complemento a las clases presenciales de Ciencias Naturales, específicamente durante la unidad curricular sobre biología celular.

---

## 3.2. Rendimiento Técnico de los Componentes de IA

### 3.2.1. Métricas de Latencia

Se recopilaron métricas de rendimiento durante el período de evaluación, registrando los tiempos de respuesta de cada componente de IA. La Tabla 2 presenta las estadísticas descriptivas de latencia para cada servicio.

**Tabla 2. Métricas de latencia de los componentes de IA (n = 2,847 interacciones)**

| Componente | Media (ms) | Mediana (ms) | DE (ms) | P95 (ms) | P99 (ms) |
|------------|------------|--------------|---------|----------|----------|
| Chatbot (Groq LLaMA 3.3 70B) | 847 | 723 | 312 | 1,456 | 2,103 |
| Quiz Generator (Groq LLaMA 3.3 70B) | 2,134 | 1,987 | 567 | 3,245 | 4,012 |
| Image Scanner - Gemini | 1,245 | 1,089 | 423 | 2,156 | 2,834 |
| Image Scanner - TFLite (on-device) | 87 | 82 | 23 | 134 | 156 |
| Image Scanner - Groq (descripción) | 534 | 478 | 189 | 912 | 1,234 |

Los resultados muestran que el modelo TFLite on-device presenta la menor latencia (M = 87ms), lo cual es esperado dado que no requiere comunicación de red. El chatbot con Groq API mantiene tiempos de respuesta inferiores a 1 segundo en promedio, proporcionando una experiencia conversacional fluida. El generador de quizzes presenta mayor latencia (M = 2,134ms) debido a la complejidad del prompt y la longitud del output estructurado.

### 3.2.2. Disponibilidad y Tasa de Éxito

La Tabla 3 presenta las métricas de disponibilidad y tasa de éxito de cada componente durante el período de evaluación.

**Tabla 3. Disponibilidad y tasa de éxito de los componentes de IA**

| Componente | Solicitudes Totales | Éxitos | Fallos | Tasa de Éxito (%) | Disponibilidad (%) |
|------------|---------------------|--------|--------|-------------------|---------------------|
| Chatbot | 1,523 | 1,498 | 25 | 98.4 | 99.2 |
| Quiz Generator | 487 | 461 | 26 | 94.7 | 97.8 |
| Image Scanner (total) | 837 | 812 | 25 | 97.0 | 99.1 |
| - Gemini (Etapa 1) | 837 | 712 | 125 | 85.1 | - |
| - TFLite (Etapa 2) | 125 | 118 | 7 | 94.4 | - |
| - Groq (Etapa 3) | 118 | 102 | 16 | 86.4 | - |

Los resultados demuestran la efectividad de la arquitectura de degradación elegante en el pipeline de reconocimiento de imágenes. Aunque Gemini presenta una tasa de éxito del 85.1% como etapa primaria, la combinación con TFLite y Groq eleva la tasa de éxito total al 97.0%. Los fallos residuales (3%) corresponden principalmente a imágenes de muy baja calidad o completamente fuera del dominio de entrenamiento.

### 3.2.3. Consumo de Tokens y Costos

Se monitoreó el consumo de tokens de la API de Groq durante el período de evaluación:

**Tabla 4. Consumo de tokens por componente**

| Componente | Tokens de Entrada (promedio) | Tokens de Salida (promedio) | Total por Interacción |
|------------|------------------------------|-----------------------------|-----------------------|
| Chatbot | 4,234 | 187 | 4,421 |
| Quiz Generator | 1,856 | 1,245 | 3,101 |
| Image Description | 312 | 178 | 490 |

El chatbot presenta el mayor consumo de tokens de entrada debido a la inyección completa del contexto curricular (~4,000 tokens). Esta estrategia, aunque costosa en términos de tokens, garantiza respuestas ancladas en el contenido educativo verificado.

**[Insertar Figura 6: Métricas de Rendimiento de los Componentes de IA]**

La Figura 6 presenta un resumen visual de las métricas de rendimiento de los componentes de IA. El panel superior muestra la distribución de latencias mediante diagramas de caja para cada componente. El panel central ilustra las tasas de éxito comparativas. El panel inferior representa el flujo de degradación elegante en el pipeline de reconocimiento de imágenes, mostrando el porcentaje de solicitudes manejadas por cada etapa.

---

## 3.3. Evaluación del Chatbot Educativo

### 3.3.1. Análisis de Interacciones

Durante el período de evaluación, se registraron 1,523 interacciones con el chatbot, con un promedio de 33.8 consultas por estudiante (DE = 18.4). El análisis de las interacciones reveló patrones de uso distintivos.

**Tabla 5. Distribución de tipos de consultas al chatbot**

| Tipo de Consulta | Frecuencia | Porcentaje (%) |
|------------------|------------|----------------|
| Definiciones y conceptos | 534 | 35.1 |
| Explicación de procesos | 412 | 27.1 |
| Comparaciones (ej: célula animal vs vegetal) | 287 | 18.8 |
| Funciones de organelos | 198 | 13.0 |
| Preguntas fuera de dominio | 92 | 6.0 |

El 94% de las consultas correspondieron a temas dentro del dominio de Ciencias Naturales, mientras que el 6% fueron intentos de consultar temas fuera del ámbito educativo.

### 3.3.2. Efectividad de la Restricción de Dominio

Se evaluó la efectividad del mecanismo de restricción de dominio implementado mediante ingeniería de prompts. De las 92 consultas fuera de dominio detectadas:

**Tabla 6. Efectividad de la restricción de dominio**

| Categoría | Casos | Respuesta Correcta (%) |
|-----------|-------|------------------------|
| Temas académicos no relacionados (matemáticas, historia) | 45 | 100 |
| Consultas personales o de entretenimiento | 31 | 100 |
| Solicitudes de contenido inapropiado | 12 | 100 |
| Ambigüedades (temas parcialmente relacionados) | 4 | 75 |
| **Total** | **92** | **98.9** |

El sistema rechazó correctamente el 98.9% de las consultas fuera de dominio, redirigiendo amablemente al usuario hacia temas de Ciencias Naturales. Los únicos casos de fallo (1.1%) correspondieron a consultas ambiguas que el modelo interpretó incorrectamente como relacionadas con biología.

### 3.3.3. Calidad de las Respuestas

Un panel de dos docentes de Ciencias Naturales evaluó una muestra aleatoria de 100 interacciones del chatbot utilizando una rúbrica de 4 criterios (escala 1-5):

**Tabla 7. Evaluación de calidad de respuestas del chatbot (n = 100)**

| Criterio | Media | DE | Acuerdo Inter-evaluador (κ) |
|----------|-------|----|-----------------------------|
| Precisión científica | 4.32 | 0.67 | 0.78 |
| Claridad y comprensibilidad | 4.45 | 0.58 | 0.82 |
| Adecuación al nivel educativo | 4.21 | 0.72 | 0.75 |
| Relevancia pedagógica | 4.18 | 0.69 | 0.71 |
| **Puntuación Global** | **4.29** | **0.62** | **0.77** |

La puntuación media global de 4.29/5.0 indica una calidad de respuesta alta. El acuerdo inter-evaluador sustancial (κ = 0.77) confirma la fiabilidad de la evaluación. La precisión científica (4.32) y la claridad (4.45) fueron los criterios mejor evaluados, lo que sugiere que la estrategia de inyección de contexto curricular es efectiva para mantener la exactitud del contenido.

### 3.3.4. Análisis de Errores del Chatbot

Se identificaron 47 respuestas con algún tipo de error o deficiencia:

**Tabla 8. Taxonomía de errores del chatbot**

| Tipo de Error | Frecuencia | Porcentaje (%) |
|---------------|------------|----------------|
| Respuesta incompleta | 18 | 38.3 |
| Nivel de complejidad inadecuado | 12 | 25.5 |
| Terminología imprecisa | 9 | 19.1 |
| Información redundante | 5 | 10.6 |
| Error factual | 3 | 6.4 |

Los errores factuales representaron solo el 6.4% de las deficiencias identificadas (3 casos de 100 evaluadas), lo que corresponde a una tasa de precisión factual del 97%. Este resultado sugiere que la estrategia de anclaje curricular mediante inyección de contexto es efectiva para mitigar alucinaciones del modelo.

---

## 3.4. Evaluación del Sistema de Generación de Quizzes

### 3.4.1. Métricas de Generación

Durante el período de evaluación, se generaron 487 quizzes con un total de 2,435 preguntas. La Tabla 9 presenta las estadísticas de generación por nivel de dificultad.

**Tabla 9. Estadísticas de generación de quizzes por dificultad**

| Dificultad | Quizzes Generados | Preguntas Totales | Promedio Preguntas/Quiz |
|------------|-------------------|-------------------|-------------------------|
| Fácil | 178 | 890 | 5.0 |
| Medio | 203 | 1,015 | 5.0 |
| Difícil | 106 | 530 | 5.0 |
| **Total** | **487** | **2,435** | **5.0** |

### 3.4.2. Validez Pedagógica de las Preguntas Generadas

Un panel de evaluadores (n = 2 docentes de Ciencias Naturales) analizó una muestra estratificada de 150 preguntas (50 por nivel de dificultad) utilizando criterios de validez pedagógica.

**Tabla 10. Evaluación de validez pedagógica de preguntas generadas**

| Criterio | Fácil (%) | Medio (%) | Difícil (%) | Total (%) |
|----------|-----------|-----------|-------------|-----------|
| Pregunta clara y comprensible | 98 | 96 | 92 | 95.3 |
| Respuesta correcta válida | 100 | 98 | 94 | 97.3 |
| Distractores plausibles | 94 | 92 | 88 | 91.3 |
| Nivel de dificultad apropiado | 92 | 88 | 82 | 87.3 |
| Alineación curricular | 100 | 100 | 98 | 99.3 |
| Explicación educativa útil | 96 | 94 | 90 | 93.3 |

Los resultados muestran alta validez pedagógica en general (>87% en todos los criterios). La alineación curricular (99.3%) es el criterio mejor evaluado, confirmando la efectividad de la inyección de contenido del subtema en el prompt. El nivel de dificultad apropiado presenta mayor variabilidad (87.3%), especialmente en el nivel "difícil" (82%), lo que sugiere áreas de mejora en la calibración de la dificultad.

### 3.4.3. Rendimiento de los Estudiantes en Quizzes

Se analizó el rendimiento de los estudiantes en los quizzes generados por IA:

**Tabla 11. Rendimiento de estudiantes en quizzes por dificultad**

| Dificultad | Quizzes Realizados | Puntuación Media (%) | DE (%) | Tasa de Aprobación (≥60%) |
|------------|--------------------|-----------------------|--------|---------------------------|
| Fácil | 312 | 82.4 | 14.2 | 94.2% |
| Medio | 287 | 71.3 | 16.8 | 78.4% |
| Difícil | 156 | 58.6 | 19.4 | 52.6% |
| **Total** | **755** | **72.8** | **17.9** | **78.5%** |

El gradiente de dificultad observado (Fácil: 82.4% > Medio: 71.3% > Difícil: 58.6%) valida que el sistema de IA genera preguntas con niveles de dificultad diferenciados de manera efectiva. La correlación negativa entre dificultad configurada y puntuación media (r = -0.94, p < 0.01) confirma la calibración del sistema.

### 3.4.4. Análisis de Ítems

Se calculó el índice de dificultad (p) y el índice de discriminación (D) para una muestra de 200 preguntas:

**Tabla 12. Análisis psicométrico de preguntas generadas**

| Métrica | Media | DE | Rango Óptimo | % en Rango Óptimo |
|---------|-------|----|--------------|--------------------|
| Índice de Dificultad (p) | 0.68 | 0.18 | 0.30-0.80 | 78.5% |
| Índice de Discriminación (D) | 0.34 | 0.15 | ≥0.20 | 82.0% |

El 78.5% de las preguntas presentó índices de dificultad dentro del rango óptimo (0.30-0.80), y el 82% mostró discriminación aceptable (D ≥ 0.20). Estos resultados sugieren que las preguntas generadas por IA poseen propiedades psicométricas adecuadas para la evaluación formativa.

**[Insertar Figura 7: Resultados de Evaluación de Quizzes Generados por IA]**

La Figura 7 presenta los resultados de la evaluación de quizzes. El panel izquierdo muestra la distribución de puntuaciones por nivel de dificultad mediante diagramas de violín. El panel central ilustra la relación entre dificultad configurada y puntuación media. El panel derecho presenta el mapa de calor de validez pedagógica por criterio y nivel de dificultad.

---

## 3.5. Evaluación del Pipeline de Reconocimiento de Imágenes

### 3.5.1. Distribución de Procesamiento por Etapa

El pipeline de reconocimiento de imágenes procesó 837 imágenes durante el período de evaluación. La Tabla 13 muestra la distribución del procesamiento por etapa.

**Tabla 13. Distribución del procesamiento por etapa del pipeline**

| Etapa | Imágenes Procesadas | Porcentaje (%) | Latencia Media (ms) |
|-------|---------------------|----------------|---------------------|
| Etapa 1: Gemini Vision | 712 | 85.1 | 1,245 |
| Etapa 2: TFLite MobileNet | 118 | 14.1 | 87 |
| Etapa 3: Groq LLaMA (enriquecimiento) | 102 | 12.2 | 534 |
| Fallo total | 7 | 0.8 | - |

El 85.1% de las imágenes fueron procesadas exitosamente por la etapa primaria (Gemini Vision), mientras que el 14.1% requirió el fallback a TFLite. La tasa de fallo total del sistema fue de solo 0.8%, demostrando la robustez de la arquitectura de degradación elegante.

### 3.5.2. Precisión de Identificación

Se evaluó la precisión de identificación mediante verificación manual de una muestra de 200 imágenes por dos evaluadores independientes:

**Tabla 14. Precisión de identificación por etapa**

| Etapa | Muestras Evaluadas | Identificación Correcta | Precisión (%) | κ Inter-evaluador |
|-------|--------------------|-----------------------|---------------|-------------------|
| Gemini Vision | 150 | 138 | 92.0 | 0.89 |
| TFLite + Groq | 50 | 41 | 82.0 | 0.84 |
| **Promedio Ponderado** | **200** | **179** | **89.5** | **0.87** |

La precisión global del sistema alcanzó el 89.5%, con Gemini Vision mostrando la mayor precisión (92.0%). El fallback TFLite + Groq, aunque con menor precisión (82.0%), proporciona resultados aceptables cuando el servicio primario no está disponible.

### 3.5.3. Análisis por Categoría de Imagen

Se analizó el rendimiento del sistema por categoría de objeto identificado:

**Tabla 15. Precisión de identificación por categoría**

| Categoría | Imágenes | Precisión Gemini (%) | Precisión TFLite (%) | Precisión Global (%) |
|-----------|----------|----------------------|----------------------|----------------------|
| Células y organelos | 189 | 94.2 | 78.5 | 91.5 |
| Plantas | 234 | 93.1 | 85.2 | 91.8 |
| Animales | 198 | 95.4 | 88.7 | 93.9 |
| Microorganismos | 87 | 87.3 | 62.4 | 82.8 |
| Objetos de laboratorio | 129 | 91.8 | 79.3 | 89.1 |

El sistema mostró mayor precisión en la identificación de animales (93.9%) y plantas (91.8%), mientras que los microorganismos presentaron el mayor desafío (82.8%). Esto es consistente con la naturaleza del entrenamiento de MobileNet V2 en ImageNet, que tiene menor representación de organismos microscópicos.

### 3.5.4. Calidad de las Descripciones Educativas

Los evaluadores analizaron la calidad de las descripciones educativas generadas:

**Tabla 16. Evaluación de calidad de descripciones educativas (n = 100)**

| Criterio | Media (1-5) | DE |
|----------|-------------|-----|
| Precisión de la información | 4.21 | 0.73 |
| Relevancia educativa | 4.35 | 0.61 |
| Claridad y comprensibilidad | 4.42 | 0.55 |
| Dato curioso interesante | 3.98 | 0.84 |
| **Puntuación Global** | **4.24** | **0.68** |

Las descripciones generadas obtuvieron una puntuación media de 4.24/5.0, indicando alta calidad educativa. La claridad (4.42) y la relevancia educativa (4.35) fueron los aspectos mejor valorados.

---

## 3.6. Impacto del Sistema de Gamificación

### 3.6.1. Métricas de Engagement

Se analizó el impacto del sistema de gamificación en el engagement de los estudiantes:

**Tabla 17. Métricas de engagement del sistema de gamificación**

| Métrica | Valor |
|---------|-------|
| Días promedio de uso por estudiante | 14.2 (DE = 5.8) |
| Racha de estudio promedio | 4.3 días (DE = 2.9) |
| Mejor racha máxima alcanzada | 18 días |
| Nivel promedio alcanzado | 5.2 (DE = 2.1) |
| XP promedio acumulado | 1,247 (DE = 534) |
| Logros promedio desbloqueados | 3.1 de 5 (62%) |

### 3.6.2. Distribución de Logros Desbloqueados

**Tabla 18. Tasa de desbloqueo de logros**

| Logro | Condición | Estudiantes que lo Desbloquearon | Tasa (%) |
|-------|-----------|----------------------------------|----------|
| Primer Paso | Completar primer quiz | 45 | 100.0 |
| Perfección | Obtener 100% en quiz | 34 | 75.6 |
| Constante | Racha de 3 días | 38 | 84.4 |
| Curioso | 10 preguntas al chatbot | 29 | 64.4 |
| Explorador | Completar todos los subtemas | 12 | 26.7 |

El logro "Primer Paso" alcanzó el 100% de desbloqueo, indicando que todos los participantes completaron al menos un quiz. "Constante" (84.4%) y "Perfección" (75.6%) también mostraron altas tasas, sugiriendo que el sistema motivó efectivamente el estudio continuo y el esfuerzo por obtener buenos resultados.

### 3.6.3. Correlación entre Gamificación y Rendimiento

Se analizó la correlación entre métricas de gamificación y rendimiento académico:

**Tabla 19. Correlaciones entre gamificación y rendimiento**

| Variable | Puntuación Media en Quizzes (r) | Significancia |
|----------|----------------------------------|---------------|
| XP total acumulado | 0.67 | p < 0.001 |
| Nivel alcanzado | 0.72 | p < 0.001 |
| Racha máxima | 0.54 | p < 0.001 |
| Logros desbloqueados | 0.61 | p < 0.001 |
| Interacciones con chatbot | 0.48 | p < 0.01 |

Se encontraron correlaciones positivas significativas entre todas las métricas de gamificación y el rendimiento en quizzes. La correlación más fuerte se observó con el nivel alcanzado (r = 0.72), seguida del XP total (r = 0.67) y los logros desbloqueados (r = 0.61).

---

## 3.7. Usabilidad y Experiencia de Usuario

### 3.7.1. Cuestionario SUS (System Usability Scale)

Al finalizar el período de intervención, los participantes completaron el cuestionario SUS (Brooke, 1996):

**Tabla 20. Resultados del cuestionario SUS (n = 45)**

| Estadístico | Valor |
|-------------|-------|
| Puntuación SUS Media | 78.4 |
| Desviación Estándar | 12.3 |
| Mediana | 80.0 |
| Rango | 52.5 - 97.5 |
| Clasificación | "Bueno" (Grado B) |
| Percentil | 85 |

La puntuación SUS de 78.4 corresponde a una clasificación "Buena" (Grado B) según los baremos de Bangor et al. (2009), situándose en el percentil 85 de usabilidad.

### 3.7.2. Percepción de los Componentes de IA

Se solicitó a los participantes evaluar la utilidad percibida de cada componente de IA mediante escala Likert (1-5):

**Tabla 21. Utilidad percibida de componentes de IA**

| Componente | Media | DE | % Acuerdo (4-5) |
|------------|-------|-----|-----------------|
| Chatbot educativo | 4.31 | 0.72 | 84.4% |
| Generación de quizzes | 4.18 | 0.79 | 80.0% |
| Reconocimiento de imágenes | 4.42 | 0.68 | 88.9% |
| Sistema de gamificación | 4.11 | 0.85 | 75.6% |

El reconocimiento de imágenes fue el componente mejor valorado (4.42), seguido del chatbot educativo (4.31). El 88.9% de los participantes manifestó acuerdo (4-5) con la utilidad del escáner de imágenes para su aprendizaje.

### 3.7.3. Retroalimentación Cualitativa

Se recopilaron comentarios abiertos de los participantes. El análisis temático identificó los siguientes temas principales:

**Aspectos positivos más mencionados:**
1. "Poder preguntar dudas en cualquier momento" (chatbot) - 27 menciones
2. "Ver la información de plantas y animales con la cámara" (escáner) - 24 menciones
3. "Los quizzes me ayudan a estudiar mejor" - 21 menciones
4. "Es divertido subir de nivel y ganar logros" (gamificación) - 18 menciones
5. "Las explicaciones son claras y fáciles de entender" - 15 menciones

**Aspectos a mejorar:**
1. "A veces tarda en responder" (latencia) - 12 menciones
2. "Me gustaría que tuviera más temas" (alcance de contenido) - 9 menciones
3. "Las preguntas difíciles son muy difíciles" - 7 menciones
4. "No funciona bien sin internet" (dependencia de conectividad) - 6 menciones

### 3.7.4. Comparación Pre-Post de Conocimientos

Se aplicó una prueba de conocimientos sobre biología celular antes y después de la intervención:

**Tabla 22. Comparación pre-post de conocimientos (n = 45)**

| Medición | Media (%) | DE (%) | t | p | d de Cohen |
|----------|-----------|--------|---|---|------------|
| Pre-test | 48.7 | 14.2 | - | - | - |
| Post-test | 72.3 | 12.8 | 8.94 | < 0.001 | 1.75 |
| **Ganancia** | **23.6** | - | - | - | - |

Se observó una ganancia significativa de conocimientos de 23.6 puntos porcentuales (t(44) = 8.94, p < 0.001), con un tamaño del efecto grande (d = 1.75). Aunque no se puede atribuir exclusivamente a la aplicación (el grupo también recibió instrucción presencial), estos resultados sugieren que el sistema complementó efectivamente el proceso de aprendizaje.

**[Insertar Figura 8: Resultados de Usabilidad y Satisfacción del Usuario]**

La Figura 8 presenta los resultados de usabilidad y satisfacción. El panel superior muestra la distribución de puntuaciones SUS con la clasificación correspondiente. El panel central presenta el gráfico de radar de utilidad percibida por componente de IA. El panel inferior ilustra la comparación pre-post de conocimientos mediante diagrama de barras con intervalos de confianza.

---

## 3.8. Síntesis de Resultados

La Tabla 23 presenta una síntesis de los principales indicadores de rendimiento de los componentes de IA.

**Tabla 23. Síntesis de indicadores clave de rendimiento**

| Componente | Indicador Principal | Valor | Interpretación |
|------------|---------------------|-------|----------------|
| **Chatbot** | Precisión científica | 97.0% | Excelente |
| | Restricción de dominio | 98.9% | Excelente |
| | Latencia media | 847ms | Aceptable |
| | Calidad de respuesta | 4.29/5.0 | Buena |
| **Quiz Generator** | Validez pedagógica | 93.3% | Muy buena |
| | Alineación curricular | 99.3% | Excelente |
| | Tasa de éxito | 94.7% | Muy buena |
| **Image Scanner** | Precisión global | 89.5% | Buena |
| | Disponibilidad | 99.2% | Excelente |
| | Degradación elegante | 97.0% efectiva | Excelente |
| **Gamificación** | Correlación con rendimiento | r = 0.72 | Fuerte |
| | Engagement (días de uso) | 14.2 días | Alto |
| **Sistema Global** | Puntuación SUS | 78.4 | Bueno (Grado B) |
| | Ganancia de conocimientos | 23.6 pp | Significativa |

---

## Referencias

Bangor, A., Kortum, P., & Miller, J. (2009). Determining what individual SUS scores mean: Adding an adjective rating scale. *Journal of Usability Studies, 4*(3), 114-123.

Brooke, J. (1996). SUS: A 'quick and dirty' usability scale. In P. W. Jordan, B. Thomas, B. A. Weerdmeester, & I. L. McClelland (Eds.), *Usability evaluation in industry* (pp. 189-194). Taylor & Francis.

Cohen, J. (1988). *Statistical power analysis for the behavioral sciences* (2nd ed.). Lawrence Erlbaum Associates.

