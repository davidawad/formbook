//! The body face a doc folder's typst template sets: the single source of the docx engine's typeface
//! (docxref.rs puts it where a `docx/reference.xml` writes `{font}`; `fb lint fonts` compares the docx with it).
//!
//! The face is the first family of the template's `set text(font: ..)` (a string, an array, or a name bound with
//! `#let name = ..`), else of the first `#let font-family`, `font-name`, `body-font`, `typeface`, `face` or
//! `serif` binding. Templates are read as `fb lint fonts` reads them (lint/fonts.rs: main.typ's imports).
use std::path::Path;

const BINDINGS: [&str; 6] = [
    "font-family",
    "font-name",
    "body-font",
    "typeface",
    "face",
    "serif",
];

/// The first string literal of `expr`.
fn first_string(expr: &str) -> Option<String> {
    let at = expr.find('"')? + 1;
    let end = expr[at..].find('"')?;
    Some(expr[at..at + end].to_string())
}

/// `expr` without a trailing `// comment`.
fn code(line: &str) -> &str {
    line.find("//").map_or(line, |i| &line[..i])
}

/// The expression bound by `#let name = ..` (or `let name = ..` inside a block) on its line.
fn binding<'a>(text: &'a str, name: &str) -> Option<&'a str> {
    text.lines().find_map(|l| {
        let t = l.trim_start();
        let t = t.strip_prefix('#').unwrap_or(t);
        let rest = t.strip_prefix("let ")?.trim_start().strip_prefix(name)?;
        let rest = rest.trim_start().strip_prefix('=')?;
        Some(code(rest).trim())
    })
}

/// The argument of `font:` in a `set text(..)` line, up to the next top-level comma or the closing parenthesis.
fn set_text_font(line: &str) -> Option<&str> {
    let at = line.find("set text(")?;
    let args = &line[at + "set text(".len()..];
    let f = args.find("font:")? + "font:".len();
    let arg = args[f..].trim_start();
    let mut depth = 0i32;
    let mut in_str = false;
    for (i, c) in arg.char_indices() {
        match c {
            '"' => in_str = !in_str,
            '(' if !in_str => depth += 1,
            ')' if !in_str && depth == 0 => return Some(arg[..i].trim()),
            ')' if !in_str => depth -= 1,
            ',' if !in_str && depth == 0 => return Some(arg[..i].trim()),
            _ => {}
        }
    }
    Some(arg.trim())
}

/// The face of an expression: a literal, or a name bound in `text` (followed once more, for `#let a = b`).
fn resolve(text: &str, expr: &str, hops: usize) -> Option<String> {
    if expr.starts_with('"') || expr.starts_with('(') {
        return first_string(expr);
    }
    let name = expr
        .split(|c: char| !(c.is_alphanumeric() || c == '-' || c == '_'))
        .next()?;
    let bound = binding(text, name)?;
    if hops > 0 && !(bound.starts_with('"') || bound.starts_with('(')) {
        return resolve(text, bound, hops - 1);
    }
    first_string(bound)
}

/// The face the template text `text` sets.
pub fn face_of(text: &str) -> Option<String> {
    let set = text
        .lines()
        .map(code)
        .filter_map(set_text_font)
        .find_map(|e| resolve(text, e, 2));
    set.or_else(|| {
        BINDINGS
            .iter()
            .find_map(|b| binding(text, b).and_then(|e| resolve(text, e, 2)))
    })
}

/// The face the typst template of `doc_dir` sets, if it names one.
pub fn face(doc_dir: &Path) -> Option<String> {
    let files = crate::lint::fonts::template_files(doc_dir).ok()?;
    let text: String = files
        .iter()
        .filter_map(|f| std::fs::read_to_string(f).ok())
        .collect::<Vec<_>>()
        .join("\n");
    face_of(&text)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn follows_set_text_to_its_binding() {
        let t = "#let font-family = (\"Times New Roman\", \"Liberation Serif\")  // a note\n\
                 #show: x => { set text(font: font-family, size: 12pt) }";
        assert_eq!(face_of(t).as_deref(), Some("Times New Roman"));
        let t = "#let typeface = \"TeX Gyre Schola\"\n  set text(font: typeface, size: type-size)";
        assert_eq!(face_of(t).as_deref(), Some("TeX Gyre Schola"));
    }

    #[test]
    fn literal_and_chained_bindings() {
        assert_eq!(
            face_of("set text(font: (\"EB Garamond\",), size: 12pt)").as_deref(),
            Some("EB Garamond")
        );
        let t = "#let font-name = \"Liberation Sans\"\n#let font-family = font-name\nset text(font: font-family)";
        assert_eq!(face_of(t).as_deref(), Some("Liberation Sans"));
    }

    #[test]
    fn falls_back_to_a_binding_and_ignores_comments() {
        assert_eq!(
            face_of("#let face = \"Gelasio\"\n// set text(font: \"Other\")").as_deref(),
            Some("Gelasio")
        );
        assert_eq!(face_of("set text(size: 12pt)"), None);
    }
}
