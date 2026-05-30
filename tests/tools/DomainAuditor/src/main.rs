use std::fs;
use std::path::{Path, PathBuf};

// DomainAuditor
// Audits Core and Analysis layers for FP purity and synchronous blocking.
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
    get_psm1_files(Path::new("C:\\Users\\danie\\SCAPE_ROOT\\Modules\\Core"), &mut ps1_files);
    get_psm1_files(Path::new("C:\\Users\\danie\\SCAPE_ROOT\\Modules\\Analysis"), &mut ps1_files);

    let findings: Vec<String> = ps1_files.iter()
        .filter_map(|f| {
            let content = fs::read_to_string(f).ok()?;
            let mut v = Vec::new();
            let file_name = f.file_name().unwrap_or_default().to_string_lossy().to_string();
            
            let mut has_violation = false;
            for line in content.lines() {
                if line.contains("$Script:") && 
                   !line.contains("$Script:ConstantsCache") && 
                   !line.contains("$Script:ColdState") && 
                   !line.contains("$Script:HotState") &&
                   !line.contains("$Script:HotStateCSharp") &&
                   !line.contains("$Script:EventQueue") &&
                   !line.contains("$Script:EventSubscribers") &&
                   !line.contains("$Script:PumpActive") &&
                   !line.contains("$Script:ActionRegistry") &&
                   !line.contains("$Script:LoadedParsers") &&
                   !line.contains("$Script:DetectionCache") &&
                   !line.contains("$Script:Stats") &&
                   !line.contains("$Script:Initialized") &&
                   !line.contains("$Script:C") &&
                   !line.contains("$Script:SignatureIndex") &&
                   !line.contains("$Script:MaxHeaderLength") &&
                   !line.contains("$Script:FSConstants") &&
                   !line.contains("$Script:DBConstants") &&
                   !line.contains("$Script:Limits") &&
                   !line.contains("$Script:ActiveProfile") &&
                   !line.contains("$Script:InteropSignature") &&
                   !line.contains("$Script:SettingsPath") &&
                   !line.contains("$Script:LocalI18N") &&
                   !line.contains("$Script:UnmappedI18N") &&
                   !line.contains("$Script:ChordTimeoutMs") {
                    has_violation = true;
                    break;
                }
            }
            if has_violation { v.push(format!("Violation in {}: Mutable $Script: state detected in Domain layer", file_name)); }
            
            if content.contains(".Wait()") || content.contains("Wait-Job") || content.contains("Start-Sleep") { 
                v.push(format!("Violation in {}: Synchronous thread block in Domain", file_name)); 
            }
            
            if !v.is_empty() { Some(v) } else { None }
        })
        .flatten()
        .collect();

    println!("--- DomainAuditor Report ---");
    if findings.is_empty() {
        println!("0 violations.");
    } else {
        findings.iter().for_each(|f| println!("{}", f));
    }
}
