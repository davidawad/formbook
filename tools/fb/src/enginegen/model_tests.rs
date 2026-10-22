//! The shared document model's features (fb-595.54.13) in its two halves: the pandoc side (lib/pandoc/xdoc.lua,
//! lib/pandoc/xengine.lua, run by `pandoc lua`) and the typst side (lib/typst/xdoc.typ), which must agree: heading
//! numbers, the computed word count `{body_words}` and a URL's break opportunities. Skipped, and logged to
//! TEST_SKIP_LOG, without pandoc or typst.
use std::path::{Path, PathBuf};
use std::process::Command;

fn skip(test: &str, why: &str) {
    eprintln!("SKIP {test}: {why}");
    if let Some(log) = std::env::var_os("TEST_SKIP_LOG") {
        use std::io::Write;
        let mut f = std::fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(log)
            .unwrap();
        writeln!(f, "enginegen::model_tests::{test}: {why}").unwrap();
    }
}

fn root() -> Option<PathBuf> {
    crate::repo_root().ok()
}

/// Run a Lua script with `pandoc lua`, lib/ on LUA_PATH; its stdout.
fn lua(root: &Path, script: &str) -> String {
    let dir = crate::proc::TempDir::new("model-lua").unwrap();
    let f = dir.path().join("t.lua");
    std::fs::write(&f, script).unwrap();
    let o = Command::new("pandoc")
        .arg("lua")
        .arg(&f)
        .env("LUA_PATH", format!("{}/lib/?.lua;;", root.display()))
        .output()
        .unwrap();
    assert!(o.status.success(), "{}", String::from_utf8_lossy(&o.stderr));
    String::from_utf8(o.stdout).unwrap()
}

const SAMPLE: &str = "---\ntitle: x\n---\n\n# Argument\n\n## First point\n\nA b-c d.[^1] see https://a.org/b/c-d/2015/11/x.\n\n### Sub\n\n## Second point\n\n# Conclusion\n\n— end\n\n# Certificate of Service\n\nNot counted here.\n\n[^1]: A note.\n";

#[test]
fn pandoc_side_numbers_counts_and_breaks() {
    let Some(root) = root() else {
        return skip("pandoc_side_numbers_counts_and_breaks", "no repo root");
    };
    if !crate::proc::have("pandoc") {
        return skip(
            "pandoc_side_numbers_counts_and_breaks",
            "pandoc not installed",
        );
    }
    let script = format!(
        r#"local xd = require("pandoc.xdoc")
local xe = require("pandoc.xengine")
local src = {src:?}
local doc = pandoc.read(src, "markdown+smart")
local spec = {{ heading = {{ {{ align = "center" }}, {{ number = "I.", hang = 36 }}, {{ number = "A.", hang = 36 }} }} }}
xd.number_headings(spec, doc.blocks)
local labels = {{}}
for _, b in ipairs(doc.blocks) do
  if b.t == "Header" then labels[#labels + 1] = (b.attributes["xd-label"] or "-") end
end
print(table.concat(labels, " "))
print(xd.numbering("(a)", 28), xd.numbering("i.", 4), xd.numbering("1.", 12))
print(xd.count_words(src, "Certificate"), xd.count_words(src, nil))
local s = xe.urls(pandoc.Inlines({{ pandoc.Str("https://a.org/b/c-d/2015/") }}))[1].text
print((s:gsub("\u{{200B}}", "|")))
print(xd.lookup({{ a = {{}} }}, "a.b|___"), xd.lookup({{ a = {{ b = "x" }} }}, "a.b|___"))
local ls = xd.commonmark_lists(pandoc.read("a. one\n\nb. two\n\n(1) three\n\n1. four\n\nx\n\nc. five\nd. six\n", "markdown").blocks)
local t = {{}}
for _, b in ipairs(ls) do t[#t + 1] = b.t .. ":" .. pandoc.utils.stringify(b) end
print(table.concat(t, " "))
"#,
        src = SAMPLE
    );
    let out = lua(&root, &script);
    let lines: Vec<&str> = out.lines().collect();
    // level 1 unnumbered, level 2 I. II. (reset by no level-1 heading between them), level 3 A.
    assert_eq!(lines[0], "- I. A. II. - -");
    assert_eq!(lines[1], "(ab)\tiv.\t12.");
    // the body before the certificate: "#" and "—" alone are no words; with the certificate and the note 22
    assert_eq!(lines[2], "13\t22");
    assert_eq!(lines[3], "https://|a.|org/|b/|c-|d/|2015/");
    // a missing field's default; lists CommonMark does not read are paragraphs with their markers
    assert_eq!(lines[4], "___\tx");
    assert_eq!(
        lines[5],
        "Para:a. one Para:b. two Para:(1) three OrderedList:four Para:x Para:c. five d. six"
    );
}

#[test]
fn typst_side_agrees() {
    let Some(root) = root() else {
        return skip("typst_side_agrees", "no repo root");
    };
    for tool in ["typst", "pdftotext"] {
        if !crate::proc::have(tool) {
            return skip("typst_side_agrees", &format!("{tool} not installed"));
        }
    }
    // a root of its own holding a copy of lib/typst (the doc imports "/lib/typst/xdoc.typ")
    let dir = crate::proc::TempDir::new("model-typst").unwrap();
    let lib = dir.path().join("lib/typst");
    std::fs::create_dir_all(&lib).unwrap();
    for e in std::fs::read_dir(root.join("lib/typst")).unwrap() {
        let p = e.unwrap().path();
        std::fs::copy(&p, lib.join(p.file_name().unwrap())).unwrap();
    }
    let layout = "size: 12\npitch: {body: 27.6, single: 13.8}\nmargin: {top: 72, bottom: 72, left: 72, right: 72}\nindent: 36\nheading:\n  - {align: center, bold: true}\n  - {bold: true, number: \"I.\", hang: 36}\n  - {bold: true, number: \"A.\", hang: 36}\ncontents: {title: \"Contents\", depth: 3, col: 36}\nclosing:\n  - {text: \"Words: {body_words}. {missing|___} {title|no}.\"}\ntail: {at: \"Certificate\"}\n";
    std::fs::write(dir.path().join("INPUT.md"), SAMPLE).unwrap();
    std::fs::write(dir.path().join("layout.yaml"), layout).unwrap();
    let main = dir.path().join("main.typ");
    std::fs::write(
        &main,
        "#import \"/lib/typst/xdoc.typ\": xdoc, split-frontmatter\n#let (meta, body) = split-frontmatter(read(\"INPUT.md\"))\n#xdoc(yaml(\"layout.yaml\") + (font: (\"Liberation Serif\",)), meta, body)\n",
    )
    .unwrap();
    let pdf = dir.path().join("out.pdf");
    let o = Command::new("typst")
        .args(["compile", "--root"])
        .arg(dir.path())
        .arg("--font-path")
        .arg(root.join("fonts"))
        .arg("--ignore-system-fonts")
        .arg("--package-cache-path")
        .arg(root.join("vendor/typst-packages"))
        .arg(&main)
        .arg(&pdf)
        .output()
        .unwrap();
    assert!(o.status.success(), "{}", String::from_utf8_lossy(&o.stderr));
    let t = Command::new("pdftotext")
        .arg(&pdf)
        .arg("-")
        .output()
        .unwrap();
    let text = String::from_utf8_lossy(&t.stdout).replace('\u{200b}', "|");
    // the same numbers in the headings and the contents, the same count as the pandoc side
    assert!(
        text.contains("I.\tFirst point") || text.contains("I. First point"),
        "{text}"
    );
    assert!(text.contains("II."), "{text}");
    assert!(text.contains("A."), "{text}");
    assert!(text.contains("Words: 13. ___ x."), "{text}");
    assert!(
        text.contains("https://|a.|org/|b/|c-|d/|2015/|11/|x."),
        "{text}"
    );
}

#[test]
fn a_numbered_heading_needs_a_hang_and_one_symbol() {
    let l: serde_yaml::Value = serde_yaml::from_str(
        "heading:\n  - {align: center}\n  - {number: \"I.\", hang: 36}\n  - {number: \"I.A\", hang: 36}\n  - {number: \"1.\"}\n  - {number: \"a.\", hang: 36, align: center}\n",
    )
    .unwrap();
    let mut errs = Vec::new();
    super::gen::validate_numbers(&l, &mut errs);
    assert_eq!(errs.len(), 3, "{errs:?}");
    assert!(errs[0].contains("heading[2].number") && errs[0].contains("one counting symbol"));
    assert!(errs[1].contains("heading[3].number") && errs[1].contains("hang"));
    assert!(errs[2].contains("heading[4].number") && errs[2].contains("left-aligned"));
}
