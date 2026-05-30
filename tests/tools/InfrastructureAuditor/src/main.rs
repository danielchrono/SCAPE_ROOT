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
            if content.contains("Wait-Job") || content.contains(".Wait()") { v.push(format!("Violation in {:?}: Synchronous wait blocking message pump", p)); }
            if content.contains("Start-Sleep") { v.push(format!("Violation in {:?}: Start-Sleep thread blocker", p)); }
            if content.contains("while (-not") { v.push(format!("Violation in {:?}: Spinlock polling detected", p)); }
            v
        }).collect();

    println!("--- InfrastructureAuditor Report ---");
    findings.iter().for_each(|f| println!("{}", f));

}
