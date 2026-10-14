# 2. Materials and Methods - Artificial Intelligence Integration

## 2.X. Multi-Model Artificial Intelligence Architecture

The mobile application implements a sophisticated multi-layered artificial intelligence architecture designed to support personalized learning experiences in natural sciences education. This architecture integrates three distinct AI subsystems: (i) a conversational educational chatbot powered by Large Language Models (LLMs), (ii) an AI-driven adaptive quiz generation system, and (iii) a multi-stage computer vision pipeline for biological specimen identification. The architectural design follows principles of graceful degradation and model complementarity, ensuring system reliability while maximizing educational effectiveness.

### 2.X.1. System Architecture and AI Components Integration

The proposed AI architecture adopts a service-oriented design pattern implemented within the Flutter framework, enabling cross-platform deployment across Android, iOS, and web environments. The architecture is structured in three functional layers: the presentation layer (screens and widgets), the service layer (AI services and business logic), and the data layer (local storage, Firebase Firestore, and external APIs). This separation of concerns facilitates modularity, maintainability, and the independent evolution of AI components.

Figure X illustrates the overall AI architecture, depicting the interaction between the mobile client, cloud-based AI services, and on-device machine learning models. The system leverages a hybrid approach that combines cloud-hosted Large Language Models for complex reasoning tasks with on-device TensorFlow Lite models for low-latency inference, thereby balancing computational requirements with response time constraints.

The integration of multiple AI services is orchestrated through dedicated service classes that encapsulate API communication, error handling, and response parsing logic. Each service implements a consistent interface pattern, enabling the application to gracefully handle API failures through fallback mechanisms. This design decision ensures continuous availability of AI-powered features even under adverse network conditions or service disruptions.

**[Insert Figure X: Overall AI Architecture of the Mobile Educational Application]**

Figure X presents the comprehensive AI architecture of the mobile application. The system is organized into three primary AI subsystems: the Educational Chatbot Service, the Adaptive Quiz Generator, and the Image Recognition Pipeline. Each subsystem interfaces with external AI providers (Groq API for LLM inference and Google Gemini for multimodal understanding) while maintaining local fallback capabilities through TensorFlow Lite models. The architecture implements a request-response pattern with asynchronous communication, enabling non-blocking user interactions. Data persistence is managed through Firebase Firestore for user progress, chat history, and achievement tracking, while the educational content is embedded within the application to ensure offline accessibility of core learning materials.

### 2.X.2. Educational Chatbot Architecture with Context-Aware Prompt Engineering

The educational chatbot represents the primary AI-driven tutoring interface, implementing a context-aware conversational agent specifically designed for natural sciences education. The system employs the LLaMA 3.3 70B model, accessed through the Groq API, which provides high-throughput inference capabilities suitable for real-time educational interactions.

The chatbot architecture implements a sophisticated prompt engineering strategy that addresses three fundamental challenges in educational AI: domain restriction, contextual grounding, and pedagogical adaptation. The system prompt is dynamically constructed by injecting the complete educational content of the didactic guide, including topic descriptions, explanatory texts, highlighted concepts, and quiz questions. This approach, known as context injection or retrieval-augmented generation (RAG) without external retrieval, ensures that the chatbot's responses are grounded in the verified educational content rather than relying solely on the model's parametric knowledge.

The prompt structure follows a hierarchical organization:

1. **Role Definition**: The system prompt establishes the chatbot as an educational assistant exclusively specialized in natural sciences, explicitly defining the permitted and restricted topic domains.

2. **Knowledge Base Injection**: The complete content of the didactic guide is embedded within the system prompt, providing the model with authoritative reference material for generating responses.

3. **Behavioral Constraints**: Explicit instructions govern response formatting (plain text without markdown), language requirements (Spanish), and the handling of out-of-domain queries.

4. **Pedagogical Directives**: The prompt includes instructions for adapting explanations to student comprehension levels and encouraging engagement with the interactive quiz system.

**[Insert Figure X: Educational Chatbot Workflow and Prompt Engineering Architecture]**

Figure X illustrates the workflow of the educational chatbot system. User queries are received through either text input or speech-to-text transcription using the Speech-to-Text library configured for Spanish language recognition. The query is then processed by the GuiaContextService, which constructs the complete system prompt by concatenating the role definition, the full educational content of the didactic guide, behavioral constraints, and pedagogical directives. This composite prompt, together with the user's query, is transmitted to the Groq API endpoint for inference using the LLaMA 3.3 70B model. The generated response is parsed, validated, and rendered in the chat interface. Concurrently, the interaction is persisted to Firebase Firestore for session continuity and learning analytics. The system also implements achievement tracking, incrementing the user's question counter to trigger gamification rewards upon reaching interaction milestones.

The implementation of speech-to-text capabilities extends the accessibility of the chatbot interface, accommodating diverse user interaction preferences and supporting students with specific learning needs. The system employs the SpeechToText library with Spanish locale configuration, implementing automatic message submission upon final recognition to streamline the conversational flow.

### 2.X.3. AI-Powered Adaptive Quiz Generation System

The quiz generation subsystem implements an automated assessment creation pipeline that leverages generative AI to produce contextually relevant evaluation items. Unlike static, pre-authored assessments, this system dynamically generates quiz questions based on the specific educational content of each subtopic, enabling scalable assessment creation while maintaining pedagogical alignment.

The generation process follows a structured pipeline:

1. **Content Retrieval**: The system retrieves the textual content associated with the requested subtopic from the embedded educational data structures.

2. **Prompt Construction**: A specialized prompt is constructed that includes the educational content, the target number of questions, the desired difficulty level (easy, medium, or hard), and explicit formatting requirements for the JSON response structure.

3. **LLM Inference**: The prompt is submitted to the Groq API using the LLaMA 3.3 70B model with carefully tuned generation parameters (temperature: 0.7 for creative diversity while maintaining coherence; max_tokens: 2500 to accommodate detailed question sets).

4. **Response Parsing and Validation**: The JSON response is parsed, validated against the expected schema, and transformed into the application's internal quiz model representation.

The prompt engineering for quiz generation incorporates several pedagogical principles:

- **Question Variety**: Instructions specify that questions should vary in style, including definitions, functional relationships, comparisons, and application scenarios.
- **Distractor Quality**: The prompt emphasizes that incorrect options should be plausible but clearly distinguishable from the correct answer, avoiding trivially eliminable distractors.
- **Answer Position Randomization**: To prevent positional bias, the system explicitly instructs the model to vary the position of correct answers across questions.
- **Educational Explanations**: Each question includes an explanation field that provides formative feedback, supporting learning from both correct and incorrect responses.

**[Insert Figure X: AI-Driven Quiz Generation Pipeline]**

Figure X depicts the AI-driven quiz generation pipeline. The process initiates when a user selects a subtopic and difficulty level, triggering a request to the QuizGeneratorService. The service retrieves the relevant educational content from the GuiaContextService and constructs a structured prompt that includes the content, pedagogical requirements, and the expected JSON output format. The request is transmitted to the Groq API endpoint with the LLaMA 3.3 70B model. The response undergoes JSON parsing and schema validation, transforming the generated content into Quiz and Pregunta model instances. Error handling encompasses network failures, rate limiting (HTTP 429), and malformed responses, with appropriate user feedback for each failure mode. Successfully generated quizzes are presented to the user with immediate scoring feedback and optional explanations for each question.

### 2.X.4. Multi-Stage Image Recognition Pipeline with Graceful Degradation

The image recognition subsystem implements a sophisticated multi-stage pipeline designed for the identification of biological specimens, organisms, and natural objects. The architecture prioritizes accuracy through a cascading model hierarchy while ensuring robustness through graceful degradation mechanisms.

The pipeline implements a three-stage processing strategy:

**Stage 1 - Multimodal Vision-Language Model (Primary)**: The system first attempts identification using Google's Gemini 1.5 Flash model through the Generative AI API. This multimodal foundation model receives the image encoded in base64 format along with a structured prompt that specifies the required output format. The prompt requests seven distinct fields: common name, scientific name, type classification (animal, plant, insect, fungus, or object), educational description, habitat information, a curious fact, and a confidence score. The structured output format facilitates reliable parsing while enabling rich educational content generation.

**Stage 2 - On-Device Classification (Fallback)**: If the Gemini API call fails due to network issues, rate limiting, or API key configuration problems, the system falls back to on-device classification using TensorFlow Lite. The implementation employs a MobileNet V2 model, which provides a favorable balance between model size, inference speed, and classification accuracy. The image preprocessing pipeline includes resizing to 224x224 pixels and normalization to the [-1, 1] range as required by MobileNet V2. The model outputs confidence scores across 1000 ImageNet classes, from which the top prediction is extracted.

**Stage 3 - Description Generation (Augmentation)**: When the TFLite model provides the identification, the system invokes the Groq API with LLaMA 3.3 70B to generate educational descriptions. This stage transforms the English ImageNet label into Spanish, generates an age-appropriate description, provides habitat information if applicable, and produces an interesting fact about the identified subject.

The implementation includes several optimizations for mobile deployment:

- **Lazy Model Initialization**: The TFLite interpreter is initialized only when needed, reducing application startup time and memory footprint.
- **Image Compression**: Input images are processed and resized to optimize API transmission and inference efficiency.
- **Label Translation**: A comprehensive dictionary maps English ImageNet labels to Spanish common names, ensuring consistent language presentation.
- **Type Detection Heuristics**: Classification into semantic categories (animal, plant, insect, fungus, object) is performed through keyword matching against curated category lists.

**[Insert Figure X: Multi-Stage Image Recognition Pipeline with Fallback Mechanisms]**

Figure X presents the multi-stage image recognition pipeline architecture. Image acquisition occurs through the device camera or gallery selection. The image is first submitted to the Gemini Vision API with a structured prompt requesting comprehensive identification data. If successful, the parsed response is directly rendered to the user. Upon failure, the system initializes the TensorFlow Lite interpreter (if not already loaded) and performs on-device classification using MobileNet V2. The resulting ImageNet label undergoes translation to Spanish and type classification through heuristic matching. Subsequently, the Groq API is invoked to generate educational descriptions that augment the basic classification. A final fallback provides minimal identification information if all enrichment stages fail. This cascading architecture ensures that users receive meaningful results across varying network conditions and API availability scenarios.

### 2.X.5. Technical Implementation and API Integration

Table X summarizes the technical specifications of the AI components integrated within the mobile application.

| Component | Model/Service | API Endpoint | Key Parameters |
|-----------|---------------|--------------|----------------|
| Educational Chatbot | LLaMA 3.3 70B | Groq API | Context window: Full guide injection |
| Quiz Generation | LLaMA 3.3 70B | Groq API | Temperature: 0.7, Max tokens: 2500 |
| Image Recognition (Primary) | Gemini 1.5 Flash | Google Generative AI | Temperature: 0.2, Max tokens: 500 |
| Image Recognition (Fallback) | MobileNet V2 | On-device TFLite | Input: 224x224, Normalization: [-1,1] |
| Description Generation | LLaMA 3.3 70B | Groq API | Temperature: 0.3, Max tokens: 300 |
| Speech Recognition | System STT | Platform Native | Locale: es_ES |

The selection of the Groq API as the primary LLM inference provider was motivated by its high-throughput inference capabilities, which enable responsive conversational interactions essential for maintaining student engagement. The LLaMA 3.3 70B model provides state-of-the-art performance on educational and reasoning tasks while being available through an accessible API endpoint.

### 2.X.6. Considerations for AI Integration in Educational Mobile Applications

The integration of AI components within mobile educational applications requires careful consideration of several cross-cutting concerns:

**Latency and User Experience**: Educational interactions demand responsive feedback to maintain cognitive flow and engagement. The architecture addresses this through asynchronous processing, loading indicators, and fallback mechanisms that provide partial results when full processing is delayed.

**Content Safety and Pedagogical Alignment**: The system implements domain restriction through explicit prompt constraints, ensuring that the chatbot responds only to queries within the natural sciences domain. This approach maintains pedagogical focus while preventing misuse.

**Offline Functionality**: Core educational content is embedded within the application, enabling offline access to the didactic guide and pre-authored quizzes. AI-enhanced features (chatbot, dynamic quiz generation, image recognition) require network connectivity but degrade gracefully to offline alternatives.

**Data Privacy and Persistence**: User interactions are persisted to Firebase Firestore for learning analytics and session continuity. The architecture implements user-scoped data isolation, ensuring that chat histories and progress data are accessible only to the authenticated user.

**Cost and Scalability**: The use of efficient models (Gemini Flash, on-device TFLite) and API providers with favorable pricing structures (Groq) enables scalable deployment while managing operational costs. The fallback architecture further reduces API costs by handling simple cases locally.

This multi-model AI architecture demonstrates the viability of integrating sophisticated AI capabilities within mobile educational applications, providing personalized tutoring, adaptive assessment, and interactive exploration features that enhance the learning experience in natural sciences education.
