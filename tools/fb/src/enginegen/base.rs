//! A layout's `base:` (fb-595.17): a shared layout (`base: /lib/layouts/<name>.yaml`, a path from the repo root) that
//! the folder's own `typst/layout.yaml` overlays, as lib/typst/xdoc.typ `with-base` reads it. The generic FRCP brief
//! is one base and each federal district's local rules are the overlay on it.
//!
//! The merge: a mapping of the overlay merges key by key into the base's (recursively); any other value (a number,
//! a string, a list of blocks) replaces the base's; a null (`~`) drops the base's key. A base may name its own base.
use serde_yaml::{Mapping, Value};
use std::path::Path;

/// How deep bases may chain before the chain is taken for a cycle.
const DEPTH: usize = 8;

/// `over` merged onto `base`.
pub fn merge(base: Value, over: Value) -> Value {
    match (base, over) {
        (Value::Mapping(mut b), Value::Mapping(o)) => {
            for (k, v) in o {
                if v.is_null() {
                    b.remove(&k);
                    continue;
                }
                let merged = match b.remove(&k) {
                    Some(old) => merge(old, v),
                    None => v,
                };
                b.insert(k, merged);
            }
            Value::Mapping(b)
        }
        (_, o) => o,
    }
}

/// The layout `l` with its `base` (and the base's own) merged under it; `read(path)` reads a base by its path from the
/// repo root (`/lib/layouts/x.yaml`). A layout without `base` is returned as it is.
pub fn resolve<R: Fn(&str) -> Result<String, String>>(l: Value, read: &R) -> Result<Value, String> {
    resolve_at(l, read, 0)
}

fn resolve_at<R: Fn(&str) -> Result<String, String>>(
    mut l: Value,
    read: &R,
    depth: usize,
) -> Result<Value, String> {
    let Some(m) = l.as_mapping_mut() else {
        return Ok(l);
    };
    let Some(b) = m.remove("base") else {
        return Ok(l);
    };
    let path = b.as_str().filter(|p| p.starts_with('/')).ok_or_else(|| {
        format!("layout.yaml: `base` = {b:?}: a path from the repo root (/lib/layouts/<name>.yaml)")
    })?;
    if depth >= DEPTH {
        return Err(format!(
            "layout.yaml: `base` {path}: bases chain more than {DEPTH} deep (a cycle?)"
        ));
    }
    let text = read(path)?;
    let base: Value = serde_yaml::from_str(&text).map_err(|e| format!("{path}: {e}"))?;
    if !base.is_mapping() {
        return Err(format!("{path}: a base layout is a mapping"));
    }
    let base = resolve_at(base, read, depth + 1)?;
    Ok(merge(base, Value::Mapping(std::mem::take(m))))
}

/// Read a base from the repo `root`.
pub fn reader(root: &Path) -> impl Fn(&str) -> Result<String, String> + '_ {
    move |p: &str| {
        let f = root.join(p.trim_start_matches('/'));
        std::fs::read_to_string(&f)
            .map_err(|e| format!("layout.yaml: `base` {p}: {}: {e}", f.display()))
    }
}

/// The repo root of a doc folder: its nearest ancestor holding data/index.json, else fb's.
pub fn root_of(dir: &Path) -> Option<std::path::PathBuf> {
    let abs = std::fs::canonicalize(dir).ok()?;
    abs.ancestors()
        .find(|d| d.join("data/index.json").is_file())
        .map(Path::to_path_buf)
        .or_else(|| crate::repo_root().ok())
}

/// The `base` a layout.yaml text names, if any (checkchanged: a changed base rechecks the folders on it).
pub fn named(text: &str) -> Option<String> {
    serde_yaml::from_str::<Mapping>(text)
        .ok()?
        .get("base")?
        .as_str()
        .map(str::to_string)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn y(s: &str) -> Value {
        serde_yaml::from_str(s).unwrap()
    }

    #[test]
    fn mappings_merge_and_other_values_replace() {
        let got = merge(
            y("size: 12\nmargin: {top: 72, left: 72}\nfront: [{text: a}]\nwords: {}\n"),
            y("margin: {left: 90}\nfront: [{text: b}]\nwords: ~\nindent: 36\n"),
        );
        assert_eq!(
            got,
            y("size: 12\nmargin: {top: 72, left: 90}\nfront: [{text: b}]\nindent: 36\n")
        );
    }

    #[test]
    fn a_base_is_read_and_chained_and_the_key_dropped() {
        let read = |p: &str| match p {
            "/lib/layouts/a.yaml" => {
                Ok("base: /lib/layouts/b.yaml\nsize: 12\npitch: {body: 24}\n".to_string())
            }
            "/lib/layouts/b.yaml" => {
                Ok("size: 10\npitch: {body: 20, single: 13.8}\nindent: 36\n".to_string())
            }
            _ => Err(format!("no {p}")),
        };
        let got = resolve(y("base: /lib/layouts/a.yaml\npitch: {body: 27.6}\n"), &read).unwrap();
        assert_eq!(
            got,
            y("size: 12\npitch: {body: 27.6, single: 13.8}\nindent: 36\n")
        );
        // no base: unchanged
        assert_eq!(resolve(y("size: 12\n"), &read).unwrap(), y("size: 12\n"));
    }

    #[test]
    fn a_relative_missing_or_cyclic_base_fails() {
        let read = |p: &str| match p {
            "/c.yaml" => Ok("base: /c.yaml\n".to_string()),
            _ => Err(format!("no {p}")),
        };
        assert!(resolve(y("base: lib/x.yaml\n"), &read)
            .unwrap_err()
            .contains("repo root"));
        assert!(resolve(y("base: /missing.yaml\n"), &read)
            .unwrap_err()
            .contains("no /missing.yaml"));
        assert!(resolve(y("base: /c.yaml\n"), &read)
            .unwrap_err()
            .contains("cycle"));
    }

    #[test]
    fn the_named_base_is_read_from_the_text() {
        assert_eq!(
            named("base: /lib/layouts/x.yaml\nsize: 12\n").as_deref(),
            Some("/lib/layouts/x.yaml")
        );
        assert_eq!(named("size: 12\n"), None);
    }
}
