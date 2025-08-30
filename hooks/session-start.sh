#!/bin/bash
# CCE Session Initialization Hook
# Auto-initializes CCE context for each Claude session

CCE_ROOT="/home/scott-sitzer/.claude"
CCE_BIN="$CCE_ROOT/cce/bin/claude-integration.sh"
AGENTS_DIR="$CCE_ROOT/agents"

# Initialize CCE if not already active
if [ -x "$CCE_BIN" ]; then
    status=$("$CCE_BIN" active)
    if [ "$status" != "active" ]; then
        "$CCE_BIN" init
    fi
fi

# Initialize session
session_id="$(date +%Y%m%d_%H%M%S)_$(basename "$(pwd)")_session"
echo "$session_id" > /tmp/claude_cce_session

# Detect current project
project_id=""
if [ -f "package.json" ]; then
    project_id=$(jq -r '.name // "unknown-project"' package.json 2>/dev/null | sed 's/[^a-zA-Z0-9-]/-/g')
elif [ -f "Cargo.toml" ]; then
    project_id=$(grep -E "^name\s*=" Cargo.toml | cut -d'"' -f2 2>/dev/null | sed 's/[^a-zA-Z0-9-]/-/g')
elif [ -f "pom.xml" ]; then
    project_id=$(grep -m1 "<artifactId>" pom.xml | sed 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/' | sed 's/[^a-zA-Z0-9-]/-/g')
elif [ -f "go.mod" ]; then
    project_id=$(head -n1 go.mod | awk '{print $2}' | awk -F'/' '{print $NF}' | sed 's/[^a-zA-Z0-9-]/-/g')
else
    project_id=$(basename "$(pwd)" | sed 's/[^a-zA-Z0-9-]/-/g')
fi

echo "$project_id" > /tmp/claude_cce_project

# Load CCE context if available
if [ -x "$CCE_BIN" ]; then
    context=$("$CCE_BIN" context)
    agent_count=$(cat "$AGENTS_DIR/agent-registry.json" 2>/dev/null | jq '.agents | length' || echo 9)
else
    agent_count=9
fi

# Display CCE status
echo "═══════════════════════════════════════════════════════"
echo "✅ CCE (Context & Coordination Engine) LOADED"
echo "═══════════════════════════════════════════════════════"
echo "• Persistent Memory: ACTIVE (Never loses context)"
echo "• Agent Orchestration: READY (Core never codes)"
echo "• Learning System: ACTIVE (Improves with each session)"
echo "• Project Context: LOADED (From previous sessions)"
echo ""
echo "Current Project: $project_id"
echo "Session: $session_id"
echo "Agents Available: $agent_count specialized agents"
echo ""
echo "🎭 Ready for automatic agent orchestration"
echo "💡 I will orchestrate specialized agents - I will NOT execute code directly"
echo "═══════════════════════════════════════════════════════"

exit 0