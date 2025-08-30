#!/bin/bash

# CCE (Context & Coordination Engine) Installation Script
# Portable installation for Claude Code multi-agent system

set -e

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLAUDE_DIR="$HOME/.claude"
CCE_DIR="$CLAUDE_DIR/cce"
AGENTS_DIR="$CLAUDE_DIR/agents"
HOOKS_DIR="$CLAUDE_DIR/hooks"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  CCE (Context & Coordination Engine) Installer${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo

# Check if Claude Code CLI is installed
if ! command -v claude-code &> /dev/null; then
    echo -e "${YELLOW}⚠️  Claude Code CLI not detected${NC}"
    echo -e "   Please install Claude Code CLI first:"
    echo -e "   ${BLUE}https://docs.anthropic.com/claude/claude-code${NC}"
    echo
    read -p "Continue installation anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${BLUE}📂 Setting up directories...${NC}"

# Create necessary directories
mkdir -p "$CCE_DIR"/{bin,context,sessions,patterns,memory}
mkdir -p "$AGENTS_DIR"
mkdir -p "$HOOKS_DIR"
mkdir -p "$CLAUDE_DIR/projects"

echo -e "${GREEN}✅ Directories created${NC}"

echo -e "${BLUE}📋 Installing agent definitions...${NC}"

# Copy agent definitions
if [ -d "agents" ]; then
    cp -r agents/*.md "$AGENTS_DIR/"
    echo -e "${GREEN}✅ Installed 17 specialized agents${NC}"
else
    echo -e "${RED}❌ Error: agents directory not found${NC}"
    exit 1
fi

echo -e "${BLUE}🔧 Installing CCE core system...${NC}"

# Copy CCE system files
if [ -f "cce/bin/claude-integration.sh" ]; then
    cp cce/bin/claude-integration.sh "$CCE_DIR/bin/"
    chmod +x "$CCE_DIR/bin/claude-integration.sh"
    echo -e "${GREEN}✅ CCE integration script installed${NC}"
else
    echo -e "${RED}❌ Error: CCE integration script not found${NC}"
    exit 1
fi

# Copy hooks
if [ -f "hooks/session-start.sh" ]; then
    cp hooks/session-start.sh "$HOOKS_DIR/"
    chmod +x "$HOOKS_DIR/session-start.sh"
    echo -e "${GREEN}✅ Auto-initialization hook installed${NC}"
else
    echo -e "${YELLOW}⚠️  Session start hook not found, creating basic version${NC}"
    cat > "$HOOKS_DIR/session-start.sh" << 'EOF'
#!/bin/bash
# Auto-initialize CCE on session start
~/.claude/cce/bin/claude-integration.sh init > /dev/null 2>&1
EOF
    chmod +x "$HOOKS_DIR/session-start.sh"
fi

echo -e "${BLUE}📝 Installing core configuration...${NC}"

# Copy CLAUDE.md if it exists
if [ -f "CLAUDE.md" ]; then
    # Backup existing CLAUDE.md if it exists
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}📋 Existing CLAUDE.md backed up${NC}"
    fi
    
    cp CLAUDE.md "$CLAUDE_DIR/"
    echo -e "${GREEN}✅ Core configuration installed${NC}"
else
    echo -e "${YELLOW}⚠️  CLAUDE.md not found, CCE may need manual configuration${NC}"
fi

echo -e "${BLUE}🚀 Initializing CCE system...${NC}"

# Initialize CCE
if "$CCE_DIR/bin/claude-integration.sh" init; then
    echo -e "${GREEN}✅ CCE system initialized${NC}"
else
    echo -e "${RED}❌ Error initializing CCE system${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Creating alias for easy access...${NC}"

# Create convenient alias
ALIAS_CMD="alias claude-cce='$CCE_DIR/bin/claude-integration.sh'"

# Add to shell profile if not already present
for shell_profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$shell_profile" ] && ! grep -q "claude-cce" "$shell_profile"; then
        echo "" >> "$shell_profile"
        echo "# CCE (Context & Coordination Engine) alias" >> "$shell_profile"
        echo "$ALIAS_CMD" >> "$shell_profile"
        echo -e "${GREEN}✅ Added alias to $(basename $shell_profile)${NC}"
        break
    fi
done

echo -e "${BLUE}✨ Installation complete!${NC}"
echo

# Display status
"$CCE_DIR/bin/claude-integration.sh" status

echo
echo -e "${BLUE}🎯 Next Steps:${NC}"
echo -e "   1. Restart your shell or run: ${YELLOW}source ~/.bashrc${NC}"
echo -e "   2. Start Claude Code CLI in any project directory"
echo -e "   3. CCE will initialize automatically and orchestrate agents"
echo
echo -e "${BLUE}💡 Usage:${NC}"
echo -e "   • CCE works automatically - no commands needed"
echo -e "   • Check status: ${YELLOW}claude-cce status${NC}"
echo -e "   • View context: ${YELLOW}claude-cce context${NC}"
echo -e "   • Manual orchestration: ${YELLOW}claude-cce orchestrate \"your request\"${NC}"
echo

echo -e "${GREEN}🎉 Welcome to intelligent, persistent AI development!${NC}"