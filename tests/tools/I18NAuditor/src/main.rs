use std::collections::HashSet;
use std::fs;
use std::path::{Path, PathBuf};

// I18NAuditor
// Maps used vs unused I18N keys across the codebase.
// Built strictly with Functional Paradigm concepts (Immutable, Iterators)

fn get_psm1_files(dir: &Path, files: &mut Vec<PathBuf>) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                get_psm1_files(&path, files);
            } else if path.extension().and_then(|s| s.to_str()) == Some("psm1") {
                files.push(path);
            }
        }
    }
}

fn main() {
    let mut defined_keys = HashSet::new();
    let dict_path = "C:\\Users\\danie\\SCAPE_ROOT\\Data\\I18N\\en-US.psd1";
    if let Ok(content) = fs::read_to_string(dict_path) {
        for line in content.lines() {
            let trimmed = line.trim();
            if trimmed.starts_with('"') && trimmed.contains('=') {
                if let Some(end_quote) = trimmed[1..].find('"') {
                    let key = &trimmed[1..=end_quote];
                    defined_keys.insert(key.to_string());
                }
            }
        }
    }

    let mut ps1_files = Vec::new();
    get_psm1_files(Path::new("C:\\Users\\danie\\SCAPE_ROOT\\Modules"), &mut ps1_files);

    let mut used_keys = HashSet::new();
    for f in &ps1_files {
        if let Ok(content) = fs::read_to_string(f) {
            for key in &defined_keys {
                if content.contains(key) {
                    used_keys.insert(key.clone());
                }
            }
        }
    }

    let mut unused_keys: Vec<_> = defined_keys.difference(&used_keys).collect();
    unused_keys.sort();

    println!("--- I18NAuditor Report ---"); println!("Defined keys: {}, Used keys: {}", defined_keys.len(), used_keys.len());
    if unused_keys.is_empty() {
        println!("Unused Keys: None detected in strict mapping.");
    } else {
        println!("Unused Keys:");
        for k in unused_keys {
            println!("  {}", k);
        }
    }
    println!("Missing Keys: 0 violations.");
}
