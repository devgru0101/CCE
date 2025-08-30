#!/usr/bin/env python3

"""
CCE Learning Data Processor
Analyzes session JSONL files to extract patterns, insights, and recommendations
"""

import json
import os
import sys
from collections import defaultdict, Counter
from datetime import datetime
from pathlib import Path
import re
from typing import Dict, List, Any, Tuple

class LearningProcessor:
    def __init__(self, projects_root: str = None):
        self.projects_root = projects_root or Path.home() / '.claude' / 'projects'
        self.patterns = defaultdict(list)
        self.agent_performance = defaultdict(lambda: {'success': 0, 'failure': 0, 'total': 0})
        self.task_complexity = defaultdict(list)
        self.error_patterns = defaultdict(int)
        self.success_patterns = []
        self.user_preferences = defaultdict(int)
        
    def process_jsonl_file(self, filepath: Path) -> Dict[str, Any]:
        """Process a single JSONL file and extract insights"""
        insights = {
            'session_id': filepath.stem,
            'total_messages': 0,
            'summaries': [],
            'agents_used': Counter(),
            'tools_used': Counter(),
            'errors_encountered': [],
            'patterns_detected': [],
            'task_complexity': 'unknown',
            'success_indicators': []
        }
        
        with open(filepath, 'r') as f:
            for line in f:
                try:
                    entry = json.loads(line)
                    insights['total_messages'] += 1
                    
                    # Extract summaries
                    if entry.get('type') == 'summary':
                        insights['summaries'].append(entry.get('summary', ''))
                        self._analyze_summary(entry.get('summary', ''))
                    
                    # Analyze message content
                    if 'message' in entry:
                        message = entry['message']
                        if isinstance(message, dict):
                            content = message.get('content', '')
                            self._analyze_content(content, insights)
                    
                    # Track tool usage
                    if 'tool' in entry:
                        insights['tools_used'][entry['tool']] += 1
                    
                    # Detect errors
                    if 'error' in entry or 'Error' in str(entry):
                        insights['errors_encountered'].append(entry)
                        self._analyze_error(entry)
                        
                except json.JSONDecodeError:
                    continue
                except Exception as e:
                    print(f"Error processing line: {e}", file=sys.stderr)
                    
        # Determine task complexity
        insights['task_complexity'] = self._estimate_complexity(insights)
        
        return insights
    
    def _analyze_summary(self, summary: str):
        """Analyze task summaries for patterns"""
        if not summary:
            return
            
        # Extract common task types
        task_keywords = {
            'frontend': ['ui', 'react', 'component', 'style', 'css'],
            'backend': ['api', 'server', 'endpoint', 'database', 'auth'],
            'testing': ['test', 'spec', 'coverage', 'unit', 'integration'],
            'debugging': ['fix', 'error', 'bug', 'issue', 'problem'],
            'feature': ['implement', 'create', 'add', 'build', 'develop'],
            'refactor': ['refactor', 'optimize', 'improve', 'clean', 'restructure']
        }
        
        summary_lower = summary.lower()
        for category, keywords in task_keywords.items():
            if any(keyword in summary_lower for keyword in keywords):
                self.patterns[category].append(summary)
    
    def _analyze_content(self, content: str, insights: Dict):
        """Analyze message content for patterns and agent mentions"""
        if not content:
            return
            
        # Detect agent mentions
        agent_pattern = r'(\w+-agent)'
        agents = re.findall(agent_pattern, content.lower())
        for agent in agents:
            insights['agents_used'][agent] += 1
            
        # Detect success indicators
        success_keywords = ['resolved', 'fixed', 'completed', 'success', 'working', '✅']
        if any(keyword in content.lower() for keyword in success_keywords):
            insights['success_indicators'].append(content[:100])
            
        # Detect common patterns
        if 'error' in content.lower() and 'fix' in content.lower():
            insights['patterns_detected'].append('error_fixing')
        if 'performance' in content.lower():
            insights['patterns_detected'].append('performance_optimization')
        if 'security' in content.lower():
            insights['patterns_detected'].append('security_concern')
    
    def _analyze_error(self, error_entry: Dict):
        """Analyze error patterns"""
        error_str = str(error_entry)
        
        # Common error categories
        if 'TypeError' in error_str:
            self.error_patterns['TypeError'] += 1
        elif 'SyntaxError' in error_str:
            self.error_patterns['SyntaxError'] += 1
        elif 'ImportError' in error_str or 'ModuleNotFound' in error_str:
            self.error_patterns['ImportError'] += 1
        elif 'Network' in error_str or 'Connection' in error_str:
            self.error_patterns['NetworkError'] += 1
        else:
            self.error_patterns['Other'] += 1
    
    def _estimate_complexity(self, insights: Dict) -> str:
        """Estimate task complexity based on insights"""
        score = 0
        
        # Factors that increase complexity
        score += len(insights['agents_used']) * 2
        score += len(insights['tools_used'])
        score += len(insights['errors_encountered']) * 3
        score += insights['total_messages'] // 10
        
        if score < 5:
            return 'simple'
        elif score < 15:
            return 'medium'
        elif score < 30:
            return 'complex'
        else:
            return 'very_complex'
    
    def process_all_sessions(self) -> Dict[str, Any]:
        """Process all session files in the projects directory"""
        all_insights = {
            'total_sessions': 0,
            'total_data_size': 0,
            'patterns': defaultdict(list),
            'agent_usage': Counter(),
            'tool_usage': Counter(),
            'error_frequency': defaultdict(int),
            'complexity_distribution': Counter(),
            'success_rate': 0,
            'recommendations': []
        }
        
        # Find all JSONL files
        for project_dir in self.projects_root.iterdir():
            if project_dir.is_dir():
                for jsonl_file in project_dir.glob('*.jsonl'):
                    all_insights['total_sessions'] += 1
                    all_insights['total_data_size'] += jsonl_file.stat().st_size
                    
                    # Process individual session
                    session_insights = self.process_jsonl_file(jsonl_file)
                    
                    # Aggregate insights
                    all_insights['agent_usage'].update(session_insights['agents_used'])
                    all_insights['tool_usage'].update(session_insights['tools_used'])
                    all_insights['complexity_distribution'][session_insights['task_complexity']] += 1
                    
                    # Track success rate
                    if session_insights['success_indicators']:
                        self.success_patterns.extend(session_insights['success_indicators'])
        
        # Calculate success rate
        if all_insights['total_sessions'] > 0:
            success_sessions = len([p for p in self.success_patterns if p])
            all_insights['success_rate'] = (success_sessions / all_insights['total_sessions']) * 100
        
        # Generate recommendations
        all_insights['recommendations'] = self._generate_recommendations(all_insights)
        
        # Add pattern analysis
        all_insights['patterns'] = dict(self.patterns)
        all_insights['error_patterns'] = dict(self.error_patterns)
        
        return all_insights
    
    def _generate_recommendations(self, insights: Dict) -> List[str]:
        """Generate actionable recommendations based on insights"""
        recommendations = []
        
        # Agent usage recommendations
        if insights['agent_usage']:
            most_used = insights['agent_usage'].most_common(1)[0]
            recommendations.append(f"Most used agent: {most_used[0]} ({most_used[1]} times) - Consider optimizing this workflow")
        
        # Error pattern recommendations
        if self.error_patterns:
            most_common_error = max(self.error_patterns, key=self.error_patterns.get)
            recommendations.append(f"Most common error type: {most_common_error} - Implement preventive measures")
        
        # Complexity recommendations
        complex_count = insights['complexity_distribution'].get('complex', 0) + \
                       insights['complexity_distribution'].get('very_complex', 0)
        if complex_count > insights['total_sessions'] * 0.3:
            recommendations.append("High proportion of complex tasks - Consider breaking down into smaller tasks")
        
        # Success rate recommendations
        if insights['success_rate'] < 70:
            recommendations.append(f"Success rate is {insights['success_rate']:.1f}% - Review failure patterns")
        
        # Tool usage recommendations
        if insights['tool_usage']:
            most_used_tool = insights['tool_usage'].most_common(1)[0]
            recommendations.append(f"Most used tool: {most_used_tool[0]} - Ensure optimal usage patterns")
        
        return recommendations
    
    def export_insights(self, output_path: str = None):
        """Export processed insights to JSON file"""
        insights = self.process_all_sessions()
        
        # Add metadata
        insights['metadata'] = {
            'processed_at': datetime.now().isoformat(),
            'processor_version': '1.0.0',
            'projects_root': str(self.projects_root)
        }
        
        # Convert non-serializable objects
        insights['agent_usage'] = dict(insights['agent_usage'])
        insights['tool_usage'] = dict(insights['tool_usage'])
        insights['complexity_distribution'] = dict(insights['complexity_distribution'])
        
        output_path = output_path or Path.home() / '.claude' / 'cce' / 'learning' / 'insights.json'
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w') as f:
            json.dump(insights, f, indent=2, default=str)
        
        return insights
    
    def print_summary(self):
        """Print a human-readable summary of insights"""
        insights = self.process_all_sessions()
        
        print("=" * 60)
        print("CCE LEARNING DATA ANALYSIS SUMMARY")
        print("=" * 60)
        print(f"\nTotal Sessions Analyzed: {insights['total_sessions']}")
        print(f"Total Data Size: {insights['total_data_size'] / (1024*1024):.2f} MB")
        print(f"Success Rate: {insights['success_rate']:.1f}%")
        
        print("\n📊 AGENT USAGE:")
        for agent, count in insights['agent_usage'].most_common(5):
            print(f"  • {agent}: {count} times")
        
        print("\n🛠️ TOOL USAGE:")
        for tool, count in insights['tool_usage'].most_common(5):
            print(f"  • {tool}: {count} times")
        
        print("\n📈 COMPLEXITY DISTRIBUTION:")
        for complexity, count in insights['complexity_distribution'].items():
            percentage = (count / insights['total_sessions']) * 100 if insights['total_sessions'] > 0 else 0
            print(f"  • {complexity}: {count} sessions ({percentage:.1f}%)")
        
        print("\n❌ ERROR PATTERNS:")
        for error_type, count in self.error_patterns.items():
            print(f"  • {error_type}: {count} occurrences")
        
        print("\n💡 RECOMMENDATIONS:")
        for i, rec in enumerate(insights['recommendations'], 1):
            print(f"  {i}. {rec}")
        
        print("\n" + "=" * 60)

def main():
    """Main execution function"""
    import argparse
    
    parser = argparse.ArgumentParser(description='CCE Learning Data Processor')
    parser.add_argument('command', choices=['analyze', 'export', 'summary'],
                       help='Command to execute')
    parser.add_argument('--projects-root', type=str,
                       help='Path to projects root directory')
    parser.add_argument('--output', type=str,
                       help='Output path for export command')
    
    args = parser.parse_args()
    
    processor = LearningProcessor(args.projects_root)
    
    if args.command == 'analyze':
        insights = processor.process_all_sessions()
        print(json.dumps(insights, indent=2, default=str))
    elif args.command == 'export':
        insights = processor.export_insights(args.output)
        print(f"Insights exported to: {args.output or '~/.claude/cce/learning/insights.json'}")
    elif args.command == 'summary':
        processor.print_summary()

if __name__ == '__main__':
    main()