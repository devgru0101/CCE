# Claude Code CCE (Context & Coordination Engine)

A sophisticated multi-agent system for Claude Code that provides persistent context, intelligent agent orchestration, and continuous learning across development sessions.

## 🎯 What is CCE?

The Context & Coordination Engine (CCE) transforms Claude Code into a persistent, learning AI development companion that:

- **Never loses context** - Maintains memory across sessions and projects
- **Intelligently orchestrates agents** - Automatically selects the right specialist agents for each task
- **Learns and improves** - Builds knowledge base of patterns that work in your codebase
- **Scales across projects** - Applies learnings from one project to benefit others

## ✨ Features

### 🧠 Persistent Memory System
- Session state persistence across Claude Code restarts
- Project-specific knowledge bases that evolve over time
- Context aggregation from code, git history, and interaction patterns

### 🎭 17 Specialized Agents
- **Core Orchestration**: `cce-agent`, `cce-learning-agent`, `cce-update-agent`
- **Development**: `frontend-agent`, `backend-agent`, `database-agent`
- **Infrastructure**: `devops-agent`, `docker-agent`, `service-agent`
- **Quality**: `testing-agent`, `security-agent`, `error-correction-agent`
- **Architecture**: `system-architecture-agent`, `planning-agent`
- **Analysis**: `knowledge-agent`, `implementation-verification-agent`
- **Automation**: `playwright-agent`

### 🚀 Intelligent Orchestration
- Automatic agent selection based on request complexity and domain
- Multi-phase execution for complex features
- Quality gates and validation at each step

## 📦 Installation

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/your-username/cce-claude-repository.git
cd cce-claude-repository

# Run the installation script
./install.sh

# Verify installation
claude-cce status
```

### Manual Setup
```bash
# Copy files to Claude Code directory
cp -r agents ~/.claude/
cp -r cce ~/.claude/
cp CLAUDE.md ~/.claude/

# Make scripts executable
chmod +x ~/.claude/cce/bin/claude-integration.sh
chmod +x ~/.claude/hooks/session-start.sh

# Initialize CCE
~/.claude/cce/bin/claude-integration.sh init
```

## 🛠️ Usage

Once installed, CCE works automatically:

1. **Start Claude Code** - CCE initializes automatically
2. **Make requests** - CCE orchestrates appropriate agents
3. **Context builds** - Each interaction improves future responses
4. **Cross-project learning** - Patterns transfer between projects

### Manual Commands
```bash
# Check CCE status
~/.claude/cce/bin/claude-integration.sh status

# View current context
~/.claude/cce/bin/claude-integration.sh context

# Get orchestration recommendation
~/.claude/cce/bin/claude-integration.sh orchestrate "your request here"
```

## 📁 Repository Structure

```
cce-claude-repository/
├── README.md                    # This file
├── install.sh                   # Automated installation script
├── CLAUDE.md                    # Core CCE configuration for Claude Code
├── agents/                      # 17 specialized agent definitions
│   ├── cce-agent.md
│   ├── frontend-agent.md
│   ├── backend-agent.md
│   └── ... (all 17 agents)
├── cce/                         # CCE system files
│   ├── bin/
│   │   └── claude-integration.sh # Core CCE orchestration script
│   ├── context/                 # Context storage
│   ├── sessions/                # Session management
│   └── patterns/                # Learned patterns storage
├── hooks/                       # Claude Code hooks
│   └── session-start.sh         # Auto-initialization hook
└── docs/                        # Documentation
    ├── agents.md                # Agent documentation
    ├── architecture.md          # System architecture
    └── examples.md              # Usage examples
```

## 🎭 Agent Descriptions

### Core Orchestration
- **`cce-agent`** - Primary orchestration, context management, memory coordination
- **`cce-learning-agent`** - Pattern recognition, success analysis, workflow optimization
- **`cce-update-agent`** - Context persistence, pattern extraction, knowledge updates

### Development Specialists
- **`frontend-agent`** - UI/UX, React/Vue/Angular, CSS, responsive design
- **`backend-agent`** - APIs, business logic, data processing, authentication
- **`database-agent`** - Schema design, optimization, migrations, queries

### Infrastructure & DevOps
- **`devops-agent`** - CI/CD, infrastructure, deployment, monitoring
- **`docker-agent`** - Containerization, dockerfile optimization, compose orchestration
- **`service-agent`** - Microservices, API design, messaging, event-driven systems

### Quality & Security
- **`testing-agent`** - Unit tests, integration tests, E2E testing, TDD/BDD
- **`security-agent`** - Security analysis, authentication, vulnerability scanning
- **`error-correction-agent`** - Error diagnosis, debugging, performance issues

### Architecture & Planning
- **`system-architecture-agent`** - System analysis, architecture mapping, dependency analysis
- **`planning-agent`** - Task planning, implementation design, architecture blueprints
- **`implementation-verification-agent`** - Requirement validation, quality assurance

### Analysis & Research
- **`knowledge-agent`** - Research, documentation lookup, best practices
- **`playwright-agent`** - Browser testing, E2E automation, visual regression

## 🔄 How It Works

1. **Auto-Initialization**: CCE activates automatically when Claude Code starts
2. **Context Loading**: Loads project context, patterns, and session state
3. **Request Analysis**: Analyzes user requests for complexity and domain
4. **Agent Orchestration**: Selects and activates appropriate specialist agents
5. **Quality Validation**: Ensures outputs meet project standards
6. **Learning Extraction**: Captures successful patterns for future use

## 🚀 Benefits

- **Zero Learning Curve** - Works automatically, no new commands to learn
- **Persistent Intelligence** - Never starts from scratch, always builds on previous work
- **Adaptive Quality** - Standards automatically adjust to project context
- **Cross-Project Learning** - Success patterns transfer between projects
- **Continuous Improvement** - Gets better with every interaction

## 🔧 Configuration

CCE is designed to work out of the box, but can be customized:

- **Quality Standards** - Adjust validation requirements per project
- **Agent Preferences** - Modify agent selection algorithms
- **Context Sources** - Configure which sources contribute to context
- **Learning Settings** - Control how patterns are extracted and applied

## 📚 Documentation

- [Agent Reference](docs/agents.md) - Detailed agent capabilities and usage
- [System Architecture](docs/architecture.md) - Technical implementation details
- [Usage Examples](docs/examples.md) - Common scenarios and workflows

## 🤝 Contributing

CCE is designed to evolve. Contributions welcome for:

- New specialized agents
- Enhanced orchestration algorithms
- Additional context sources
- Quality validation improvements

## 📄 License

MIT License - Feel free to adapt and extend for your needs.

---

**Transform your Claude Code experience with persistent, intelligent, multi-agent development.**