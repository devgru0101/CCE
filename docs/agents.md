# CCE Agent Reference

This document provides detailed information about all 17 specialized agents in the CCE system.

## 🎭 Agent Categories

### Core Orchestration Agents

#### `cce-agent` 
**Purpose**: Primary orchestration, context management, memory coordination  
**Auto-Activation**: HIGHEST priority (1) - Always runs first  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Core Functions:**
- Load and maintain persistent context across sessions
- Orchestrate other specialized agents based on task requirements  
- Update and maintain the Context & Coordination Engine
- Store learnings and patterns for future use
- Manage session state and project context

**Workflow:**
1. Load current project context from ~/.claude/cce/context/
2. Analyze user request for complexity and requirements
3. Determine which specialized agents to activate
4. Coordinate multi-agent workflows
5. Store session learnings and update context
6. Update knowledge base with new patterns

#### `cce-learning-agent`
**Purpose**: Pattern recognition, success analysis, workflow optimization, agent improvement  
**Auto-Activation**: After task completion  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Core Functions:**
- Extract successful patterns from completed tasks
- Analyze interaction outcomes for improvement opportunities
- Update agent selection algorithms based on performance
- Cross-project pattern sharing and optimization
- Performance tracking and recommendation adjustment

#### `cce-update-agent` 
**Purpose**: Context persistence, pattern extraction, knowledge updates, session learning  
**Auto-Activation**: Session end or major context changes  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Core Functions:**
- Persist session context and learnings
- Extract and store successful implementation patterns
- Update project knowledge bases
- Maintain context compression for performance
- Handle knowledge base synchronization

### Development Specialists

#### `frontend-agent`
**Purpose**: UI/UX implementation, component development, styling, responsive design, client-side logic  
**Auto-Activation**: frontend, UI, component, React, Vue, CSS, styling, layout keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- React/Vue/Angular component development
- CSS-in-JS, styled-components, SCSS/SASS
- Responsive design and accessibility
- State management (Redux, Zustand, Pinia)
- Performance optimization (code splitting, lazy loading)
- Testing (Jest, Testing Library, Cypress)

#### `backend-agent`
**Purpose**: Server-side development, APIs, business logic, data processing, authentication, database operations  
**Auto-Activation**: backend, API, server, endpoint, route, controller, service keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- RESTful API design and implementation
- GraphQL schemas and resolvers
- Authentication and authorization systems
- Database integration and ORM usage
- Background job processing
- Microservices architecture

#### `database-agent`
**Purpose**: Database design, schema optimization, migrations, queries, indexing, data modeling  
**Auto-Activation**: database, SQL, NoSQL, schema, migration keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Schema design and normalization
- Query optimization and indexing strategies
- Migration scripts and version control
- Database performance tuning
- Data modeling for different database types
- Backup and recovery strategies

### Infrastructure & DevOps

#### `devops-agent`
**Purpose**: CI/CD pipelines, infrastructure, deployment, kubernetes, terraform, monitoring  
**Auto-Activation**: CI/CD, deploy, infrastructure, kubernetes, terraform keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- CI/CD pipeline configuration (GitHub Actions, Jenkins, GitLab CI)
- Infrastructure as Code (Terraform, CloudFormation)
- Container orchestration (Kubernetes, Docker Swarm)
- Monitoring and logging setup (Prometheus, Grafana, ELK)
- Cloud platform integration (AWS, GCP, Azure)

#### `docker-agent`
**Purpose**: Docker containerization, dockerfile optimization, compose orchestration, image building  
**Auto-Activation**: docker, container, dockerfile, compose keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Dockerfile optimization and multi-stage builds
- Docker Compose configuration
- Container security best practices
- Image size optimization
- Registry management and deployment

#### `service-agent`
**Purpose**: Microservices, service architecture, API design, workers, messaging, event-driven systems  
**Auto-Activation**: microservice, service, API, worker, message, event keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Microservices architecture design
- Inter-service communication patterns
- Message queue integration (RabbitMQ, Kafka, Redis)
- Event-driven architecture
- Service discovery and load balancing

### Quality & Security

#### `testing-agent`
**Purpose**: Unit tests, integration tests, E2E testing, coverage analysis, TDD/BDD  
**Auto-Activation**: test, testing, unit, integration, E2E, TDD, BDD keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Test framework setup and configuration
- Unit test design and implementation
- Integration test strategies
- End-to-end test automation
- Test coverage analysis and improvement
- Performance and load testing

#### `security-agent`
**Purpose**: Security analysis, authentication, vulnerability scanning, encryption, OWASP compliance  
**Auto-Activation**: security, auth, vulnerability, encryption, OWASP keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Security vulnerability assessment
- Authentication and authorization implementation
- Encryption and data protection
- OWASP compliance checking
- Security testing and penetration testing
- Secure coding practices

#### `error-correction-agent`
**Purpose**: Error diagnosis, debugging, exception handling, crash fixes, performance issues  
**Auto-Activation**: error, bug, debug, crash, exception, fix keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Error analysis and root cause identification
- Exception handling implementation
- Performance bottleneck identification
- Memory leak detection and fixing
- Debugging strategy and tool usage

### Architecture & Planning

#### `system-architecture-agent`
**Purpose**: Complete system analysis, architecture mapping, technology stack identification  
**Auto-Activation**: architecture, system, design, stack, analysis keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- System architecture design and documentation
- Technology stack evaluation and selection
- Scalability and performance architecture
- Architecture pattern implementation
- Dependency analysis and management

#### `planning-agent`
**Purpose**: Task planning, implementation design, architecture blueprints, roadmaps, strategy  
**Auto-Activation**: plan, design, blueprint, roadmap, strategy keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Project planning and task breakdown
- Implementation strategy development
- Risk assessment and mitigation planning
- Resource allocation and timeline estimation
- Milestone definition and tracking

#### `implementation-verification-agent`
**Purpose**: Requirement validation, quality assurance, completeness checks, performance verification  
**Auto-Activation**: verify, validate, QA, check, review keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Requirements verification and validation
- Code quality assessment
- Performance benchmarking
- Compliance checking
- Acceptance criteria validation

### Analysis & Research

#### `knowledge-agent`
**Purpose**: Research, documentation lookup, best practices, technology comparison, learning  
**Auto-Activation**: research, documentation, best practices, compare, learn keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Technical research and analysis
- Best practices identification
- Technology comparison and evaluation
- Documentation creation and maintenance
- Knowledge base management

#### `playwright-agent`
**Purpose**: Browser testing, E2E automation, visual regression, cross-browser testing  
**Auto-Activation**: playwright, browser, E2E, visual, automation keywords  
**Tools**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch  

**Specializations:**
- Playwright test automation
- Cross-browser testing strategies
- Visual regression testing
- Performance testing in browsers
- Test reporting and analysis

## 🔄 Agent Orchestration Patterns

### Simple Tasks (1 agent)
- Direct implementation requests
- Single-domain problems
- Quick fixes or updates

### Medium Complexity (2-4 agents)
- Feature implementations
- Cross-domain solutions
- Integration tasks

### Complex Projects (5+ agents)
- Full application development
- System redesigns
- Multi-service implementations

## 📊 Agent Selection Algorithm

The CCE uses several factors to select agents:

1. **Keyword Analysis** - Scanning request for domain-specific terms
2. **Context Awareness** - Current project type and patterns
3. **Historical Performance** - Which agents worked well for similar requests
4. **Complexity Assessment** - How many agents are needed for the scope
5. **Quality Requirements** - Which validation agents are needed

## 🎯 Quality Gates

Each agent applies quality standards:

- **Intent Alignment** (30%) - Solves the actual problem
- **Code Quality** (25%) - Maintainable, readable, follows patterns
- **Performance** (20%) - Efficient and scalable
- **Security** (15%) - Secure and validates inputs
- **Integration** (10%) - Compatible with existing codebase

Standards adapt based on project context (enterprise, startup, prototype, learning).