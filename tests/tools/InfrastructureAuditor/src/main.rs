
// InfrastructureAuditor
// Audits Acquisition, Forensics, Forge, Infrastructure, and Extensions for async runspace isolation.
// Built strictly with Functional Paradigm concepts (Immutable, Iterators)

fn main() {
    let dirs = vec!["Modules\\Extensions", "Modules\\Infrastructure", "Modules\\Acquisition", "Modules\\Forensics", "Modules\\Forge"];
    let findings: Vec<String> = dirs.iter()
        .filter_map(|d| std::fs::read_dir(format!("C:\\Users\\danie\\SCAPE_ROOT\\{}", d)).ok())
        .flat_map(|entries| entries.filter_map(Result::ok).map(|e| e.path()))
        .filter(|p| p.extension().map_or(false, |ext| ext == "psm1"))
        .filter_map(|p| std::fs::read_to_string(&p).ok().map(|c| (p, c)))
        .flat_map(|(p, content)| {
            let mut v = Vec::new();
            let mut ps_created = false;
            let mut has_runspace_bind = false;
            let f_name = p.file_name().unwrap_or_default().to_string_lossy();
            for line in content.lines() {
                if line.contains("Wait-Job") || (line.contains(".Wait(") && !line.contains(".Wait(0)")) {
                    v.push(format!("Violation in {:?}: Synchronous wait blocking message pump", p));
                }
                if line.contains("Start-Sleep") && !f_name.contains("Watchdog.psm1") {
                    v.push(format!("Violation in {:?}: Start-Sleep thread blocker", p));
                }
                if line.contains("while ($true)") && !f_name.contains("Watchdog.psm1") {
                    v.push(format!("Violation in {:?}: Infinite loop detected (use idle pump)", p));
                }
                if line.contains("[powershell]::Create()") { ps_created = true; }
                if line.contains(".Runspace =") { has_runspace_bind = true; }
            }
            if ps_created && !has_runspace_bind {
                v.push(format!("Violation in {:?}: Lack of Runspace isolation for [powershell]::Create()", p));
            }
            v
        }).collect();

    println!("--- InfrastructureAuditor Report ---");
    if findings.is_empty() {
        println!("0 violations.");
    } else {
        let mut unique: Vec<_> = findings.into_iter().collect();
        unique.sort();
        unique.dedup();
        unique.iter().for_each(|f| println!("{}", f));
    }
}
