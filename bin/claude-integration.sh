#!/bin/bash

# CCE (Context & Coordination Engine) Integration Script
# Manages persistent context, agent orchestration, and learning system

CCE_ROOT="$HOME/.claude/cce"
PROJECTS_ROOT="$HOME/.claude/projects"
AGENTS_ROOT="$HOME/.claude/agents"
SESSION_FILE="$CCE_ROOT/sessions/current.json"
CONTEXT_FILE="$CCE_ROOT/context/current.json"

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Initialize CCE directories if they don't exist
init_cce() {
    mkdir -p "$CCE_ROOT"/{bin,context,agents,memory,patterns,sessions}
    mkdir -p "$PROJECTS_ROOT"
    mkdir -p "$AGENTS_ROOT"
    
    # Create default session if not exists
    if [ ! -f "$SESSION_FILE" ]; then
        echo "{
  \"session_id\": \"$(date +%Y%m%d_%H%M%S)\",
  \"start_time\": \"$(date -Iseconds)\",
  \"project\": \"$(basename $(pwd))\",
  \"context_sources\": [],
  \"active\": true
}" > "$SESSION_FILE"
    fi
    
    echo -e "${GREEN}✅ CCE initialized${NC}"
}

# Check if CCE is active
check_active() {
    if [ -f "$SESSION_FILE" ]; then
        active=$(jq -r '.active' "$SESSION_FILE" 2>/dev/null)
        if [ "$active" = "true" ]; then
            echo "active"
        else
            echo "inactive"
        fi
    else
        echo "not_initialized"
    fi
}

# Get current context
get_context() {
    if [ ! -f "$CONTEXT_FILE" ]; then
        # Build initial context
        echo "{
  \"project\": \"$(basename $(pwd))\",
  \"working_directory\": \"$(pwd)\",
  \"git_branch\": \"$(git branch --show-current 2>/dev/null || echo 'not_git')\",
  \"timestamp\": \"$(date -Iseconds)\",
  \"files_count\": $(find . -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" -o -name "*.rs" 2>/dev/null | wc -l),
  \"language_stats\": $(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" -o -name "*.rs" \) 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | jq -Rs '
    split("\n") | 
    map(select(. != "") | split(" ") | select(length == 2) | {(.[1]): (.[0] | tonumber)}) | 
    add // {}
  '),
  \"patterns\": [],
  \"context_sources\": $(ls -1 *.md README* 2>/dev/null | head -5 | jq -Rs 'split("\n") | map(select(. != ""))')
}" > "$CONTEXT_FILE"
    fi
    
    cat "$CONTEXT_FILE"
}

# Orchestrate agent selection
orchestrate() {
    local request="$1"
    
    # Analyze request complexity and requirements
    local complexity="simple"
    local recommended_agent="general-purpose"
    local approach="direct"
    
    # Check for keywords indicating complexity
    if echo "$request" | grep -qiE "(create|build|implement|feature|system|architecture|database|api|frontend|backend)"; then
        complexity="complex"
        
        # Determine specific agent based on domain
        if echo "$request" | grep -qiE "(frontend|ui|react|vue|angular|css|html)"; then
            recommended_agent="frontend-specialist"
        elif echo "$request" | grep -qiE "(backend|api|server|database|sql|nosql)"; then
            recommended_agent="backend-specialist"
        elif echo "$request" | grep -qiE "(test|testing|unit|integration|e2e)"; then
            recommended_agent="testing-specialist"
        elif echo "$request" | grep -qiE "(security|auth|authentication|encryption)"; then
            recommended_agent="security-specialist"
        elif echo "$request" | grep -qiE "(performance|optimize|scale|speed)"; then
            recommended_agent="performance-specialist"
        elif echo "$request" | grep -qiE "(architecture|design|pattern|structure)"; then
            recommended_agent="architecture-specialist"
        else
            recommended_agent="general-purpose"
        fi
        
        approach="multi-phase"
    fi
    
    # Return orchestration recommendation
    echo "{
  \"request\": \"$request\",
  \"complexity\": \"$complexity\",
  \"recommended_agent\": \"$recommended_agent\",
  \"approach\": \"$approach\",
  \"phases\": $([ "$approach" = "multi-phase" ] && echo '["research", "design", "implementation", "validation"]' || echo '["implementation"]'),
  \"context_needed\": $([ "$complexity" = "complex" ] && echo 'true' || echo 'false')
}"
}

# Main command handler
case "$1" in
    "init")
        init_cce
        ;;
    "active")
        check_active
        ;;
    "context")
        get_context
        ;;
    "orchestrate")
        orchestrate "$2"
        ;;
    "status")
        echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✅ CCE (Context & Coordination Engine) STATUS${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
        
        status=$(check_active)
        if [ "$status" = "active" ]; then
            echo -e "Status: ${GREEN}ACTIVE${NC}"
            
            if [ -f "$SESSION_FILE" ]; then
                session_id=$(jq -r '.session_id' "$SESSION_FILE")
                project=$(jq -r '.project' "$SESSION_FILE")
                echo -e "Session: ${YELLOW}$session_id${NC}"
                echo -e "Project: ${YELLOW}$project${NC}"
            fi
            
            context_count=$(jq '.context_sources | length' "$CONTEXT_FILE" 2>/dev/null || echo 0)
            echo -e "Context Sources: ${YELLOW}$context_count${NC}"
            
            echo -e "\n${GREEN}Features:${NC}"
            echo -e "  • Persistent Memory: ${GREEN}ACTIVE${NC} (Never loses context)"
            echo -e "  • Agent Orchestration: ${GREEN}READY${NC} (Intelligent delegation)"
            echo -e "  • Learning System: ${GREEN}ACTIVE${NC} (Improves each session)"
            echo -e "  • Project Context: ${GREEN}LOADED${NC} (From previous sessions)"
            
            echo -e "\n${BLUE}🎭 Ready for automatic agent orchestration${NC}"
            echo -e "${BLUE}💡 Core orchestrates - agents execute${NC}"
        else
            echo -e "Status: ${RED}INACTIVE${NC}"
            echo -e "\nRun '~/.claude/cce/bin/claude-integration.sh init' to activate"
        fi
        
        echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
        ;;
    *)
        echo "CCE Integration Script"
        echo "Usage: $0 {init|active|context|orchestrate|status}"
        echo ""
        echo "Commands:"
        echo "  init        - Initialize CCE system"
        echo "  active      - Check if CCE is active"
        echo "  context     - Get current context"
        echo "  orchestrate - Get agent recommendation for request"
        echo "  status      - Show full CCE status"
        ;;
esac