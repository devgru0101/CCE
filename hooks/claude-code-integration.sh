#!/bin/bash

# Claude Code Core Integration Hook
# MANDATORY execution before ANY Claude Code task
# This hook forces Claude to consult CCE for context and memory

CCE_ROOT="$HOME/.claude/cce"
INTEGRATION_SCRIPT="$CCE_ROOT/bin/claude-core-cce-integration.sh"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Hook activation - this should be called by Claude Code before every task
activate_cce_consultation() {
    local task_description="$1"
    local task_type="${2:-general}"
    local force_consultation="${3:-true}"
    
    echo -e "${MAGENTA}🎯 CLAUDE CODE CORE CCE INTEGRATION ACTIVATED${NC}"
    
    # Initialize integration if not already done
    if [ ! -f "$CCE_ROOT/memory/core-session-memory.json" ]; then
        echo -e "${YELLOW}⚠️  CCE Core integration not initialized - initializing now...${NC}"
        "$INTEGRATION_SCRIPT" init
    fi
    
    # MANDATORY CCE consultation
    echo -e "${CYAN}📋 Running MANDATORY CCE pre-task consultation...${NC}"
    local consultation_result
    consultation_result=$("$INTEGRATION_SCRIPT" consult "$task_description" "$task_type")
    
    # Parse consultation results
    local requires_cce_agent=$(echo "$consultation_result" | grep "CCE AGENT REQUIRED:" | cut -d' ' -f4)
    local recommended_agents=$(echo "$consultation_result" | grep -A1 "RECOMMENDED AGENTS:" | tail -1 | sed 's/^[[:space:]]*//')
    
    # Display results
    echo -e "\n${GREEN}✅ CCE Consultation Complete${NC}"
    echo -e "${BLUE}Task Understanding: Enhanced with full context${NC}"
    echo -e "${BLUE}Memory State: Persistent and aware${NC}"
    echo -e "${BLUE}Recommended Approach: $recommended_agents${NC}"
    
    # Store consultation in environment for Claude to access
    export CCE_TASK_DESCRIPTION="$task_description"
    export CCE_TASK_TYPE="$task_type"
    export CCE_REQUIRES_CCE_AGENT="$requires_cce_agent"
    export CCE_RECOMMENDED_AGENTS="$recommended_agents"
    export CCE_CONSULTATION_ACTIVE="true"
    
    # Return success indicator
    return 0
}

# Post-task memory update hook
complete_cce_integration() {
    local task_status="${1:-completed}"
    local task_outcome="$2"
    
    if [ "$CCE_CONSULTATION_ACTIVE" = "true" ]; then
        echo -e "${CYAN}🧠 Updating CCE memory with task completion...${NC}"
        
        "$INTEGRATION_SCRIPT" update "$CCE_TASK_DESCRIPTION" "$CCE_TASK_TYPE" "$task_status" "$task_outcome"
        
        # Clear environment variables
        unset CCE_TASK_DESCRIPTION
        unset CCE_TASK_TYPE
        unset CCE_REQUIRES_CCE_AGENT
        unset CCE_RECOMMENDED_AGENTS
        unset CCE_CONSULTATION_ACTIVE
        
        echo -e "${GREEN}✅ CCE memory updated - learning preserved${NC}"
    fi
}

# Claude Code startup hook - runs when Claude Code starts
claude_code_startup() {
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎭 CLAUDE CODE CCE INTEGRATION STARTUP${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    
    # Check if CCE system is available
    if [ ! -f "$INTEGRATION_SCRIPT" ]; then
        echo -e "${RED}❌ CCE Core Integration not found${NC}"
        echo -e "${YELLOW}⚠️  Claude Code will operate without persistent memory${NC}"
        return 1
    fi
    
    # Initialize CCE integration
    "$INTEGRATION_SCRIPT" init >/dev/null 2>&1
    
    # Load previous session memory
    local memory_state
    memory_state=$("$INTEGRATION_SCRIPT" memory 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        local session_id=$(echo "$memory_state" | jq -r '.session_id // "unknown"')
        local last_interaction=$(echo "$memory_state" | jq -r '.memory_state.last_interaction // "never"')
        local task_count=$(echo "$memory_state" | jq -r '.context_awareness.recent_tasks | length')
        
        echo -e "${GREEN}✅ CCE INTEGRATION ACTIVE${NC}"
        echo -e "${BLUE}Session ID: $session_id${NC}"
        echo -e "${BLUE}Last Interaction: $last_interaction${NC}"
        echo -e "${BLUE}Recent Tasks: $task_count${NC}"
        echo -e "${CYAN}🧠 Persistent Memory: LOADED${NC}"
        echo -e "${CYAN}🎯 Context Awareness: ACTIVE${NC}"
        echo -e "${CYAN}📚 Learning System: ENABLED${NC}"
        
        # Set global environment variable to indicate CCE is active
        export CLAUDE_CCE_ACTIVE="true"
        export CLAUDE_SESSION_ID="$session_id"
        
    else
        echo -e "${YELLOW}⚠️  CCE memory loading failed - starting fresh session${NC}"
        export CLAUDE_CCE_ACTIVE="false"
    fi
    
    echo -e "\n${YELLOW}🎯 IMPORTANT: All tasks will now consult CCE for context and memory${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
}

# Claude Code task wrapper - intercepts all task execution
claude_code_task_wrapper() {
    local original_task="$1"
    local task_type="${2:-general}"
    
    # MANDATORY CCE consultation before task
    if ! activate_cce_consultation "$original_task" "$task_type"; then
        echo -e "${RED}❌ CCE consultation failed - proceeding without memory${NC}"
    fi
    
    # Task execution would happen here (handled by Claude Code)
    # This is where Claude Code would normally process the task
    
    # The actual execution is not in this script - this is just the hook
    # Claude Code itself needs to check these environment variables:
    # - CCE_CONSULTATION_ACTIVE
    # - CCE_REQUIRES_CCE_AGENT
    # - CCE_RECOMMENDED_AGENTS
    
    echo -e "${BLUE}🎯 Task ready for execution with CCE guidance${NC}"
    echo -e "${CYAN}Environment variables set for Claude Code:${NC}"
    echo -e "  CCE_CONSULTATION_ACTIVE=$CCE_CONSULTATION_ACTIVE"
    echo -e "  CCE_REQUIRES_CCE_AGENT=$CCE_REQUIRES_CCE_AGENT"
    echo -e "  CCE_RECOMMENDED_AGENTS=$CCE_RECOMMENDED_AGENTS"
}

# Debug function to show CCE integration status
show_cce_status() {
    echo -e "${CYAN}═══ CCE Integration Status ═══${NC}"
    echo "CCE Active: ${CLAUDE_CCE_ACTIVE:-false}"
    echo "Session ID: ${CLAUDE_SESSION_ID:-none}"
    echo "Integration Script: $([ -f "$INTEGRATION_SCRIPT" ] && echo "✅ Available" || echo "❌ Missing")"
    echo "Memory File: $([ -f "$CCE_ROOT/memory/core-session-memory.json" ] && echo "✅ Available" || echo "❌ Missing")"
    echo "Current Consultation: ${CCE_CONSULTATION_ACTIVE:-false}"
    
    if [ "$CCE_CONSULTATION_ACTIVE" = "true" ]; then
        echo "Current Task: $CCE_TASK_DESCRIPTION"
        echo "Task Type: $CCE_TASK_TYPE"
        echo "Requires CCE Agent: $CCE_REQUIRES_CCE_AGENT"
        echo "Recommended Agents: $CCE_RECOMMENDED_AGENTS"
    fi
}

# Main command handler
main() {
    case "${1:-status}" in
        "startup")
            claude_code_startup
            ;;
        "consult")
            activate_cce_consultation "$2" "$3"
            ;;
        "complete")
            complete_cce_integration "$2" "$3"
            ;;
        "wrap")
            claude_code_task_wrapper "$2" "$3"
            ;;
        "status")
            show_cce_status
            ;;
        *)
            echo "Claude Code CCE Integration Hook"
            echo "Usage: $0 {startup|consult|complete|wrap|status}"
            echo ""
            echo "Commands:"
            echo "  startup                    - Initialize CCE integration on Claude startup"
            echo "  consult <task> [type]      - Run CCE consultation before task"
            echo "  complete <status> <outcome> - Update CCE memory after task completion"
            echo "  wrap <task> [type]         - Full task wrapper with CCE integration"
            echo "  status                     - Show CCE integration status"
            echo ""
            echo "This hook ensures Claude Code Core consults CCE for every task"
            ;;
    esac
}

# Auto-run startup if called without arguments and CCE not active
if [ $# -eq 0 ] && [ "$CLAUDE_CCE_ACTIVE" != "true" ]; then
    claude_code_startup
else
    main "$@"
fi