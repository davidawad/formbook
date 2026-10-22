//! `fb engines families`: the state doc folders' typst templates clustered into families (fb-595.54.12, part 1).
//!
//! A template is the `.typ` file a folder's `typst/main.typ` imports (the file that is not `main.typ`). Its code is
//! read as tokens with the comments dropped, every string literal replaced by `S`, every number (with its unit) by
//! `N`, and the template's own name (the file stem, which also names its entry function) by `F`: two templates with
//! the same tokens are the same code modulo parameters (an *exact* family). Exact families are then joined when
//! their token 5-shingle sets overlap at or above a threshold (Jaccard, single linkage): `near` families. The
//! report gives both, with sizes, so the generator's reach can be read off it.
use std::collections::{BTreeMap, HashMap, HashSet};
use std::path::{Path, PathBuf};

/// Shingle length in tokens.
const K: usize = 5;

/// The normalized tokens of typst code: comments dropped, strings `S`, numbers `N`, `stem` as `F`.
pub fn tokens(src: &str, stem: &str) -> Vec<String> {
    let c: Vec<char> = src.chars().collect();
    let mut out = Vec::new();
    let mut i = 0;
    while i < c.len() {
        let ch = c[i];
        if ch == '/' && c.get(i + 1) == Some(&'/') {
            while i < c.len() && c[i] != '\n' {
                i += 1;
            }
        } else if ch == '/' && c.get(i + 1) == Some(&'*') {
            i += 2;
            while i < c.len() && !(c[i] == '*' && c.get(i + 1) == Some(&'/')) {
                i += 1;
            }
            i += 2;
        } else if ch == '"' {
            i += 1;
            while i < c.len() && c[i] != '"' {
                if c[i] == '\\' {
                    i += 1;
                }
                i += 1;
            }
            i += 1;
            out.push("S".to_string());
        } else if ch.is_ascii_digit()
            || (ch == '.' && c.get(i + 1).is_some_and(|d| d.is_ascii_digit()))
        {
            while i < c.len() && (c[i].is_ascii_alphanumeric() || c[i] == '.' || c[i] == '%') {
                i += 1;
            }
            out.push("N".to_string());
        } else if ch.is_alphabetic() || ch == '_' {
            let s = i;
            while i < c.len() && (c[i].is_alphanumeric() || c[i] == '_' || c[i] == '-') {
                i += 1;
            }
            let w: String = c[s..i].iter().collect();
            let w = w.trim_end_matches('-').to_string();
            i = s + w.chars().count();
            out.push(if w == stem { "F".to_string() } else { w });
        } else if ch.is_whitespace() {
            i += 1;
        } else {
            out.push(ch.to_string());
            i += 1;
        }
    }
    out
}

/// The set of hashed `K`-token shingles of a token list.
pub fn shingles(t: &[String]) -> HashSet<u64> {
    use std::hash::{Hash, Hasher};
    t.windows(K.min(t.len().max(1)))
        .map(|w| {
            let mut h = std::collections::hash_map::DefaultHasher::new();
            w.hash(&mut h);
            h.finish()
        })
        .collect()
}

/// Jaccard similarity of two shingle sets.
pub fn jaccard(a: &HashSet<u64>, b: &HashSet<u64>) -> f64 {
    if a.is_empty() && b.is_empty() {
        return 1.0;
    }
    let i = a.intersection(b).count() as f64;
    i / (a.len() as f64 + b.len() as f64 - i)
}

/// One template: its doc folder and normalized tokens.
pub struct Template {
    pub folder: PathBuf,
    pub toks: Vec<String>,
}

/// The template file of a doc folder: the `.typ` in `typst/` that is not `main.typ` (none, or the first by name
/// when there are several).
pub fn template_file(folder: &Path) -> Option<PathBuf> {
    let mut v: Vec<PathBuf> = std::fs::read_dir(folder.join("typst"))
        .ok()?
        .filter_map(|e| e.ok().map(|e| e.path()))
        .filter(|p| p.extension().is_some_and(|x| x == "typ"))
        .filter(|p| p.file_name().is_some_and(|n| n != "main.typ"))
        .collect();
    v.sort();
    v.into_iter().next()
}

/// Every doc folder under `courts/` whose path has a `state` component and whose `typst/` holds a template.
pub fn state_templates(root: &Path) -> Vec<Template> {
    let mut out = Vec::new();
    let mut stack = vec![root.join("courts")];
    while let Some(d) = stack.pop() {
        let Ok(rd) = std::fs::read_dir(&d) else {
            continue;
        };
        for e in rd.filter_map(|e| e.ok()) {
            let p = e.path();
            if p.is_dir()
                && !p
                    .file_name()
                    .is_some_and(|n| n.to_string_lossy().starts_with('.'))
            {
                stack.push(p);
            }
        }
        let rel = d.strip_prefix(root).unwrap_or(&d).to_path_buf();
        if !rel.components().any(|c| c.as_os_str() == "state") {
            continue;
        }
        if let Some(f) = template_file(&d) {
            let stem = f
                .file_stem()
                .unwrap_or_default()
                .to_string_lossy()
                .to_string();
            let src = std::fs::read_to_string(&f).unwrap_or_default();
            out.push(Template {
                folder: rel,
                toks: tokens(&src, &stem),
            });
        }
    }
    out.sort_by(|a, b| a.folder.cmp(&b.folder));
    out
}

/// Families: indices into `ts`, each family sorted, families largest first (then by first folder). `threshold`
/// None gives the exact families (identical tokens).
pub fn cluster(ts: &[Template], threshold: Option<f64>) -> Vec<Vec<usize>> {
    let mut exact: BTreeMap<&[String], Vec<usize>> = BTreeMap::new();
    for (i, t) in ts.iter().enumerate() {
        exact.entry(&t.toks).or_default().push(i);
    }
    let groups: Vec<Vec<usize>> = exact.into_values().collect();
    let Some(th) = threshold else {
        return sorted(groups);
    };
    let sh: Vec<HashSet<u64>> = groups.iter().map(|g| shingles(&ts[g[0]].toks)).collect();
    let mut parent: Vec<usize> = (0..groups.len()).collect();
    fn find(p: &mut [usize], x: usize) -> usize {
        let mut r = x;
        while p[r] != r {
            r = p[r];
        }
        p[x] = r;
        r
    }
    for a in 0..groups.len() {
        for b in a + 1..groups.len() {
            let (la, lb) = (sh[a].len() as f64, sh[b].len() as f64);
            if la.min(lb) < th * la.max(lb) {
                continue; // Jaccard <= min/max: cannot reach the threshold
            }
            if jaccard(&sh[a], &sh[b]) >= th {
                let (ra, rb) = (find(&mut parent, a), find(&mut parent, b));
                parent[ra] = rb;
            }
        }
    }
    let mut joined: HashMap<usize, Vec<usize>> = HashMap::new();
    for (gi, g) in groups.into_iter().enumerate() {
        let r = find(&mut parent, gi);
        joined.entry(r).or_default().extend(g);
    }
    sorted(joined.into_values().collect())
}

fn sorted(mut v: Vec<Vec<usize>>) -> Vec<Vec<usize>> {
    for g in &mut v {
        g.sort();
    }
    v.sort_by(|a, b| b.len().cmp(&a.len()).then(a[0].cmp(&b[0])));
    v
}
