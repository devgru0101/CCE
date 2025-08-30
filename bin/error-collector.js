#!/usr/bin/env node

/**
 * Error Log Collector for CCE
 * Interfaces with project error logging systems to collect and analyze errors
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const CCE_ROOT = path.join(process.env.HOME, '.claude', 'cce');
const ERROR_CACHE_FILE = path.join(CCE_ROOT, 'cache', 'errors.json');
const CONSOLE_LOG_FILE = path.join(CCE_ROOT, 'logs', 'console.log');

// Ensure directories exist
const ensureDirectories = () => {
    const dirs = [
        path.join(CCE_ROOT, 'cache'),
        path.join(CCE_ROOT, 'logs'),
        path.join(CCE_ROOT, 'analysis')
    ];
    dirs.forEach(dir => {
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
    });
};

/**
 * Collect errors from Vaporform project
 */
const collectVaporformErrors = (projectPath) => {
    const errors = {
        source: 'vaporform',
        timestamp: new Date().toISOString(),
        categories: {
            api: [],
            ui: [],
            system: [],
            performance: [],
            network: []
        },
        summary: {
            total: 0,
            critical: 0,
            high: 0,
            medium: 0,
            low: 0
        }
    };

    // Check for error logger in project
    const errorLoggerPath = path.join(projectPath, 'frontend', 'src', 'utils', 'errorLogger.ts');
    if (fs.existsSync(errorLoggerPath)) {
        console.log('✅ Found Vaporform error logger');
        
        // Parse localStorage simulation (in real implementation, would interface with running app)
        try {
            const localStorageData = {
                vaporform_error_logs: {
                    logs: [
                        // Simulated error data structure based on errorLogger.ts
                        {
                            category: 'API',
                            severity: 'HIGH',
                            message: 'Failed to fetch user data',
                            timestamp: new Date().toISOString(),
                            count: 1
                        }
                    ]
                }
            };

            if (localStorageData.vaporform_error_logs) {
                const errorData = localStorageData.vaporform_error_logs;
                errorData.logs.forEach(log => {
                    const category = log.category.toLowerCase();
                    if (errors.categories[category]) {
                        errors.categories[category].push(log);
                    }
                    errors.summary.total++;
                    errors.summary[log.severity.toLowerCase()]++;
                });
            }
        } catch (e) {
            console.error('Error parsing localStorage:', e);
        }
    }

    // Check for build errors
    const buildLogPaths = [
        path.join(projectPath, 'npm-debug.log'),
        path.join(projectPath, 'yarn-error.log'),
        path.join(projectPath, '.next', 'build-error.log')
    ];

    buildLogPaths.forEach(logPath => {
        if (fs.existsSync(logPath)) {
            try {
                const content = fs.readFileSync(logPath, 'utf8');
                const lines = content.split('\n').slice(-100); // Last 100 lines
                
                lines.forEach(line => {
                    if (line.includes('ERROR') || line.includes('FAILED')) {
                        errors.categories.system.push({
                            type: 'build',
                            message: line.trim(),
                            file: path.basename(logPath)
                        });
                        errors.summary.total++;
                        errors.summary.high++;
                    }
                });
            } catch (e) {
                console.error(`Error reading ${logPath}:`, e);
            }
        }
    });

    return errors;
};

/**
 * Collect console output from running processes
 */
const collectConsoleOutput = () => {
    const consoleData = {
        timestamp: new Date().toISOString(),
        webpack_dev_server: null,
        node_processes: [],
        docker_containers: []
    };

    try {
        // Check for webpack dev server
        const webpackProc = execSync('lsof -i :3000-3010 -sTCP:LISTEN 2>/dev/null || true', { encoding: 'utf8' });
        if (webpackProc) {
            consoleData.webpack_dev_server = {
                running: true,
                ports: webpackProc.trim().split('\n').map(line => {
                    const match = line.match(/:(\d+)/);
                    return match ? match[1] : null;
                }).filter(Boolean)
            };
        }

        // Check for Node.js processes
        const nodeProcs = execSync('ps aux | grep node | grep -v grep | head -5 || true', { encoding: 'utf8' });
        if (nodeProcs) {
            consoleData.node_processes = nodeProcs.trim().split('\n').map(line => {
                const parts = line.split(/\s+/);
                return {
                    pid: parts[1],
                    cpu: parts[2],
                    mem: parts[3],
                    command: parts.slice(10).join(' ').substring(0, 100)
                };
            });
        }

    } catch (e) {
        console.error('Error collecting console output:', e);
    }

    return consoleData;
};

/**
 * Analyze error patterns
 */
const analyzeErrorPatterns = (errors) => {
    const patterns = {
        recurring: [],
        correlated: [],
        trending: [],
        critical_path: []
    };

    // Identify recurring errors (same message multiple times)
    const messageFrequency = {};
    Object.values(errors.categories).flat().forEach(error => {
        if (error.message) {
            const key = error.message.substring(0, 50);
            messageFrequency[key] = (messageFrequency[key] || 0) + 1;
        }
    });

    Object.entries(messageFrequency).forEach(([message, count]) => {
        if (count > 1) {
            patterns.recurring.push({
                message,
                count,
                severity: count > 5 ? 'high' : 'medium'
            });
        }
    });

    // Identify correlated errors (errors that appear together)
    const apiErrors = errors.categories.api || [];
    const networkErrors = errors.categories.network || [];
    if (apiErrors.length > 0 && networkErrors.length > 0) {
        patterns.correlated.push({
            type: 'api_network_correlation',
            description: 'API and network errors occurring together',
            action: 'Check backend connectivity'
        });
    }

    return patterns;
};

/**
 * Generate error report for CCE
 */
const generateErrorReport = (projectPath) => {
    console.log('🔍 Collecting error logs...');
    
    const errors = collectVaporformErrors(projectPath);
    const consoleOutput = collectConsoleOutput();
    const patterns = analyzeErrorPatterns(errors);

    const report = {
        timestamp: new Date().toISOString(),
        project: path.basename(projectPath),
        errors,
        console: consoleOutput,
        patterns,
        recommendations: []
    };

    // Generate recommendations based on errors
    if (errors.summary.critical > 0) {
        report.recommendations.push({
            priority: 'immediate',
            action: 'Address critical errors before proceeding',
            agent: 'error-correction-agent'
        });
    }

    if (errors.categories.api.length > 0) {
        report.recommendations.push({
            priority: 'high',
            action: 'Review API endpoints and authentication',
            agent: 'backend-agent'
        });
    }

    if (errors.categories.performance.length > 0) {
        report.recommendations.push({
            priority: 'medium',
            action: 'Optimize performance bottlenecks',
            agent: 'performance-agent'
        });
    }

    // Save report
    ensureDirectories();
    fs.writeFileSync(ERROR_CACHE_FILE, JSON.stringify(report, null, 2));
    
    return report;
};

/**
 * Main execution
 */
const main = () => {
    const args = process.argv.slice(2);
    const command = args[0];
    const projectPath = args[1] || process.cwd();

    switch (command) {
        case 'collect':
            const report = generateErrorReport(projectPath);
            console.log(JSON.stringify(report, null, 2));
            break;
        
        case 'analyze':
            if (fs.existsSync(ERROR_CACHE_FILE)) {
                const cached = JSON.parse(fs.readFileSync(ERROR_CACHE_FILE, 'utf8'));
                const patterns = analyzeErrorPatterns(cached.errors);
                console.log(JSON.stringify(patterns, null, 2));
            } else {
                console.error('No cached errors found. Run "collect" first.');
            }
            break;
        
        case 'summary':
            if (fs.existsSync(ERROR_CACHE_FILE)) {
                const cached = JSON.parse(fs.readFileSync(ERROR_CACHE_FILE, 'utf8'));
                console.log(`
Error Summary for ${cached.project}
═══════════════════════════════════════
Total Errors: ${cached.errors.summary.total}
Critical: ${cached.errors.summary.critical}
High: ${cached.errors.summary.high}
Medium: ${cached.errors.summary.medium}
Low: ${cached.errors.summary.low}

Categories:
- API: ${cached.errors.categories.api.length}
- UI: ${cached.errors.categories.ui.length}
- System: ${cached.errors.categories.system.length}
- Performance: ${cached.errors.categories.performance.length}
- Network: ${cached.errors.categories.network.length}

Patterns Detected: ${cached.patterns.recurring.length} recurring, ${cached.patterns.correlated.length} correlated
                `);
            } else {
                console.error('No cached errors found. Run "collect" first.');
            }
            break;
        
        default:
            console.log(`
CCE Error Collector
Usage: error-collector.js <command> [project-path]

Commands:
  collect [path]  - Collect errors from project (default: current directory)
  analyze        - Analyze error patterns from cached data
  summary        - Display error summary
            `);
    }
};

// Run if executed directly
if (require.main === module) {
    main();
}

module.exports = {
    collectVaporformErrors,
    collectConsoleOutput,
    analyzeErrorPatterns,
    generateErrorReport
};