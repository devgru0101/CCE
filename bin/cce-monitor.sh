#!/bin/bash

# CCE Continuous Monitoring System
# Real-time monitoring of CCE system health and performance

CCE_ROOT="$HOME/.claude/cce"
MONITOR_DIR="$CCE_ROOT/monitoring"
HEALTH_LOG="$MONITOR_DIR/health.log"
PID_FILE="$MONITOR_DIR/monitor.pid"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Initialize monitoring
init_monitoring() {
    mkdir -p "$MONITOR_DIR"
    
    # Create health log
    cat > "$HEALTH_LOG" <<EOF
CCE System Health Monitor
========================
Started: $(date -Iseconds)

EOF
    
    echo -e "${GREEN}🔍 CCE Monitoring System Initialized${NC}"
    echo -e "${BLUE}Health Log: $HEALTH_LOG${NC}"
}

# Check CCE component health
check_component_health() {
    local timestamp=$(date -Iseconds)
    local health_score=0
    local max_score=10
    
    echo "[$timestamp] Health Check Started" >> "$HEALTH_LOG"
    
    # Check core files
    if [ -f "$CCE_ROOT/bin/claude-integration.sh" ]; then
        health_score=$((health_score + 1))
    else
        echo "[$timestamp] WARNING: claude-integration.sh missing" >> "$HEALTH_LOG"
    fi
    
    if [ -f "$CCE_ROOT/bin/cce-orchestrator.sh" ]; then
        health_score=$((health_score + 1))
    else
        echo "[$timestamp] WARNING: cce-orchestrator.sh missing" >> "$HEALTH_LOG"
    fi
    
    # Check enhanced agents
    if [ -f "$HOME/.claude/agents/cce-agent-enhanced.md" ]; then
        health_score=$((health_score + 1))
    else
        echo "[$timestamp] WARNING: cce-agent-enhanced.md missing" >> "$HEALTH_LOG"
    fi
    
    if [ -f "$HOME/.claude/agents/planning-agent-enhanced.md" ]; then
        health_score=$((health_score + 1))
    else
        echo "[$timestamp] WARNING: planning-agent-enhanced.md missing" >> "$HEALTH_LOG"
    fi
    
    # Check supporting tools
    if [ -f "$CCE_ROOT/bin/error-collector.js" ]; then
        health_score=$((health_score + 1))
    fi
    
    if [ -f "$CCE_ROOT/bin/learning-processor.py" ]; then
        health_score=$((health_score + 1))
    fi
    
    if [ -f "$CCE_ROOT/bin/agent-communication.sh" ]; then
        health_score=$((health_score + 1))
    fi
    
    # Check context collection
    if [ -f "$CCE_ROOT/context/current.json" ]; then
        local context_size=$(stat -c%s "$CCE_ROOT/context/current.json" 2>/dev/null || echo "0")
        if [ "$context_size" -gt 50 ]; then
            health_score=$((health_score + 1))
        fi
    fi
    
    # Check learning data
    local learning_files=$(find "$HOME/.claude/projects" -name "*.jsonl" 2>/dev/null | wc -l)
    if [ "$learning_files" -gt 0 ]; then
        health_score=$((health_score + 1))
    fi
    
    # Check communication system
    if [ -d "$CCE_ROOT/communication" ]; then
        health_score=$((health_score + 1))
    fi
    
    # Calculate health percentage
    local health_percent=$(echo "scale=0; $health_score * 100 / $max_score" | bc 2>/dev/null || echo "0")
    
    echo "[$timestamp] Health Score: $health_score/$max_score ($health_percent%)" >> "$HEALTH_LOG"
    
    # Return health status
    if [ $health_percent -ge 90 ]; then
        echo "healthy"
    elif [ $health_percent -ge 70 ]; then
        echo "warning"
    else
        echo "critical"
    fi
}

# Monitor performance metrics
monitor_performance() {
    local timestamp=$(date -Iseconds)
    
    # Monitor context collection performance
    local start_time=$(date +%s.%N)
    "$CCE_ROOT/bin/claude-integration.sh" context >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local context_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
    
    echo "[$timestamp] Context Collection Time: ${context_time}s" >> "$HEALTH_LOG"
    
    # Monitor system resources
    local memory_usage=$(ps aux | awk '/claude/ {sum += $6} END {print sum/1024}' 2>/dev/null || echo "0")
    local cpu_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    
    echo "[$timestamp] Memory Usage: ${memory_usage}MB" >> "$HEALTH_LOG"
    echo "[$timestamp] CPU Load: $cpu_load" >> "$HEALTH_LOG"
    
    # Check disk space
    local disk_usage=$(df -h "$CCE_ROOT" | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "[$timestamp] Disk Usage: ${disk_usage}%" >> "$HEALTH_LOG"
}

# Monitor learning system activity
monitor_learning() {
    local timestamp=$(date -Iseconds)
    
    # Check recent learning activity
    local recent_jsonl=$(find "$HOME/.claude/projects" -name "*.jsonl" -mtime -1 2>/dev/null | wc -l)
    echo "[$timestamp] Recent Learning Files (24h): $recent_jsonl" >> "$HEALTH_LOG"
    
    # Check learning data size
    local total_learning_size=$(du -sh "$HOME/.claude/projects" 2>/dev/null | awk '{print $1}' || echo "0")
    echo "[$timestamp] Total Learning Data: $total_learning_size" >> "$HEALTH_LOG"
    
    # Check if learning processor is working
    if command -v python3 >/dev/null 2>&1; then
        local learning_status=$(python3 "$CCE_ROOT/bin/learning-processor.py" summary 2>&1 | head -1)
        echo "[$timestamp] Learning Processor Status: $learning_status" >> "$HEALTH_LOG"
    fi
}

# Real-time dashboard display
show_dashboard() {
    clear
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎯 CCE SYSTEM HEALTH DASHBOARD${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    
    local health_status=$(check_component_health)
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "\n${BLUE}⏰ Last Updated: $timestamp${NC}"
    
    # System health indicator
    case "$health_status" in
        "healthy")
            echo -e "\n${GREEN}🟢 SYSTEM STATUS: HEALTHY${NC}"
            echo -e "${GREEN}   All components operational${NC}"
            ;;
        "warning")
            echo -e "\n${YELLOW}🟡 SYSTEM STATUS: WARNING${NC}"
            echo -e "${YELLOW}   Some issues detected${NC}"
            ;;
        "critical")
            echo -e "\n${RED}🔴 SYSTEM STATUS: CRITICAL${NC}"
            echo -e "${RED}   Multiple failures detected${NC}"
            ;;
    esac
    
    # Core components status
    echo -e "\n${CYAN}📊 CORE COMPONENTS:${NC}"
    [ -f "$CCE_ROOT/bin/claude-integration.sh" ] && echo -e "  ${GREEN}✅${NC} CCE Integration" || echo -e "  ${RED}❌${NC} CCE Integration"
    [ -f "$CCE_ROOT/bin/cce-orchestrator.sh" ] && echo -e "  ${GREEN}✅${NC} CCE Orchestrator" || echo -e "  ${RED}❌${NC} CCE Orchestrator"
    [ -f "$CCE_ROOT/bin/error-collector.js" ] && echo -e "  ${GREEN}✅${NC} Error Collector" || echo -e "  ${RED}❌${NC} Error Collector"
    [ -f "$CCE_ROOT/bin/learning-processor.py" ] && echo -e "  ${GREEN}✅${NC} Learning Processor" || echo -e "  ${RED}❌${NC} Learning Processor"
    [ -f "$CCE_ROOT/bin/agent-communication.sh" ] && echo -e "  ${GREEN}✅${NC} Agent Communication" || echo -e "  ${RED}❌${NC} Agent Communication"
    
    # Enhanced agents status
    echo -e "\n${CYAN}🤖 ENHANCED AGENTS:${NC}"
    [ -f "$HOME/.claude/agents/cce-agent-enhanced.md" ] && echo -e "  ${GREEN}✅${NC} CCE Agent Enhanced" || echo -e "  ${RED}❌${NC} CCE Agent Enhanced"
    [ -f "$HOME/.claude/agents/planning-agent-enhanced.md" ] && echo -e "  ${GREEN}✅${NC} Planning Agent Enhanced" || echo -e "  ${RED}❌${NC} Planning Agent Enhanced"
    
    # Active monitoring info
    echo -e "\n${CYAN}📈 MONITORING:${NC}"
    if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
        echo -e "  ${GREEN}✅${NC} Background Monitor Running (PID: $(cat $PID_FILE))"
    else
        echo -e "  ${YELLOW}⚠️${NC}  Background Monitor Stopped"
    fi
    
    # Learning system status
    local learning_files=$(find "$HOME/.claude/projects" -name "*.jsonl" 2>/dev/null | wc -l)
    local learning_size=$(du -sh "$HOME/.claude/projects" 2>/dev/null | awk '{print $1}' || echo "0")
    echo -e "\n${CYAN}🧠 LEARNING SYSTEM:${NC}"
    echo -e "  ${GREEN}📁${NC} Learning Files: $learning_files"
    echo -e "  ${GREEN}💾${NC} Learning Data Size: $learning_size"
    
    # Context status
    if [ -f "$CCE_ROOT/context/current.json" ]; then
        local context_size=$(stat -c%s "$CCE_ROOT/context/current.json" 2>/dev/null || echo "0")
        local context_kb=$(echo "scale=1; $context_size / 1024" | bc 2>/dev/null || echo "0")
        echo -e "\n${CYAN}🔍 CONTEXT:${NC}"
        echo -e "  ${GREEN}📋${NC} Context Size: ${context_kb}KB"
        echo -e "  ${GREEN}⏱️${NC}  Last Updated: $(stat -c %y "$CCE_ROOT/context/current.json" 2>/dev/null | cut -d'.' -f1 || echo "Unknown")"
    fi
    
    # Quick actions
    echo -e "\n${YELLOW}⚡ QUICK ACTIONS:${NC}"
    echo -e "  ${BLUE}1${NC} - Run full validation test"
    echo -e "  ${BLUE}2${NC} - Check recent health logs"
    echo -e "  ${BLUE}3${NC} - Start/stop background monitoring"
    echo -e "  ${BLUE}q${NC} - Quit dashboard"
    
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════${NC}"
}

# Background monitoring daemon
start_daemon() {
    if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Background monitor already running (PID: $(cat $PID_FILE))${NC}"
        return 1
    fi
    
    init_monitoring
    
    # Start background process
    (
        echo $$ > "$PID_FILE"
        while true; do
            check_component_health >/dev/null
            monitor_performance
            monitor_learning
            sleep 300  # Check every 5 minutes
        done
    ) &
    
    echo -e "${GREEN}✅ Background monitoring started${NC}"
    echo -e "${BLUE}PID: $(cat $PID_FILE)${NC}"
}

# Stop background monitoring
stop_daemon() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo -e "${GREEN}✅ Background monitoring stopped${NC}"
        else
            echo -e "${YELLOW}⚠️  Background monitor was not running${NC}"
        fi
        rm -f "$PID_FILE"
    else
        echo -e "${YELLOW}⚠️  No background monitor PID file found${NC}"
    fi
}

# Interactive dashboard
interactive_dashboard() {
    while true; do
        show_dashboard
        read -p "Enter action (1-3, q): " -n 1 action
        
        case "$action" in
            "1")
                clear
                echo -e "${YELLOW}🧪 Running full validation test...${NC}"
                "$CCE_ROOT/bin/cce-validator.sh" full
                echo -e "\n${BLUE}Press any key to continue...${NC}"
                read -n 1
                ;;
            "2")
                clear
                echo -e "${YELLOW}📋 Recent health logs:${NC}"
                echo -e "${MAGENTA}════════════════════════${NC}"
                tail -20 "$HEALTH_LOG" 2>/dev/null || echo "No health logs found"
                echo -e "${MAGENTA}════════════════════════${NC}"
                echo -e "\n${BLUE}Press any key to continue...${NC}"
                read -n 1
                ;;
            "3")
                clear
                if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
                    stop_daemon
                else
                    start_daemon
                fi
                echo -e "\n${BLUE}Press any key to continue...${NC}"
                read -n 1
                ;;
            "q"|"Q")
                clear
                echo -e "${GREEN}👋 CCE Dashboard closed${NC}"
                break
                ;;
            *)
                ;;
        esac
    done
}

# Main command handler
main() {
    case "${1:-dashboard}" in
        "start")
            start_daemon
            ;;
        "stop")
            stop_daemon
            ;;
        "status")
            health_status=$(check_component_health)
            echo "CCE System Status: $health_status"
            ;;
        "dashboard")
            interactive_dashboard
            ;;
        "check")
            show_dashboard
            ;;
        "logs")
            if [ -f "$HEALTH_LOG" ]; then
                tail -f "$HEALTH_LOG"
            else
                echo "No health logs found. Run 'start' first."
            fi
            ;;
        *)
            echo "CCE Monitoring System"
            echo "Usage: $0 {start|stop|status|dashboard|check|logs}"
            echo ""
            echo "Commands:"
            echo "  start     - Start background monitoring daemon"
            echo "  stop      - Stop background monitoring daemon"
            echo "  status    - Show current system status"
            echo "  dashboard - Show interactive dashboard (default)"
            echo "  check     - Show status once and exit"
            echo "  logs      - Follow health logs in real-time"
            ;;
    esac
}

# Cleanup function
cleanup() {
    if [ -f "$PID_FILE" ]; then
        stop_daemon
    fi
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi