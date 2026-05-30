use std::fs;
use std::path::Path;
use regex::Regex;
use walkdir::WalkDir;
use std::collections::HashSet;

fn main() {
    println!("--- ConstantsAuditor Report ---");
    
    // Read dumped keys
    let keys_content = fs::read_to_string("ui_keys.txt").unwrap_or_default();
    // remove empty lines and remove UTF-16 BOM if any (powershell Out-File uses UTF-16 by default)
    // Wait, Out-File uses UTF-16 LE by default in Windows PowerShell. We might need to read it as UTF-16.
    // Let's just read it as bytes and convert if necessary.
    let bytes = fs::read("ui_keys.txt").unwrap_or_default();
    let keys_string = if bytes.len() >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE {
        let u16_words: Vec<u16> = bytes[2..].chunks_exact(2).map(|c| u16::from_le_bytes([c[0], c[1]])).collect();
        String::from_utf16_lossy(&u16_words)
    } else {
        String::from_utf8_lossy(&bytes).to_string()
    };

    let mut defined_constants: HashSet<String> = keys_string.lines()
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();
        
    let constant_regex = Regex::new(r#"ui::[A-Za-z0-9_:]+"#).unwrap();
    let mut used_constants = HashSet::new();
    
    // To find hardcoded ANSI
    let ansi_regex = Regex::new(r#"(?i)\[char\]27|`e\["#).unwrap();
    let mut ansi_leaks = 0;
    
    // To find hardcoded ints > 10 (simple heuristic: standalone numbers > 10 in assignment or params)
    let int_regex = Regex::new(r#"\b([1-9][1-9]|[2-9][0-9]|[1-9][0-9]{2,})\b"#).unwrap();
    let mut int_leaks = 0;

    for entry in WalkDir::new("C:\\Users\\danie\\SCAPE_ROOT")
        .into_iter()
        .filter_map(Result::ok)
    {
        let path = entry.path();
        let path_str = path.to_string_lossy();
        if path_str.contains("Data\\Constants") || path_str.contains(".git") || path_str.contains("tests\\tools") {
            continue;
        }

        if let Some(ext) = path.extension() {
            if ext == "ps1" || ext == "psm1" {
                if let Ok(content) = fs::read_to_string(path) {
                    for cap in constant_regex.captures_iter(&content) {
                        used_constants.insert(cap[0].to_string());
                    }
                    
                    for line in content.lines() {
                        let trimmed = line.trim();
                        if trimmed.starts_with("#") { continue; }
                        
                        if ansi_regex.is_match(trimmed) {
                            ansi_leaks += 1;
                            println!("ANSI Leak: {} -> {}", path.display(), trimmed);
                        }
                        
                        if int_regex.is_match(trimmed) && trimmed.contains("=") && !trimmed.contains("\"") && !trimmed.contains("'") {
                            int_leaks += 1;
                            // Uncommenting println for full trace if needed, but keeping it simple to just count them
                        }
                    }
                }
            }
        }
    }
    
    let unused_constants: Vec<_> = defined_constants.iter()
        .filter(|k| !used_constants.contains(*k))
        .collect();

    println!("Unused Constants: {}", unused_constants.len());
    for u in unused_constants.iter().take(20) {
        println!("  - {}", u);
    }
    if unused_constants.len() > 20 {
        println!("  ... and {} more", unused_constants.len() - 20);
    }

    println!("Hardcoded integers > 10: {} violations.", int_leaks);
    println!("ANSI Escapes leaked: {} violations.", ansi_leaks);
}
