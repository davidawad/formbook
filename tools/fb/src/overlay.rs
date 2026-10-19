//! `fb overlay <doc-dir> <id> [FILED-EXAMPLE.pdf]`: overlay a rendered sample on its FILED-EXAMPLE, page by page.
//!   red   = our render only
//!   blue  = FILED-EXAMPLE only
//!   black = both agree (red multiplied over blue)
//! Pages are paired by text, not index: each rendered page is matched to the FILED-EXAMPLE page sharing the
//! most words (Jaccard similarity of lowercase alphanumeric words longer than 3 characters), so a partial
//! transcription still lines up with the pages it came from.
//! Reads `usage/OUTPUT-<id>.typst.pdf` and `usage/FILED-EXAMPLE-<id>.pdf` (unless a PDF is given); writes
//! `<repo>/.overlay/<doc path>/OVERLAY-<id>.pdf` and `.txt` (the page map). `.overlay/` is gitignored.
use crate::layout::{overlay_name, Doc};
use crate::proc::{capture, pdf_pages, TempDir};
use crate::{fail, repo_root, Res};
use std::collections::BTreeSet;
use std::path::Path;
use std::process::{Command, ExitCode};

const DPI: &str = "100";

/// Lowercase alphanumeric words longer than 3 characters, distinct.
fn word_set(text: &str) -> BTreeSet<String> {
    text.to_ascii_lowercase()
        .split(|c: char| !c.is_ascii_alphanumeric())
        .filter(|w| w.len() > 3)
        .map(str::to_string)
        .collect()
}

/// Word-overlap of two pages in thousandths: floor(1000 * |both| / |either|), 0 for two empty pages.
fn score(a: &BTreeSet<String>, b: &BTreeSet<String>) -> u32 {
    let both = a.intersection(b).count() as u32;
    let any = a.union(b).count() as u32;
    (1000 * both).checked_div(any).unwrap_or(0)
}

/// The reference page (1-based, 0 = none) with the highest score; the first wins ties.
fn best_page(ours: &BTreeSet<String>, refs: &[BTreeSet<String>]) -> (u32, usize) {
    refs.iter().enumerate().fold((0, 0), |(best, at), (j, r)| {
        let s = score(ours, r);
        if s > best {
            (s, j + 1)
        } else {
            (best, at)
        }
    })
}

fn map_line(i: usize, best_j: usize, best: u32) -> String {
    format!(
        "ours p.{i}  filed p.{best_j}  word-overlap {}.{}%",
        best / 10,
        best % 10
    )
}

fn page_words(pdf: &Path, page: usize) -> Res<BTreeSet<String>> {
    let p = page.to_string();
    let o = capture(
        Command::new("pdftotext")
            .args(["-f", &p, "-l", &p])
            .arg(pdf)
            .arg("-"),
    )?;
    Ok(word_set(&String::from_utf8_lossy(&o.stdout)))
}

fn all_words(pdf: &Path) -> Res<Vec<BTreeSet<String>>> {
    (1..=pdf_pages(pdf) as usize)
        .map(|n| page_words(pdf, n))
        .collect()
}

fn run(cmd: &mut Command, what: &str) -> Res<()> {
    let o = capture(cmd)?;
    o.status.success().then_some(()).ok_or_else(|| {
        fail(
            1,
            format!(
                "fb overlay: {what} failed: {}",
                String::from_utf8_lossy(&o.stderr).trim()
            ),
        )
    })
}

fn raster(pdf: &Path, page: usize, stem: &Path) -> Res<()> {
    let p = page.to_string();
    run(
        Command::new("pdftoppm")
            .args([
                "-r",
                DPI,
                "-gray",
                "-png",
                "-singlefile",
                "-f",
                &p,
                "-l",
                &p,
            ])
            .arg(pdf)
            .arg(stem),
        "pdftoppm",
    )
}

fn magick_str(args: &[&str]) -> Res<String> {
    let o = capture(Command::new("magick").args(args))?;
    o.status
        .success()
        .then(|| String::from_utf8_lossy(&o.stdout).into_owned())
        .ok_or_else(|| fail(1, "fb overlay: magick failed"))
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let (dir, id, extra) = match args {
        [d, i] => (d, i, None),
        [d, i, r] => (d, i, Some(r)),
        _ => {
            return Err(fail(
                2,
                "usage: fb overlay <doc-dir> <id> [FILED-EXAMPLE.pdf]",
            ))
        }
    };
    let root = repo_root()?;
    let doc = Doc::open(Path::new(dir))?;
    let ours = doc.output(id, "typst");
    let reference = match extra {
        Some(r) => Path::new(r).to_path_buf(),
        None => {
            let filed = doc.ids(crate::layout::FILED);
            let s = crate::layout::pair(id, &filed).ok_or_else(|| {
                fail(
                    1,
                    format!("fb usage: no {} for {id}", crate::layout::filed_name(id)),
                )
            })?;
            doc.filed(&s)
        }
    };
    let out_dir = doc.overlay_dir(&root);
    let out = out_dir.join(overlay_name(id, "pdf"));
    let map = out_dir.join(overlay_name(id, "txt"));
    let label_font = root.join("fonts/eb-garamond/EBGaramond-Regular.otf");
    if !ours.is_file() {
        return Err(fail(
            1,
            format!("no render: {} (run fb render first)", ours.display()),
        ));
    }
    if !reference.is_file() {
        return Err(fail(
            1,
            format!("no FILED-EXAMPLE pdf: {}", reference.display()),
        ));
    }
    std::fs::create_dir_all(&out_dir)
        .map_err(|e| fail(2, format!("fb overlay: {}: {e}", out_dir.display())))?;
    let tmp = TempDir::new("overlay")?;
    let t = tmp.path();
    let ours_words = all_words(&ours)?;
    let ref_words = all_words(&reference)?;
    let mut lines = vec![];
    let mut pages = vec![];
    for (idx, ow) in ours_words.iter().enumerate() {
        let i = idx + 1;
        let (best, best_j) = best_page(ow, &ref_words);
        lines.push(map_line(i, best_j, best));
        raster(&ours, i, &t.join("op"))?;
        let [op, oc, rp, rc] = ["op", "oc", "rp", "rc"].map(|n| t.join(format!("{n}.png")));
        run(
            Command::new("magick")
                .arg(&op)
                .args(["+level-colors", "red,white"])
                .arg(&oc),
            "magick",
        )?;
        let label = if best_j > 0 {
            raster(&reference, best_j, &t.join("rp"))?;
            run(
                Command::new("magick")
                    .arg(&rp)
                    .args(["+level-colors", "blue,white"])
                    .arg(&rc),
                "magick",
            )?;
            format!("ours p.{i} (red)  over  filed p.{best_j} (blue)")
        } else {
            run(
                Command::new("magick")
                    .arg(&oc)
                    .args(["-fill", "white", "-colorize", "100"])
                    .arg(&rc),
                "magick",
            )?;
            format!("ours p.{i} (red)  no matching filed page")
        };
        let geo = magick_str(&["identify", "-format", "%wx%h", &rc.to_string_lossy()])?;
        let page = t.join(format!("page-{i:03}.png"));
        run(
            Command::new("magick")
                .arg(&rc)
                .arg("(")
                .arg(&oc)
                .args(["-resize", &format!("{geo}!"), ")"])
                .args(["-compose", "multiply", "-composite", "-font"])
                .arg(&label_font)
                .args([
                    "-gravity",
                    "north",
                    "-fill",
                    "gray40",
                    "-pointsize",
                    "14",
                    "-annotate",
                    "+0+6",
                    &label,
                ])
                .arg(&page),
            "magick",
        )?;
        pages.push(page);
    }
    std::fs::write(
        &map,
        lines.iter().map(|l| format!("{l}\n")).collect::<String>(),
    )
    .map_err(|e| fail(2, format!("fb overlay: {}: {e}", map.display())))?;
    run(
        Command::new("magick")
            .args(["-density", DPI])
            .args(&pages)
            .arg(&out),
        "magick",
    )?;
    println!("wrote {}", out.display());
    lines.iter().for_each(|l| println!("{l}"));
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn set(t: &str) -> BTreeSet<String> {
        word_set(t)
    }

    #[test]
    fn words_are_lowercase_alnum_longer_than_three() {
        let w = set("The Court's HOLDING, in 2024-cv-17: ok? Yes");
        let want: BTreeSet<String> = ["court", "holding", "2024"].map(String::from).into();
        assert_eq!(w, want);
    }

    #[test]
    fn score_is_floor_jaccard_in_thousandths() {
        assert_eq!(score(&set("aaaa bbbb cccc"), &set("aaaa bbbb dddd")), 500);
        assert_eq!(score(&set("aaaa"), &set("aaaa")), 1000);
        assert_eq!(score(&set(""), &set("")), 0);
        assert_eq!(score(&set("aaaa bbbb cccc"), &set("aaaa dddd eeee")), 200);
    }

    #[test]
    fn best_page_is_first_max_or_zero() {
        let refs = vec![set("xxxx yyyy"), set("aaaa bbbb"), set("aaaa bbbb")];
        assert_eq!(best_page(&set("aaaa bbbb"), &refs), (1000, 2));
        assert_eq!(best_page(&set("zzzz"), &refs), (0, 0));
        assert_eq!(best_page(&set("zzzz"), &[]), (0, 0));
    }

    #[test]
    fn map_line_format() {
        assert_eq!(
            map_line(3, 5, 873),
            "ours p.3  filed p.5  word-overlap 87.3%"
        );
        assert_eq!(map_line(1, 0, 0), "ours p.1  filed p.0  word-overlap 0.0%");
    }
}
