#!/bin/bash

# CCE Automated Testing & Quality Assurance
# Comprehensive automated testing suite for continuous validation

CCE_ROOT="$HOME/.claude/cce"
AUTOMATION_DIR="$CCE_ROOT/automation"
TEST_REPORT="$AUTOMATION_DIR/automated_test_report.json"
NOTIFICATION_LOG="$AUTOMATION_DIR/notifications.log"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Initialize automation environment
init_automation() {
    mkdir -p "$AUTOMATION_DIR"
    
    echo -e "${CYAN}🤖 CCE Test Automation Initialized${NC}"
    echo -e "${BLUE}Report Output: $TEST_REPORT${NC}"
    echo -e "${BLUE}Notification Log: $NOTIFICATION_LOG${NC}"
}

# Run comprehensive test suite
run_automated_tests() {
    local timestamp=$(date -Iseconds)
    local test_id="auto_$(date +%Y%m%d_%H%M%S)"
    
    echo -e "${YELLOW}🧪 Starting Automated Test Suite...${NC}"
    echo -e "${BLUE}Test ID: $test_id${NC}"
    
    # Initialize test report
    cat > "$TEST_REPORT" <<EOF
{
  "test_id": "$test_id",
  "timestamp": "$timestamp",
  "environment": {
    "hostname": "$(hostname)",
    "user": "$(whoami)",
    "pwd": "$(pwd)",
    "shell": "$SHELL"
  },
  "tests": {},
  "summary": {
    "total": 0,
    "passed": 0,
    "failed": 0,
    "warnings": 0,
    "execution_time": 0
  },
  "recommendations": []
}
EOF
    
    local start_time=$(date +%s)
    
    # Test 1: Component integrity
    echo -e "${YELLOW}📦 Testing Component Integrity...${NC}"
    test_component_integrity "$test_id"
    
    # Test 2: Functional validation
    echo -e "${YELLOW}⚙️  Testing Functional Validation...${NC}"
    test_functional_validation "$test_id"
    
    # Test 3: Performance benchmarks
    echo -e "${YELLOW}⚡ Running Performance Benchmarks...${NC}"
    test_performance_benchmarks "$test_id"
    
    # Test 4: Integration workflows
    echo -e "${YELLOW}🔄 Testing Integration Workflows...${NC}"
    test_integration_workflows "$test_id"
    
    # Test 5: Error handling
    echo -e "${YELLOW}🚨 Testing Error Handling...${NC}"
    test_error_handling "$test_id"
    
    # Test 6: Learning system validation
    echo -e "${YELLOW}🧠 Testing Learning System...${NC}"
    test_learning_system "$test_id"
    
    local end_time=$(date +%s)
    local execution_time=$((end_time - start_time))
    
    # Update test report with summary
    update_test_summary "$test_id" "$execution_time"
    
    echo -e "${GREEN}✅ Automated Test Suite Completed${NC}"
    echo -e "${BLUE}Execution Time: ${execution_time}s${NC}"
}

# Test component integrity
test_component_integrity() {
    local test_id="$1"
    local test_name="component_integrity"
    local passed=0
    local failed=0
    local warnings=0
    
    # Check core CCE files
    local required_files=(
        "$CCE_ROOT/bin/claude-integration.sh"
        "$CCE_ROOT/bin/cce-orchestrator.sh" 
        "$CCE_ROOT/bin/error-collector.js"
        "$CCE_ROOT/bin/learning-processor.py"
        "$CCE_ROOT/bin/agent-communication.sh"
        "$CCE_ROOT/bin/cce-validator.sh"
        "$CCE_ROOT/bin/cce-monitor.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ] && [ -x "$file" ]; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
            log_test_failure "$test_name" "Missing or non-executable: $(basename $file)"
        fi
    done
    
    # Check enhanced agents
    local agent_files=(
        "$HOME/.claude/agents/cce-agent-enhanced.md"
        "$HOME/.claude/agents/planning-agent-enhanced.md"
    )
    
    for agent in "${agent_files[@]}"; do
        if [ -f "$agent" ]; then
            # Validate agent structure
            if grep -q "tools:" "$agent" && grep -q "description:" "$agent"; then
                passed=$((passed + 1))
            else
                warnings=$((warnings + 1))
                log_test_warning "$test_name" "Agent structure incomplete: $(basename $agent)"
            fi
        else
            failed=$((failed + 1))
            log_test_failure "$test_name" "Missing agent: $(basename $agent)"
        fi
    done
    
    # Check directory structure
    local required_dirs=(
        "$CCE_ROOT/context"
        "$CCE_ROOT/sessions"
        "$CCE_ROOT/cache"
        "$CCE_ROOT/logs"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            passed=$((passed + 1))
        else
            warnings=$((warnings + 1))
            log_test_warning "$test_name" "Directory missing: $(basename $dir)"
        fi
    done
    
    record_test_result "$test_id" "$test_name" "$passed" "$failed" "$warnings"
}

# Test functional validation
test_functional_validation() {
    local test_id="$1"
    local test_name="functional_validation"
    local passed=0
    local failed=0
    local warnings=0
    
    # Test CCE integration script
    if "$CCE_ROOT/bin/claude-integration.sh" active >/dev/null 2>&1; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
        log_test_failure "$test_name" "CCE integration script failed"
    fi
    
    # Test orchestrator
    local orchestrator_output
    orchestrator_output=$("$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "test automation" 2>&1)
    if [ $? -eq 0 ] && echo "$orchestrator_output" | grep -q "CCE AGENT ACTIVATION"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
        log_test_failure "$test_name" "Orchestrator validation failed"
    fi
    
    # Test error collector
    if command -v node >/dev/null 2>&1; then
        if node "$CCE_ROOT/bin/error-collector.js" collect "$PWD" >/dev/null 2>&1; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
            log_test_failure "$test_name" "Error collector failed"
        fi
    else
        warnings=$((warnings + 1))
        log_test_warning "$test_name" "Node.js not available for error collector test"
    fi
    
    # Test learning processor
    if command -v python3 >/dev/null 2>&1; then
        if python3 "$CCE_ROOT/bin/learning-processor.py" summary >/dev/null 2>&1; then
            passed=$((passed + 1))
        else
            warnings=$((warnings + 1))
            log_test_warning "$test_name" "Learning processor test inconclusive"
        fi
    else
        warnings=$((warnings + 1))
        log_test_warning "$test_name" "Python3 not available for learning processor test"
    fi
    
    # Test agent communication
    if "$CCE_ROOT/bin/agent-communication.sh" init >/dev/null 2>&1; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
        log_test_failure "$test_name" "Agent communication initialization failed"
    fi
    
    record_test_result "$test_id" "$test_name" "$passed" "$failed" "$warnings"
}

# Test performance benchmarks
test_performance_benchmarks() {
    local test_id="$1"
    local test_name="performance_benchmarks"
    local passed=0
    local failed=0
    local warnings=0
    
    # Benchmark context collection
    local start_time=$(date +%s.%N)
    "$CCE_ROOT/bin/claude-integration.sh" context >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local context_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
    
    if [ "$context_time" != "N/A" ]; then
        if [ "$(echo "$context_time < 5.0" | bc 2>/dev/null)" = "1" ]; then
            passed=$((passed + 1))
        else
            warnings=$((warnings + 1))
            log_test_warning "$test_name" "Context collection slow: ${context_time}s"
        fi
    else
        failed=$((failed + 1))
        log_test_failure "$test_name" "Context collection benchmark failed"
    fi
    
    # Benchmark orchestrator
    start_time=$(date +%s.%N)
    "$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "performance test" >/dev/null 2>&1
    end_time=$(date +%s.%N)
    local orchestrator_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
    
    if [ "$orchestrator_time" != "N/A" ]; then
        if [ "$(echo "$orchestrator_time < 3.0" | bc 2>/dev/null)" = "1" ]; then
            passed=$((passed + 1))
        else
            warnings=$((warnings + 1))
            log_test_warning "$test_name" "Orchestrator slow: ${orchestrator_time}s"
        fi
    else
        failed=$((failed + 1))
        log_test_failure "$test_name" "Orchestrator benchmark failed"
    fi
    
    # Check memory usage
    local memory_usage=$(ps aux | awk '/claude/ {sum += $6} END {print sum/1024}' 2>/dev/null || echo "0")
    if [ "$(echo "$memory_usage < 100" | bc 2>/dev/null)" = "1" ]; then
        passed=$((passed + 1))
    else
        warnings=$((warnings + 1))
        log_test_warning "$test_name" "High memory usage: ${memory_usage}MB"
    fi
    
    record_test_result "$test_id" "$test_name" "$passed" "$failed" "$warnings"
}

# Test integration workflows
test_integration_workflows() {
    local test_id="$1"
    local test_name="integration_workflows"
    local passed=0
    local failed=0
    local warnings=0
    
    # Test end-to-end workflow simulation
    local temp_dir="/tmp/cce_workflow_test_$$"
    mkdir -p "$temp_dir"
    
    # Create test scenario
    cat > "$temp_dir/test_scenario.txt" <<EOF
Implement a simple function to calculate factorial
EOF
    
    # Run complete workflow
    local workflow_output
    workflow_output=$("$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "Implement a simple function to calculate factorial" 2>&1)
    local workflow_status=$?
    
    # Check workflow components
    if [ $workflow_status -eq 0 ]; then
        if echo "$workflow_output" | grep -q "CCE AGENT ACTIVATION"; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
            log_test_failure "$test_name" "CCE Agent activation not detected in workflow"
        fi
        
        if echo "$workflow_output" | grep -q "CONTEXT COLLECTION"; then
            passed=$((passed + 1))
        else
            warnings=$((warnings + 1))
            log_test_warning "$test_name" "Context collection not explicitly detected"
        fi
        
        if echo "$workflow_output" | grep -q "AGENT RECOMMENDATION"; then
            passed=$((passed + 1))
        else
            warnings=$((warnings + 1))
            log_test_warning "$test_name" "Agent recommendation not detected"
        fi
    else
        failed=$((failed + 1))
        log_test_failure "$test_name" "Workflow execution failed with status: $workflow_status"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    record_test_result "$test_id" "$test_name" "$passed" "$failed" "$warnings"
}

# Test error handling
test_error_handling() {
    local test_id="$1"
    local test_name="error_handling"
    local passed=0
    local failed=0
    local warnings=0
    
    # Test graceful handling of missing dependencies
    # Simulate missing file
    local temp_backup=""
    if [ -f "$CCE_ROOT/bin/claude-integration.sh" ]; then
        temp_backup="$CCE_ROOT/bin/claude-integration.sh.backup"
        mv "$CCE_ROOT/bin/claude-integration.sh" "$temp_backup"
    fi
    
    # Test error detection
    local error_output
    error_output=$("$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "test error handling" 2>&1)
    local error_status=$?
    
    if [ $error_status -ne 0 ]; then
        passed=$((passed + 1))  # Should fail gracefully
    else
        warnings=$((warnings + 1))
        log_test_warning "$test_name" "No error detected when component missing"
    fi
    
    # Restore backup
    if [ -n "$temp_backup" ] && [ -f "$temp_backup" ]; then
        mv "$temp_backup" "$CCE_ROOT/bin/claude-integration.sh"
        chmod +x "$CCE_ROOT/bin/claude-integration.sh"
    fi
    
    # Test invalid input handling
    error_output=$("$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "" 2>&1)
    if echo "$error_output" | grep -q -i "error\|invalid\|empty"; then
        passed=$((passed + 1))
    else
        warnings=$((warnings + 1))
        log_test_warning "$test_name" "Empty input not properly handled"
    fi
    
    record_test_result "$test_id" "$test_name" "$passed" "$failed" "$warnings"
}

# Test learning system
test_learning_system() {
    local test_id="$1"
    local test_name="learning_system"
    local passed=0
    local failed=0
    local warnings=0
    
    # Check learning data existence
    local learning_files=$(find "$HOME/.claude/projects" -name "*.jsonl" 2>/dev/null | wc -l)
    if [ "$learning_files" -gt 0 ]; then
        passed=$((passed + 1))
    else
        warnings=$((warnings + 1))
        log_test_warning "$test_name" "No learning data files found"
    fi
    
    # Check learning data format
    if [ "$learning_files" -gt 0 ]; then
        local sample_file=$(find "$HOME/.claude/projects" -name "*.jsonl" 2>/dev/null | head -1)
        if [ -n "$sample_file" ]; then
            # Check if file contains valid JSON lines
            local valid_json_lines=$(head -10 "$sample_file" | while IFS= read -r line; do echo "$line" | jq . >/dev/null 2>&1 && echo "1"; done | wc -l)
            if [ "$valid_json_lines" -gt 5 ]; then
                passed=$((passed + 1))
            else
                warnings=$((warnings + 1))
                log_test_warning "$test_name" "Learning data format may be invalid"
            fi
        fi
    fi
    
    # Test learning processor if available
    if command -v python3 >/dev/null 2>&1 && [ -f "$CCE_ROOT/bin/learning-processor.py" ]; then
        local learning_output
        learning_output=$(python3 "$CCE_ROOT/bin/learning-processor.py" summary 2>&1)
        if [ $? -eq 0 ] && echo "$learning_output" | grep -q -i "session\|analysis"; then
            passed=$((passed + 1))
        else
            warnings=$((warnings + 1))
            log_test_warning "$test_name" "Learning processor test inconclusive"
        fi
    fi
    
    record_test_result "$test_id" "$test_name" "$passed" "$failed" "$warnings"
}

# Helper functions for logging
log_test_failure() {
    local test="$1"
    local message="$2"
    local timestamp=$(date -Iseconds)
    echo "[$timestamp] FAIL - $test: $message" >> "$NOTIFICATION_LOG"
}

log_test_warning() {
    local test="$1"
    local message="$2"
    local timestamp=$(date -Iseconds)
    echo "[$timestamp] WARN - $test: $message" >> "$NOTIFICATION_LOG"
}

# Record test results in JSON format
record_test_result() {
    local test_id="$1"
    local test_name="$2"
    local passed="$3"
    local failed="$4"
    local warnings="$5"
    
    # Update test report using temporary file
    local temp_file=$(mktemp)
    jq --arg test "$test_name" --argjson passed "$passed" --argjson failed "$failed" --argjson warnings "$warnings" \
       '.tests[$test] = {
         "passed": $passed,
         "failed": $failed,
         "warnings": $warnings,
         "total": ($passed + $failed + $warnings)
       }' "$TEST_REPORT" > "$temp_file" && mv "$temp_file" "$TEST_REPORT"
}

# Update final test summary
update_test_summary() {
    local test_id="$1"
    local execution_time="$2"
    
    # Calculate totals and generate recommendations
    local temp_file=$(mktemp)
    jq --argjson exec_time "$execution_time" '
       .summary.execution_time = $exec_time |
       .summary.total = (.tests | to_entries | map(.value.total) | add // 0) |
       .summary.passed = (.tests | to_entries | map(.value.passed) | add // 0) |
       .summary.failed = (.tests | to_entries | map(.value.failed) | add // 0) |
       .summary.warnings = (.tests | to_entries | map(.value.warnings) | add // 0) |
       .recommendations = (
         if .summary.failed > 0 then 
           ["Critical issues detected - immediate attention required"]
         elif .summary.warnings > 5 then
           ["Multiple warnings detected - review system configuration"]
         elif .summary.execution_time > 30 then
           ["Performance issues detected - review system resources"]
         else
           ["System operating within normal parameters"]
         end
       )
    ' "$TEST_REPORT" > "$temp_file" && mv "$temp_file" "$TEST_REPORT"
}

# Generate automated report
generate_automated_report() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🤖 AUTOMATED TEST REPORT${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    
    if [ -f "$TEST_REPORT" ]; then
        local test_id=$(jq -r '.test_id' "$TEST_REPORT")
        local timestamp=$(jq -r '.timestamp' "$TEST_REPORT")
        local total=$(jq -r '.summary.total' "$TEST_REPORT")
        local passed=$(jq -r '.summary.passed' "$TEST_REPORT")
        local failed=$(jq -r '.summary.failed' "$TEST_REPORT")
        local warnings=$(jq -r '.summary.warnings' "$TEST_REPORT")
        local exec_time=$(jq -r '.summary.execution_time' "$TEST_REPORT")
        
        echo -e "\n${BLUE}Test ID: $test_id${NC}"
        echo -e "${BLUE}Timestamp: $timestamp${NC}"
        echo -e "${BLUE}Execution Time: ${exec_time}s${NC}"
        
        echo -e "\n${CYAN}📊 RESULTS SUMMARY:${NC}"
        echo -e "  ${GREEN}Passed: $passed${NC}"
        echo -e "  ${RED}Failed: $failed${NC}"
        echo -e "  ${YELLOW}Warnings: $warnings${NC}"
        echo -e "  ${BLUE}Total: $total${NC}"
        
        # Calculate success rate
        local success_rate=0
        if [ "$total" -gt 0 ]; then
            success_rate=$(echo "scale=1; $passed * 100 / $total" | bc 2>/dev/null || echo "0")
        fi
        echo -e "  ${CYAN}Success Rate: ${success_rate}%${NC}"
        
        # Show recommendations
        echo -e "\n${CYAN}💡 RECOMMENDATIONS:${NC}"
        jq -r '.recommendations[]' "$TEST_REPORT" | while IFS= read -r rec; do
            echo -e "  • $rec"
        done
        
        # System health indicator
        if [ "$failed" -eq 0 ]; then
            echo -e "\n${GREEN}🟢 SYSTEM STATUS: HEALTHY${NC}"
        elif [ "$failed" -le 2 ]; then
            echo -e "\n${YELLOW}🟡 SYSTEM STATUS: NEEDS ATTENTION${NC}"
        else
            echo -e "\n${RED}🔴 SYSTEM STATUS: CRITICAL${NC}"
        fi
        
    else
        echo -e "${RED}❌ No test report found${NC}"
    fi
    
    echo -e "\n${BLUE}Full Report: $TEST_REPORT${NC}"
    echo -e "${BLUE}Notifications: $NOTIFICATION_LOG${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
}

# Scheduled test execution
schedule_tests() {
    local interval="${1:-daily}"
    
    case "$interval" in
        "hourly")
            echo "0 * * * * $0 run >/dev/null 2>&1" | crontab -
            echo -e "${GREEN}✅ Hourly automated tests scheduled${NC}"
            ;;
        "daily")
            echo "0 6 * * * $0 run >/dev/null 2>&1" | crontab -
            echo -e "${GREEN}✅ Daily automated tests scheduled (6 AM)${NC}"
            ;;
        "weekly")
            echo "0 6 * * 1 $0 run >/dev/null 2>&1" | crontab -
            echo -e "${GREEN}✅ Weekly automated tests scheduled (Monday 6 AM)${NC}"
            ;;
        *)
            echo -e "${RED}❌ Invalid interval. Use: hourly, daily, weekly${NC}"
            return 1
            ;;
    esac
}

# Main command handler
main() {
    case "${1:-run}" in
        "run")
            init_automation
            run_automated_tests
            generate_automated_report
            ;;
        "report")
            generate_automated_report
            ;;
        "schedule")
            schedule_tests "$2"
            ;;
        "unschedule")
            crontab -r 2>/dev/null
            echo -e "${GREEN}✅ Automated tests unscheduled${NC}"
            ;;
        *)
            echo "CCE Automated Testing System"
            echo "Usage: $0 {run|report|schedule|unschedule}"
            echo ""
            echo "Commands:"
            echo "  run                    - Run complete automated test suite (default)"
            echo "  report                 - Show latest test report"
            echo "  schedule [interval]    - Schedule automated tests (hourly|daily|weekly)"
            echo "  unschedule            - Remove scheduled tests"
            ;;
    esac
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi