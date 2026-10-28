//! Running poppler and parsing its output: `pdftotext -bbox-layout` (words in line segments),
//! `pdftohtml -xml` (font size, bold, italic per text run), `pdffonts`, and `pdftocairo -svg` per page.
use super::{svg, Font, Rect, Word};
use crate::{fail, Res};
use quick_xml::events::{BytesStart, Event};
use quick_xml::Reader;
use std::path::Path;
use std::process::Command;

/// One pdftotext `<line>`: its box and words.
#[derive(Debug, Clone)]
pub struct Seg {
    pub bbox: Rect,
    pub words: Vec<Word>,
}

/// One pdftohtml `<text>` run.
#[derive(Debug, Clone)]
pub struct Run {
    pub bbox: Rect,
    pub size: f64,
    /// Font family without the subset prefix.
    pub family: String,
    pub chars: usize,
    pub bold: usize,
    pub italic: usize,
}

#[derive(Debug, Default)]
pub struct RawPage {
    pub n: usize,
    pub w: f64,
    pub h: f64,
    pub segs: Vec<Seg>,
    pub runs: Vec<Run>,
    pub svg: svg::SvgPage,
}

pub struct Raw {
    pub fonts: Vec<Font>,
    pub pages: Vec<RawPage>,
}

pub fn run(cmd: &str, args: &[&str]) -> Res<String> {
    let out = Command::new(cmd)
        .args(args)
        .output()
        .map_err(|e| fail(2, format!("fb: cannot run {cmd}: {e}")))?;
    if !out.status.success() {
        return Err(fail(
            2,
            format!(
                "fb: {cmd} {} failed: {}",
                args.join(" "),
                String::from_utf8_lossy(&out.stderr).trim()
            ),
        ));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

pub fn read(pdf: &Path) -> Res<Raw> {
    read_upto(pdf, None)
}

/// `read`, limited to pages 1..=`last` when it is given.
pub fn read_upto(pdf: &Path, last: Option<usize>) -> Res<Raw> {
    let p = pdf.to_str().ok_or_else(|| fail(2, "fb: non-UTF-8 path"))?;
    let l = last.map(|n| n.to_string());
    let range: Vec<&str> = l.as_deref().map_or(vec![], |l| vec!["-f", "1", "-l", l]);
    let mut args = range.clone();
    args.extend(["-bbox-layout", p, "-"]);
    let mut pages = parse_bbox(&run("pdftotext", &args)?)?;
    let mut args = range;
    args.extend(["-xml", "-i", "-nodrm", "-zoom", "1", "-stdout", "-q", p]);
    let runs = parse_html(&run("pdftohtml", &args)?)?;
    for (n, rs) in runs {
        if let Some(pg) = pages.get_mut(n.wrapping_sub(1)) {
            pg.runs = rs;
        }
    }
    let svgs = svg_pages(p, pages.len())?;
    for (pg, s) in pages.iter_mut().zip(svgs) {
        pg.svg = s;
    }
    Ok(Raw {
        fonts: parse_fonts(&run("pdffonts", &[p])?),
        pages,
    })
}

/// `pdftocairo -svg` one page at a time (it writes one page per file), on all cores.
fn svg_pages(pdf: &str, n: usize) -> Res<Vec<svg::SvgPage>> {
    // one folder per call: callers may measure several PDFs at once (fb cross-engine)
    static CALLS: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
    let call = CALLS.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    let dir = std::env::temp_dir().join(format!("fb-measure-{}-{call}", std::process::id()));
    std::fs::create_dir_all(&dir).map_err(|e| fail(2, format!("fb: {e}")))?;
    let workers = std::thread::available_parallelism().map_or(4, |c| c.get());
    let pages: Vec<usize> = (1..=n).collect();
    let mut out: Vec<Res<svg::SvgPage>> = Vec::with_capacity(n);
    std::thread::scope(|s| {
        let handles: Vec<_> = pages
            .chunks(n.div_ceil(workers).max(1))
            .map(|chunk| {
                let dir = &dir;
                s.spawn(move || {
                    chunk
                        .iter()
                        .map(|&i| {
                            let f = dir.join(format!("p{i}.svg"));
                            let fs = f.to_string_lossy().into_owned();
                            let is = i.to_string();
                            run("pdftocairo", &["-svg", "-f", &is, "-l", &is, pdf, &fs])?;
                            let text = std::fs::read_to_string(&f)
                                .map_err(|e| fail(2, format!("fb: {fs}: {e}")))?;
                            let _ = std::fs::remove_file(&f);
                            svg::parse(&text)
                        })
                        .collect::<Vec<_>>()
                })
            })
            .collect();
        for h in handles {
            out.extend(
                h.join()
                    .unwrap_or_else(|_| vec![Err(fail(2, "fb: svg worker panicked"))]),
            );
        }
    });
    let _ = std::fs::remove_dir_all(&dir);
    out.into_iter().collect()
}

fn attr(e: &BytesStart, key: &[u8]) -> Option<String> {
    e.attributes()
        .flatten()
        .find(|a| a.key.as_ref() == key)
        .and_then(|a| a.unescape_value().ok().map(|v| v.into_owned()))
}

fn fattr(e: &BytesStart, key: &[u8]) -> f64 {
    attr(e, key).and_then(|v| v.parse().ok()).unwrap_or(0.0)
}

fn rect_of(e: &BytesStart) -> Rect {
    Rect {
        x0: fattr(e, b"xMin"),
        y0: fattr(e, b"yMin"),
        x1: fattr(e, b"xMax"),
        y1: fattr(e, b"yMax"),
    }
}

fn xml_err(what: &str, e: impl std::fmt::Display) -> crate::Fail {
    fail(2, format!("fb: cannot parse {what}: {e}"))
}

pub fn parse_bbox(xml: &str) -> Res<Vec<RawPage>> {
    let mut rd = Reader::from_str(xml);
    rd.config_mut().check_end_names = false;
    let mut pages: Vec<RawPage> = Vec::new();
    let mut word: Option<Word> = None;
    loop {
        match rd
            .read_event()
            .map_err(|e| xml_err("pdftotext output", e))?
        {
            Event::Start(e) | Event::Empty(e) => match e.name().as_ref() {
                b"page" => pages.push(RawPage {
                    n: pages.len() + 1,
                    w: fattr(&e, b"width"),
                    h: fattr(&e, b"height"),
                    ..RawPage::default()
                }),
                b"line" => {
                    if let Some(p) = pages.last_mut() {
                        p.segs.push(Seg {
                            bbox: rect_of(&e),
                            words: vec![],
                        });
                    }
                }
                b"word" => {
                    let r = rect_of(&e);
                    word = Some(Word {
                        t: String::new(),
                        x0: r.x0,
                        y0: r.y0,
                        x1: r.x1,
                        y1: r.y1,
                    });
                }
                _ => {}
            },
            Event::Text(t) => {
                if let Some(w) = word.as_mut() {
                    w.t.push_str(&t.unescape().map_err(|e| xml_err("pdftotext text", e))?);
                }
            }
            Event::End(e) if e.name().as_ref() == b"word" => {
                let seg = pages.last_mut().and_then(|p| p.segs.last_mut());
                if let (Some(w), Some(s)) = (word.take(), seg) {
                    s.words.push(w);
                }
            }
            Event::Eof => break,
            _ => {}
        }
    }
    Ok(pages)
}

/// pdftohtml -xml: page number -> runs.
pub fn parse_html(xml: &str) -> Res<Vec<(usize, Vec<Run>)>> {
    let mut rd = Reader::from_str(xml);
    rd.config_mut().check_end_names = false;
    let mut specs: std::collections::HashMap<String, (f64, String)> = Default::default();
    let mut out: Vec<(usize, Vec<Run>)> = Vec::new();
    let (mut b, mut i) = (0usize, 0usize);
    let mut cur: Option<Run> = None;
    loop {
        match rd
            .read_event()
            .map_err(|e| xml_err("pdftohtml output", e))?
        {
            Event::Start(e) | Event::Empty(e) => match e.name().as_ref() {
                b"page" => out.push((
                    attr(&e, b"number")
                        .and_then(|n| n.parse().ok())
                        .unwrap_or(0),
                    vec![],
                )),
                b"fontspec" => {
                    let fam = attr(&e, b"family").unwrap_or_default();
                    specs.insert(
                        attr(&e, b"id").unwrap_or_default(),
                        (fattr(&e, b"size"), strip_subset(&fam).to_string()),
                    );
                }
                b"text" => {
                    let (t, l) = (fattr(&e, b"top"), fattr(&e, b"left"));
                    let (size, family) = specs
                        .get(&attr(&e, b"font").unwrap_or_default())
                        .cloned()
                        .unwrap_or_default();
                    cur = Some(Run {
                        bbox: Rect {
                            x0: l,
                            y0: t,
                            x1: l + fattr(&e, b"width"),
                            y1: t + fattr(&e, b"height"),
                        },
                        size,
                        family,
                        chars: 0,
                        bold: 0,
                        italic: 0,
                    });
                }
                b"b" => b += 1,
                b"i" => i += 1,
                _ => {}
            },
            Event::End(e) => match e.name().as_ref() {
                b"b" => b = b.saturating_sub(1),
                b"i" => i = i.saturating_sub(1),
                b"text" => {
                    if let (Some(r), Some(p)) = (cur.take(), out.last_mut()) {
                        p.1.push(r);
                    }
                    (b, i) = (0, 0);
                }
                _ => {}
            },
            Event::Text(t) => {
                if let Some(r) = cur.as_mut() {
                    let n = t
                        .unescape()
                        .map(|s| s.chars().filter(|c| !c.is_whitespace()).count())
                        .unwrap_or(0);
                    r.chars += n;
                    r.bold += if b > 0 { n } else { 0 };
                    r.italic += if i > 0 { n } else { 0 };
                }
            }
            Event::Eof => break,
            _ => {}
        }
    }
    Ok(out)
}

/// `ABCDEF+Name` -> `Name`.
pub fn strip_subset(name: &str) -> &str {
    name.split_once('+').map_or(name, |(pre, rest)| {
        if pre.len() == 6 && pre.chars().all(|c| c.is_ascii_uppercase()) {
            rest
        } else {
            name
        }
    })
}

pub fn parse_fonts(text: &str) -> Vec<Font> {
    text.lines()
        .skip(2)
        .filter_map(|l| {
            let cols: Vec<&str> = l.split_whitespace().collect();
            // name type... encoding emb sub uni object ID: the last six columns are fixed.
            let n = cols.len();
            (n >= 7).then(|| {
                let name = cols[0];
                let name = strip_subset(name);
                Font {
                    name: name.to_string(),
                    kind: cols[1..n - 5]
                        .join(" ")
                        .rsplit_once(' ')
                        .map_or(String::new(), |(k, _)| k.to_string()),
                    embedded: cols[n - 5] == "yes",
                }
            })
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bbox_words_lines_pages() {
        let x = r#"<html><body><doc><page width="612.000000" height="792.000000"><flow><block>
<line xMin="72.0" yMin="133.3" xMax="539.5" yMax="149.0"><word xMin="72.0" yMin="133.3" xMax="115.8" yMax="149.0">TABLE</word><word xMin="119.3" yMin="133.3" xMax="138.1" yMax="149.0">&amp;OF</word></line>
</block></flow></page><page width="612" height="1008"></page></doc></body></html>"#;
        let p = parse_bbox(x).unwrap();
        assert_eq!(p.len(), 2);
        assert_eq!(p[1].h, 1008.0);
        assert_eq!(p[0].segs[0].words[1].t, "&OF");
        assert_eq!(p[0].segs[0].bbox.x1, 539.5);
    }

    #[test]
    fn html_runs_bold_italic() {
        let x = r##"<pdf2xml><page number="2" height="792" width="612"><fontspec id="0" size="14" family="X" color="#000000"/>
<text top="72" left="229" width="158" height="16" font="0"><b>TABLE OF</b> x<i>yz</i></text></page></pdf2xml>"##;
        let r = parse_html(x).unwrap();
        assert_eq!(r[0].0, 2);
        let run = &r[0].1[0];
        assert_eq!(
            (run.chars, run.bold, run.italic, run.size),
            (10, 7, 2, 14.0)
        );
    }

    #[test]
    fn fonts_strip_subset_prefix() {
        let t = "name type encoding emb sub uni object ID\n---- ----\nOIFGKE+Garamond-Bold                 TrueType          WinAnsi          yes yes no     246  0\nXWNPDC+EBGaramond-Bold-Identity-H    CID Type 0C       Identity-H       yes yes yes     32  0\n";
        let f = parse_fonts(t);
        assert_eq!(f[0].name, "Garamond-Bold");
        assert_eq!(f[0].kind, "TrueType");
        assert_eq!(f[1].kind, "CID Type 0C");
        assert!(f[1].embedded);
    }
}
