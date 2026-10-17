//! The check list of checks.yaml as check.sh read it, and the PASS/FAIL/SKIP text.
use super::sh::{cmd, pipe_capture, Env};
use crate::Res;

/// The jq program of check.sh: one tab-separated row per check.
const JQ: &str = r#".[] | [.id, (.gate|tostring), .method, .name, .expect, (.fix.anchor // ""), ((.engines // ["*"]) | join(",")), (.engines_reason // "-"), ((.args // []) | join("\u001f"))] | @tsv"#;

#[derive(Debug, Clone, PartialEq, Default)]
pub struct Row {
    pub id: String,
    pub gate: String,
    pub method: String,
    pub name: String,
    pub expect: String,
    pub anchor: String,
    pub engines: String,
    pub ereason: String,
    pub args: String,
}

/// `IFS=<tab> read -r v1 .. vn`: tab is IFS white space, so runs of tabs are one separator and
/// leading/trailing tabs are dropped; the last variable takes the rest of the line.
pub fn read_fields(line: &str, n: usize) -> Vec<String> {
    let mut rest = line.trim_start_matches('\t');
    let mut v: Vec<String> = (1..n)
        .map(|_| {
            let (f, r) = rest.split_once('\t').unwrap_or((rest, ""));
            rest = r.trim_start_matches('\t');
            f.to_string()
        })
        .collect();
    v.push(rest.trim_end_matches('\t').to_string());
    v
}

pub fn parse_row(line: &str) -> Row {
    let f = read_fields(line, 9);
    Row {
        id: f[0].clone(),
        gate: f[1].clone(),
        method: f[2].clone(),
        name: f[3].clone(),
        expect: f[4].clone(),
        anchor: f[5].clone(),
        engines: f[6].clone(),
        ereason: f[7].clone(),
        args: f[8].clone(),
    }
}

/// `yq -o=json e '.checks' checks.yaml | jq -r ...`, one Row per line.
pub fn load(env: &Env, court: &str) -> Res<Vec<Row>> {
    let file = format!("{court}/checks.yaml");
    let yq = cmd(env, "yq", &["-o=json", "e", ".checks", &file]);
    let jq = cmd(env, "jq", &["-r", JQ]);
    let text = pipe_capture(yq, jq)?;
    Ok(match text.is_empty() {
        true => vec![],
        false => text.split('\n').map(parse_row).collect(),
    })
}

/// `case " $GATES " in *" $gate "*`.
pub fn in_gates(gates: &str, gate: &str) -> bool {
    format!(" {gates} ").contains(&format!(" {gate} "))
}

/// `case ",$engines," in *",*,"* | *",$ENGINE,"*`.
pub fn runs_on(engines: &str, engine: &str) -> bool {
    let e = format!(",{engines},");
    e.contains(",*,") || e.contains(&format!(",{engine},"))
}

/// `IFS=<US>; set -- $args`: non-white separator, one trailing separator ends the last field.
pub fn split_args(args: &str) -> Vec<String> {
    let mut v: Vec<String> = args.split('\u{1f}').map(String::from).collect();
    if v.last().is_some_and(|s| s.is_empty()) {
        v.pop();
    }
    v
}

/// printf '%-14s': pad with spaces to 14 bytes.
pub fn pad14(s: &str) -> String {
    format!("{s}{}", " ".repeat(14usize.saturating_sub(s.len())))
}

pub fn skip_text(r: &Row, engine: &str) -> String {
    format!(
        "  SKIP  {} {}\n          not run for engine {engine} (only: {}): {}\n",
        pad14(&r.id),
        r.name,
        r.engines,
        r.ereason
    )
}

pub fn pass_text(r: &Row, meas: &str) -> String {
    format!("  PASS  {} {}\n          {meas}\n", pad14(&r.id), r.name)
}

/// The FAIL block, with DETAIL's lines (if any) prefixed by `          - `.
pub fn fail_text(r: &Row, meas: &str, template: &str, line: Option<usize>, detail: &str) -> String {
    let at = line.map_or("?".to_string(), |n| n.to_string());
    let head = format!(
        "  FAIL  {} {}\n          measured: {meas}\n          expected: {}\n          fix:      {template}:{at}  ({})\n",
        pad14(&r.id),
        r.name,
        r.expect,
        r.anchor
    );
    let det: String = match detail.is_empty() {
        true => String::new(),
        false => detail
            .split('\n')
            .map(|l| format!("          - {l}\n"))
            .collect(),
    };
    head + &det
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn read_like_the_shell() {
        assert_eq!(read_fields("a\t\tb\tc\t", 3), vec!["a", "b", "c"]);
        assert_eq!(read_fields("a\tb\tc\td\t\t", 3), vec!["a", "b", "c\td"]);
        assert_eq!(read_fields("\ta", 3), vec!["a", "", ""]);
    }

    #[test]
    fn rows() {
        let r = parse_row("CA9-X\t1\theading_present\tn\te\tanc\t*\t-\t^a\u{1f}b");
        assert_eq!(r.method, "heading_present");
        assert_eq!(split_args(&r.args), vec!["^a", "b"]);
        // an empty args column (trailing tab) is no argument at all
        let r = parse_row("CA9-X\t1\tm\tn\te\tanc\t*\t-\t");
        assert_eq!((r.ereason.as_str(), r.args.as_str()), ("-", ""));
        assert!(split_args("").is_empty());
        assert_eq!(
            split_args("\u{1f}x\u{1f}\u{1f}y\u{1f}"),
            vec!["", "x", "", "y"]
        );
        // an empty anchor collapses: the following columns shift left, as in check.sh
        let r = parse_row("I\t0\tm\tn\te\t\t*\t-\t");
        assert_eq!((r.anchor.as_str(), r.engines.as_str()), ("*", "-"));
    }

    #[test]
    fn filters() {
        assert!(in_gates("0", "0"));
        assert!(in_gates("1 2", "2"));
        assert!(!in_gates("1", "11"));
        assert!(!in_gates("1", ""));
        assert!(runs_on("*", "docx"));
        assert!(runs_on("typst,latex", "latex"));
        assert!(!runs_on("typst", "docx"));
    }

    #[test]
    fn text() {
        assert_eq!(pad14("CA9-FORM-001"), "CA9-FORM-001  ");
        assert_eq!(pad14("CA9-REVIEW-0001x"), "CA9-REVIEW-0001x");
        assert_eq!(pad14("é"), format!("é{}", " ".repeat(12)));
        let r = Row {
            id: "ID".into(),
            name: "nm".into(),
            expect: "ex".into(),
            anchor: "an".into(),
            engines: "typst".into(),
            ereason: "why".into(),
            ..Row::default()
        };
        assert_eq!(
            pass_text(&r, "m"),
            "  PASS  ID             nm\n          m\n"
        );
        assert_eq!(
            skip_text(&r, "docx"),
            "  SKIP  ID             nm\n          not run for engine docx (only: typst): why\n"
        );
        assert_eq!(
            fail_text(&r, "m", "t.typ", None, "a\n\nb"),
            "  FAIL  ID             nm\n          measured: m\n          expected: ex\n          fix:      t.typ:?  (an)\n          - a\n          - \n          - b\n"
        );
        assert!(fail_text(&r, "m", "t", Some(7), "").ends_with("t:7  (an)\n"));
    }
}
