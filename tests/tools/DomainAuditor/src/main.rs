// DomainAuditor
// Audits Core and Analysis layers for FP purity and synchronous blocking.
// Built strictly with Functional Paradigm concepts (Immutable, Iterators)

fn main() {

    // Static Analysis Phase
    let ps1_files = vec!["Modules\\Core\\EventBus.psm1", "Modules\\Core\\State.psm1"];
    let findings: Vec<String> = ps1_files.iter()
        .filter_map(|f| std::fs::read_to_string(format!("C:\\Users\\danie\\SCAPE_ROOT\\{}", f)).ok())
        .flat_map(|content| {
            let mut v = Vec::new();
            if content.contains("$Script:") { v.push("Violation: Mutable $Script: state detected in Domain layer".to_string()); }
            if content.contains(".Wait()") || content.contains("Wait-Job") { v.push("Violation: Synchronous thread block in Domain".to_string()); }
            v
        }).collect();

    println!("--- DomainAuditor Report ---");
    findings.iter().for_each(|f| println!("{}", f));

}
