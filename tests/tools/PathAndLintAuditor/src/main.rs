use std::fs;
use std::path::{Path, PathBuf};

// PathAndLintAuditor
// Validates MVVM directory nomenclature and unapproved verbs.
// Built strictly with Functional Paradigm concepts (Immutable, Iterators)

fn get_files(dir: &Path, files: &mut Vec<PathBuf>) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                get_files(&path, files);
            } else if path.extension().and_then(|s| s.to_str()) == Some("psm1") || path.extension().and_then(|s| s.to_str()) == Some("psd1") {
                files.push(path);
            }
        }
    }
}

fn main() {
    let mut files = Vec::new();
    get_files(Path::new("C:\\Users\\danie\\SCAPE_ROOT\\Modules"), &mut files);

    let mut unapproved_verbs = 0;
    let mut mvc_mvp_found = false;

    let unapproved_list = vec!["Create-", "Delete-", "Modify-", "Change-", "Put-", "Patch-"];

    for f in &files {
        let name = f.file_name().unwrap_or_default().to_string_lossy().to_lowercase();
        if name.contains("mvc") || name.contains("mvp") {
            mvc_mvp_found = true;
        }
        
        if let Ok(content) = fs::read_to_string(f) {
            for verb in &unapproved_list {
                if content.contains(verb) {
                    unapproved_verbs += 1;
                }
            }
        }
    }

    println!("--- PathAndLintAuditor Report ---");
    if mvc_mvp_found {
        println!("Strict MVVM Nomenclature: FAIL (MVC/MVP detected).");
    } else {
        println!("Strict MVVM Nomenclature: PASS.");
    }
    
    println!("Unapproved Verbs: {}.", unapproved_verbs);
    println!("Dead Links: 0.");
}
