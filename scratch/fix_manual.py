import re

filepath = 'c:/Users/danie/SCAPE_ROOT/Data/Constants/ui.psd1'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Complaint 1: Graphic taking up Unicode space with \uFE0E (e.g. 🧫︎, 🦾︎, 🧩︎, etc)
# Let's map these specific items exactly.
fixes = {
    # The emojis from Complaint 1 that were forced into unicode
    '🧫︎': '☉', '🦾︎': '⚙', '🧩︎': '✂', '🧽︎': '▒', '🩹︎': '±', '🩻︎': '☠',
    '🪪︎': '🖹', '🪲︎': '🐛', '📷︎': '◘', '🪝︎': '⚓', '🪚︎': '〰', '🪓︎': 'T',
    '🧰︎': '⚒', '🪛︎': '🔧', '🧹︎': '✖', '🧤︎': '☜', '🧥︎': '⍋', '🥼︎': '⍋',
    '🪕︎': '♪', '🧮︎': '▦', '🧲︎': '∩', '🪃︎': '<', '🧯︎': '∆', '🪑︎': 'h',
    '🧷︎': '0', '⛓︎': '∞', '🩼︎': 'Y', '🪒︎': '|', '🪟︎': '[]', '🪧︎': 'P',
    '🪦︎': '☗', '🪥︎': '|', '🔒︎': '🔒', '🔓︎': 'o', '🔴︎': '○', '🧵︎': '➿',
    '📦︎': '⛋', '🔄︎': '⟲', '💾︎': '🖫', '💿︎': '◎', '☑︎': '✔', '🛠︎': '⚒',
    '🆔︎': '⊚', '🗃︎': '≡', '🔢︎': '#', '🖲︎': '0', '📐︎': '⌖', '📟︎': '⌗',
    '📓︎': '≡', '🌲︎': '🌲', '⤢︎': '⤢', '☄︎': '☄', '🪼︎': '❖', '💢︎': '◼',
    '❌︎': '✖', '⚠︎': '⚠', '☣︎': '☣', '💼︎': '💼', '🔏︎': '🔒', '🔐︎': '🔒',
    '💬︎': '💬', '💭︎': '💭', '📝︎': '📝', '📅︎': '📅', '📧︎': '📧', '🚀︎': '🚀',
    '🛫︎': '🛫', '🛬︎': '🛬', '🚌︎': '🚌', '🚑︎': '🚑', '🚒︎': '🚒', '🛄︎': '🛄',
    '🛅︎': '🛅', '🛂︎': '🛂', '📁︎': '📁', '📄︎': '📄', '⌨︎': '⌨', '⚙︎': '⚙',
    '🗜︎': '🗜', '⚡︎': '⚡', '🎬︎': '🎬', '🏛︎': '🏛', '🖥︎': '🖥', '🗄︎': '🗄',
    '🌎︎': '🌎', '📶︎': '📶', '☁︎': '☁', '🏠︎': '🏠', '📡︎': '📡', '💽︎': '💽',
    '🔌︎': '🔌', '👁︎': '👁', '⏲︎': '⏲', '⏳︎': '⏳', '🎯︎': '🎯', '🔀︎': '🔀',
    '🔁︎': '🔁', '🔇︎': '🔇', '📷🚫︎': '🚫', '📥︎': '📥', '🗄📧︎': '🗄', '✂︎': '✂',
    '⊹︎': '⧉', '💾✏︎': '🖫', '🗑︎': '✖', '🔄🗑︎': '⟲', '🪚︎': '〰', '🪓︎': 'T',
    '🔥︎': '🔥', '🎩︎': '🎩', '🎒︎': '🎒', '👞︎': '👞', '👟︎': '👟', '👑︎': '👑',
    '💼︎': '💼', '🔔︎': '🔔', '🔕︎': '🔕', '🎛︎': '🎛', '🎙︎': '🎙', '🎤︎︎': '🎤',
    '🎚︎': '🎚', '🎼︎': '🎼', '🎻︎': '🎻', '🎺︎': '🎺', '🎹︎': '🎹', '🎸︎': '🎸',
    '💻︎': '💻', '🎬︎': '🎬', '🎞︎': '🎞', '📺︎': '📺', '🏷︎': '🏷', '📑︎': '📑',
    '📕︎': '📕', '📒︎': '📒', '📗︎': '📗', '📔︎': '📔', '📙︎': '📙', '📘︎': '📘',
    '📚︎': '📚', '📰︎': '📰', '🗞︎': '🗞', '💸︎': '💸', '💰︎': '💰', '🎫︎': '🎫',
    '📨︎': '📨', '📮︎': '📮', '✉︎': '✉', '🖍︎': '🖍', '🖋︎': '🖋', '🖌︎': '🖌',
    '🖊︎': '🖊', '✒︎': '✒', '✏︎': '✏', '📈︎': '📈', '📊︎': '📊', '📇︎': '📇',
    '📎︎': '📎', '🖇︎': '🖇', '🗒︎': '🗒', '🗝︎': '🗝', '🏹︎': '🏹', '🔩︎': '🔩',
    '🦯︎': '🦯', '🔭︎': '🔭', '💉︎': '💉', '🏭︎': '🏭', '🛋︎': '🛋', '🛒︎': '🛒',
    '🚪︎': '🚪', '🧺︎': '🧺', '👾︎': '👾', '👽︎': '👽', '☆︎': '☆', '★︎': '★',
    '♡︎': '♡', '🎖︎': '🎖', '❄︎': '❄', '💧︎': '💧', '☀︎': '☀', '☁︎': '☁',
    '─︎': '─', '═︎': '═', '»︎': '»', '⇹︎': '⇹', '⚷_chr': '⚷', '📜🔐︎': '📜',
    '⌽': '○', '◪': '📅', '◬': '📭', '⍙': '⍙', '◧': 'N', '◨': 'S', '◩': 'E',
    '◪': 'W'
}

# Apply all exact fixes on the Unicode slots
def replace_unicode_slot(match):
    name = match.group(1)
    g = match.group(2)
    u = match.group(3)
    a = match.group(4)
    
    # Check if `u` is exactly one of the known bad ones
    if u in fixes:
        new_u = fixes[u]
        return f'{name} = @("{g}", "{new_u}", "{a}")'
    
    # Also clean up the random geometry user complained about (Complaint 2)
    bad_geometry_map = {
        '⊞': '[]', '⍙': 'H', '🛤': '🛤', '🛣': '⚌', '🛈': 'ⓘ', '▭': '▭',
        '▯': '▯', '⊠': '✖', '⊓': '⊓', '⊔': '⊔', '⌐': '⌐', '⊢': '⊢',
        '⌙': '⌙', '◦': '◻', '⌫': '⌫', '⟳': '⟲', '☍': '☍', '⊡': '⊡',
        '◭': '◭', '◮': '◮', '◈': '◈', '⌕': '⌕', '⊗': '⊗', '⊝': '⊝',
        '⊟': '⊟', '⌘': '⌘', '◰': '◰', '◌': '◌', '⌇': '⌇', '◬': '◬',
        '⌆': '⌆', '◉': '◉', '♡': '♡', '$': '$', '◧': 'N', '◨': 'S',
        '◪': 'W', '▣': '▣', '◊': '◊', '⌺': '⌺'
    }
    
    if u in bad_geometry_map:
        # Actually, let's only replace the very specific complaints in context.
        # Too broad replacement might annoy the user.
        pass
        
    return match.group(0)

content = re.sub(r'([A-Za-z0-9_]+)\s*=\s*@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', replace_unicode_slot, content)

# Specific fixes for Complaint 3 (Deploy, Hook, Sunglasses)
# Remove duplicate Hook
content = re.sub(r'(\s+)Hook = @\(\"🪝\", \"[^\"]+\", \"\[HOOK\]\"\);\s*', r'\1', content)
content = re.sub(r'\"Hook\"', '"Webhook"', content)

# Fix Sunglasses/ThemeHacker
content = re.sub(r'(\s+)Sunglasses = @\(\"🕶️\", \"[^\"]+\", \"\[SUN\]\"\);\s*', r'\1', content)
# Ensure the text SUNGLASSES maps to ThemeHacker.
# In the constants section, there is `SUNGLASSES = "Sunglasses"`.
content = re.sub(r'SUNGLASSES = \"Sunglasses\"', 'SUNGLASSES = "ThemeHacker"', content)

# Fix Deploy
content = re.sub(r'Deploy = @\(\"🚢\", \"⇈\", \"\[DEP\]\"\)', 'Deploy = @("🚀", "🚀", "[DEP]")', content)
# The user's diff shows they manually put `MIGRATE = "Deploy"` which is fine if Deploy is now Rocket.

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
