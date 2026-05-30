import re

filepath = 'c:/Users/danie/SCAPE_ROOT/Data/Constants/ui.psd1'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove duplicates
to_remove = [
    r'Hook = @\(\"🪝\", \"[^\"]+\", \"\[HOOK\]\"\);\s*',
    r'Sunglasses = @\(\"🕶️\", \"[^\"]+\", \"\[SUN\]\"\);\s*',
    r'PSNew = @\(\"🆕\", \"[^\"]+\", \"\[NEW\]\"\);\s*',
    r'PSRemove = @\(\"🗑️\", \"[^\"]+\", \"\[RM\]\"\);\s*',
    r'Ready = @\(\"✅\", \"[^\"]+\", \"\[READY\]\"\);\s*',
    r'ThemePowerShell = @\(\"📸\", \"[^\"]+\", \"\[PS\]\"\);\s*' # Just an example, let's leave this
]
for r in to_remove:
    content = re.sub(r, '', content)

# Also fix aliases that pointed to removed items
content = re.sub(r'\"Hook\"', '"Webhook"', content)
content = re.sub(r'\"Sunglasses\"', '"ThemeHacker"', content)
content = re.sub(r'\"PSNew\"', '"New"', content)
content = re.sub(r'\"PSRemove\"', '"Delete"', content)
content = re.sub(r'\"Ready\"', '"Success"', content)
content = re.sub(r'MIGRATE = \"Deploy\"', 'MIGRATE = "Rocket"', content)
content = re.sub(r'Deploy = @\(\"🚢\", \"⇈\", \"\[DEP\]\"\)', 'Deploy = @("🚀", "⇈", "[DEP]")', content)

# 2. Map bad Unicodes and Emojis to high quality classic symbols
mapping = {
    # Forensics & Disk
    'Corrupted': '⚠', 'Overwritten': '⟲', 'Unallocated': '◻', 'Allocated': '◼',
    'SlackSpace': '▤', 'Fragmented': '⊘', 'Intact': '✔', 'Partial': '◐',
    'Encrypted': '🔒', 'Decrypted': '🔓', 'Deleted': '✖', 'Recovered': '♻',
    'Unrecoverable': '💀', 'Tampered': '⚠', 'Orphaned': '⍉', 'Carve': '✂',
    'ImageDisk': '◎', 'Verify': '✔', 'WriteBlock': '⊘', 'HashCalc': '#',
    'Reconstruct': '⟲', 'Wipe': '✖', 'Scrub': '▒', 'BytePatch': '±',
    'BruteForce': '⚒', 'XRayScan': '☠', 'FingerprintID': '⊚', 'MFT': '≡',
    'Inode': '№', 'BootSector': '⚙', 'Superblock': '❖', 'GPTHeader': '⌖',
    'MBR': '⌗', 'FATTable': '▦', 'Journal': '≡', 'BTree': '🌲', 'Extent': '⤢',
    'NestedArchive': '◫', 'HexView': '#', 'BinaryView': '0', 'Entropy': '☄',
    'Cluster': '❖', 'Sector': '☉', 'Block': '◼', 'BadSector': '✖', 
    'PendingSector': '⚠', 'Reallocated': '⟲', 'SSDWear': '📉', 'SMARTWarn': '⚠',
    'HeadCrash': '⚠', 'Evidence': '💼', 'ChainOfCustody': '∞', 'Sealed': '🔒',
    'IDCard': '🖹',

    # System & Tools
    'FileTemp': '⏱', 'FileArchive': '🗜', 'FileExec': '⚡', 'FileMedia': '▶',
    'NetworkCloud': '☁', 'Disk': '🖫', 'DiskSSD': '⚡', 'DiskHDD': '🖴',
    'DiskUSB': '☍', 'DiskNetwork': '⛃', 'Memory': '☷', 'Chip': '▦', 'CPU': '⚙',
    'Power': '⏻', 'BatteryFull': '▮', 'BatteryHalf': '⌸', 'BatteryLow': '▯',
    'Charging': '⚡', 'Lock': '🔒', 'Unlock': '🔓', 'Key': '⚷', 'KeyPair': '⚷',
    'Certificate': '📜', 'Shield': '🛡', 'Bug': '🐛', 'EyeOpen': '👁', 
    'EyeClosed': '⚇', 'User': '👤', 'Users': '👥', 'Admin': '👑', 'Guest': '☺',
    'Service': '⚙', 'Terminal': '💻', 'Container': '⛋', 'API': '☍', 'Webhook': '⚓',
    'Robot': '🤖', 'Clock': '⏱', 'Calendar': '📅', 'Timer': '⏲', 'Stopwatch': '⏰',
    'Hourglass': '⏳', 'Settings': '⚙', 'Config': '🔧', 'Preferences': '🎛',
    'Target': '🎯', 'Search': '🔍', 'Filter': 'Y', 'SortAsc': '▲', 'SortDesc': '▼',
    'GroupBy': '≡', 'Refresh': '⟲', 'Sync': '⟲', 'Update': '↑', 'Upgrade': '↑',
    'Play': '▶', 'Pause': '⏸', 'Stop': '■', 'Record': '●', 'Eject': '⏏',
    'Next': '⏭', 'Prev': '⏮', 'Shuffle': '⤮', 'Repeat': '⟲', 'VolumeMax': '🔊',
    'VolumeMed': '🔉', 'VolumeMin': '🔈', 'VolumeMute': '🔇', 'MicOn': '🎤',
    'MicOff': '🚫', 'CameraOn': '📷', 'CameraOff': '🚫', 'Print': '🖨',
    'Scan': '📠', 'Fax': '📠', 'MailSend': '📤', 'MailReceive': '📥', 
    'Share': '🔗', 'Link': '🔗', 'Unlink': '✂', 'Copy': '📋', 'Cut': '✂',
    'Paste': '📌', 'Clone': '⧉', 'Save': '🖫', 'SaveAs': '🖫', 'Trash': '🗑',
    'Delete': '✖', 'Restore': '⟲', 'Undo': '↶', 'Redo': '↷', 'Open': '📂',
    'Edit': '✎', 'Load': '📂', 'Import': '📥', 'Export': '📤', 'Upload': '↑',
    'Download': '↓', 'Install': '↓', 'Uninstall': '✖', 'Execute': '⚡',
    'Build': '⚒', 'Deploy': '🚀', 'Test': '🧪', 'Tools': '⚒', 'Wrench': '🔧',
    'Hammer': '🔨', 'Pickaxe': '⛏', 'Construction': '🏗', 'Funnel': 'Y',
    'Fire': '🔥', 'Lightning': '⚡', 'Sparkle': '✨', 'GitBranch': 'ᛘ',
    'GitPush': '↑', 'GitPull': '↓', 'GitMerge': 'ᛘ',

    # Other categories that had bad unicode or emoji forcing
    'ThemeMinimal': '◻', 'ThemePowerShell': '⏵', 'CompassN': 'N', 'CompassS': 'S',
    'CompassW': 'W', 'Normalize': '▣', 'WindowTile': '⊞', 'TabClose': '✖',
    'CheckboxHalf': '⊟', 'RadioOn': '◉', 'SliderStart': '├', 'SliderHandle': '◈',
    'InputDate': '📅', 'Combobox': '⊟', 'Helicopter': 'H', 'BusStop': 'B',
    'TrafficLightV': '🚦', 'BabySymbol': '👶', 'Customs': '🛃', 'RailwayTrack': '🛤',
    'FolderOpen': '📂', 'NetworkWired': '☍', 'BatteryLow': '▯', 'VolumeMax': '🔊',
    'VolumeMed': '🔉', 'Plunger': '⑆', 'GraduationCap': '🎓', 'Dress': '👗',
    'ClutchBag': '👛', 'Handbag': '👜', 'TShirt': '👕', 'WomansSandal': '👡',
    'Lipstick': '💄', 'WomansClothes': '👚', 'WomansBoot': '👢', 'Ring': '💍',
    'Kimono': '👘', 'GemStone': '💎', 'Glasses': '👓', 'Jeans': '👖',
    'Necktie': '👔', 'HighHeel': '👠', 'PrayerBeads': '📿', 'WomansHat': '👒',
    'ShoppingBags': '🛍', 'BilledCap': '🧢', 'Scarf': '🧣', 'Sari': '🥻',
    'HikingBoot': '🥾', 'FlatShoe': '🥿', 'BalletShoes': '🩰', 'Swimsuit': '🩱',
    'Briefs': '🩲', 'Shorts': '🩳', 'PostalHorn': '📯', 'SpeakerLow': '🔈',
    'SpeakerMed': '🔉', 'SpeakerHigh': '🔊', 'Drum': '🥁', 'Accordion': '🪗',
    'LongDrum': '🪘', 'Maracas': '🪇', 'MobilePhone': '📱', 'Dvd': '📀',
    'OpticalDisk': '💿', 'FloppyDisk': '🖫', 'ComputerDisk': '💽',
    'ComputerMouse': '🖱', 'Trackball': '🖲', 'Desktop': '🖥', 'Plug': '🔌',
    'LowBattery': '▯', 'MovieCamera': '🎥', 'Lantern': '🏮', 'VideoCamera': '📹',
    'LightBulb': '💡', 'Videocassette': '📼', 'FilmProjector': '📽',
    'Candle': '🕯', 'MagnifyRight': '🔎', 'MagnifyLeft': '🔍', 'DiyaLamp': '🪔',
    'PageCurl': '📃', 'OpenBook': '📖', 'Scroll': '📜', 'DollarNote': '$',
    'Receipt': '🧾', 'Coin': '🪙', 'MailboxDown': '📪', 'MailboxUp': '📫',
    'MailboxOpenUp': '📬', 'MailboxOpenDown': '📭', 'RulerTriangle': '📐',
    'RoundPushpin': '📍', 'TearCalendar': '📆', 'SpiralCalendar': '🗓',
    'Wastebasket': '🗑', 'Bomb': '💣', 'Ladder': '🪜', 'Shovel': '铲',
    'Satellite': '🛰', 'Microscope': '🔬', 'PetriDish': '🧫', 'Dna': '🧬',
    'Pill': '💊', 'Stethoscope': '🩺', 'Bandage': '🩹', 'BloodDrop': '🩸',
    'Bathtub': '🛁', 'Elevator': '🛗', 'Shower': '🚿', 'Bed': '🛏', 'Toilet': '🚽',
    'LotionBottle': '🧴', 'Soap': '🧼', 'PaperRoll': '🧻', 'Mousetrap': '🪤',
    'Mirror': '🪞', 'Bubbles': '🫧', 'Moai': '🗿', 'Cigarette': '🚬',
    'NazarAmulet': '🧿', 'FuneralUrn': '⚱', 'HeartEmpty': '♡', 'Rainbow': '🌈',
    'PSVariable': '$', 'PSVariableConst': '🔒', 'PSVariableEnv': 'E',
    'PSModuleCore': '◈', 'PSRemove': '✖', 'BadgeUpdated': '⟲',
    'BadgeUnlock': '🔓', 'Decrypted': '🔓', 'Scrub': '▒', 'BytePatch': '±',
    'Reallocated': '⟲', 'ToggleOff': '○', 'Lock': '🔒', 'Unlock': '🔓',
    'Bug': '🐛', 'Webhook': '⚓', 'Refresh': '⟲', 'Tools': '⚒',
    'Screwdriver': '🔧', 'Saw': '〰', 'Axe': 'T', 'Broom': '彡',
    'Sponge': '▒', 'Gloves': '☜', 'Coat': '⍋', 'LabCoat': '⍋',
    'Banjo': '♪', 'Abacus': '▦', 'Package': '⛋', 'Magnet': '∩',
    'Toolbox': '⚒', 'Boomerang': '<', 'Chains': '∞', 'Crutch': 'Y',
    'XRay': '☠', 'FireExtinguisher': '∆', 'SafetyPin': '0', 'Toothbrush': '|',
    'Window': '[]', 'Chair': 'h', 'Razor': '|', 'Placard': 'P',
    'Headstone': '☗', 'IDCardIcon': '🖹', 'PSModule': '❖', 'PSRunspace': '➿'
}

def replacer(match):
    name = match.group(1)
    g = match.group(2)
    u = match.group(3)
    a = match.group(4)
    
    if name in mapping:
        new_u = mapping[name]
        return f'{name} = @("{g}", "{new_u}", "{a}")'
    
    # If not explicitly mapped, ensure there are no bad unicodes left
    bad_unicodes = '⊞⍙🛤🛣🛈▭▯⊠⊓⊔⌐⊢⌙◦⌫⟳☍⊡◭◮⊠◈⌕⊗⊝⊟⌘◰◌⌇◬⌆◉♡$◧◨◪▣◊⌺'
    if any(c in u for c in bad_unicodes):
        # Very generic fallback if somehow missed
        new_u = g.replace('\uFE0F', '') + '\uFE0E'
        return f'{name} = @("{g}", "{new_u}", "{a}")'

    return match.group(0)

content = re.sub(r'([A-Za-z0-9_]+)\s*=\s*@\(\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\s*,\s*\"([^\"]+)\"\)', replacer, content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
