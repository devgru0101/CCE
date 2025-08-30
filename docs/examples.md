# CCE Usage Examples

This document provides practical examples of how the CCE system works in real scenarios.

## 🚀 Getting Started Examples

### Simple Request - Single Agent
**User Request:** "Fix the login button styling"

**CCE Process:**
1. Context loads current project (React app detected)
2. Keywords: "fix", "button", "styling" → triggers `frontend-agent`
3. Agent analyzes existing CSS patterns
4. Implements fix following project conventions
5. Learning system records successful styling pattern

**Outcome:** Single agent execution, quick resolution, pattern learned for future styling tasks.

### Medium Complexity - Multi-Agent
**User Request:** "Add user authentication with JWT tokens"

**CCE Process:**
1. Context analysis: Full-stack application detected
2. Keywords: "authentication", "JWT" → complexity: high
3. Agent orchestration: `security-agent` → `backend-agent` → `frontend-agent` → `testing-agent`
4. Each agent builds on previous work using shared context
5. Quality validation ensures security best practices
6. Learning system captures authentication implementation pattern

**Outcome:** Multi-agent coordination, enterprise-grade security, reusable auth pattern.

### Complex Project - Full Orchestration
**User Request:** "Build a real-time chat application with React, Node.js, and WebSockets"

**CCE Process:**
1. System architecture analysis → `system-architecture-agent` designs overall structure
2. Planning phase → `planning-agent` breaks down into phases
3. Implementation phase → Multiple agents work in parallel:
   - `backend-agent`: WebSocket server, message handling
   - `frontend-agent`: React chat UI, real-time updates  
   - `database-agent`: Message persistence schema
   - `security-agent`: Authentication, message encryption
   - `testing-agent`: Unit and integration tests
4. Integration phase → `implementation-verification-agent` validates completeness
5. Learning extraction → Patterns stored for future real-time applications

**Outcome:** Full application built with enterprise quality, multiple reusable patterns learned.

## 🎭 Agent-Specific Examples

### Frontend Agent Examples

#### React Component Creation
```typescript
// User request: "Create a reusable button component with variants"
// CCE learns project uses styled-components and TypeScript

interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size: 'small' | 'medium' | 'large';
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
}

const StyledButton = styled.button<ButtonProps>`
  /* Styles based on learned project patterns */
`;

export const Button: React.FC<ButtonProps> = ({ 
  variant = 'primary', 
  size = 'medium', 
  children, 
  ...props 
}) => {
  return (
    <StyledButton variant={variant} size={size} {...props}>
      {children}
    </StyledButton>
  );
};
```

#### Responsive Layout Implementation
```css
/* User request: "Make the dashboard mobile-responsive"
   CCE applies learned mobile-first patterns */

.dashboard {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
  padding: 1rem;
}

@media (min-width: 768px) {
  .dashboard {
    grid-template-columns: 250px 1fr;
    padding: 2rem;
  }
}

@media (min-width: 1200px) {
  .dashboard {
    grid-template-columns: 300px 1fr 250px;
  }
}
```

### Backend Agent Examples

#### API Endpoint Creation
```javascript
// User request: "Add CRUD endpoints for user management"
// CCE applies learned Express.js patterns and error handling

const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/users - List users (admin only)
router.get('/', auth, requireAdmin, async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/users - Create user
router.post('/', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  body('name').trim().isLength({ min: 2 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const user = new User(req.body);
    await user.save();
    
    const { password, ...userResponse } = user.toObject();
    res.status(201).json(userResponse);
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ error: 'Email already exists' });
    }
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
```

### Testing Agent Examples

#### Unit Test Generation
```javascript
// User request: "Add tests for the user service"
// CCE generates comprehensive tests based on learned patterns

const { createUser, getUserById, updateUser } = require('../services/userService');
const User = require('../models/User');

jest.mock('../models/User');

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createUser', () => {
    it('should create a user successfully', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123'
      };

      User.prototype.save = jest.fn().mockResolvedValue(userData);
      User.mockImplementation(() => ({
        save: User.prototype.save
      }));

      const result = await createUser(userData);

      expect(User).toHaveBeenCalledWith(userData);
      expect(User.prototype.save).toHaveBeenCalled();
      expect(result).toEqual(userData);
    });

    it('should handle validation errors', async () => {
      const invalidUserData = {
        name: 'John Doe',
        email: 'invalid-email',
        password: '123'
      };

      User.prototype.save = jest.fn().mockRejectedValue({
        name: 'ValidationError',
        errors: {
          email: { message: 'Invalid email format' },
          password: { message: 'Password too short' }
        }
      });

      User.mockImplementation(() => ({
        save: User.prototype.save
      }));

      await expect(createUser(invalidUserData)).rejects.toThrow('ValidationError');
    });
  });
});
```

## 🔄 Workflow Examples

### Development Workflow
```bash
# User starts new feature
$ claude-code

# CCE auto-initializes and loads context
✅ CCE (Context & Coordination Engine) LOADED
Current Project: e-commerce-app
Context Sources: 12

# User request
> "Add shopping cart functionality with persistence"

# CCE orchestrates multiple agents:
# 1. planning-agent: Creates implementation plan
# 2. database-agent: Designs cart schema
# 3. backend-agent: Implements cart API
# 4. frontend-agent: Creates cart UI components
# 5. testing-agent: Adds comprehensive tests
# 6. cce-learning-agent: Extracts patterns

# Learning outcome: "E-commerce cart pattern" stored for future projects
```

### Debugging Workflow
```bash
# User encounters error
> "The payment processing is throwing 500 errors"

# CCE orchestrates debugging:
# 1. error-correction-agent: Analyzes error logs
# 2. security-agent: Checks for security issues
# 3. backend-agent: Implements fix
# 4. testing-agent: Adds regression tests

# Learning outcome: "Payment error handling pattern" stored
```

### Code Review Workflow
```bash
# User requests review
> "Review my authentication implementation for security issues"

# CCE orchestrates review:
# 1. security-agent: Security vulnerability scan
# 2. implementation-verification-agent: Code quality assessment
# 3. knowledge-agent: Best practices comparison
# 4. cce-update-agent: Documents findings

# Learning outcome: Security review checklist updated
```

## 📊 Learning Examples

### Pattern Discovery
**Scenario**: User frequently implements React forms with similar validation patterns.

**CCE Learning Process**:
1. Identifies common form structure across implementations
2. Extracts reusable validation patterns
3. Creates "React Form with Validation" pattern template
4. Auto-suggests pattern for future form requests

**Result**: Future form implementations are 60% faster and more consistent.

### Cross-Project Learning
**Scenario**: User implements caching solution in Project A.

**CCE Learning Process**:
1. Extracts successful caching pattern from Project A
2. Generalizes pattern for different tech stacks
3. Applies pattern when similar performance issues detected in Project B
4. Measures success and refines pattern

**Result**: Performance solutions transfer across different projects automatically.

### Quality Calibration
**Scenario**: User consistently requests more detailed error handling.

**CCE Learning Process**:
1. Notices user feedback pattern requesting better error handling
2. Increases error handling weight in quality assessment
3. Adjusts agent behavior to include more comprehensive error handling
4. Updates quality standards for this user's projects

**Result**: Future implementations automatically include more robust error handling.

## 🎯 Advanced Examples

### Custom Agent Creation
```yaml
# ~/.claude/agents/custom-ai-agent.md
---
name: custom-ai-agent
description: Specialized agent for AI/ML model integration
tools: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, WebFetch
model: sonnet
---

**Purpose**: AI/ML model integration, data preprocessing, model deployment

## Specializations
- TensorFlow/PyTorch model integration
- Data pipeline creation
- Model serving and API development
- Performance optimization for ML workloads

## Auto-Activation
- Keywords: ml, ai, model, tensorflow, pytorch, data, prediction
- Project types: data-science, ml-platform
```

### Multi-Project Pattern Sharing
```bash
# Project A: E-commerce platform learns authentication pattern
# Project B: Social media app benefits from the pattern

$ cd ~/social-media-app
$ claude-code

> "Implement user authentication"

# CCE automatically applies e-commerce authentication pattern:
# - JWT token structure learned from Project A
# - Security validations from Project A  
# - Error handling patterns from Project A
# - Adapted to social media app context

# Result: Consistent, high-quality auth across projects
```

### Enterprise Integration
```yaml
# ~/.claude/cce/config/enterprise.yaml
enterprise:
  quality_gates:
    - security_scan: mandatory
    - performance_test: mandatory
    - code_review: mandatory
  
  compliance:
    - gdpr: enabled
    - hipaa: enabled
    - sox: enabled
  
  integrations:
    - sonarqube: "https://sonar.company.com"
    - jira: "https://company.atlassian.net"
    - slack: "https://hooks.slack.com/webhook"
```

These examples demonstrate how CCE transforms Claude Code into an intelligent, learning development companion that gets better with every interaction while maintaining the highest standards of code quality and security.