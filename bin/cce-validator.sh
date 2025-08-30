#!/bin/bash

# CCE Validation and Testing Framework
# Comprehensive testing suite to verify CCE system functionality

CCE_ROOT="$HOME/.claude/cce"
AGENTS_DIR="$HOME/.claude/agents"
PROJECTS_DIR="$HOME/.claude/projects"
TEST_RESULTS="$CCE_ROOT/validation"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Initialize validation environment
init_validation() {
    mkdir -p "$TEST_RESULTS"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    TEST_LOG="$TEST_RESULTS/validation_$timestamp.log"
    
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🧪 CCE VALIDATION & TESTING FRAMEWORK${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Test Session: $timestamp${NC}"
    echo -e "${BLUE}Results Log: $TEST_LOG${NC}"
    echo ""
    
    # Create test log
    cat > "$TEST_LOG" <<EOF
CCE Validation Test Results
===========================
Timestamp: $(date -Iseconds)
Test Session: $timestamp
Environment: $(uname -a)

EOF
}

# Test Results Tracking
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0
declare -i TESTS_TOTAL=0

log_test() {
    local test_name="$1"
    local status="$2"
    local details="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if [ "$status" = "PASS" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✅ PASS${NC} - $test_name"
        echo "PASS - $test_name: $details" >> "$TEST_LOG"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}❌ FAIL${NC} - $test_name"
        echo "FAIL - $test_name: $details" >> "$TEST_LOG"
    fi
    
    if [ -n "$details" ]; then
        echo "   Details: $details" >> "$TEST_LOG"
    fi
    echo "" >> "$TEST_LOG"
}

# Test 1: CCE System Components Existence
test_cce_components() {
    echo -e "${YELLOW}📂 Testing CCE System Components...${NC}"
    
    # Core CCE files
    local core_files=(
        "$CCE_ROOT/bin/claude-integration.sh"
        "$CCE_ROOT/bin/cce-orchestrator.sh"
        "$CCE_ROOT/bin/error-collector.js"
        "$CCE_ROOT/bin/learning-processor.py"
        "$CCE_ROOT/bin/agent-communication.sh"
    )
    
    for file in "${core_files[@]}"; do
        if [ -f "$file" ]; then
            log_test "Core CCE File Exists: $(basename $file)" "PASS" "Found at $file"
        else
            log_test "Core CCE File Exists: $(basename $file)" "FAIL" "Missing file: $file"
        fi
    done
    
    # Enhanced agents
    local enhanced_agents=(
        "$AGENTS_DIR/cce-agent-enhanced.md"
        "$AGENTS_DIR/planning-agent-enhanced.md"
    )
    
    for agent in "${enhanced_agents[@]}"; do
        if [ -f "$agent" ]; then
            log_test "Enhanced Agent Exists: $(basename $agent)" "PASS" "Found at $agent"
        else
            log_test "Enhanced Agent Exists: $(basename $agent)" "FAIL" "Missing agent: $agent"
        fi
    done
}

# Test 2: CCE Integration Script Functionality
test_cce_integration() {
    echo -e "${YELLOW}🔌 Testing CCE Integration...${NC}"
    
    # Test claude-integration.sh status
    if command -v "$CCE_ROOT/bin/claude-integration.sh" >/dev/null 2>&1; then
        local status_output
        status_output=$("$CCE_ROOT/bin/claude-integration.sh" active 2>&1)
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            log_test "CCE Integration Script Execution" "PASS" "Script executed successfully"
        else
            log_test "CCE Integration Script Execution" "FAIL" "Exit code: $exit_code, Output: $status_output"
        fi
    else
        log_test "CCE Integration Script Execution" "FAIL" "Script not executable or not found"
    fi
    
    # Test context collection
    if [ -f "$CCE_ROOT/context/current.json" ]; then
        local context_size=$(stat -c%s "$CCE_ROOT/context/current.json" 2>/dev/null || echo "0")
        if [ "$context_size" -gt 50 ]; then
            log_test "Context Collection" "PASS" "Context file exists with $context_size bytes"
        else
            log_test "Context Collection" "FAIL" "Context file too small or empty: $context_size bytes"
        fi
    else
        log_test "Context Collection" "FAIL" "No context file found at $CCE_ROOT/context/current.json"
    fi
}

# Test 3: Error Collection System
test_error_collection() {
    echo -e "${YELLOW}🚨 Testing Error Collection System...${NC}"
    
    # Test error collector script
    if [ -f "$CCE_ROOT/bin/error-collector.js" ]; then
        # Test if Node.js is available
        if command -v node >/dev/null 2>&1; then
            # Test error collector with current directory
            local error_output
            error_output=$(cd "$PWD" && node "$CCE_ROOT/bin/error-collector.js" collect "$PWD" 2>&1)
            local exit_code=$?
            
            if [ $exit_code -eq 0 ]; then
                log_test "Error Collector Execution" "PASS" "Error collector ran successfully"
                
                # Check if error cache was created
                if [ -f "$CCE_ROOT/cache/errors.json" ]; then
                    log_test "Error Cache Generation" "PASS" "Error cache file created"
                else
                    log_test "Error Cache Generation" "FAIL" "No error cache file generated"
                fi
            else
                log_test "Error Collector Execution" "FAIL" "Exit code: $exit_code, Output: $error_output"
            fi
        else
            log_test "Error Collector Prerequisites" "FAIL" "Node.js not available"
        fi
    else
        log_test "Error Collector Availability" "FAIL" "error-collector.js not found"
    fi
}

# Test 4: Learning System
test_learning_system() {
    echo -e "${YELLOW}🧠 Testing Learning System...${NC}"
    
    # Check if learning data exists
    local learning_data_count=0
    if [ -d "$PROJECTS_DIR" ]; then
        learning_data_count=$(find "$PROJECTS_DIR" -name "*.jsonl" 2>/dev/null | wc -l)
    fi
    
    if [ "$learning_data_count" -gt 0 ]; then
        log_test "Learning Data Availability" "PASS" "Found $learning_data_count JSONL learning files"
    else
        log_test "Learning Data Availability" "FAIL" "No learning data found in $PROJECTS_DIR"
    fi
    
    # Test learning processor
    if [ -f "$CCE_ROOT/bin/learning-processor.py" ]; then
        if command -v python3 >/dev/null 2>&1; then
            # Test learning processor with summary command
            local learning_output
            learning_output=$(python3 "$CCE_ROOT/bin/learning-processor.py" summary 2>&1)
            local exit_code=$?
            
            if [ $exit_code -eq 0 ]; then
                log_test "Learning Processor Execution" "PASS" "Learning processor ran successfully"
            else
                log_test "Learning Processor Execution" "FAIL" "Exit code: $exit_code, Output: $learning_output"
            fi
        else
            log_test "Learning Processor Prerequisites" "FAIL" "Python3 not available"
        fi
    else
        log_test "Learning Processor Availability" "FAIL" "learning-processor.py not found"
    fi
}

# Test 5: Agent Communication System
test_agent_communication() {
    echo -e "${YELLOW}🎭 Testing Agent Communication System...${NC}"
    
    if [ -f "$CCE_ROOT/bin/agent-communication.sh" ]; then
        # Test communication system initialization
        local comm_output
        comm_output=$("$CCE_ROOT/bin/agent-communication.sh" init 2>&1)
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            log_test "Agent Communication Init" "PASS" "Communication system initialized"
            
            # Check if communication directories were created
            if [ -d "$CCE_ROOT/communication" ]; then
                log_test "Communication Directories" "PASS" "Communication directories created"
            else
                log_test "Communication Directories" "FAIL" "Communication directories not created"
            fi
        else
            log_test "Agent Communication Init" "FAIL" "Exit code: $exit_code, Output: $comm_output"
        fi
    else
        log_test "Agent Communication Availability" "FAIL" "agent-communication.sh not found"
    fi
}

# Test 6: CCE Orchestrator Functionality
test_cce_orchestrator() {
    echo -e "${YELLOW}🎯 Testing CCE Orchestrator...${NC}"
    
    if [ -f "$CCE_ROOT/bin/cce-orchestrator.sh" ]; then
        # Test orchestrator with a simple task
        local orchestrator_output
        orchestrator_output=$("$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "test simple task" 2>&1)
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            log_test "CCE Orchestrator Execution" "PASS" "Orchestrator ran successfully"
            
            # Check if orchestrator enforces CCE Agent first
            if echo "$orchestrator_output" | grep -q "CCE AGENT ACTIVATION"; then
                log_test "CCE Agent First Enforcement" "PASS" "CCE Agent runs first as required"
            else
                log_test "CCE Agent First Enforcement" "FAIL" "CCE Agent first execution not detected"
            fi
        else
            log_test "CCE Orchestrator Execution" "FAIL" "Exit code: $exit_code, Output: $orchestrator_output"
        fi
    else
        log_test "CCE Orchestrator Availability" "FAIL" "cce-orchestrator.sh not found"
    fi
}

# Test 7: Enhanced Agents Definition Quality
test_enhanced_agents() {
    echo -e "${YELLOW}👥 Testing Enhanced Agent Definitions...${NC}"
    
    # Test CCE Agent Enhanced
    if [ -f "$AGENTS_DIR/cce-agent-enhanced.md" ]; then
        local cce_content=$(cat "$AGENTS_DIR/cce-agent-enhanced.md")
        
        # Check for required sections
        local required_sections=(
            "Context Collection Phases"
            "Error Intelligence Gathering"
            "Database & Services Analysis"
            "Historical Learning Integration"
            "Quality Gates"
        )
        
        local missing_sections=0
        for section in "${required_sections[@]}"; do
            if ! echo "$cce_content" | grep -q "$section"; then
                missing_sections=$((missing_sections + 1))
            fi
        done
        
        if [ $missing_sections -eq 0 ]; then
            log_test "CCE Agent Enhanced Definition" "PASS" "All required sections present"
        else
            log_test "CCE Agent Enhanced Definition" "FAIL" "$missing_sections sections missing"
        fi
    else
        log_test "CCE Agent Enhanced Definition" "FAIL" "cce-agent-enhanced.md not found"
    fi
    
    # Test Planning Agent Enhanced
    if [ -f "$AGENTS_DIR/planning-agent-enhanced.md" ]; then
        local planning_content=$(cat "$AGENTS_DIR/planning-agent-enhanced.md")
        
        # Check for deep code review capabilities
        local required_capabilities=(
            "Database Schema Deep Dive"
            "Service & API Analysis"
            "Code Quality Assessment"
            "Security Analysis"
        )
        
        local missing_capabilities=0
        for capability in "${required_capabilities[@]}"; do
            if ! echo "$planning_content" | grep -q "$capability"; then
                missing_capabilities=$((missing_capabilities + 1))
            fi
        done
        
        if [ $missing_capabilities -eq 0 ]; then
            log_test "Planning Agent Enhanced Definition" "PASS" "All deep code review capabilities present"
        else
            log_test "Planning Agent Enhanced Definition" "FAIL" "$missing_capabilities capabilities missing"
        fi
    else
        log_test "Planning Agent Enhanced Definition" "FAIL" "planning-agent-enhanced.md not found"
    fi
}

# Test 8: System Integration Test
test_system_integration() {
    echo -e "${YELLOW}🔄 Testing End-to-End System Integration...${NC}"
    
    # Test full workflow simulation
    local temp_test_dir="/tmp/cce_integration_test"
    mkdir -p "$temp_test_dir"
    
    # Create a mock project structure for testing
    cat > "$temp_test_dir/test_request.txt" <<EOF
Create a simple React component for user authentication
EOF
    
    # Test the full CCE workflow
    local integration_result
    integration_result=$("$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "Create a simple React component for user authentication" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        # Check if the workflow included all expected steps
        local required_steps=(
            "CCE AGENT ACTIVATION"
            "CONTEXT COLLECTION"
            "AGENT RECOMMENDATION"
        )
        
        local missing_steps=0
        for step in "${required_steps[@]}"; do
            if ! echo "$integration_result" | grep -q "$step"; then
                missing_steps=$((missing_steps + 1))
            fi
        done
        
        if [ $missing_steps -eq 0 ]; then
            log_test "End-to-End Integration" "PASS" "All workflow steps executed"
        else
            log_test "End-to-End Integration" "FAIL" "$missing_steps workflow steps missing"
        fi
    else
        log_test "End-to-End Integration" "FAIL" "Integration test failed with exit code: $exit_code"
    fi
    
    # Cleanup
    rm -rf "$temp_test_dir"
}

# Performance Benchmarking
benchmark_performance() {
    echo -e "${YELLOW}⚡ Running Performance Benchmarks...${NC}"
    
    # Benchmark context collection speed
    local start_time=$(date +%s.%N)
    "$CCE_ROOT/bin/claude-integration.sh" context >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local context_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
    
    if [ "$context_time" != "N/A" ] && [ "$(echo "$context_time < 5.0" | bc 2>/dev/null)" = "1" ]; then
        log_test "Context Collection Performance" "PASS" "Completed in ${context_time}s (< 5s target)"
    else
        log_test "Context Collection Performance" "FAIL" "Took ${context_time}s (> 5s target)"
    fi
    
    # Benchmark orchestrator speed
    start_time=$(date +%s.%N)
    "$CCE_ROOT/bin/cce-orchestrator.sh" orchestrate "test performance" >/dev/null 2>&1
    end_time=$(date +%s.%N)
    local orchestrator_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
    
    if [ "$orchestrator_time" != "N/A" ] && [ "$(echo "$orchestrator_time < 3.0" | bc 2>/dev/null)" = "1" ]; then
        log_test "Orchestrator Performance" "PASS" "Completed in ${orchestrator_time}s (< 3s target)"
    else
        log_test "Orchestrator Performance" "FAIL" "Took ${orchestrator_time}s (> 3s target)"
    fi
}

# Generate Final Report
generate_report() {
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}📊 VALIDATION RESULTS SUMMARY${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    
    local success_rate=0
    if [ $TESTS_TOTAL -gt 0 ]; then
        success_rate=$(echo "scale=1; $TESTS_PASSED * 100 / $TESTS_TOTAL" | bc 2>/dev/null || echo "0")
    fi
    
    echo -e "${BLUE}Total Tests: $TESTS_TOTAL${NC}"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo -e "${CYAN}Success Rate: ${success_rate}%${NC}"
    
    # Overall system health
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}🎉 SYSTEM STATUS: HEALTHY${NC}"
        echo -e "${GREEN}✅ CCE system is fully operational${NC}"
        echo -e "${GREEN}✅ All components are working correctly${NC}"
        echo -e "${GREEN}✅ Ready for production use${NC}"
    elif [ $TESTS_FAILED -le 2 ]; then
        echo -e "\n${YELLOW}⚠️  SYSTEM STATUS: NEEDS ATTENTION${NC}"
        echo -e "${YELLOW}🔧 Minor issues detected${NC}"
        echo -e "${YELLOW}📋 Review failed tests and address issues${NC}"
    else
        echo -e "\n${RED}🚨 SYSTEM STATUS: CRITICAL ISSUES${NC}"
        echo -e "${RED}❌ Multiple system failures detected${NC}"
        echo -e "${RED}🛠️  Immediate attention required${NC}"
    fi
    
    echo -e "\n${BLUE}Detailed results saved to: $TEST_LOG${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"
    
    # Append summary to log
    cat >> "$TEST_LOG" <<EOF

VALIDATION SUMMARY
==================
Total Tests: $TESTS_TOTAL
Passed: $TESTS_PASSED
Failed: $TESTS_FAILED
Success Rate: ${success_rate}%
Test Completed: $(date -Iseconds)
EOF
}

# Main execution
main() {
    local command=${1:-"full"}
    
    case "$command" in
        "full")
            init_validation
            test_cce_components
            test_cce_integration
            test_error_collection
            test_learning_system
            test_agent_communication
            test_cce_orchestrator
            test_enhanced_agents
            test_system_integration
            benchmark_performance
            generate_report
            ;;
        "quick")
            init_validation
            test_cce_components
            test_cce_integration
            generate_report
            ;;
        "components")
            init_validation
            test_cce_components
            generate_report
            ;;
        "integration")
            init_validation
            test_system_integration
            generate_report
            ;;
        "performance")
            init_validation
            benchmark_performance
            generate_report
            ;;
        *)
            echo "CCE Validation Framework"
            echo "Usage: $0 [full|quick|components|integration|performance]"
            echo ""
            echo "Commands:"
            echo "  full        - Run complete validation suite (default)"
            echo "  quick       - Run essential tests only"
            echo "  components  - Test component availability only"
            echo "  integration - Test end-to-end integration only"
            echo "  performance - Run performance benchmarks only"
            ;;
    esac
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi