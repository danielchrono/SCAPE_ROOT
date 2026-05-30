import re

def fix_ui_psd1():
    file_path = 'c:/Users/danie/SCAPE_ROOT/Data/Constants/ui.psd1'
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    def replacer(match):
        full_match = match.group(0)
        g = match.group(1)
        u = match.group(2)
        a = match.group(3)
        
        # Check if 'u' is a high Unicode character (surrogate pair in UTF-16, or code point > 0xFFFF)
        # In Python 3, strings are Unicode code points. Emojis are > 0xFFFF.
        is_high = any(ord(c) > 0xFFFF for c in u)
        
        # Also check if it's in the Miscellaneous Symbols and Pictographs block (0x1F300 - 0x1F5FF)
        # or Emoticons (0x1F600 - 0x1F64F) or Transport/Map (0x1F680 - 0x1F6FF)
        is_pictograph = any(0x1F000 <= ord(c) <= 0x1FAFF for c in u)
        
        has_fe0e = '\uFE0E' in u
        
        g_base = g.replace('\uFE0F', '').replace('\uFE0E', '')
        u_base = u.replace('\uFE0F', '').replace('\uFE0E', '')

        needs_fix = False
        
        if is_high or is_pictograph:
            # It's an emoji. Even if it's the same as 'g', it needs FE0E to become B&W.
            if u == g_base + '\uFE0E':
                pass # Already correct
            else:
                needs_fix = True
        elif has_fe0e and g_base != u_base:
            # It has FE0E but doesn't match 'g'
            needs_fix = True
        elif u == g and any(ord(c) > 0x26FF for c in u):
            # Same as g, and it's some symbol that might be colored
            # Let's check if it's a known non-emoji shape like ◫ (0x25EB) which is < 0x26FF
            # If it's > 0x26FF, we probably want FE0E
            needs_fix = True
            
        if needs_fix:
            new_u = g_base + '\uFE0E'
            return f'@("{g}", "{new_u}", "{a}")'
        else:
            return full_match

    new_content = re.sub(r'@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', replacer, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

fix_ui_psd1()
print("Replacement complete.")
