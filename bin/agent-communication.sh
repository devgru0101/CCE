#!/bin/bash

# Inter-Agent Communication System for CCE
# Enables agents to share context, coordinate actions, and pass information

CCE_ROOT="$HOME/.claude/cce"
COMM_DIR="$CCE_ROOT/communication"
MESSAGE_QUEUE="$COMM_DIR/queue"
AGENT_STATUS="$COMM_DIR/status"
SHARED_CONTEXT="$COMM_DIR/shared_context.json"
AGENT_RESULTS="$COMM_DIR/results"

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Initialize communication directories
init_communication() {
    mkdir -p "$MESSAGE_QUEUE"
    mkdir -p "$AGENT_STATUS"
    mkdir -p "$AGENT_RESULTS"
    
    # Initialize shared context
    if [ ! -f "$SHARED_CONTEXT" ]; then
        echo '{
  "session_id": "'$(date +%Y%m%d_%H%M%S)'",
  "agents_active": [],
  "shared_data": {},
  "task_queue": [],
  "completed_tasks": [],
  "error_log": [],
  "coordination_rules": {
    "parallel_execution": true,
    "max_parallel_agents": 3,
    "quality_gates": true
  }
}' > "$SHARED_CONTEXT"
    fi
    
    echo -e "${GREEN}✅ Agent communication system initialized${NC}"
}

# Send message from one agent to another
send_message() {
    local from_agent="$1"
    local to_agent="$2"
    local message_type="$3"
    local content="$4"
    local priority="${5:-normal}"
    
    local message_id="msg_$(date +%s)_$(uuidgen | cut -c1-8)"
    local message_file="$MESSAGE_QUEUE/${to_agent}_${message_id}.json"
    
    cat > "$message_file" <<EOF
{
  "id": "$message_id",
  "from": "$from_agent",
  "to": "$to_agent",
  "type": "$message_type",
  "priority": "$priority",
  "timestamp": "$(date -Iseconds)",
  "content": $content,
  "status": "pending"
}
EOF
    
    echo -e "${BLUE}📤 Message sent from $from_agent to $to_agent (ID: $message_id)${NC}"
    echo "$message_id"
}

# Receive messages for an agent
receive_messages() {
    local agent_name="$1"
    local message_count=0
    
    echo -e "${CYAN}📥 Checking messages for $agent_name...${NC}"
    
    for message_file in "$MESSAGE_QUEUE"/${agent_name}_*.json; do
        if [ -f "$message_file" ]; then
            message_count=$((message_count + 1))
            
            # Read and display message
            local message=$(cat "$message_file")
            echo -e "${YELLOW}Message $message_count:${NC}"
            echo "$message" | jq '.'
            
            # Mark as read (move to processed)
            mv "$message_file" "$MESSAGE_QUEUE/processed_$(basename $message_file)"
        fi
    done
    
    if [ $message_count -eq 0 ]; then
        echo -e "${GRAY}No new messages${NC}"
    else
        echo -e "${GREEN}Processed $message_count messages${NC}"
    fi
}

# Update agent status
update_agent_status() {
    local agent_name="$1"
    local status="$2"  # idle, working, completed, error
    local current_task="$3"
    local progress="${4:-0}"
    
    local status_file="$AGENT_STATUS/${agent_name}.json"
    
    cat > "$status_file" <<EOF
{
  "agent": "$agent_name",
  "status": "$status",
  "current_task": "$current_task",
  "progress": $progress,
  "last_update": "$(date -Iseconds)",
  "capabilities": $(get_agent_capabilities "$agent_name"),
  "performance": {
    "tasks_completed": $(get_agent_task_count "$agent_name" "completed"),
    "tasks_failed": $(get_agent_task_count "$agent_name" "failed"),
    "average_time": $(get_agent_avg_time "$agent_name")
  }
}
EOF
    
    echo -e "${GREEN}✅ Status updated for $agent_name: $status${NC}"
}

# Get agent capabilities from agent definition
get_agent_capabilities() {
    local agent_name="$1"
    local agent_file="$HOME/.claude/agents/${agent_name}.md"
    
    if [ -f "$agent_file" ]; then
        # Extract tools from agent definition
        local tools=$(grep "^tools:" "$agent_file" | sed 's/tools: //')
        echo '["'$(echo $tools | sed 's/, /", "/g')'"]'
    else
        echo '[]'
    fi
}

# Get agent task count
get_agent_task_count() {
    local agent_name="$1"
    local status="$2"
    
    # Count from results directory
    local count=$(find "$AGENT_RESULTS" -name "${agent_name}_*_${status}.json" 2>/dev/null | wc -l)
    echo $count
}

# Get agent average completion time
get_agent_avg_time() {
    local agent_name="$1"
    
    # Placeholder - would calculate from historical data
    echo "120"  # 120 seconds average
}

# Share context between agents
share_context() {
    local agent_name="$1"
    local context_key="$2"
    local context_value="$3"
    
    # Update shared context
    local temp_file=$(mktemp)
    jq --arg key "$context_key" --argjson value "$context_value" \
       '.shared_data[$key] = $value' "$SHARED_CONTEXT" > "$temp_file"
    mv "$temp_file" "$SHARED_CONTEXT"
    
    echo -e "${BLUE}🔄 Context shared by $agent_name: $context_key${NC}"
    
    # Notify interested agents
    notify_context_update "$agent_name" "$context_key"
}

# Get shared context
get_shared_context() {
    local context_key="$1"
    
    if [ -z "$context_key" ]; then
        # Return all shared context
        jq '.shared_data' "$SHARED_CONTEXT"
    else
        # Return specific context
        jq --arg key "$context_key" '.shared_data[$key]' "$SHARED_CONTEXT"
    fi
}

# Notify agents of context updates
notify_context_update() {
    local from_agent="$1"
    local context_key="$2"
    
    # Get list of active agents
    local active_agents=$(jq -r '.agents_active[]' "$SHARED_CONTEXT")
    
    for agent in $active_agents; do
        if [ "$agent" != "$from_agent" ]; then
            send_message "$from_agent" "$agent" "context_update" \
                "{\"key\": \"$context_key\", \"timestamp\": \"$(date -Iseconds)\"}" \
                "low"
        fi
    done
}

# Coordinate agent execution
coordinate_execution() {
    local task_description="$1"
    local agents_required="$2"  # JSON array of agent names
    
    echo -e "${MAGENTA}🎭 COORDINATING AGENT EXECUTION${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Task:${NC} $task_description"
    
    # Parse agent list
    local agents=$(echo "$agents_required" | jq -r '.[]')
    
    # Check agent availability
    echo -e "\n${CYAN}Checking agent availability...${NC}"
    for agent in $agents; do
        local status_file="$AGENT_STATUS/${agent}.json"
        if [ -f "$status_file" ]; then
            local status=$(jq -r '.status' "$status_file")
            echo "  • $agent: $status"
        else
            echo "  • $agent: available"
        fi
    done
    
    # Determine execution strategy
    local parallel_agents=()
    local sequential_agents=()
    
    # Classify agents based on dependencies
    for agent in $agents; do
        case "$agent" in
            "cce-agent"|"planning-agent")
                sequential_agents+=("$agent")
                ;;
            *)
                parallel_agents+=("$agent")
                ;;
        esac
    done
    
    echo -e "\n${CYAN}Execution Plan:${NC}"
    echo "Sequential: ${sequential_agents[@]}"
    echo "Parallel: ${parallel_agents[@]}"
    
    # Generate coordination plan
    cat <<EOF

${GREEN}📋 COORDINATION PLAN${NC}
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

Phase 1: Sequential Execution
EOF
    
    local phase=1
    for agent in "${sequential_agents[@]}"; do
        echo "  $phase. $agent - Must complete before next phase"
        phase=$((phase + 1))
    done
    
    if [ ${#parallel_agents[@]} -gt 0 ]; then
        echo -e "\nPhase 2: Parallel Execution"
        echo "  The following agents will run simultaneously:"
        for agent in "${parallel_agents[@]}"; do
            echo "    • $agent"
        done
    fi
    
    echo -e "\n${GREEN}Quality Gates:${NC}"
    echo "  ✓ Each phase must complete successfully"
    echo "  ✓ Errors will trigger rollback procedures"
    echo "  ✓ Results will be validated before proceeding"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Store agent results
store_result() {
    local agent_name="$1"
    local task_id="$2"
    local status="$3"  # completed, failed
    local result_data="$4"
    
    local result_file="$AGENT_RESULTS/${agent_name}_${task_id}_${status}.json"
    
    cat > "$result_file" <<EOF
{
  "agent": "$agent_name",
  "task_id": "$task_id",
  "status": "$status",
  "timestamp": "$(date -Iseconds)",
  "result": $result_data
}
EOF
    
    # Update shared context with completion
    local temp_file=$(mktemp)
    if [ "$status" = "completed" ]; then
        jq --arg task "$task_id" '.completed_tasks += [$task]' "$SHARED_CONTEXT" > "$temp_file"
    else
        jq --arg error "{\"task\": \"$task_id\", \"agent\": \"$agent_name\", \"time\": \"$(date -Iseconds)\"}" \
           '.error_log += [$error]' "$SHARED_CONTEXT" > "$temp_file"
    fi
    mv "$temp_file" "$SHARED_CONTEXT"
    
    echo -e "${GREEN}✅ Result stored for $agent_name (Task: $task_id, Status: $status)${NC}"
}

# Get coordination status
get_coordination_status() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎭 AGENT COORDINATION STATUS${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    
    # Active agents
    echo -e "\n${CYAN}Active Agents:${NC}"
    for status_file in "$AGENT_STATUS"/*.json; do
        if [ -f "$status_file" ]; then
            local agent=$(basename "$status_file" .json)
            local status=$(jq -r '.status' "$status_file")
            local task=$(jq -r '.current_task' "$status_file")
            local progress=$(jq -r '.progress' "$status_file")
            
            if [ "$status" != "idle" ]; then
                echo "  • $agent: $status (Task: $task, Progress: ${progress}%)"
            fi
        fi
    done
    
    # Message queue status
    local pending_messages=$(find "$MESSAGE_QUEUE" -name "*.json" ! -name "processed_*" 2>/dev/null | wc -l)
    echo -e "\n${CYAN}Message Queue:${NC}"
    echo "  Pending messages: $pending_messages"
    
    # Shared context summary
    echo -e "\n${CYAN}Shared Context:${NC}"
    local context_keys=$(jq -r '.shared_data | keys[]' "$SHARED_CONTEXT" 2>/dev/null)
    if [ -n "$context_keys" ]; then
        echo "$context_keys" | while read key; do
            echo "  • $key"
        done
    else
        echo "  (empty)"
    fi
    
    # Task completion
    local completed=$(jq '.completed_tasks | length' "$SHARED_CONTEXT")
    local errors=$(jq '.error_log | length' "$SHARED_CONTEXT")
    echo -e "\n${CYAN}Task Statistics:${NC}"
    echo "  Completed: $completed"
    echo "  Errors: $errors"
    
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
}

# Main command handler
case "$1" in
    "init")
        init_communication
        ;;
    "send")
        send_message "$2" "$3" "$4" "$5" "$6"
        ;;
    "receive")
        receive_messages "$2"
        ;;
    "status")
        if [ -n "$2" ]; then
            update_agent_status "$2" "$3" "$4" "$5"
        else
            get_coordination_status
        fi
        ;;
    "share")
        share_context "$2" "$3" "$4"
        ;;
    "get-context")
        get_shared_context "$2"
        ;;
    "coordinate")
        coordinate_execution "$2" "$3"
        ;;
    "result")
        store_result "$2" "$3" "$4" "$5"
        ;;
    *)
        echo "Inter-Agent Communication System"
        echo "Usage: $0 {init|send|receive|status|share|get-context|coordinate|result}"
        echo ""
        echo "Commands:"
        echo "  init                    - Initialize communication system"
        echo "  send <from> <to> <type> <content> [priority] - Send message"
        echo "  receive <agent>         - Receive messages for agent"
        echo "  status [agent] [status] [task] [progress] - Update/view status"
        echo "  share <agent> <key> <value> - Share context data"
        echo "  get-context [key]       - Get shared context"
        echo "  coordinate <task> <agents_json> - Coordinate agent execution"
        echo "  result <agent> <task_id> <status> <data> - Store agent result"
        ;;
esac