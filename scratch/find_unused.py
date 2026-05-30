import os
import re

ui_psd1_path = r"C:\Users\danie\SCAPE_ROOT\Data\Constants\ui.psd1"
codebase_dir = r"C:\Users\danie\SCAPE_ROOT\Modules"

with open(ui_psd1_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

constants = set()
stack = []

for line in lines:
    line = line.split('#')[0].strip()
    if not line:
        continue
    
    # Check for closing brace
    if line == '}':
        if stack:
            stack.pop()
        continue
    
    # check for key = @{
    m1 = re.match(r'^([a-zA-Z0-9_]+)\s*=\s*@\{', line)
    if m1:
        key = m1.group(1)
        stack.append(key)
        continue
    
    # Check for single line nested properties like: Reset = "..."; Bold = "..."
    # or just key = "value"
    # we can just extract any key assignment
    pairs = line.split(';')
    for pair in pairs:
        pair = pair.strip()
        m2 = re.match(r'^([a-zA-Z0-9_]+)\s*=', pair)
        if m2:
            key = m2.group(1)
            # if it ends with @{ we handle it differently but single line is usually strings
            path = "::".join(stack + [key])
            if path.startswith("ui::"):
                pass
            else:
                path = "ui::" + path
            constants.add(path)

print(f"Total extracted constants: {len(constants)}")

# Now scan codebase
used = set()
for root, _, files in os.walk(codebase_dir):
    for file in files:
        if file.endswith('.psm1') or file.endswith('.ps1'):
            with open(os.path.join(root, file), 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                # find all Get-ScapeConstant -Path "..."
                matches = re.findall(r'Get-ScapeConstant\s+-Path\s+["\']([^"\']+)["\']', content)
                for m in matches:
                    used.add(m)
                    
print(f"Total used paths: {len(used)}")

unused = []
for c in constants:
    # A constant is used if its exact path is used, or a parent is used
    # e.g. ui::ANSI::ESC is used if ui::ANSI is used, or ui::ANSI::ESC is used
    is_used = False
    parts = c.split("::")
    for i in range(1, len(parts)+1):
        parent_path = "::".join(parts[:i])
        if parent_path in used:
            is_used = True
            break
    if not is_used:
        unused.append(c)

print(f"Unused constants count: {len(unused)}")
with open(r"C:\Users\danie\SCAPE_ROOT\scratch\unused.txt", "w") as f:
    for u in sorted(unused):
        f.write(u + "\n")
