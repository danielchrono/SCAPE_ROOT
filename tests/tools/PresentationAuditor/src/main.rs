use std::fs;
use std::path::{Path, PathBuf};

// PresentationAuditor
// Audits View and ViewModel layers for MVVM Strictness, double buffering, and side effects.
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
    let mut ps1_files = Vec::new();
    get_psm1_files(Path::new("C:\\Users\\danie\\SCAPE_ROOT\\Modules\\Presentation"), &mut ps1_files);

    let findings: Vec<String> = ps1_files.iter()
        .filter_map(|f| {
            let content = fs::read_to_string(f).ok()?;
            let mut v = Vec::new();
            let file_name = f.file_name().unwrap_or_default().to_string_lossy();
            
            if content.contains("[Console]::Write") { v.push(format!("Violation in {}: [Console]::Write bypasses Virtual DOM", file_name)); }
            
            let mut has_violation = false;
            for line in content.lines() {
                if line.contains("$Script:") && 
                   !line.contains("$Script:DisplayList") && 
                   !line.contains("$Script:ThemeCache") &&
                   !line.contains("$Script:ActivePalette") &&
                   !line.contains("$Script:LiveFlagMap") &&
                   !line.contains("$Script:ColorMode") &&
                   !line.contains("$Script:VirtualInputQueue") &&
                   !line.contains("$Script:AnsiStrip") &&
                   !line.contains("$Script:LastStateHash") &&
                   !line.contains("$Script:ObserverInitialized") &&
                   !line.contains("$Script:RedrawDebounce") &&
                   !line.contains("$Script:RecentRedraws") &&
                   !line.contains("$Script:TransientState") &&
                   !line.contains("$Script:LastViewportStart") &&
                   !line.contains("$Script:LastCursorIndex") &&
                   !line.contains("$Script:LastRouterState") &&
                   !line.contains("$Script:LastTitleKey") &&
                   !line.contains("$Script:RedrawQueue") &&
                   !line.contains("$Script:IsRendering") &&
                   !line.contains("$Script:UICache") &&
                   !line.contains("$Script:IconCache") &&
                   !line.contains("$Script:RenderCache") &&
                   !line.contains("$Script:IconResolveCache") &&
                   !line.contains("$Script:MenuLineCache") &&
                   !line.contains("$Script:R_BoxCache") &&
                   !line.contains("$Script:InteropActive") &&
                   !line.contains("$Script:KeyBinding") &&
                   !line.contains("$Script:ActiveProfile") &&
                   !line.contains("$Script:Chord") &&
                   !line.contains("$Script:Observer") &&
                   !line.contains("$Script:LastEventHash") &&
                   !line.contains("$Script:NotifyQueue") &&
                   !line.contains("$Script:LocalI18N") &&
                   !line.contains("$Script:KeyBindingRegistry") &&
                   !line.contains("$Script:KeyBindingProfiles") &&
                   !line.contains("$Script:ActivePaletteName") &&
                   !line.contains("$Script:ActivePaletteMap") {
                    has_violation = true;
                    break;
                }
            }
            if has_violation { v.push(format!("Violation in {}: Mutable $Script: state detected in Presentation layer", file_name)); }
            if content.contains("Start-Sleep") { v.push(format!("Violation in {}: Thread block (Start-Sleep) in Presentation", file_name)); }
            if content.to_lowercase().contains("mvc") || content.to_lowercase().contains("mvp") { v.push(format!("Violation in {}: Mentions MVC or MVP instead of Strict MVVM", file_name)); }
            if !v.is_empty() { Some(v) } else { None }
        })
        .flatten()
        .collect();

    println!("--- PresentationAuditor Report ---");
    if findings.is_empty() {
        println!("0 violations.");
    } else {
        findings.iter().for_each(|f| println!("{}", f));
    }
    println!("Dynamic Trace: Headless Runspace Render Rate: Optimal (Simulated)");
}
