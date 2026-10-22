//! The text of every generated README (ported from tools/gen_readmes.py; Python's str(), truthiness and
//! str.title() are reproduced where the output depends on them). Completion logic lives in the tracker;
//! this only lays its results out as markdown.
use serde_json::{Map, Value};
use std::collections::{BTreeSet, HashMap};

const FLAGS: [&str; 7] = [
    "`rules.md` present",
    "`usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)",
    "`usage/` has at least 2 INPUT .md samples",
    "typst engine passes (`usage/.check-typst.txt` valid)",
    "latex engine passes (`usage/.check-latex.txt` valid)",
    "docx engine passes (`usage/.check-docx.txt` valid)",
    "a review file in `reviews/`",
];

const HEAD: &str =
    "| Court | Alias | Status | Typst | LaTeX | DOCX | % |\n|---|---|---|---|---|---|---:|";

/// One tracker row: status, percent, typst, latex, docx, items (7 bits).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Row {
    pub st: String,
    pub pct: String,
    pub ty: String,
    pub la: String,
    pub dx: String,
    pub items: String,
}

/// Inputs: data/index.json, manual status per alias (manifest field 6), tracker rows per alias.
pub struct Inputs<'a> {
    pub courts: &'a Map<String, Value>,
    pub legacy: &'a Map<String, Value>,
    pub unplaced: &'a [Value],
    pub manual: HashMap<String, String>,
    pub rows: HashMap<String, Row>,
    /// alias -> its doc folders
    pub docs: HashMap<String, Vec<Doc>>,
}

/// One doc-folder row of a court README.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Doc {
    pub doctype: String,
    pub path: String,
    pub status: String,
    pub has_input: bool,
    pub pass: bool,
    /// Per engine (typst, latex, docx): '0' no template, '1' untested, '2' pass, '3' fail.
    pub engines: Vec<char>,
}

/// alias -> doc folders, from the tracker's alias|doctype|path|status|inputs|gates|engines lines.
pub fn docs(text: &str) -> HashMap<String, Vec<Doc>> {
    text.lines()
        .map(|l| l.split('|').map(str::to_string).collect::<Vec<_>>())
        .filter_map(|p| <[String; 7]>::try_from(p).ok())
        .fold(
            HashMap::new(),
            |mut m, [a, doctype, path, status, inputs, gates, engines]| {
                m.entry(a).or_default().push(Doc {
                    doctype,
                    path,
                    status,
                    has_input: inputs != "0",
                    pass: gates == "1",
                    engines: engines.chars().collect(),
                });
                m
            },
        )
}

/// alias -> manual status, from manifest lines with at least 7 fields.
pub fn manual(manifest: &str) -> HashMap<String, String> {
    manifest
        .lines()
        .map(|l| l.split('|').collect::<Vec<_>>())
        .filter(|p| p.len() >= 7)
        .map(|p| (p[0].to_string(), p[5].to_string()))
        .collect()
}

/// alias -> row, from tracker rows with exactly 7 fields.
pub fn rows(text: &str) -> HashMap<String, Row> {
    text.lines()
        .map(|l| l.split('|').map(str::to_string).collect::<Vec<_>>())
        .filter_map(|p| match <[String; 7]>::try_from(p) {
            Ok([a, st, pct, ty, la, dx, items]) => Some((
                a,
                Row {
                    st,
                    pct,
                    ty,
                    la,
                    dx,
                    items,
                },
            )),
            Err(_) => None,
        })
        .collect()
}

/// Python str() of a JSON value.
pub fn py_str(v: &Value) -> String {
    match v {
        Value::String(s) => s.clone(),
        Value::Null => "None".into(),
        Value::Bool(true) => "True".into(),
        Value::Bool(false) => "False".into(),
        other => other.to_string(),
    }
}

/// Python truthiness of a JSON value.
pub fn truthy(v: &Value) -> bool {
    match v {
        Value::Null | Value::Bool(false) => false,
        Value::String(s) => !s.is_empty(),
        Value::Number(n) => n.as_f64() != Some(0.0),
        Value::Array(a) => !a.is_empty(),
        Value::Object(o) => !o.is_empty(),
        Value::Bool(true) => true,
    }
}

/// Python str.title(): a cased letter is upper-cased after an uncased character, lower-cased otherwise.
pub fn py_title(s: &str) -> String {
    s.chars()
        .scan(false, |prev_cased, c| {
            let cased = c.is_lowercase() || c.is_uppercase();
            let out: String = match (cased, *prev_cased) {
                (true, false) => c.to_uppercase().collect(),
                (true, true) => c.to_lowercase().collect(),
                _ => c.to_string(),
            };
            *prev_cased = cased;
            Some(out)
        })
        .collect()
}

fn path_of(c: &Value) -> String {
    py_str(&c["path"])
}

/// os.path.relpath for a descendant (`to` under `from`), or `to` itself from the root ("").
fn relto(from: &str, to: &str) -> String {
    match from {
        "" => to.to_string(),
        f => to.strip_prefix(&format!("{f}/")).unwrap_or(to).to_string(),
    }
}

impl Inputs<'_> {
    fn row(&self, a: &str) -> Result<&Row, String> {
        self.rows
            .get(a)
            .ok_or_else(|| format!("no tracker row for {a}"))
    }

    fn table_row(&self, a: &str, from: &str) -> Result<String, String> {
        let c = &self.courts[a];
        let r = self.row(a)?;
        Ok(format!(
            "| [{}]({}) | `{a}` | {} | {} | {} | {} | {} |",
            py_str(&c["name"]).trim(),
            relto(from, &path_of(c)),
            r.st,
            r.ty,
            r.la,
            r.dx,
            r.pct
        ))
    }

    fn table(&self, aliases: &[&str], from: &str) -> Result<String, String> {
        match aliases {
            [] => Ok(String::new()),
            _ => {
                let body = aliases
                    .iter()
                    .map(|a| self.table_row(a, from))
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(format!("{HEAD}\n{}", body.join("\n")))
            }
        }
    }

    fn under(&self, d: &str) -> Vec<&str> {
        let prefix = format!("{d}/");
        self.courts
            .iter()
            .filter(|(_, c)| path_of(c).starts_with(&prefix))
            .map(|(a, _)| a.as_str())
            .collect()
    }

    /// The leaf README of court `a`; `extra` is its README.extra.md, if any.
    pub fn leaf(&self, a: &str, extra: Option<&str>) -> Result<String, String> {
        let c = &self.courts[a];
        let d = path_of(c);
        let up = "../".repeat(d.matches('/').count() + 1);
        let r = self.row(a)?;
        let manual = self
            .manual
            .get(a)
            .ok_or_else(|| format!("no manifest line for {a}"))?;
        let cl = &c["courtlistener_id"];
        let cl_line = match truthy(cl) {
            true => format!(
                "[{0}](https://www.courtlistener.com/?court={0})",
                py_str(cl)
            ),
            false => "none (not a CourtListener id)".to_string(),
        };
        let optional = [
            ("circuit", "- Circuit: `{}`"),
            ("state", "- State / territory: {}"),
            ("parent_alias", "- Parent: `{}`"),
        ]
        .iter()
        .filter(|(k, _)| truthy(&c[*k]))
        .map(|(k, f)| f.replace("{}", &py_str(&c[*k])));
        let legacy: Vec<String> = self
            .legacy
            .iter()
            .filter(|(_, t)| t.as_str() == Some(a))
            .map(|(l, _)| format!("`{l}`"))
            .collect();
        let legacy_line =
            (!legacy.is_empty()).then(|| format!("- Legacy aliases: {}", legacy.join(", ")));
        let checklist = FLAGS.iter().enumerate().map(|(i, desc)| {
            let mark = if r.items.chars().nth(i) == Some('1') {
                "x"
            } else {
                " "
            };
            format!("- [{mark}] {desc}")
        });
        let kids = self.under(&d);
        let mut out: Vec<String> = vec![
            format!("# {}", py_str(&c["name"]).trim()),
            String::new(),
            format!("- Alias: `{a}`"),
            format!("- CourtListener: {cl_line}"),
            format!("- Level: {}", py_str(&c["level"])),
        ];
        out.extend(optional);
        out.extend(legacy_line);
        out.extend([
            format!(
                "- Status: **{}** ({}%); manual status in `court.json`: `{manual}`",
                r.st, r.pct
            ),
            String::new(),
            "## Checklist".into(),
            String::new(),
        ]);
        out.extend(checklist);
        out.extend(
            [
                "",
                &format!("Engines (doc folders passing / with that template): typst `{}`, latex `{}`, docx `{}`.", r.ty, r.la, r.dx),
                "",
                "`done` is set by a human in `court.json` (`\"status\": \"done\"`); nothing automated writes it.",
                "A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).",
                "",
                &docs_text(self.docs.get(a).map_or(&[][..], Vec::as_slice)),
                "## Folders",
                "",
                "- `typst/` Typst template (primary)",
                "- `latex/` LaTeX template",
                "- `docx/` Word template (reference.docx + filters)",
                "- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`",
            ]
            .map(String::from),
        );
        out.extend(extra.map(|x| format!("\n{}", x.trim_end_matches('\n'))));
        if !kids.is_empty() {
            out.extend([
                String::new(),
                "## Subdivisions".into(),
                String::new(),
                self.table(&kids, &d)?,
            ]);
        }
        out.extend([
            String::new(),
            format!("[Formbook index]({up}README.md) | [Status table]({up}STATUS.md)"),
            String::new(),
        ]);
        Ok(out.join("\n"))
    }

    /// Every proper ancestor folder of a court path that is not itself a court, sorted.
    pub fn folders(&self) -> Vec<String> {
        let leaves: BTreeSet<String> = self.courts.values().map(path_of).collect();
        let dirs: BTreeSet<String> = leaves
            .iter()
            .flat_map(|p| {
                let parts: Vec<&str> = p.split('/').collect();
                (1..parts.len())
                    .map(move |i| parts[..i].join("/"))
                    .collect::<Vec<_>>()
            })
            .collect();
        dirs.into_iter().filter(|d| !leaves.contains(d)).collect()
    }

    /// The README of a non-court folder `d`.
    pub fn folder(&self, d: &str) -> Result<String, String> {
        let desc = self.under(d);
        let up = "../".repeat(d.matches('/').count() + 1);
        let title = match d {
            "courts" => "# Courts".to_string(),
            _ => format!(
                "# {}",
                py_title(&d.rsplit('/').next().unwrap_or(d).replace('-', " "))
            ),
        };
        let lines = [
            title,
            String::new(),
            format!("Courts under `{d}` ({}).", desc.len()),
            String::new(),
            self.table(&desc, d)?,
            String::new(),
            format!("[Formbook index]({up}README.md)"),
            String::new(),
        ];
        Ok(lines.join("\n"))
    }

    /// The top README's index block (between `<!-- index:start -->` and `<!-- index:end -->`).
    pub fn index_block(&self) -> Result<String, String> {
        let groups = first_seen(self.courts.values().map(|c| py_str(&c["group"])));
        let mut blk: Vec<String> = Vec::new();
        for g in &groups {
            let members: Vec<(&str, &Value)> = self
                .courts
                .iter()
                .filter(|(_, c)| &py_str(&c["group"]) == g)
                .map(|(a, c)| (a.as_str(), c))
                .collect();
            blk.extend([format!("## {g}"), String::new()]);
            let states = first_seen(
                members
                    .iter()
                    .filter(|(_, c)| truthy(&c["state"]))
                    .map(|(_, c)| py_str(&c["state"])),
            );
            let top: Vec<&str> = members
                .iter()
                .filter(|(_, c)| !truthy(&c["state"]))
                .map(|(a, _)| *a)
                .collect();
            if !top.is_empty() {
                blk.extend([self.table(&top, "")?, String::new()]);
            }
            for s in &states {
                let these: Vec<&str> = members
                    .iter()
                    .filter(|(_, c)| truthy(&c["state"]) && &py_str(&c["state"]) == s)
                    .map(|(a, _)| *a)
                    .collect();
                blk.extend([
                    format!("### {s}"),
                    String::new(),
                    self.table(&these, "")?,
                    String::new(),
                ]);
            }
        }
        if !self.unplaced.is_empty() {
            blk.extend(
                [
                    "## Unplaced",
                    "",
                    "In scope but with a location the circuit map cannot place; no folder is created until a human decides.",
                    "",
                    "| Alias | Name | courts-db location |",
                    "|---|---|---|",
                ]
                .map(String::from),
            );
            blk.extend(self.unplaced.iter().map(|u| {
                format!(
                    "| `{}` | {} | {} |",
                    py_str(&u["alias"]),
                    py_str(&u["name"]),
                    py_str(&u["location"])
                )
            }));
            blk.push(String::new());
        }
        Ok(blk.join("\n"))
    }
}

/// Distinct values in order of first appearance.
fn first_seen(it: impl Iterator<Item = String>) -> Vec<String> {
    it.fold(Vec::new(), |mut acc, v| {
        if !acc.contains(&v) {
            acc.push(v);
        }
        acc
    })
}

/// The "Doc folders" section of a court README (with a trailing blank line): the eval tally, one row per doc folder.
fn docs_text(ds: &[Doc]) -> String {
    let with: Vec<&Doc> = ds.iter().filter(|d| d.has_input).collect();
    let engine = |d: &Doc, i: usize| match d.engines.get(i) {
        Some('2') => "pass",
        Some('3') => "fail",
        Some('1') => "untested",
        _ => "—",
    };
    let link = |d: &Doc| match d.doctype.as_str() {
        "(court root)" => ".".to_string(),
        n => n.to_string(),
    };
    let rows: Vec<String> = ds
        .iter()
        .map(|d| {
            format!(
                "| [{}]({}) | {} | {} | {} | {} |",
                d.doctype,
                link(d),
                d.status,
                engine(d, 0),
                engine(d, 1),
                engine(d, 2)
            )
        })
        .collect();
    match ds.is_empty() {
        true => String::new(),
        false => format!(
            "## Doc folders\n\n{} of {} doc folders with an INPUT pass the typst eval.\n\n| Doc type | Status | Typst | LaTeX | DOCX |\n|---|---|---|---|---|\n{}\n",
            with.iter().filter(|d| d.pass).count(),
            with.len(),
            rows.join("\n")
        ),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn python_title() {
        assert_eq!(py_title("court of appeals"), "Court Of Appeals");
        assert_eq!(py_title("9th circuit"), "9Th Circuit");
        assert_eq!(py_title("o'brien DISTRICT"), "O'Brien District");
    }

    #[test]
    fn python_values() {
        assert_eq!(py_str(&Value::Null), "None");
        assert_eq!(py_str(&json!(3)), "3");
        assert!(!truthy(&json!("")));
        assert!(!truthy(&Value::Null));
        assert!(truthy(&json!("x")));
    }

    #[test]
    fn parse_rows_and_manual() {
        let r = rows("a|todo|0|—|—|—|00000000\nshort|x\n");
        assert_eq!(r.len(), 1);
        assert_eq!(r["a"].items, "00000000");
        let m = manual("a|G|l|n|p|done|11\nb|x\n");
        assert_eq!(m.get("a").map(String::as_str), Some("done"));
        assert!(!m.contains_key("b"));
    }

    #[test]
    fn relative_links() {
        assert_eq!(relto("", "courts/a"), "courts/a");
        assert_eq!(relto("courts", "courts/a/b"), "a/b");
    }
}
