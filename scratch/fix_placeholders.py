import re

def process_file():
    filepath = 'c:/Users/danie/SCAPE_ROOT/Data/Constants/ui.psd1'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Remove Trombone
    content = re.sub(r'Trombone = @\(\"𖡎\", \"𖡎︎\", \"\[TROM\]\"\);?\s*', '', content)
    
    # 2. Fix Harp (Use a better harp graphic and unicode)
    # Graphic: 🪉 (Harp), Unicode: ♮ (Natural) or 𝄞 (G Clef)
    content = re.sub(r'Harp = @\(\"🪉\", \"[^\"]+\", \"\[HARP\]\"\)', 'Harp = @("🪉", "♮", "[HARP]")', content)

    # 3. Fix WriteBlock (Graphic: 🛑, Unicode: ⊘)
    content = re.sub(r'WriteBlock = @\(\"🛑\", \"⛔(?:︎)?\", \"\[WB\]\"\)', 'WriteBlock = @("🛑", "⊘", "[WB]")', content)

    # 4. Fix FATTable (Graphic should be emoji, Unicode should be text)
    content = re.sub(r'FATTable = @\(\"▦\", \"▦(?:︎)?\", \"\[FAT\]\"\)', 'FATTable = @("🗂️", "▦", "[FAT]")', content)

    # 5. Fix Duplicates
    # Remove ShieldCheck definition
    content = re.sub(r'ShieldCheck = @\(\"🛡️\", \"⛨(?:︎)?\", \"\[SAFE\]\"\);\s*', '', content)
    # Replace usage of ShieldCheck with Shield
    content = re.sub(r'\"ShieldCheck\"', '"Shield"', content)
    
    # 6. Replace placeholder characters with better B&W ones
    # We will define a dictionary mapping the Icon NAME to a better Unicode symbol.
    # We will search the file for the bad chars, but it's safer to just replace them manually in the strings.
    # Bad chars: ⍡ ⌿ ⊐ ⫟ ⊒ ⍑ ⌶ ⍟ ⊞ ⊞ ☖ ☗ ▤ ⊸ ⍢ ◫ ⧄ ∡ ♾ ℋ ⍍ ⏣ ⊏ ⌦ ֍ ⌗ ⌂
    
    replacements = {
        'GPU': '▤', 'Lock': '🔒︎', 'Unlock': '🔓︎', 'KeyPair': '🗝', 'MailDraft': '📝︎', 
        'MailArchive': '🗃', 'SaveAs': '💾︎', 'Trash': '🗑', 'Delete': '🗑', 'Restore': '⟲',
        'New': '★', 'Construction': '🏗', 'Screwdriver': '🔧︎', 'Saw': '🪚︎', 'Axe': '🪓︎',
        'Bucket': '🪣︎', 'Plunger': '🪠︎', 'Sponge': '🧽︎', 'CodeCommit': '⚲',
        'GraduationCap': '🎓︎', 'TopHat': '🎩︎', 'Backpack': '🎒︎', 'Dress': '👗︎',
        'Bikini': '👙︎', 'Purse': '👛︎', 'ManShoe': '👞︎', 'RunningShoe': '👟︎',
        'SafetyVest': '🦺︎', 'Scarf': '🧣︎', 'Gloves': '🧤︎', 'Coat': '🧥︎',
        'Socks': '🧦︎', 'Sari': '🥻︎', 'HikingBoot': '🥾︎', 'LabCoat': '🥼︎',
        'Headphone': '🎧︎', 'Radio': '📻︎', 'Violin': '🎻︎', 'Trumpet': '🎺︎',
        'Saxophone': '🎷︎', 'Guitar': '🎸︎', 'Drum': '🥁︎', 'Banjo': '🪕︎',
        'Accordion': '🪗︎', 'LongDrum': '🪘︎', 'Flute': '🪈︎', 'MovieCamera': '🎥︎',
        'ClapperBoard': '🎬︎', 'Lantern': '🏮︎', 'FilmProjector': '📽', 'Candle': '🕯',
        'Label': '🏷', 'BookmarkTabs': '📑︎', 'Notebook': '📓︎', 'PageCurl': '📃︎',
        'ClosedBook': '📕︎', 'Ledger': '📒︎', 'GreenBook': '📗︎', 'NotebookDeco': '📔︎',
        'OrangeBook': '📙︎', 'OpenBook': '📖︎', 'BlueBook': '📘︎', 'Scroll': '📜︎',
        'Books': '📚︎', 'PageUp': '📄︎', 'Newspaper': '📰︎', 'RolledNewspaper': '🗞',
        'MoneyBag': '💰︎', 'Package': '📦︎', 'Postbox': '📮︎', 'Memo': '📝︎',
        'Crayon': '🖍', 'FountainPen': '🖋', 'ChartUp': '📈︎', 'Pushpin': '📌︎',
        'BarChart': '📊︎', 'RulerTriangle': '📐︎', 'Clipboard': '📋︎', 'ChartDown': '📉︎',
        'RulerStraight': '📏︎', 'FileFolder': '📁︎', 'RoundPushpin': '📍︎', 'Briefcase': '💼︎',
        'TearCalendar': '📆︎', 'CardIndex': '📇︎', 'OpenFolder': '📂︎', 'FileCabinet': '🗄',
        'CardBox': '🗃', 'CardDividers': '🗂', 'LinkedClips': '🖇', 'SpiralCalendar': '🗓',
        'SpiralNotepad': '🗒', 'Scissors': '✂', 'LockedKey': '🔐︎', 'LockedPen': '🔏︎',
        'OldKey': '🗝', 'BowArrow': '🏹︎', 'Bomb': '💣︎', 'Clamp': '🗜', 'Dagger': '🗡',
        'NutBolt': '🔩︎', 'HammerWrench': '🛠', 'Magnet': '🧲︎', 'WhiteCane': '🦯︎',
        'Toolbox': '🧰︎', 'Hook': '🪝︎', 'Ladder': '🪜︎', 'Boomerang': '🪃︎',
        'Shovel': '铲', 'Gear': '⚙', 'Chains': '⛓', 'CrossedSwords': '⚔',
        'BalanceScale': '⚖', 'Bandage': '🩹︎', 'BloodDrop': '🩸︎', 'Crutch': '🩼︎',
        'XRay': '🩻︎', 'Bathtub': '🛁︎', 'Elevator': '🛗︎', 'CouchLamp': '🛋',
        'ShoppingCart': '🛒︎', 'Shower': '🚿︎', 'Bed': '🛏', 'Toilet': '🚽︎',
        'Door': '🚪︎', 'LotionBottle': '🧴︎', 'FireExtinguisher': '🧯︎', 'SafetyPin': '🧷︎',
        'Basket': '🧺︎', 'Soap': '🧼︎', 'PaperRoll': '🧻︎', 'Toothbrush': '🪥︎',
        'Mousetrap': '🪤︎', 'Window': '🪟︎', 'Mirror': '🪞︎', 'Chair': '🪑︎',
        'Razor': '🪒︎', 'Placard': '🪧︎', 'Headstone': '🪦︎', 'IDCardIcon': '🪪︎',
        'Hamsa': '🪬︎', 'FuneralUrn': '⚱', 'Coffin': '⚰', 'Monster': '👾︎',
        'Alien': '👽︎', 'HeartFull': '❤', 'Bookmark': '🔖︎', 'Tag': '🏷',
        'PSClass': '🖹', 'PSFunction': 'ƒ', 'PSFunctionPrivate': '🔒',
        'PSFunctionPublic': '🔓', 'PSVariableEnv': 'E', 'PSAlias': 'A',
        'PSDebug': 'D', 'PSHelp': '?',
        # More targeted ones from the bad characters:
        'ThemeCorporate': '🏢', 'ThemeHacker': '💻', 'ThemeMinimal': '◻',
        'ThemeRetro': '🕹', 'Persona': '👤', 'Corrupted': '⚠',
        'Overwritten': '⟲', 'Unallocated': '◻', 'Allocated': '◼',
        'SlackSpace': '▤', 'Fragmented': '▚', 'Partial': '◐',
        'Encrypted': '🔒', 'Decrypted': '🔓', 'Deleted': '❌',
        'Unrecoverable': '💀', 'Tampered': '⚠', 'Orphaned': '⍉',
        'Carve': '✂', 'ImageDisk': '💿', 'Verify': '✔',
        'HashCalc': '#', 'Reconstruct': '⟲', 'Wipe': '✖',
        'Scrub': '✖', 'BytePatch': '✎', 'BruteForce': '⚒',
        'XRayScan': '🔎', 'FingerprintID': '🆔', 'MFT': '🖹',
        'Inode': 'I', 'BootSector': 'B', 'Superblock': 'S',
        'GPTHeader': 'G', 'MBR': 'M', 'Journal': 'J',
        'BTree': 'T', 'Extent': 'E', 'NestedArchive': '◫',
        'HexView': 'H', 'BinaryView': 'B', 'Entropy': 'E',
        'Cluster': 'C', 'Sector': 'S', 'Block': '◼',
        'PendingSector': '⚠', 'Reallocated': '⟲', 'SSDWear': '⚠',
        'SMARTWarn': '⚠', 'HeadCrash': '⚠', 'Evidence': 'E',
        'ChainOfCustody': 'C', 'Sealed': '🔒', 'IDCard': '🆔',
        'PassportControl': '🛂',
        'Customs': '🛃', 'BaggageClaim': '🛄', 'LeftLuggage': '🛅',
        'CircledInfo': 'ⓘ', 'PlaceOfWorship': '⛪', 'StopSign': '🛑',
        'Wireless': '📶', 'Wheel': '⚙', 'RingBuoy': '⭕',
        'OilDrum': '🛢', 'Motorway': '🛣', 'RailwayTrack': '🛤',
        'Folder': '📁', 'FolderOpen': '📂', 'FolderSync': '⟲',
        'FolderSecure': '🔒', 'File': '📄', 'FileCode': '⌨',
        'FileConfig': '⚙', 'FileLog': '📜', 'FileTemp': '⏱',
        'FileArchive': '🗜', 'FileExec': '⚡', 'FileMedia': '🎬',
        'Database': '🗄', 'DatabaseSync': '⟲', 'Server': '🖥',
        'ServerRack': '🗄', 'NetworkLocal': '🏠', 'Router': '📡',
        'Disk': '💾', 'DiskSSD': '⚡', 'DiskHDD': '💽',
        'DiskUSB': '🔌', 'DiskNetwork': '🔮', 'Memory': '🧠',
        'Chip': '🔲', 'CPU': '⚙', 'Power': '⏻',
        'BatteryFull': '🔋', 'BatteryHalf': '🪫', 'BatteryLow': '🪫',
        'Charging': '⚡', 'Key': '🔑', 'KeyPair': '🗝',
        'Certificate': '📜', 'Shield': '🛡', 'Bug': '🐛',
        'EyeOpen': '👁', 'EyeClosed': '⚇', 'User': '👤',
        'Users': '👥', 'Admin': '👑', 'Guest': '🎭',
        'Service': '⚙', 'Terminal': '💻', 'Container': '📦',
        'API': '🔌', 'Webhook': '🪝', 'Robot': '🤖',
        'Clock': '⏱', 'Calendar': '📅', 'Timer': '⏲',
        'Stopwatch': '⏰', 'Hourglass': '⏳', 'Settings': '⚙',
        'Config': '🔧', 'Preferences': '🎛', 'Target': '🎯',
        'Search': '🔍', 'Filter': 'Y', 'SortAsc': '▲',
        'SortDesc': '▼', 'GroupBy': 'G', 'Refresh': '⟲',
        'Sync': '⟲', 'Update': '↑', 'Upgrade': '↑',
        'Play': '▶', 'Pause': '⏸', 'Stop': '■',
        'Record': '●', 'Eject': '⏏', 'Next': '⏭',
        'Prev': '⏮', 'Shuffle': '⤮', 'Repeat': '⟲',
        'VolumeMax': '🔊', 'VolumeMed': '🔉', 'VolumeMin': '🔈',
        'VolumeMute': '🔇', 'MicOn': '🎤', 'MicOff': '🚫',
        'CameraOn': '📷', 'CameraOff': '🚫', 'Print': '🖨',
        'Scan': '📠', 'Fax': '📠', 'MailSend': '📤',
        'MailReceive': '📥', 'Share': '🔗', 'Link': '🔗',
        'Unlink': '✂', 'Copy': '📋', 'Cut': '✂',
        'Paste': '📌', 'Clone': '⧉', 'Save': '💾',
        'Undo': '↶', 'Redo': '↷', 'Open': '📂',
        'Edit': '✎', 'Load': '📂', 'Import': '📥',
        'Export': '📤', 'Upload': '↑', 'Download': '↓',
        'Install': '↓', 'Uninstall': '✖', 'Execute': '⚡',
        'Build': '⚒', 'Deploy': '↑', 'Test': '🧪',
        'Tools': '⚒', 'Wrench': '🔧', 'Hammer': '🔨',
        'Pickaxe': '⛏', 'Construction': '🏗', 'Funnel': 'Y',
        'Fire': '🔥', 'Lightning': '⚡', 'Sparkle': '✨',
        'GitBranch': 'ᛘ', 'GitPush': '↑', 'GitPull': '↓',
        'GitMerge': 'ᛘ', 'ArrowUp': '↑', 'ArrowDown': '↓',
        'ArrowLeft': '←', 'ArrowRight': '→', 'ArrowDoubleUp': '⇈',
        'ArrowDoubleDown': '⇊', 'ArrowDoubleLeft': '⇇', 'ArrowDoubleRight': '⇉',
        'ArrowSync': '⟲', 'ArrowDiagonalUR': '↗', 'ArrowDiagonalDR': '↘',
        'ArrowCurveRight': '⤵', 'ArrowCurveLeft': '⤴', 'ArrowTarget': '→',
        'ArrowRedirect': '⇉', 'ArrowJump': '↱', 'CaretUp': '▲',
        'CaretDown': '▼', 'CaretLeft': '◀', 'CaretRight': '▶',
        'CaretSmallUp': '▴', 'CaretSmallDown': '▾', 'CaretSmallLeft': '◂',
        'CaretSmallRight': '▸', 'Compass': '⌖', 'CompassN': 'N',
        'CompassS': 'S', 'CompassE': 'E', 'CompassW': 'W',
        'Home': 'H', 'End': 'E', 'Jump': 'J',
        'Return': '↵', 'Breadcrumb': '›', 'NextTab': '⇨',
        'PrevTab': '⇦', 'Menu': '≡', 'Submenu': '▸',
        'Back': '◂', 'Close': '✖', 'Minimize': '—',
        'Maximize': '□', 'Normalize': '▣', 'Help': '?',
        'WindowTile': '⊞', 'WindowSplitH': '⬌', 'WindowSplitV': '⇕',
        'WindowFull': '⛶', 'TabNew': '+', 'TabClose': '✖',
        'FocusIn': '⊕', 'FocusOut': '⊖', 'Chat': '💬',
        'Comment': '💭', 'Mention': '@', 'CheckboxOn': '☑',
        'CheckboxOff': '☐', 'CheckboxHalf': '⊟', 'RadioOn': '◉',
        'RadioOff': '○', 'ToggleOn': 'ON', 'ToggleOff': 'OFF',
        'SliderStart': '├', 'SliderMid': '─', 'SliderEnd': '┤',
        'SliderHandle': '◈', 'InputText': 'T', 'InputNumber': '#',
        'InputDate': 'D', 'InputEmail': '@', 'InputPassword': '*',
        'Dropdown': '▼', 'Listbox': '▤', 'Combobox': '⊟',
        'BracketAngle': '<>', 'BracketSquare': '[]', 'BracketCurly': '{}',
        'BracketParen': '()'
    }

    def replacer(match):
        name = match.group(1)
        g = match.group(2)
        u = match.group(3)
        a = match.group(4)
        
        bad_chars = '⍡⌿⊐⫟⊒⍑⌶⍟⊞☖☗▤⊸⍢◫⧄∡♾ℋ⍍⏣⊏⌦֍⌗⌂'
        has_bad = any(c in u for c in bad_chars)
        
        if has_bad:
            if name in replacements:
                u = replacements[name]
            else:
                # Fallback to something standard if not mapped
                u = g.replace('\uFE0F', '') + '\uFE0E'
                
        return f'{name} = @("{g}", "{u}", "{a}")'
        
    content = re.sub(r'([A-Za-z0-9_]+)\s*=\s*@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', replacer, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

process_file()
print("Placeholders replaced.")
