import json
import sys

log_file = r'C:\Users\danie\.gemini\antigravity\brain\4bc26f06-2acb-43bb-8bab-01205c9dd8ab\.system_generated\logs\transcript.jsonl'
with open(log_file, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            if 'tool_calls' in data:
                for call in data['tool_calls']:
                    if call['name'] in ['write_to_file', 'replace_file_content']:
                        args = call.get('args', {})
                        if 'implementation_plan.md' in args.get('TargetFile', ''):
                            content = args.get('CodeContent', args.get('ReplacementContent', ''))
                            lines_len = len(content.splitlines())
                            print(f"Found plan with {lines_len} lines")
                            with open(f'C:\\Users\\danie\\SCAPE_ROOT\\temp_plan_{lines_len}.md', 'w', encoding='utf-8') as out:
                                out.write(content)
        except Exception as e:
            pass
