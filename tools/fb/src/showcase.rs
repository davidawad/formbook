//! `fb showcase`: regenerate every image in docs/showcase/ from files committed in this repo (was
//! docs/showcase/make-screenshots.sh). The overlay is regenerated into the gitignored .overlay/ by `fb overlay`
//! first; overlays are never committed.
//! Needs pdftoppm (poppler), magick (ImageMagick), typst; the formbook toolchain
//! ($HOME/.local/share/formbook/env/bin, see `fb bootstrap`) is put on PATH first. Layout and labels are typeset
//! by typst with its bundled fonts (--ignore-system-fonts), so output does not depend on installed fonts. Page
//! images come from pdftoppm at fixed resolution.
use crate::proc::{capture, have, TempDir};
use crate::{fail, repo_root, Res};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const TRES: &str = "courts/third-circuit/court-of-appeals/opening-brief";
const NYS: &str = "courts/second-circuit/new-york/state/supreme-court/motion-brief";
const CAND: &str = "courts/ninth-circuit/california/federal/northern-district/complaint";
const SCOTUS: &str = "courts/supreme-court-of-the-united-states/merits-brief";
const CA1: &str = "courts/first-circuit/court-of-appeals/opening-brief";
const MDB: &str = "courts/fourth-circuit/maryland/federal/bankruptcy-district/adversary-complaint";
const CASUP: &str = "courts/ninth-circuit/california/state/superior-court/complaint";
const TXSC: &str = "courts/fifth-circuit/texas/state/supreme-court/brief-on-the-merits";

const HERO_TYP: &str = r####"#let bx = eval("bo" + "x", mode: "code")  // typst's inline layout primitive
#set page(width: 1180pt, height: 520pt, margin: 18pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 15pt, fill: rgb("#222"))
#let lab(t) = align(center, text(weight: "bold", size: 17pt)[#t])
#let arrow = align(horizon + center, text(size: 40pt, fill: rgb("#888"))[→])
#let frame(body) = bx(stroke: 0.8pt + rgb("#999"), fill: white, body)
#grid(columns: (1fr, 34pt, auto, 34pt, auto), rows: (1fr, auto), column-gutter: 4pt, row-gutter: 10pt,
  frame(bx(width: 100%, height: 100%, inset: 9pt, clip: true,
    text(font: "DejaVu Sans Mono", size: 9.6pt, fill: rgb("#223"), raw(read("input.txt"), lang: none)))),
  arrow,
  frame(image("h-ours.png", height: 100%)),
  arrow,
  frame(image("h-filed.png", height: 100%)),
  lab[markdown in], [], lab[formbook (Typst)], [], lab[filed with the court])
"####;

const OVERLAY_TYP: &str = r####"#let bx = eval("bo" + "x", mode: "code")  // typst's inline layout primitive
#set page(width: auto, height: auto, margin: 14pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 14pt, fill: rgb("#222"))
#align(center)[
  #bx(stroke: 0.8pt + rgb("#999"), image("o.png", height: 640pt))
  #v(6pt)
  #text(fill: rgb("#d00000"), weight: "bold")[red] = only in our render · #text(fill: rgb("#0044cc"), weight: "bold")[blue] = only in the filed exemplar · black = both agree
]
"####;

const PAGES_TYP: &str = r####"#let bx = eval("bo" + "x", mode: "code")  // typst's inline layout primitive
#set page(width: auto, height: auto, margin: 14pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 13pt, fill: rgb("#222"))
#let names = ("cover", "table of contents", "table of authorities", "statement", "argument", "conclusion", "certificate of compliance", "certificate of service")
#grid(columns: 4, column-gutter: 10pt, row-gutter: 12pt,
  ..range(8).map(i => align(center, stack(spacing: 5pt,
    bx(stroke: 0.8pt + rgb("#999"), image("p" + str(i + 1) + ".png", width: 215pt)),
    names.at(i)))))
"####;

const COURTS_TAIL_TYP: &str = r####"#let bx = eval("bo" + "x", mode: "code")  // typst's inline layout primitive
#set page(width: auto, height: auto, margin: 14pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 13pt, fill: rgb("#222"))
#let labels = (l1, l2, l3, l4, l5, l6, l7, l8)
#grid(columns: 4, column-gutter: 10pt, row-gutter: 12pt,
  ..range(8).map(i => align(center, stack(spacing: 5pt,
    bx(stroke: 0.8pt + rgb("#999"), image("c" + str(i + 1) + ".png", width: 215pt)),
    labels.at(i)))))
"####;

const FOLDER_TYP: &str = r####"#set page(width: auto, height: auto, margin: 16pt, fill: rgb("#f6f4ee"))
#set text(font: "DejaVu Sans Mono", size: 13pt, fill: rgb("#223"))
#raw(read("tree.txt"), lang: none)
"####;

/// The first `n` lines of a markdown sample that are not headings, each cut to `width` characters.
fn input_excerpt(md: &str, n: usize, width: usize) -> String {
    md.lines()
        .filter(|l| !l.starts_with('#'))
        .take(n)
        .map(|l| format!("{}\n", l.chars().take(width).collect::<String>()))
        .collect()
}

/// The court-folder tree picture: the folder, then its entries to depth 2 (docx and latex left out).
fn tree_lines(folder: &str, entries: &[String]) -> Vec<String> {
    let mut paths: Vec<String> = entries
        .iter()
        .filter(|p| {
            !p.ends_with(".DS_Store") && !p.starts_with("./docx") && !p.starts_with("./latex")
        })
        .cloned()
        .collect();
    paths.sort();
    let mut out = vec![format!("{folder}/")];
    out.extend(paths.iter().map(|p| {
        let rel = p.trim_start_matches("./");
        match rel.split_once('/') {
            None => format!("|-- {rel}"),
            Some((_, rest)) => format!("|   |-- {rest}"),
        }
    }));
    out.into_iter()
        .map(|l| l.chars().take(90).collect())
        .collect()
}

/// `./name` and `./name/child` for every entry of `dir` to depth 2.
fn depth_two(dir: &Path) -> Vec<String> {
    let mut out = vec![];
    for e in std::fs::read_dir(dir).into_iter().flatten().flatten() {
        let name = e.file_name().to_string_lossy().into_owned();
        out.push(format!("./{name}"));
        if e.path().is_dir() {
            for c in std::fs::read_dir(e.path()).into_iter().flatten().flatten() {
                out.push(format!("./{name}/{}", c.file_name().to_string_lossy()));
            }
        }
    }
    out
}

/// `#let l<n> = "<label>"` lines followed by the fixed grid source.
fn courts_typ(labels: &[&str]) -> String {
    let lets: String = labels
        .iter()
        .enumerate()
        .map(|(i, l)| format!("#let l{} = \"{l}\"\n", i + 1))
        .collect();
    format!("{lets}{COURTS_TAIL_TYP}")
}

struct Shots {
    root: PathBuf,
    out: PathBuf,
    work: TempDir,
}

fn run(cmd: &mut Command, what: &str) -> Res<()> {
    let o = capture(cmd)?;
    o.status.success().then_some(()).ok_or_else(|| {
        fail(
            1,
            format!(
                "fb showcase: {what} failed: {}",
                String::from_utf8_lossy(&o.stderr).trim()
            ),
        )
    })
}

impl Shots {
    fn w(&self, name: &str) -> PathBuf {
        self.work.path().join(name)
    }

    /// Rasterize one page to `<work>/<name>.png`.
    fn page(&self, src: &str, n: usize, name: &str, res: u32) -> Res<()> {
        let n = n.to_string();
        run(
            Command::new("pdftoppm")
                .args([
                    "-r",
                    &res.to_string(),
                    "-f",
                    &n,
                    "-l",
                    &n,
                    "-png",
                    "-singlefile",
                    src,
                ])
                .arg(self.w(name)),
            "pdftoppm",
        )
    }

    /// Typeset `typ` with typst, then palette-reduce and strip metadata into docs/showcase/<out>.
    fn compose(&self, file: &str, typ: &str, out: &str, colors: u32) -> Res<()> {
        std::fs::write(self.w(file), typ)
            .map_err(|e| fail(2, format!("fb showcase: {file}: {e}")))?;
        let raw = self.w(&format!("raw-{out}"));
        run(
            Command::new("typst")
                .current_dir(self.work.path())
                .args(["compile", "--root"])
                .arg(self.work.path())
                .args(["--ignore-system-fonts", "--format", "png", "--ppi", "72"])
                .arg(self.w(file))
                .arg(&raw),
            "typst",
        )?;
        run(
            Command::new("magick")
                .arg(&raw)
                .args([
                    "-strip",
                    "-colors",
                    &colors.to_string(),
                    "-define",
                    "png:exclude-chunks=date,time",
                ])
                .arg(self.out.join(out)),
            "magick",
        )
    }

    fn hero(&self) -> Res<()> {
        let t_out = format!("{TRES}/usage/OUTPUT-opening-brief.typst.pdf");
        let t_filed = format!("{TRES}/usage/FILED-EXAMPLE-opening-brief.pdf");
        let md = std::fs::read_to_string(self.root.join(TRES).join("usage/INPUT-opening-brief.md"))
            .map_err(|e| fail(2, format!("fb showcase: {e}")))?;
        std::fs::write(self.w("input.txt"), input_excerpt(&md, 30, 52))
            .map_err(|e| fail(2, format!("fb showcase: {e}")))?;
        self.page(&t_out, 1, "h-ours", 100)?;
        self.page(&t_filed, 1, "h-filed", 100)?;
        self.compose("hero.typ", HERO_TYP, "hero.png", 96)
    }

    fn overlay(&self) -> Res<()> {
        let exe = std::env::current_exe().map_err(|e| fail(2, format!("fb showcase: {e}")))?;
        run(
            Command::new(exe).args(["overlay", CAND, "complaint"]),
            "fb overlay",
        )?;
        self.page(
            &format!(".overlay/{CAND}/OVERLAY-complaint.pdf"),
            2,
            "o",
            130,
        )?;
        self.compose("overlay.typ", OVERLAY_TYP, "overlay.png", 64)
    }

    fn pages(&self) -> Res<()> {
        let t_out = format!("{TRES}/usage/OUTPUT-opening-brief.typst.pdf");
        for (i, p) in [1, 2, 3, 6, 11, 14, 15, 17].iter().enumerate() {
            self.page(&t_out, *p, &format!("p{}", i + 1), 70)?;
        }
        self.compose("pages.typ", PAGES_TYP, "pages.png", 48)
    }

    fn courts(&self) -> Res<()> {
        let list = [
            (
                format!("{SCOTUS}/usage/OUTPUT-merits-brief.typst.pdf"),
                "U.S. Supreme Court: merits brief",
            ),
            (
                format!("{CA1}/usage/OUTPUT-opening-brief.typst.pdf"),
                "1st Circuit: opening brief",
            ),
            (
                format!("{TRES}/usage/OUTPUT-opening-brief.typst.pdf"),
                "3rd Circuit: opening brief",
            ),
            (
                format!("{CAND}/usage/OUTPUT-complaint.typst.pdf"),
                "N.D. Cal.: complaint",
            ),
            (
                format!("{MDB}/usage/OUTPUT-adversary-complaint.typst.pdf"),
                "D. Md. Bankruptcy: adversary complaint",
            ),
            (
                format!("{CASUP}/usage/OUTPUT-complaint.typst.pdf"),
                "California Superior Court: complaint",
            ),
            (
                format!("{NYS}/usage/OUTPUT-motion-brief.typst.pdf"),
                "New York Supreme Court: motion brief",
            ),
            (
                format!("{TXSC}/usage/OUTPUT-brief-on-the-merits.typst.pdf"),
                "Texas Supreme Court: brief on the merits",
            ),
        ];
        for (i, (pdf, _)) in list.iter().enumerate() {
            self.page(pdf, 1, &format!("c{}", i + 1), 70)?;
        }
        let labels: Vec<&str> = list.iter().map(|(_, l)| *l).collect();
        self.compose("courts.typ", &courts_typ(&labels), "courts.png", 48)
    }

    fn folder(&self) -> Res<()> {
        let tree = tree_lines(TRES, &depth_two(&self.root.join(TRES)));
        std::fs::write(
            self.w("tree.txt"),
            tree.iter().map(|l| format!("{l}\n")).collect::<String>(),
        )
        .map_err(|e| fail(2, format!("fb showcase: {e}")))?;
        self.compose("folder.typ", FOLDER_TYP, "folder.png", 16)
    }
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    if !args.is_empty() {
        return Err(fail(2, "usage: fb showcase"));
    }
    let root = repo_root()?;
    let env_bin =
        Path::new(&std::env::var("HOME").unwrap_or_default()).join(".local/share/formbook/env/bin");
    let mut paths = vec![env_bin];
    paths.extend(std::env::split_paths(
        &std::env::var_os("PATH").unwrap_or_default(),
    ));
    std::env::set_var(
        "PATH",
        std::env::join_paths(paths).map_err(|e| fail(2, format!("fb showcase: {e}")))?,
    );
    for t in ["pdftoppm", "magick", "typst"] {
        if !have(t) {
            return Err(fail(1, format!("fb showcase: missing {t}")));
        }
    }
    std::env::set_current_dir(&root).map_err(|e| fail(2, format!("fb showcase: {e}")))?;
    let s = Shots {
        out: root.join("docs/showcase"),
        root,
        work: TempDir::new("showcase")?,
    };
    s.hero()?;
    s.overlay()?;
    s.pages()?;
    s.courts()?;
    s.folder()?;
    let mut pngs: Vec<PathBuf> = std::fs::read_dir(&s.out)
        .into_iter()
        .flatten()
        .flatten()
        .map(|e| e.path())
        .filter(|p| p.extension().is_some_and(|x| x == "png"))
        .collect();
    pngs.sort();
    run_inherit(Command::new("ls").arg("-l").args(&pngs))?;
    Ok(ExitCode::SUCCESS)
}

fn run_inherit(cmd: &mut Command) -> Res<()> {
    cmd.status()
        .map(|_| ())
        .map_err(|e| fail(2, format!("fb showcase: {e}")))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn excerpt_skips_headings_and_cuts_width() {
        let md = "# title\n## sub\nabcdefghij\nxyz\n";
        assert_eq!(input_excerpt(md, 30, 5), "abcde\nxyz\n");
        assert_eq!(input_excerpt("a\nb\nc\n", 2, 52), "a\nb\n");
    }

    #[test]
    fn tree_nests_depth_two_and_drops_noise() {
        let e: Vec<String> = [
            "./usage",
            "./usage/INPUT.md",
            "./README.md",
            "./docx",
            "./docx/x",
            "./latex",
            "./usage/.DS_Store",
            "./typst",
        ]
        .map(String::from)
        .into();
        assert_eq!(
            tree_lines("c/f", &e),
            [
                "c/f/",
                "|-- README.md",
                "|-- typst",
                "|-- usage",
                "|   |-- INPUT.md"
            ]
        );
    }

    #[test]
    fn tree_lines_are_cut_to_90_chars() {
        let long = format!("./{}", "a".repeat(120));
        assert_eq!(tree_lines("f", &[long])[1].chars().count(), 90);
    }

    #[test]
    fn courts_source_defines_one_label_per_court() {
        let t = courts_typ(&["A", "B"]);
        assert!(t.starts_with("#let l1 = \"A\"\n#let l2 = \"B\"\n#let bx = "));
    }
}
