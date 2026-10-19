//! `fb worklist [--stdout|--check]`: generate data/worklist.json, every open unit of work in the tree.
//!
//! A unit is one (court, doc type) pair. Its id is "<court alias>.<doctype>", also the claim branch
//! suffix (contrib/<id>). Per (court, doctype), looking at courts/<court>/<doctype>/:
//!   no folder, doctype is `core` for the court's level   -> kind new-template, priority high
//!   no folder, doctype is `extended` for the level       -> kind new-doctype,  priority normal
//!   folder, no typst/*.typ                               -> kind new-template, priority high
//!   folder + template, no usage/FILED-EXAMPLE-*.pdf      -> kind add-exemplar, priority high
//!   folder + template + FILED-EXAMPLE, longest usage/OUTPUT-*.typst.pdf shorter than the doc type's
//!   min_pages                                            -> kind deepen,       priority low
//!   anything else                                        -> complete, not listed
//! Vocabulary: data/doctypes.json. Courts: data/index.json. Court order: data/priority.json.
//! Output is deterministic (no timestamps), sorted by id, one unit per line.
use crate::proc::pdf_pages;
use crate::{fail, repo_root, Res};
use serde_json::{json, Map, Value};
use std::path::Path;
use std::process::ExitCode;

/// What the tree holds for one existing doc-type folder.
#[derive(Debug, Clone, PartialEq)]
pub struct Have {
    pub has_typ: bool,
    pub n_ex: usize,
    pub pages: u32,
}

#[derive(Debug, Clone, PartialEq)]
struct Want {
    d: String,
    tier: &'static str,
}

fn read_json(p: &Path) -> Res<Value> {
    let t = std::fs::read_to_string(p)
        .map_err(|e| fail(2, format!("fb worklist: {}: {e}", p.display())))?;
    serde_json::from_str(&t).map_err(|e| fail(2, format!("fb worklist: {}: {e}", p.display())))
}

fn strs(v: &Value) -> Vec<String> {
    v.as_array()
        .map(|a| {
            a.iter()
                .filter_map(|x| x.as_str().map(str::to_string))
                .collect()
        })
        .unwrap_or_default()
}

/// Longest typst-engine OUTPUT pdf in folder `d`, in pages (0 if none or no pdfinfo).
pub fn max_pages(d: &Path) -> u32 {
    files(d.join("usage"), |n| {
        n.starts_with("OUTPUT-") && n.ends_with(".typst.pdf")
    })
    .iter()
    .map(|f| pdf_pages(f))
    .max()
    .unwrap_or(0)
}

pub fn files(dir: impl AsRef<Path>, keep: impl Fn(&str) -> bool) -> Vec<std::path::PathBuf> {
    let mut v: Vec<_> = std::fs::read_dir(dir)
        .into_iter()
        .flatten()
        .flatten()
        .filter(|e| e.path().is_file() && keep(&e.file_name().to_string_lossy()))
        .map(|e| e.path())
        .collect();
    v.sort();
    v
}

/// The existing doc-type folders of one court, as (doctype, facts), in glob (sorted) order.
fn facts(path: &Path) -> Vec<(String, Have)> {
    let mut dirs: Vec<_> = std::fs::read_dir(path)
        .into_iter()
        .flatten()
        .flatten()
        .filter(|e| e.path().is_dir() && !e.file_name().to_string_lossy().starts_with('.'))
        .collect();
    dirs.sort_by_key(|e| e.file_name());
    dirs.into_iter()
        .filter_map(|e| {
            let b = e.file_name().to_string_lossy().into_owned();
            let d = e.path();
            if matches!(b.as_str(), "typst" | "latex" | "docx" | "usage" | "reviews")
                || d.join("court.json").is_file()
            {
                return None;
            }
            Some((
                b,
                Have {
                    has_typ: !files(d.join("typst"), |n| n.ends_with(".typ")).is_empty(),
                    n_ex: files(d.join("usage"), |n| {
                        n.starts_with("FILED-EXAMPLE-") && n.ends_with(".pdf")
                    })
                    .len(),
                    pages: max_pages(&d),
                },
            ))
        })
        .collect()
}

/// The unit (without the court columns) for an existing folder, or None when it is complete.
fn existing_unit(f: &Have, d: &str, min: f64) -> Option<(&'static str, &'static str, String)> {
    if !f.has_typ {
        let note = if f.n_ex > 0 {
            "folder has an exemplar but no typst template"
        } else {
            "folder exists but has no typst template and no exemplar"
        };
        Some(("new-template", "high", note.into()))
    } else if f.n_ex == 0 {
        Some((
            "add-exemplar",
            "high",
            "template exists but no usage/FILED-EXAMPLE-*.pdf (BLOCKED: no exemplar)".into(),
        ))
    } else if f.pages > 0 && f64::from(f.pages) < min {
        Some((
            "deepen",
            "low",
            format!(
                "longest sample is {} pages; a realistic {d} runs about {}+",
                f.pages,
                num(min)
            ),
        ))
    } else {
        None
    }
}

/// A number as jq prints it in string interpolation: integers without a fraction.
fn num(n: f64) -> String {
    if n.fract() == 0.0 {
        format!("{}", n as i64)
    } else {
        format!("{n}")
    }
}

/// Every open unit, sorted by id. `have` yields the folder facts of a court path.
pub fn units(
    index: &Value,
    voc: &Value,
    priority: &Value,
    have: &dyn Fn(&str) -> Vec<(String, Have)>,
) -> Vec<Value> {
    let order = strs(&priority["order"]);
    let rank = |a: &str| order.iter().position(|x| x == a).unwrap_or(order.len());
    let mut out: Vec<(String, Value)> = vec![];
    for (alias, c) in index["courts"].as_object().into_iter().flatten() {
        let path = c["path"].as_str().unwrap_or("");
        let level = c["level"].as_str().unwrap_or("");
        let lv = &voc["levels"][level];
        let want: Vec<Want> = strs(&lv["core"])
            .into_iter()
            .map(|d| Want { d, tier: "core" })
            .chain(strs(&lv["extended"]).into_iter().map(|d| Want {
                d,
                tier: "extended",
            }))
            .collect();
        let facts = have(path);
        let mut rows: Vec<(String, &str, &str, String)> = vec![]; // doctype, kind, priority, note
        for w in want
            .iter()
            .filter(|w| !facts.iter().any(|(d, _)| *d == w.d))
        {
            let (kind, pr) = if w.tier == "core" {
                ("new-template", "high")
            } else {
                ("new-doctype", "normal")
            };
            rows.push((w.d.clone(), kind, pr, "no folder yet".into()));
        }
        for (d, f) in &facts {
            let min = voc["doctypes"][d.as_str()]["min_pages"]
                .as_f64()
                .unwrap_or(2.0);
            if let Some((kind, pr, note)) = existing_unit(f, d, min) {
                rows.push((d.clone(), kind, pr, note));
            }
        }
        for (d, kind, pr, note) in rows {
            let id = format!("{alias}.{d}");
            let title = voc["doctypes"][d.as_str()]["title"]
                .as_str()
                .unwrap_or(&d)
                .to_string();
            let mut u = Map::new();
            u.insert("id".into(), json!(id));
            u.insert("kind".into(), json!(kind));
            u.insert("alias".into(), json!(alias));
            u.insert("court_path".into(), json!(path));
            u.insert("level".into(), json!(level));
            u.insert("doctype".into(), json!(d));
            u.insert("title".into(), json!(title));
            u.insert("folder".into(), json!(format!("{path}/{d}")));
            u.insert("status".into(), json!("open"));
            u.insert("priority".into(), json!(pr));
            u.insert("court_rank".into(), json!(rank(alias)));
            u.insert("note".into(), json!(note));
            out.push((id, Value::Object(u)));
        }
    }
    out.sort_by(|a, b| a.0.cmp(&b.0));
    out.into_iter().map(|(_, u)| u).collect()
}

/// The file text: a header line, one unit per line (comma-led after the first), a closing line.
pub fn render(units: &[Value]) -> String {
    let mut counts = Map::new();
    let mut kinds: Vec<&str> = units.iter().filter_map(|u| u["kind"].as_str()).collect();
    kinds.sort();
    kinds.dedup();
    for k in kinds {
        counts.insert(
            k.into(),
            json!(units.iter().filter(|u| u["kind"] == k).count()),
        );
    }
    let mut s = format!(
        "{{\"schema\": 1, \"generated_by\": \"fb worklist\", \"count\": {}, \"counts\": {},\n\"units\": [\n",
        units.len(),
        Value::Object(counts)
    );
    for (i, u) in units.iter().enumerate() {
        s.push_str(if i == 0 { "" } else { "," });
        s.push_str(&u.to_string());
        s.push('\n');
    }
    s.push_str("]}\n");
    s
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let mode = match args {
        [] => "write",
        [a] if a == "--stdout" => "stdout",
        [a] if a == "--check" => "check",
        _ => return Err(fail(2, "usage: fb worklist [--stdout|--check]")),
    };
    let root = repo_root()?;
    let index = read_json(&root.join("data/index.json"))?;
    let voc = read_json(&root.join("data/doctypes.json"))?;
    let priority = read_json(&root.join("data/priority.json"))?;
    let us = units(&index, &voc, &priority, &|p| facts(&root.join(p)));
    let text = render(&us);
    let target = root.join("data/worklist.json");
    match mode {
        "stdout" => print!("{text}"),
        "check" => {
            if std::fs::read_to_string(&target).ok().as_deref() != Some(text.as_str()) {
                return Err(fail(
                    1,
                    "fb worklist: data/worklist.json is stale; run: just worklist",
                ));
            }
            println!("worklist.json is current");
        }
        _ => {
            std::fs::write(&target, &text)
                .map_err(|e| fail(2, format!("fb worklist: {}: {e}", target.display())))?;
            let counts = serde_json::from_str::<Value>(&text)
                .map(|v| v["counts"].to_string())
                .unwrap_or_default();
            println!("wrote data/worklist.json: {} open units {counts}", us.len());
        }
    }
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fixture() -> (Value, Value, Value) {
        (
            json!({"courts": {"ca1": {"path": "courts/c1", "name": "One", "level": "appeals"},
                              "ca2": {"path": "courts/c2", "name": "Two", "level": "appeals"}}}),
            json!({"levels": {"appeals": {"core": ["opening-brief"], "extended": ["amicus-brief"]}},
                   "doctypes": {"opening-brief": {"title": "Opening brief", "min_pages": 10}}}),
            json!({"order": ["ca2", "ca1"]}),
        )
    }

    fn h(n_ex: usize, pages: u32) -> Have {
        Have {
            has_typ: true,
            n_ex,
            pages,
        }
    }

    fn untemplated(n_ex: usize) -> Have {
        Have {
            has_typ: false,
            n_ex,
            pages: 0,
        }
    }

    #[test]
    fn missing_folders_become_new_units_by_tier() {
        let (i, v, p) = fixture();
        let us = units(&i, &v, &p, &|_| vec![]);
        let ids: Vec<&str> = us.iter().map(|u| u["id"].as_str().unwrap()).collect();
        assert_eq!(
            ids,
            [
                "ca1.amicus-brief",
                "ca1.opening-brief",
                "ca2.amicus-brief",
                "ca2.opening-brief"
            ]
        );
        assert_eq!(us[0]["kind"], "new-doctype");
        assert_eq!(us[0]["priority"], "normal");
        assert_eq!(us[1]["kind"], "new-template");
        assert_eq!(us[1]["title"], "Opening brief");
        assert_eq!(us[0]["title"], "amicus-brief");
        assert_eq!(us[3]["court_rank"], 0);
        assert_eq!(us[1]["court_rank"], 1);
    }

    #[test]
    fn existing_folder_states() {
        let (i, v, p) = fixture();
        let st = |f: Have| {
            units(&i, &v, &p, &|path| {
                if path == "courts/c1" {
                    vec![("opening-brief".into(), f.clone())]
                } else {
                    vec![]
                }
            })
            .into_iter()
            .find(|u| u["id"] == "ca1.opening-brief")
        };
        assert_eq!(
            st(untemplated(1)).unwrap()["note"],
            "folder has an exemplar but no typst template"
        );
        assert_eq!(st(untemplated(0)).unwrap()["kind"], "new-template");
        assert_eq!(st(h(0, 0)).unwrap()["kind"], "add-exemplar");
        let d = st(h(1, 4)).unwrap();
        assert_eq!(d["kind"], "deepen");
        assert_eq!(
            d["note"],
            "longest sample is 4 pages; a realistic opening-brief runs about 10+"
        );
        assert!(st(h(1, 10)).is_none());
        assert!(st(h(1, 0)).is_none(), "no pdfinfo (0 pages) never deepens");
    }

    #[test]
    fn render_layout_is_one_unit_per_line() {
        let (i, v, p) = fixture();
        let us = units(&i, &v, &p, &|_| vec![]);
        let t = render(&us);
        let lines: Vec<&str> = t.lines().collect();
        assert!(lines[0].starts_with("{\"schema\": 1, \"generated_by\": \"fb worklist\", \"count\": 4, \"counts\": {\"new-doctype\":2,\"new-template\":2},"));
        assert_eq!(lines[1], "\"units\": [");
        assert!(lines[2].starts_with("{\"id\":\"ca1.amicus-brief\""));
        assert!(lines[3].starts_with(",{\"id\":"));
        assert_eq!(lines.last(), Some(&"]}"));
        assert!(serde_json::from_str::<Value>(&t).is_ok());
    }
}
