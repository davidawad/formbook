//! The font family a doc folder's typst template declares, and the effective checks file of a default run.
use super::sh::{capture, cmd, io_fail, Env};
use crate::Res;
use std::path::Path;

/// The family the repo uses when a template names none (docs/FONTS.md).
const FALLBACK: [&str; 2] = ["Times New Roman", "Liberation Serif"];

const NAMES: [&str; 5] = ["font-family", "face", "typeface", "body-font", "font-name"];

/// Every `"..."` literal of `s`, up to a `//` comment.
fn literals(s: &str) -> Vec<String> {
    let code = s.split("//").next().unwrap_or(s);
    code.split('"')
        .skip(1)
        .step_by(2)
        .map(str::to_string)
        .collect()
}

/// Families a template source declares: the string literals of `#let font-family|face|typeface|body-font|font-name = ...`.
pub fn families_in(src: &str) -> Vec<String> {
    src.lines()
        .filter_map(|l| {
            let rest = l.trim_start().strip_prefix("#let ")?.trim_start();
            let (name, rhs) = rest.split_once('=')?;
            NAMES.contains(&name.trim()).then_some(rhs)
        })
        .flat_map(literals)
        .collect()
}

fn typ_files(dir: &Path) -> Vec<std::path::PathBuf> {
    let mut v: Vec<_> = std::fs::read_dir(dir)
        .map(|rd| rd.filter_map(Result::ok).map(|e| e.path()).collect())
        .unwrap_or_default();
    v.sort();
    v.iter()
        .flat_map(|p| match p.is_dir() {
            true => typ_files(p),
            false => (p.extension().is_some_and(|e| e == "typ"))
                .then(|| p.clone())
                .into_iter()
                .collect(),
        })
        .collect()
}

/// Declared families of the doc folder's typst templates, in file order, de-duplicated; the repo default when none.
pub fn families(doc: &str) -> Vec<String> {
    let found: Vec<String> = typ_files(&Path::new(doc).join("typst"))
        .iter()
        .filter_map(|p| std::fs::read_to_string(p).ok())
        .flat_map(|s| families_in(&s))
        .fold(Vec::new(), |mut acc, f| {
            if !acc.contains(&f) {
                acc.push(f);
            }
            acc
        });
    match found.is_empty() {
        true => FALLBACK.map(String::from).to_vec(),
        false => found,
    }
}

/// `TeX Gyre Termes` -> `TeXGyreTermes`: how poppler spells the start of a PostScript font name.
pub fn pdf_prefix(families: &[String]) -> String {
    families
        .iter()
        .map(|f| f.replace(' ', ""))
        .collect::<Vec<_>>()
        .join("|")
}

/// data/checks-default.yaml merged with the declared font and any eval.yaml overrides (court folder, then the
/// doc folder itself, the later one wins), written to `out`. Returns its path.
pub fn effective(env: &Env, root: &str, court: &str, doc: &str, out: &str) -> Res<String> {
    let fams = families(doc);
    let declared = format!("{out}/declared.yaml");
    let body = format!(
        "font:\n  typst_family: \"{}\"\n  pdf_prefix: \"{}\"\n",
        fams[0],
        pdf_prefix(&fams)
    );
    std::fs::write(&declared, body).map_err(|e| io_fail(&declared, e))?;
    let default = format!("{root}/data/checks-default.yaml");
    let overrides = [court, doc]
        .into_iter()
        .map(|d| format!("{d}/eval.yaml"))
        .filter(|p| Path::new(p).is_file());
    let files: Vec<String> =
        [default, declared]
            .into_iter()
            .chain(overrides)
            .fold(Vec::new(), |mut acc, f| {
                if !acc.contains(&f) {
                    acc.push(f);
                }
                acc
            });
    let eff = format!("{out}/checks-effective.yaml");
    let mut args = vec!["eval-all", ". as $i ireduce ({}; . * $i)"];
    args.extend(files.iter().map(String::as_str));
    let (text, ok) = capture(cmd(env, "yq", &args))?;
    match ok {
        true => {
            std::fs::write(&eff, format!("{text}\n")).map_err(|e| io_fail(&eff, e))?;
            Ok(eff)
        }
        false => Err(crate::fail(
            2,
            "fb check: yq could not merge the default checks",
        )),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn declared_families() {
        let src = "#let font-family = (\"Times New Roman\", \"Liberation Serif\")   // note \"x\"\n#let face = \"TeX Gyre Schola\"\n#let other = \"nope\"\n";
        assert_eq!(
            families_in(src),
            ["Times New Roman", "Liberation Serif", "TeX Gyre Schola"]
        );
        assert!(families_in("#let font-family = font-name\n").is_empty());
    }

    #[test]
    fn prefixes() {
        let f = [
            "TeX Gyre Termes".to_string(),
            "Liberation Serif".to_string(),
        ];
        assert_eq!(pdf_prefix(&f), "TeXGyreTermes|LiberationSerif");
        assert_eq!(
            families("/nonexistent/doc"),
            ["Times New Roman", "Liberation Serif"]
        );
    }
}
