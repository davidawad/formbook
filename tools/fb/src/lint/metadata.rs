//! Validate a markdown filing's YAML frontmatter against the repo brief metadata contract.
use crate::{fail, Res};
use serde_yaml::Value;
use std::path::Path;
use std::process::ExitCode;

pub(crate) fn frontmatter(text: &str) -> Result<&str, String> {
    let mut lines = text.split_inclusive('\n');
    if lines.next().map(str::trim_end) != Some("---") {
        return Err("file must start with YAML frontmatter delimited by ---".into());
    }
    let body_start = text.find('\n').map(|n| n + 1).unwrap_or(text.len());
    let rest = &text[body_start..];
    let end = rest
        .split_inclusive('\n')
        .scan(0usize, |offset, line| {
            let start = *offset;
            *offset += line.len();
            Some((start, line))
        })
        .find(|(_, line)| matches!(line.trim_end(), "---" | "..."))
        .map(|(start, _)| start)
        .ok_or_else(|| "frontmatter has no closing --- or ... delimiter".to_string())?;
    Ok(&rest[..end])
}

fn get<'a>(map: &'a serde_yaml::Mapping, key: &str) -> Option<&'a Value> {
    map.get(Value::String(key.to_string()))
}

fn is_nonempty_string(value: Option<&Value>) -> bool {
    matches!(value, Some(Value::String(s)) if !s.trim().is_empty())
}

fn string_list(value: Option<&Value>) -> bool {
    matches!(value, Some(Value::Sequence(xs)) if !xs.is_empty() && xs.iter().all(|x| matches!(x, Value::String(s) if !s.trim().is_empty())))
}

fn canonical(map: &serde_yaml::Mapping) -> Vec<String> {
    let mut errors = Vec::new();
    let key = "filing_type";
    if !is_nonempty_string(get(map, key)) {
        errors.push(format!("`{key}` must be a non-empty string"));
    }
    if !is_nonempty_string(get(map, "caption")) {
        errors.push("`caption` must be a non-empty string".into());
    }
    match get(map, "parties") {
        Some(Value::Sequence(parties)) if !parties.is_empty() => {
            for (i, party) in parties.iter().enumerate() {
                let valid = party.as_mapping().is_some_and(|p| {
                    is_nonempty_string(get(p, "name")) && is_nonempty_string(get(p, "role"))
                });
                if !valid {
                    errors.push(format!(
                        "`parties[{i}]` must have non-empty string `name` and `role`"
                    ));
                }
            }
        }
        _ => errors.push("`parties` must be a non-empty list of {name, role} objects".into()),
    }
    match get(map, "lower_court") {
        Some(Value::Mapping(court)) => {
            for key in ["name", "case_number"] {
                if !is_nonempty_string(get(court, key)) {
                    errors.push(format!("`lower_court.{key}` must be a non-empty string"));
                }
            }
        }
        _ => errors.push("`lower_court` must be an object".into()),
    }
    match get(map, "counsel") {
        Some(Value::Sequence(groups)) if !groups.is_empty() => {
            for (i, group) in groups.iter().enumerate() {
                let valid = group
                    .as_mapping()
                    .is_some_and(|g| string_list(get(g, "names")) && string_list(get(g, "lines")));
                if !valid {
                    errors.push(format!(
                        "`counsel[{i}]` must have non-empty string lists `names` and `lines`"
                    ));
                }
            }
        }
        _ => errors.push("`counsel` must be a non-empty list of counsel groups".into()),
    }
    errors
}

/// ca9's established brief metadata predates the cross-court fields. Keep it valid while the shared
/// contract is adopted: `caption` contains party names and designations, and `proceeding` contains
/// the lower-court description.
fn ca9_legacy(map: &serde_yaml::Mapping) -> Vec<String> {
    let mut errors = Vec::new();
    for key in ["case_number", "proceeding", "brief_title", "phone"] {
        if !is_nonempty_string(get(map, key)) {
            errors.push(format!("legacy ca9 `{key}` must be a non-empty string"));
        }
    }
    if !matches!(get(map, "caption"), Some(Value::Sequence(sides)) if sides.len() == 2 && sides.iter().all(|side| side.as_mapping().is_some_and(|m| string_list(get(m, "names")) && is_nonempty_string(get(m, "designation")))))
    {
        errors
            .push("legacy ca9 `caption` must contain two sides with names and designation".into());
    }
    if !matches!(get(map, "counsel"), Some(Value::Sequence(groups)) if !groups.is_empty() && groups.iter().all(|g| g.as_mapping().is_some_and(|m| string_list(get(m, "names")) && string_list(get(m, "lines")))))
    {
        errors.push(
            "legacy ca9 `counsel` must be a non-empty list of groups with names and lines".into(),
        );
    }
    if !matches!(get(map, "signature"), Some(Value::Mapping(sig)) if is_nonempty_string(get(sig, "signer")) && string_list(get(sig, "lines")))
    {
        errors.push(
            "legacy ca9 `signature` must have a signer and non-empty string list `lines`".into(),
        );
    }
    errors
}

fn validate(text: &str) -> Result<(), Vec<String>> {
    let source = frontmatter(text).map_err(|e| vec![e])?;
    let value: Value =
        serde_yaml::from_str(source).map_err(|e| vec![format!("invalid YAML frontmatter: {e}")])?;
    let Some(map) = value.as_mapping() else {
        return Err(vec!["frontmatter must be a YAML object".into()]);
    };
    let canonical_errors = canonical(map);
    if canonical_errors.is_empty() {
        return Ok(());
    }
    let legacy_errors = ca9_legacy(map);
    if legacy_errors.is_empty() {
        return Ok(());
    }
    let mut errors =
        vec!["metadata matches neither the shared brief profile nor the ca9 legacy profile".into()];
    errors.extend(canonical_errors);
    errors.extend(legacy_errors);
    Err(errors)
}

pub fn main(path: &Path) -> Res<ExitCode> {
    let text = std::fs::read_to_string(path)
        .map_err(|e| fail(2, format!("fb lint metadata: {}: {e}", path.display())))?;
    match validate(&text) {
        Ok(()) => {
            println!("LINT metadata {}: valid", path.display());
            Ok(ExitCode::SUCCESS)
        }
        Err(errors) => {
            for e in errors {
                println!("LINT metadata {}: {e}", path.display());
            }
            println!("RESULT: LINT FAIL (metadata)");
            Ok(ExitCode::from(1))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const CANONICAL: &str = "---\nfiling_type: opening brief\ncaption: A v. B\nparties:\n  - name: A\n    role: appellant\nlower_court:\n  name: U.S. District Court\n  case_number: 1:25-cv-1\ncounsel:\n  - names: [Ada Counsel]\n    lines: [Firm, Address]\n---\n# Argument\n";

    #[test]
    fn accepts_shared_brief_metadata() {
        assert!(validate(CANONICAL).is_ok());
    }

    #[test]
    fn accepts_ca9_legacy_brief_metadata() {
        let sample = "---\ncase_number: 26-1\ncaption:\n  - names: [A]\n    designation: Appellant\n  - names: [B]\n    designation: Appellee\nproceeding: Appeal from trial court\nbrief_title: Opening Brief\ncounsel:\n  - names: [Ada]\n    lines: [Firm]\nphone: 555-0100\nsignature:\n  signer: Ada\n  lines: [Firm, Address]\n---\n";
        assert!(validate(sample).is_ok());
    }

    #[test]
    fn rejects_missing_metadata_and_bad_yaml() {
        assert!(validate("---\nfiling_type: brief\n---\n").is_err());
        assert!(validate("---\ncaption: [broken\n---\n").is_err());
    }
}
