//! `fb manifest [--doctypes] [repo-root]`: one line per court (or per Typst doc type) for the tracker.
//!
//! Court lines:    alias|group|level|name|path|manual|flags   (flags: see keys::court_flags)
//! Doc-type lines: alias|group|doctype|path|flags             (flags: see keys::doctype_flags)
//! Order follows data/index.json; courts missing from it sort with position 0, ties bytewise.
mod files;
mod keys;

use crate::{fail, Res};
use serde_json::Value;
use std::collections::HashMap;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

pub fn main(args: &[String]) -> Res<ExitCode> {
    let (doctypes, rest) = match args.split_first() {
        Some((f, r)) if f == "--doctypes" => (true, r),
        _ => (false, args),
    };
    let root = rest
        .first()
        .map_or_else(crate::repo_root, |r| Ok(PathBuf::from(r)))?;
    let out = if doctypes {
        doctype_lines(&root)?
    } else {
        court_lines(&root)?
    };
    std::io::stdout()
        .write_all(out.as_bytes())
        .map_err(|e| fail(1, format!("fb manifest: {e}")))?;
    Ok(ExitCode::SUCCESS)
}

/// The court manifest as text (one line per court.json, each ending in a newline).
pub fn court_lines(root: &Path) -> Res<String> {
    let order = Order::load(root)?;
    let rows = court_jsons(root)?
        .iter()
        .map(|cj| {
            let j = read_json(&root.join(cj))?;
            let dir = parent(cj);
            let alias = jq_str(&j["alias"]);
            let name = jq_str(&j["name"]).replace(['|', '\n'], " ");
            let manual = match &j["status"] {
                Value::Null | Value::Bool(false) => "todo".to_string(),
                v => jq_str(v),
            };
            let rest = [
                jq_str(&j["level"]),
                name,
                jq_str(&j["path"]),
                manual,
                keys::court_flags(&root.join(dir)),
            ];
            Ok(order.row(&alias, &rest, &[]))
        })
        .collect::<Res<Vec<_>>>()?;
    Ok(Order::render(rows))
}

/// The doc-type manifest: the court root (when typst/main.typ exists) and each doc-type subfolder.
pub fn doctype_lines(root: &Path) -> Res<String> {
    let order = Order::load(root)?;
    let rows = court_jsons(root)?
        .iter()
        .map(|cj| {
            let alias = jq_raw(&read_json(&root.join(cj))?["alias"]);
            let dir = parent(cj);
            let own = root.join(&dir).join("typst").join("main.typ").is_file();
            let court_root = own.then(|| ("(court root)".to_string(), dir.clone()));
            let subs = files::visible(&root.join(&dir))
                .into_iter()
                .map(|n| (n.clone(), format!("{dir}/{n}")))
                .filter(|(_, p)| is_doctype(&root.join(p)));
            Ok(court_root
                .into_iter()
                .chain(subs)
                .map(|(dt, p)| {
                    let flags = keys::doctype_flags(&root.join(&p));
                    order.row(&alias, &[dt.clone(), p, flags], &[alias.clone(), dt])
                })
                .collect::<Vec<_>>())
        })
        .collect::<Res<Vec<_>>>()?;
    Ok(Order::render(rows.into_iter().flatten().collect()))
}

/// A subfolder is a doc type when it is no court of its own and holds typst/, samples/ or exemplars/.
fn is_doctype(p: &Path) -> bool {
    p.is_dir()
        && !p.join("court.json").is_file()
        && ["typst", "samples", "exemplars"]
            .iter()
            .any(|s| p.join(s).is_dir())
}

/// Every `court.json` under courts/, as a root-relative path.
fn court_jsons(root: &Path) -> Res<Vec<String>> {
    fn walk(root: &Path, rel: &str, acc: &mut Vec<String>) {
        let names = fs::read_dir(root.join(rel))
            .map(|rd| rd.filter_map(Result::ok).collect::<Vec<_>>())
            .unwrap_or_default();
        names.iter().for_each(|e| {
            let name = e.file_name().to_string_lossy().into_owned();
            let child = format!("{rel}/{name}");
            match e.file_type() {
                Ok(t) if t.is_dir() => walk(root, &child, acc),
                _ if name == "court.json" => acc.push(child),
                _ => {}
            }
        });
    }
    let mut acc = Vec::new();
    walk(root, "courts", &mut acc);
    Ok(acc)
}

fn parent(rel: &str) -> String {
    rel.rsplit_once('/').map_or(".", |(d, _)| d).to_string()
}

pub fn read_json(p: &Path) -> Res<Value> {
    let text = fs::read_to_string(p).map_err(|e| fail(1, format!("{}: {e}", p.display())))?;
    serde_json::from_str(&text).map_err(|e| fail(1, format!("{}: {e}", p.display())))
}

/// A value as `jq -r` prints it.
pub fn jq_raw(v: &Value) -> String {
    match v {
        Value::String(s) => s.clone(),
        other => other.to_string(),
    }
}

/// A value as jq's `join` renders it (null becomes empty).
fn jq_str(v: &Value) -> String {
    match v {
        Value::Null => String::new(),
        other => jq_raw(other),
    }
}

/// data/index.json order: alias -> (position, group).
struct Order(HashMap<String, (usize, String)>);

/// A row ready to sort: index position, extra sort keys, the whole keyed line (last resort), the output line.
type Row = (usize, Vec<String>, String, String);

impl Order {
    fn load(root: &Path) -> Res<Order> {
        let idx = read_json(&root.join("data/index.json"))?;
        let map = idx["courts"]
            .as_object()
            .map(|courts| {
                courts
                    .iter()
                    .enumerate()
                    .map(|(i, (a, c))| (a.clone(), (i, jq_str(&c["group"]))))
                    .collect()
            })
            .unwrap_or_default();
        Ok(Order(map))
    }

    /// `alias|group|rest...`, keyed like `sort -t'|' -k1,1n <keys>` over "pos|alias|group|rest" (C locale;
    /// an alias missing from the index has an empty position, which sorts as 0).
    fn row(&self, alias: &str, rest: &[String], keys: &[String]) -> Row {
        let (pos, group) = self
            .0
            .get(alias)
            .map_or((None, ""), |(p, g)| (Some(*p), g.as_str()));
        let line = [alias, group]
            .into_iter()
            .chain(rest.iter().map(String::as_str))
            .collect::<Vec<_>>()
            .join("|");
        let whole = format!("{}|{line}", pos.map_or(String::new(), |p| p.to_string()));
        (pos.unwrap_or(0), keys.to_vec(), whole, line)
    }

    fn render(mut rows: Vec<Row>) -> String {
        rows.sort_by(|a, b| (a.0, &a.1, &a.2).cmp(&(b.0, &b.1, &b.2)));
        rows.into_iter().map(|r| r.3 + "\n").collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn jq_rendering() {
        assert_eq!(jq_raw(&json!("a")), "a");
        assert_eq!(jq_raw(&Value::Null), "null");
        assert_eq!(jq_str(&Value::Null), "");
        assert_eq!(jq_str(&json!(3)), "3");
    }

    #[test]
    fn order_rows() {
        let o = Order(
            [
                ("b".to_string(), (0, "G".to_string())),
                ("a".to_string(), (1, "H".to_string())),
            ]
            .into_iter()
            .collect(),
        );
        let rows = vec![
            o.row("a", &["x".into()], &[]),
            o.row("zz", &["y".into()], &[]),
            o.row("b", &["z".into()], &[]),
        ];
        // "zz" is not in the index: position 0, and "0|b..." sorts before "|zz..." bytewise
        assert_eq!(Order::render(rows), "b|G|z\nzz||y\na|H|x\n");
    }
}
