#!/bin/bash

# Claude Code Core CCE Integration
# Forces Claude Code Core to consult CCE before ALL tasks
# Provides persistent memory and context awareness to core Claude

CCE_ROOT="$HOME/.claude/cce"
CORE_INTEGRATION_LOG="$CCE_ROOT/logs/core-integration.log"
CCE_MEMORY_FILE="$CCE_ROOT/memory/core-session-memory.json"
TASK_HISTORY_FILE="$CCE_ROOT/memory/task-history.jsonl"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Initialize core integration
init_core_integration() {
    mkdir -p "$CCE_ROOT/memory"
    mkdir -p "$CCE_ROOT/logs"
    
    # Create core session memory if it doesn't exist
    if [ ! -f "$CCE_MEMORY_FILE" ]; then
        cat > "$CCE_MEMORY_FILE" <<EOF
{
  "session_id": "$(date +%Y%m%d_%H%M%S)",
  "start_time": "$(date -Iseconds)",
  "context_awareness": {
    "current_project": null,
    "working_directory": "$(pwd)",
    "recent_tasks": [],
    "conversation_context": [],
    "error_patterns": [],
    "success_patterns": []
  },
  "memory_state": {
    "last_interaction": null,
    "conversation_thread": [],
    "task_completion_status": {},
    "learned_preferences": {},
    "project_specific_knowledge": {}
  },
  "integration_status": {
    "cce_active": true,
    "agents_available": [],
    "last_cce_consultation": null,
    "memory_persistence": "active"
  }
}
EOF
    fi
    
    echo -e "${GREEN}🧠 Claude Code Core CCE Integration Initialized${NC}"
    echo -e "${BLUE}Memory File: $CCE_MEMORY_FILE${NC}"
    echo -e "${BLUE}Task History: $TASK_HISTORY_FILE${NC}"
}

# CCE Pre-Task Consultation - MANDATORY before any task
cce_pre_task_consultation() {
    local task_description="$1"
    local task_type="${2:-general}"
    local timestamp=$(date -Iseconds)
    
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎯 CCE PRE-TASK CONSULTATION${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Task: $task_description${NC}"
    echo -e "${BLUE}Type: $task_type${NC}"
    echo -e "${BLUE}Timestamp: $timestamp${NC}"
    
    # Step 1: Update core memory with current context
    update_core_memory "$task_description" "$task_type"
    
    # Step 2: Analyze task and determine if CCE Agent is needed
    local requires_cce_agent=$(analyze_task_complexity "$task_description" "$task_type")
    
    # Step 3: Get CCE recommendation for task approach
    local cce_recommendation=$(get_cce_task_recommendation "$task_description" "$task_type")
    
    # Step 4: Check for relevant historical patterns
    local historical_context=$(get_historical_task_context "$task_description")
    
    # Step 5: Determine appropriate agent(s)
    local recommended_agents=$(determine_task_agents "$task_description" "$task_type")
    
    # Step 6: Generate consultation report
    local consultation_report=$(generate_consultation_report "$task_description" "$task_type" "$requires_cce_agent" "$cce_recommendation" "$historical_context" "$recommended_agents")
    
    echo -e "\n${CYAN}📋 CONSULTATION RESULTS:${NC}"
    echo "$consultation_report"
    
    # Log the consultation
    log_task_consultation "$task_description" "$task_type" "$consultation_report"
    
    echo -e "\n${GREEN}✅ CCE Consultation Complete - Proceeding with informed approach${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    
    # Return the consultation result
    echo "$consultation_report"
}

# Update core memory with current context
update_core_memory() {
    local task="$1"
    local task_type="$2"
    local timestamp=$(date -Iseconds)
    
    # Update memory file with current context
    local temp_file=$(mktemp)
    jq --arg task "$task" --arg type "$task_type" --arg time "$timestamp" \
       '.memory_state.last_interaction = $time |
        .memory_state.conversation_thread += [{
          "timestamp": $time,
          "task": $task,
          "type": $type,
          "status": "consulting"
        }] |
        .context_awareness.recent_tasks += [{
          "task": $task,
          "type": $type,
          "timestamp": $time
        }] |
        .context_awareness.working_directory = "'$(pwd)'" |
        .integration_status.last_cce_consultation = $time' \
       "$CCE_MEMORY_FILE" > "$temp_file" && mv "$temp_file" "$CCE_MEMORY_FILE"
}

# Analyze task complexity to determine if CCE Agent is needed
analyze_task_complexity() {
    local task="$1"
    local task_type="$2"
    
    # Keywords that indicate CCE Agent is needed (comprehensive context required)
    local cce_required_keywords=(
        "complex" "multiple" "system" "architecture" "integration" 
        "database" "api" "service" "deployment" "configuration"
        "error" "debug" "fix" "troubleshoot" "analyze" "review"
        "project" "codebase" "repository" "workflow" "process"
    )
    
    # Task types that always need CCE Agent
    local cce_required_types=(
        "development" "coding" "implementation" "debugging" 
        "architecture" "planning" "review"
    )
    
    # Check if task contains complexity indicators
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    for keyword in "${cce_required_keywords[@]}"; do
        if echo "$task_lower" | grep -q "$keyword"; then
            echo "true"
            return
        fi
    done
    
    # Check if task type requires CCE Agent
    for type in "${cce_required_types[@]}"; do
        if [ "$task_type" = "$type" ]; then
            echo "true"
            return
        fi
    done
    
    # Simple tasks might not need full CCE Agent
    echo "false"
}

# Get CCE recommendation for task approach
get_cce_task_recommendation() {
    local task="$1"
    local task_type="$2"
    
    # Run CCE orchestrator to get recommendation
    local recommendation
    if [ -f "$CCE_ROOT/bin/cce-orchestrator.sh" ]; then
        recommendation=$("$CCE_ROOT/bin/cce-orchestrator.sh" recommend "$task" 2>/dev/null || echo "CCE orchestrator not available")
    else
        recommendation="CCE orchestrator not found - using fallback logic"
    fi
    
    echo "$recommendation"
}

# Get historical context for similar tasks
get_historical_task_context() {
    local task="$1"
    
    if [ ! -f "$TASK_HISTORY_FILE" ]; then
        echo "No historical task data available"
        return
    fi
    
    # Extract keywords from current task
    local task_keywords=$(echo "$task" | tr '[:upper:]' '[:lower:]' | grep -oE '[a-z]{3,}' | head -5)
    
    # Search for similar historical tasks
    local similar_tasks=""
    for keyword in $task_keywords; do
        local matches=$(grep -i "$keyword" "$TASK_HISTORY_FILE" 2>/dev/null | tail -3)
        if [ -n "$matches" ]; then
            similar_tasks="$similar_tasks\n$matches"
        fi
    done
    
    if [ -n "$similar_tasks" ]; then
        echo -e "Historical patterns found:\n$similar_tasks"
    else
        echo "No similar historical tasks found"
    fi
}

# Determine appropriate agents for the task
determine_task_agents() {
    local task="$1"
    local task_type="$2"
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    local recommended_agents=()
    
    # Always recommend CCE Agent for complex tasks
    local requires_cce=$(analyze_task_complexity "$task" "$task_type")
    if [ "$requires_cce" = "true" ]; then
        recommended_agents+=("cce-agent")
    fi
    
    # Git/GitHub related tasks
    if echo "$task_lower" | grep -qE "(git|github|commit|push|pull|branch|merge|repository|repo)"; then
        recommended_agents+=("git-agent")
    fi
    
    # File operations
    if echo "$task_lower" | grep -qE "(file|directory|folder|copy|move|delete|create|read|write)"; then
        recommended_agents+=("file-ops-agent")
    fi
    
    # System administration
    if echo "$task_lower" | grep -qE "(system|admin|configure|install|setup|service|process|permission)"; then
        recommended_agents+=("system-admin-agent")
    fi
    
    # Development tasks
    if echo "$task_lower" | grep -qE "(code|develop|implement|build|compile|test|debug)"; then
        if echo "$task_lower" | grep -qE "(frontend|ui|react|vue|angular|css|html)"; then
            recommended_agents+=("frontend-agent")
        fi
        if echo "$task_lower" | grep -qE "(backend|api|server|database|auth)"; then
            recommended_agents+=("backend-agent")
        fi
        if echo "$task_lower" | grep -qE "(database|sql|schema|migration|query)"; then
            recommended_agents+=("database-agent")
        fi
    fi
    
    # Testing tasks
    if echo "$task_lower" | grep -qE "(test|testing|spec|coverage|unit|integration)"; then
        recommended_agents+=("testing-agent")
    fi
    
    # Documentation tasks
    if echo "$task_lower" | grep -qE "(document|readme|doc|guide|manual|explain)"; then
        recommended_agents+=("documentation-agent")
    fi
    
    # If no specific agents identified, recommend general-purpose
    if [ ${#recommended_agents[@]} -eq 0 ]; then
        recommended_agents+=("general-purpose-agent")
    fi
    
    # Return comma-separated list
    IFS=','
    echo "${recommended_agents[*]}"
}

# Generate consultation report
generate_consultation_report() {
    local task="$1"
    local task_type="$2" 
    local requires_cce="$3"
    local cce_recommendation="$4"
    local historical_context="$5"
    local recommended_agents="$6"
    
    cat <<EOF

🎯 TASK: $task
📋 TYPE: $task_type
🧠 CCE AGENT REQUIRED: $requires_cce

🤖 RECOMMENDED AGENTS:
$(echo "$recommended_agents" | tr ',' '\n' | sed 's/^/  • /')

💡 CCE RECOMMENDATION:
$cce_recommendation

📚 HISTORICAL CONTEXT:
$historical_context

✅ APPROACH:
1. $([ "$requires_cce" = "true" ] && echo "Run CCE Agent first for comprehensive context" || echo "Proceed directly with task-specific agents")
2. Execute with recommended agents: $recommended_agents
3. Validate results against historical patterns
4. Update memory and learning systems

EOF
}

# Log task consultation to history
log_task_consultation() {
    local task="$1"
    local task_type="$2" 
    local consultation_report="$3"
    local timestamp=$(date -Iseconds)
    
    # Log to integration log
    echo "[$timestamp] CONSULTATION: $task ($task_type)" >> "$CORE_INTEGRATION_LOG"
    
    # Add to task history JSONL
    local task_record=$(jq -n \
        --arg timestamp "$timestamp" \
        --arg task "$task" \
        --arg type "$task_type" \
        --arg consultation "$consultation_report" \
        '{
            timestamp: $timestamp,
            task: $task,
            type: $type,
            consultation: $consultation,
            status: "consulted"
        }')
    
    echo "$task_record" >> "$TASK_HISTORY_FILE"
}

# Post-task memory update
post_task_memory_update() {
    local task="$1"
    local task_type="$2"
    local status="$3"  # completed, failed, cancelled
    local outcome="$4"
    local timestamp=$(date -Iseconds)
    
    echo -e "${CYAN}🧠 Updating Core Memory with Task Outcome${NC}"
    
    # Update memory with task completion
    local temp_file=$(mktemp)
    jq --arg task "$task" --arg type "$task_type" --arg status "$status" --arg outcome "$outcome" --arg time "$timestamp" \
       '.memory_state.task_completion_status[$task] = {
          "status": $status,
          "outcome": $outcome, 
          "completed_at": $time
        } |
        .memory_state.conversation_thread[-1].status = $status |
        .memory_state.conversation_thread[-1].outcome = $outcome |
        .memory_state.conversation_thread[-1].completed_at = $time' \
       "$CCE_MEMORY_FILE" > "$temp_file" && mv "$temp_file" "$CCE_MEMORY_FILE"
    
    # Log to task history
    local completion_record=$(jq -n \
        --arg timestamp "$timestamp" \
        --arg task "$task" \
        --arg type "$task_type" \
        --arg status "$status" \
        --arg outcome "$outcome" \
        '{
            timestamp: $timestamp,
            task: $task,
            type: $type,
            status: $status,
            outcome: $outcome
        }')
    
    echo "$completion_record" >> "$TASK_HISTORY_FILE"
    
    echo -e "${GREEN}✅ Core memory updated with task outcome${NC}"
}

# Get current memory state for Claude Core reference
get_core_memory_state() {
    if [ -f "$CCE_MEMORY_FILE" ]; then
        jq '.' "$CCE_MEMORY_FILE"
    else
        echo '{"error": "Core memory not initialized"}'
    fi
}

# Main command handler
main() {
    case "${1:-help}" in
        "init")
            init_core_integration
            ;;
        "consult")
            cce_pre_task_consultation "$2" "$3"
            ;;
        "update")
            post_task_memory_update "$2" "$3" "$4" "$5"
            ;;
        "memory")
            get_core_memory_state
            ;;
        "status")
            echo -e "${CYAN}Claude Code Core CCE Integration Status${NC}"
            echo -e "${BLUE}Memory File: $([ -f "$CCE_MEMORY_FILE" ] && echo "✅ Active" || echo "❌ Missing")${NC}"
            echo -e "${BLUE}Task History: $([ -f "$TASK_HISTORY_FILE" ] && echo "✅ Active ($(wc -l < "$TASK_HISTORY_FILE" 2>/dev/null || echo "0") entries)" || echo "❌ Missing")${NC}"
            echo -e "${BLUE}Integration Log: $([ -f "$CORE_INTEGRATION_LOG" ] && echo "✅ Active" || echo "❌ Missing")${NC}"
            ;;
        *)
            echo "Claude Code Core CCE Integration"
            echo "Usage: $0 {init|consult|update|memory|status}"
            echo ""
            echo "Commands:"
            echo "  init                                    - Initialize core integration"
            echo "  consult <task> [type]                   - CCE consultation before task"
            echo "  update <task> <type> <status> <outcome> - Update memory after task"
            echo "  memory                                  - Show current memory state"
            echo "  status                                  - Show integration status"
            echo ""
            echo "IMPORTANT: Claude Code Core should call 'consult' before EVERY task"
            ;;
    esac
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi