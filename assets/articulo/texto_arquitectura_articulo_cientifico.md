# Arquitectura del Sistema Inteligente de Tutoría con IA para la Enseñanza de Ciencias Naturales

## 2.1. System Design and Architecture

mi_app was designed as an agent-based Intelligent Tutoring System (ITS) aimed at supporting intelligent teaching and tutoring processes in Natural Sciences education, specifically focused on cell biology content, considering Human-AI Interaction (HAI) principles, academic monitoring, and active teaching and learning methodologies. The architectural design adopts a service-oriented approach based on microservices, with the aim of facilitating interoperability with mobile platforms, flexible deployment, and scalability of the system in real-world educational contexts.

The architecture was implemented using Flutter 3.7.2+ as the cross-platform framework, which allows the main components of the system—data management, orchestration, interaction, and analytics—to be run independently across Android, iOS, and web platforms, enabling the system deployment to be replicated in different educational institutions working under mobile learning environments.

Under this architecture, the layers of interaction, orchestration, Multi-Agent System (MAS), adaptive learning, and data management are presented, establishing well-defined communication channels between them. This scheme is particularly relevant in an ITS that integrates technologies such as mobile platforms, cloud services (Firebase), generative AI models (Google Generative AI), and machine learning frameworks (TensorFlow Lite), as it minimizes the coupling between these technologies through automated service flows (Figure 2). Service-based deployment enables incremental updates, allowing specific components to be improved or replaced without interrupting the overall operation of the system.

### 2.1.1. User Interface Layer

The architecture incorporates a layer of mobile interaction implemented in Flutter, which enables two-way communication between students and the intelligent tutoring system. The interaction is managed by services in Dart, which expose REST APIs for authentication, session management, and academic information synchronization, ensuring secure integration through Firebase Authentication with Google Sign-In support.

The mobile application acts as an educational context provider, supplying real data on learning activities, student progress, and interaction patterns, which allows for the generation of adaptive responses based on the learning process. The main application screens include:

**Table 1.** Application screens and their educational functions.

| Screen | Function | Technology |
|--------|----------|------------|
| ChatScreen | Interactive dialogue with educational chatbot | Google Generative AI |
| ScannerScreen | Image capture and cell analysis | TensorFlow Lite, Camera |
| ARScreen | Augmented reality visualization of cellular structures | SimpleMarkerDetector |
| GuiaScreen | Structured lessons on cell biology | GuiaContextService |
| QuizScreen | Knowledge assessment and evaluation | Quiz Models |

### 2.1.2. Middleware Orchestration Layer

This layer constitutes the operational core of the system and is implemented using Dart services as the orchestration engine, which is responsible for coordinating communication and control flows among the user interface, the multi-agent system (MAS), the adaptive learning module, the database, and external AI services. The selection of a service-oriented architecture enables the modeling of complex interaction pipelines in a flexible and transparent manner, combining event-driven workflows with conditional logic.

Within this layer, each tutoring interaction is managed as a well-defined execution cycle that includes the reception of the user query, contextual enrichment using academic and historical data, evaluation by the Intelligent Switching Router, activation of the appropriate specialized agents, and validation of the generated response prior to delivery. Orchestration logic ensures that these processes are executed in a controlled and sequential manner, preserving consistency across interactions while allowing dynamic adaptation of tutoring strategies.

### 2.1.3. Intelligent Switching Router

The Intelligent Switching Router is implemented within the orchestration layer, acting as a central decision node. This router operates as a decision agent, analyzing each incoming request considering multiple dimensions, such as the type of query, the academic context, the history of interactions, and signals derived from student behavior. Based on this analysis, it determines how the request should be processed and which strategies should be prioritized.

The router represents a fundamental abstraction for the architecture, as it allows the decision logic to be decoupled from the internal workings of the MAS. mi_app can manage diverse educational scenarios without relying on rigid flows, enabling dynamic tutoring that combines conceptual explanation, practical support through cell recognition, augmented reality visualization, and gamified feedback.

The following services are coordinated by the Intelligent Switching Router:

- **AuthService**: Manages user authentication through Firebase Auth and Google Sign-In
- **FirestoreService**: Handles real-time data access for profiles, interaction histories, and session management
- **ScannerService**: Processes cell images using TensorFlow Lite models for recognition and classification
- **GuiaContextService**: Provides adaptive educational content based on student progress
- **ChatService**: Coordinates interactions with the generative AI model for educational dialogue

### 2.1.4. Multi-Agent System

This constitutes the intelligent core of the overall system and is composed of multiple specialized agents: Generative Agent, Vision Agent, Pedagogical Agent, and AR Agent, which cooperate in an integrated manner within the system architecture. This design decision simplifies the representation of the system and emphasizes that tutoring is the result of internal collaboration between agents, rather than the isolated activation of independent components.

**Table 2.** Specialized agents in the Multi-Agent System.

| Agent | Technology | Function | Output |
|-------|------------|----------|--------|
| Generative Agent | Google Generative AI | Educational chatbot for conceptual queries | Natural language responses about cell biology |
| Vision Agent | TensorFlow Lite | Cell image recognition and classification | Identification of cellular structures |
| Pedagogical Agent | GuiaContextService | Adaptive content delivery | Personalized learning paths |
| AR Agent | SimpleMarkerDetector | Augmented reality visualization | 3D cellular structure models |

The MAS is responsible for interpreting user requests, generating contextualized responses, proposing learning resources, and offering adaptive feedback. Its design reflects the inherent complexity of tutoring in science education, where student needs can vary significantly depending on domain knowledge, learning styles, and engagement levels. By centralizing these capabilities, the architecture promotes pedagogical consistency and facilitates the future evolution of the system.

The **Output UI** component consolidates the outputs produced by the different agents, adjusts the depth and style of the response according to the student's profile, and records the interaction in the system for later use in analysis and adaptation processes.

The **Gamification** module provides reward signals through a point-based system that includes:
- Points for successful interactions
- Experience Points (XP) for completed activities
- Level progression based on accumulated learning
- Achievement badges for milestones reached

### 2.1.5. Integration of Adaptive Learning

A distinguishing feature of the mi_app architecture is the explicit incorporation of adaptive learning mechanisms as a system for continuous personalization (Figure 2). This layer introduces meta-cognitive capabilities that allow the system to learn from accumulated experience and progressively optimize its tutoring strategies.

The **Meta-Agent IA Coordinator** acts as a high-level controller, observing system interactions, evaluating results, and dynamically selecting strategies that maximize learning outcomes, allowing mi_app to adapt to emerging patterns beyond static rules. Learning is supported by:

- **Progress Model (UserProgressModel)**: Tracks student advancement through learning objectives, storing completion rates, current subtopics, and overall progress percentages
- **Reward Calculator**: Transforms interaction signals into numerical values that inform the gamification system and guide adaptive content selection
- **UserStatistics and Achievements**: Maintains cumulative metrics on quiz performance, time spent, and unlocked achievements

The architecture implements hybrid decision logic, where the Intelligent Switching Router prioritizes strategies based on student performance metrics when sufficient confidence exists; otherwise, it resorts to heuristics or inference based on language models.

**Table 3.** Reward assignment matrix for adaptive learning.

| Reinforcement Type | User Input | Assigned Value | Impact on the System |
|-------------------|------------|----------------|---------------------|
| Positive (Reward) | Correct quiz answers, successful cell scan, completed lesson | +XP, +Points, Achievement | Strategy validation: selected approach successfully addressed user need |
| Negative (Penalty) | Incorrect answers, failed recognition, abandoned session | No reward or -Points | Error correction: strategy was ineffective or agent selection was inappropriate |
| Neutral | Content browsing, navigation without explicit interaction | No change | State maintenance: insufficient evidence to modify system behavior |

### 2.1.6. Data Management and Knowledge Base Layer

The Data Management and Knowledge Layer supports the MAS and adaptive learning module through Firebase Firestore as the primary database that stores user profiles, interaction histories, and relevant metrics. It integrates a hybrid knowledge base with local educational resources and external services, ensuring relevant, traceable, and contextualized information, as well as facilitating system analysis and evaluation.

**Table 4.** Data layer components and their functions.

| Component | Content | Technology |
|-----------|---------|------------|
| Firebase Firestore | User profiles, session history, chat messages, progress records | Cloud Firestore |
| Knowledge Base | Structured educational content about cell biology | celula_data.dart |
| Memory | Conversation history, session records | ChatHistoryScreen |
| ML Models | Pre-trained models for cell recognition | TensorFlow Lite (assets/models/) |

**External Resources** integrated into the system include:
- Google Generative AI API for educational chatbot functionality
- YouTube Player for educational video content
- Speech to Text for accessibility features
- Image Picker and Camera for cell image capture

**Educational Assets** stored locally:
- `assets/libro/` - Structured text content
- `assets/CELULA/` - Cell-related images and visual resources
- `assets/marcadores/` - QR markers for augmented reality
- `assets/Diagrama/` - Educational diagrams and schemes
- `assets/models/` - TensorFlow Lite model files

Figure 2 illustrates the overall architecture of the mi_app intelligent tutoring system, structured into clearly decoupled layers that support scalability, security, and pedagogical adaptation. At the top, a set of cross-cutting principles—educational objectives, instructional design, learning styles, privacy and security, trust and reliability, and bias and fairness—frame the operation of the ITS.

User interaction begins with students through a mobile interface built with Flutter, which serves as an educational context provider. Communication is managed via Dart-based services connected to an orchestration engine, which coordinates interaction flows and activates the Intelligent Switching Router responsible for dynamically selecting the appropriate intelligent components for each request.

At the core of the system lies the Multi-Agent System (MAS), composed of specialized agents (Generative, Vision, Pedagogical, and AR), along with support components for output customization and gamification. These agents collaborate to produce contextualized and pedagogically aligned responses, supported by a data layer that integrates Firebase Firestore, local knowledge bases, memory systems, and ML models.

Operating in a decoupled manner, the Adaptive Learning module supervises the system at a strategic level by evaluating outcomes through progress tracking and reward calculation, updating decision policies without directly generating content. This clear separation between decision-making, content generation, and evaluation enables progressive adaptation while preserving interpretability, ethical safeguards, and stability in real-world educational environments.

### 2.1.7. Considerations for the Design of the Architecture

The proposed architecture is based on a set of cross-cutting principles that guide its design and operation as an ITS. First, educational objectives guide the definition of teaching strategies aligned with constructivist learning theories, ensuring that each recommendation, feedback, or explanation contributes directly to the achievement of learning outcomes in cell biology education.

**Table 5.** Alignment between mi_app architecture and ethical design principles.

| Principle | Criterion Applied | Implementation in mi_app | Architectural Component |
|-----------|------------------|-------------------------|------------------------|
| Human Wellbeing | Student-centered tutoring | Academic support and engagement are prioritized | MAS |
| Bias and Fairness | Equity in access | All users have access to the same functionalities | Flutter UI |
| | Performance-based adaptation | Personalization is grounded in academic and interaction indicators | Intelligent Switching Router |
| Transparency | Decision traceability | Every decision is logged and traceable | Firestore, Progress Model |
| | Separation between decision-making and generation | The LLM generates language but does not decide pedagogical strategies | Orchestration, Router |
| Accountability | Decision flow control | Tutoring logic is implemented through explicit flows and auditable services | Orchestration Layer |
| Trust and Reliability | Consistency in tutoring | Students with similar academic backgrounds receive coherent strategies | MAS |
| | Experience-validated learning | The system adjusts its behavior only when explicit evidence of positive or negative feedback exists | Meta-Agent, Reward Calculator |
| Privacy and Data Governance | Data minimization | The system uses only the academic data necessary for tutoring | Firebase, Services |
| | Isolation of sensitive information | Data are stored in separate layers with controlled access | Firestore, Auth |
| Robustness and Security | Architectural resilience | The use of services and cross-platform deployment allows faults to be isolated | Flutter, Firebase |

---

## Figure Caption

**Figure 2.** Architecture of the proposed intelligent tutoring system with AI for teaching Natural Sciences (mi_app). The system is structured in clearly decoupled layers: User Interface (Flutter), Middleware Orchestration (Services), Multi-Agent System (Generative, Vision, Pedagogical, AR agents), Adaptive Learning (Meta-Agent, Progress Model, Reward Calculator), and Data Knowledge Layer (Firestore, Knowledge Base, Memory, ML Models). Cross-cutting principles frame the operation ensuring educational alignment, privacy, trust, and fairness.

---

## Technologies Used

**Table 6.** Main technologies implemented in mi_app.

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Framework | Flutter | 3.7.2+ | Cross-platform mobile development |
| Language | Dart | SDK ^3.7.2 | Application logic |
| Backend | Firebase Core | 3.8.1 | Cloud infrastructure |
| Authentication | Firebase Auth | 5.3.3 | User authentication |
| Database | Cloud Firestore | 5.5.0 | Real-time data storage |
| Generative AI | Google Generative AI | 0.4.6 | Educational chatbot |
| Machine Learning | TensorFlow Lite | 0.11.0 | Cell recognition models |
| Authentication | Google Sign-In | 6.2.2 | OAuth authentication |
| Camera | Camera | 0.11.0 | Image capture |
| Accessibility | Speech to Text | 7.0.0 | Voice input |
| Media | YouTube Player | 9.1.1 | Educational videos |

---

*Document prepared for scientific publication - mi_app: Intelligent Tutoring System for Natural Sciences Education*
