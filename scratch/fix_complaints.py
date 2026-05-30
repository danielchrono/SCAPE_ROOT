import re

filepath = 'c:/Users/danie/SCAPE_ROOT/Data/Constants/ui.psd1'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Fields the user complained about or that were mapped to single letters/emojis incorrectly
bad_fields = [
    'XRayScan', 'Decrypted', 'Sealed', 'BootSector', 'Journal', 'Cluster', 
    'Inode', 'Superblock', 'GPTHeader', 'MBR', 'BTree', 'Evidence', 
    'ChainOfCustody', 'IDCard', 'FingerprintID', 'MFT', 'Entropy', 
    'HexView', 'BinaryView', 'Sector', 'Block', 'InputText', 'InputNumber'
]

def replacer(match):
    name = match.group(1)
    g = match.group(2)
    u = match.group(3)
    a = match.group(4)
    
    if name in bad_fields:
        # Use exactly Graphic + FE0E
        base_g = g.replace('\uFE0F', '')
        new_u = base_g + '\uFE0E'
        return f'{name} = @("{g}", "{new_u}", "{a}")'
    return match.group(0)

# Also fix the general ones where 'u' is a single uppercase letter which was a bad fallback
def letter_replacer(match):
    name = match.group(1)
    g = match.group(2)
    u = match.group(3)
    a = match.group(4)
    
    # If Unicode slot is exactly 1 uppercase letter like "B", "J", "M", "T"
    if len(u) == 1 and u in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
        base_g = g.replace('\uFE0F', '')
        new_u = base_g + '\uFE0E'
        return f'{name} = @("{g}", "{new_u}", "{a}")'
    return match.group(0)

# Also fix Decrypted, Sealed, etc. specifically if they have emojis in U slot without FE0E
def emoji_replacer(match):
    name = match.group(1)
    g = match.group(2)
    u = match.group(3)
    a = match.group(4)
    
    # If Unicode slot has high unicode or is identical to Graphic but missing FE0E
    if not '\uFE0E' in u and (u == g.replace('\uFE0F', '') or any(ord(c) > 0x26FF for c in u)):
        base_g = g.replace('\uFE0F', '')
        new_u = base_g + '\uFE0E'
        return f'{name} = @("{g}", "{new_u}", "{a}")'
    return match.group(0)

content = re.sub(r'([A-Za-z0-9_]+)\s*=\s*@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', replacer, content)
content = re.sub(r'([A-Za-z0-9_]+)\s*=\s*@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', letter_replacer, content)
content = re.sub(r'([A-Za-z0-9_]+)\s*=\s*@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', emoji_replacer, content)

# Restore some common sense things that might have been hit
# e.g. InputText = @("📝", "T", "[TXT]") -> now @("📝", "📝︎", "[TXT]") which is better
# ArrowTarget = @("➜", "➔", "[->]") -> ➔ is fine, not a letter

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
