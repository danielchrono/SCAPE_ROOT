import re
from collections import defaultdict

with open('c:/Users/danie/SCAPE_ROOT/Data/Constants/ui.psd1', 'r', encoding='utf-8') as f:
    content = f.read()

icons = re.findall(r'([A-Za-z0-9_]+)\s*=\s*@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', content)

out = []

# 1. Duplicates
g_map = defaultdict(list)
for name, g, u, a in icons:
    base_g = g.replace('\uFE0F', '')
    g_map[base_g].append(name)

out.append('--- DUPLICATES ---')
for g, names in g_map.items():
    if len(names) > 1:
        out.append(f'{g}: {names}')

# 2. Bad Unicodes
bad_unicodes = '⊞⍙🛤🛣🛈▭▯⊠⊓⊔⌐⊢⌙◦⌫⟳☍⊡◭◮⊠◈⌕⊗⊝⊟⌘◰◌⌇◬⌆◉♡$◧◨◪▣◊⌺'
out.append('\n--- BAD UNICODES ---')
for name, g, u, a in icons:
    if any(c in u for c in bad_unicodes):
        out.append(f'{name}: {g} -> {u}')

# 3. Graphic in Unicode slot (from the user's first list)
user_emojis = '🧫🦾🧩🧽🩹🩻🪪🪲📜📷🪝🪚🪓🧰🪛🧹🧤🧥🥼🪕🧮🧲🪃🧯🪑🧷⛓💥🩼🪒🪟🪧🪦🪥🔒🔓🟢🧵🔴📦🔄💾'
out.append('\n--- GRAPHIC IN UNICODE ---')
for name, g, u, a in icons:
    base_g = g.replace('\uFE0F', '').replace('\uFE0E', '')
    base_u = u.replace('\uFE0F', '').replace('\uFE0E', '')
    if base_u in user_emojis:
        out.append(f'{name}: {g} -> {u}')

with open('c:/Users/danie/SCAPE_ROOT/scratch/analyze_output.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(out))
