import os
import re

codebase_dir = r"C:\Users\danie\SCAPE_ROOT\Modules"

hardcoded_ints = []
for root, _, files in os.walk(codebase_dir):
    for file in files:
        if file.endswith('.psm1') or file.endswith('.ps1'):
            with open(os.path.join(root, file), 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                for i, line in enumerate(lines):
                    # Ignore lines with Get-ScapeConstant
                    if "Get-ScapeConstant" in line:
                        continue
                    # Ignore comments
                    if line.strip().startswith('#'):
                        continue
                    # Find integers > 10 that are likely hardcoded layout/timeout values
                    # look for things like: $Width = 30, $Height = 40, Sleep(20), [int]$x = 50
                    matches = re.finditer(r'\b(2[0-9]|[3-9][0-9]|[1-9][0-9]{2,})\b', line)
                    for m in matches:
                        val = m.group(1)
                        # Filter out common false positives like 255, 256, years, etc
                        # But let's just collect all and print a sample
                        hardcoded_ints.append(f"{file}:{i+1}: {line.strip()}")

print(f"Total hardcoded ints found: {len(hardcoded_ints)}")
for h in hardcoded_ints[:30]:
    print(h)
