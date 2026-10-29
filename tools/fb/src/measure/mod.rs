//! `fb measure <pdf> [-o measured.jsoif pleading > 0 { format!(" pleading {pleading}") } else { String::new() }]`: the geometry of a PDF as JSON, the same for a filed exemplar and
//! for our render, so `fb diff` can compare them gate by gate.
//!
//! Sources (poppler only): words and lines from `pdftotext -bbox-layout`, baselines, rules, boxes, vectors and
//! images from `pdftocairo -svg` (one page at a time), per-line weight/slant/size from `pdftohtml -xml`,
//! embedded fonts from `pdffonts`. Coordinates are PDF points, origin top left, rounded to 0.01 pt (the
//! measurement resolution: two equal values can differ by at most that after rounding).
mod build;
mod mask;
mod poppler;
mod stats;
mod svg;

use crate::{fail, Res};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

pub use build::frame as frame_of;
pub use build::mode as mode_of;
pub use mask::MaskRegion;
pub use stats::continues;

/// Bumped whenever the measured.json layout or its derivation changes (invalidates the cache).
pub const SCHEMA: u32 = 4;

/// Coordinate resolution of measured.json in points.
pub const RES: f64 = 0.01;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Measured {
    pub schema: u32,
    pub source: String,
    pub sha256: String,
    pub fonts: Vec<Font>,
    pub pages: Vec<Page>,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Font {
    /// The embedded name without the subset prefix (`ABCDEF+`).
    pub name: String,
    pub kind: String,
    pub embedded: bool,
}

#[derive(Serialize, Deserialize, Clone, Copy, Debug, PartialEq, Default)]
pub struct Rect {
    pub x0: f64,
    pub y0: f64,
    pub x1: f64,
    pub y1: f64,
}

impl Rect {
    pub fn w(&self) -> f64 {
        self.x1 - self.x0
    }
    pub fn h(&self) -> f64 {
        self.y1 - self.y0
    }
    pub fn intersects(&self, o: &Rect) -> bool {
        self.x0 < o.x1 && o.x0 < self.x1 && self.y0 < o.y1 && o.y0 < self.y1
    }
    pub fn contains_pt(&self, x: f64, y: f64) -> bool {
        x >= self.x0 && x <= self.x1 && y >= self.y0 && y <= self.y1
    }
    pub fn union(&self, o: &Rect) -> Rect {
        Rect {
            x0: self.x0.min(o.x0),
            y0: self.y0.min(o.y0),
            x1: self.x1.max(o.x1),
            y1: self.y1.max(o.y1),
        }
    }
    fn rounded(&self) -> Rect {
        Rect {
            x0: r2(self.x0),
            y0: r2(self.y0),
            x1: r2(self.x1),
            y1: r2(self.y1),
        }
    }
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Word {
    pub t: String,
    pub x0: f64,
    pub y0: f64,
    pub x1: f64,
    pub y1: f64,
}

/// One visual line: every pdftotext line segment sharing the line's vertical band (tab-separated TOC
/// columns, superscript markers) merged, words left to right.
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Line {
    pub text: String,
    /// The y of the glyph origins (mode over the line's glyphs); `yMax` of the box when no glyph was found
    /// (`baseline_est` true).
    pub baseline: f64,
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    pub baseline_est: bool,
    pub left: f64,
    pub right: f64,
    pub top: f64,
    pub bottom: f64,
    /// Font size of most of the line's characters (pdftohtml, whole points); 0 when unknown.
    pub size: f64,
    /// Font family of most of the line's characters (pdftohtml, subset prefix dropped); empty when unknown.
    #[serde(default)]
    pub font: String,
    pub bold: bool,
    pub italic: bool,
    pub words: Vec<Word>,
}

/// Text frame of a page: extreme left and right of its lines and its first and last baselines.
#[derive(Serialize, Deserialize, Clone, Copy, Debug, PartialEq)]
pub struct Frame {
    pub left: f64,
    pub right: f64,
    pub top: f64,
    pub bottom: f64,
}

/// Derived page layout numbers (diagnostic; the gates compare lines, not these).
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, Default)]
pub struct Stats {
    /// Most common line left edge.
    pub left: Option<f64>,
    /// Most common positive baseline-to-baseline distance.
    pub pitch: Option<f64>,
    /// Most common first-line indent of paragraphs (first line right of the rest).
    pub first_line_indent: Option<f64>,
    /// Most common hanging indent of paragraphs (rest of the lines right of the first), as the left edge of
    /// the hanging lines.
    pub hanging: Option<f64>,
    /// Every distinct line left edge with its count, left to right.
    pub lefts: Vec<(f64, usize)>,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Masked {
    pub kind: String,
    pub bbox: Rect,
    #[serde(default, skip_serializing_if = "String::is_empty")]
    pub text: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Page {
    pub n: usize,
    pub w: f64,
    pub h: f64,
    pub frame: Option<Frame>,
    pub stats: Stats,
    pub lines: Vec<Line>,
    /// Horizontal or vertical strokes and thin filled rectangles (underlines, signature lines, table rules).
    pub rules: Vec<Rect>,
    /// Rectangles (filled or stroked) larger than a rule in both directions.
    pub boxes: Vec<Rect>,
    /// Bounding boxes of other vector paths that are not glyphs.
    pub vectors: Vec<Rect>,
    /// Raster images (signatures, seals, stamps): recorded, never compared.
    pub images: Vec<Rect>,
    /// What was taken out before comparison and why (CM/ECF banner, clerk stamp, mask file region).
    pub masked: Vec<Masked>,
}

pub fn r2(v: f64) -> f64 {
    (v * 100.0).round() / 100.0
}

pub fn sha256_file(p: &Path) -> Res<String> {
    let bytes = std::fs::read(p).map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))?;
    Ok(format!("{:x}", Sha256::digest(&bytes)))
}

/// Measure a PDF with the given mask regions (from a mask file; built-in masks always apply).
pub fn measure(pdf: &Path, regions: &[MaskRegion]) -> Res<Measured> {
    measure_pleading(pdf, regions, 0)
}

/// `measure` of a PDF on pleading paper of `pleading` numbered lines a page (0: none), its line numbers left out
/// (build.rs unpleading).
pub fn measure_pleading(pdf: &Path, regions: &[MaskRegion], pleading: usize) -> Res<Measured> {
    let sha256 = sha256_file(pdf)?;
    let raw = poppler::read(pdf)?;
    let pages = build::pages_pleading(raw.pages, regions, pleading);
    Ok(Measured {
        schema: SCHEMA,
        source: pdf.display().to_string(),
        sha256,
        fonts: raw.fonts,
        pages,
    })
}

/// The first `n` pages of `pdf` measured (no cache), with its mask file regions: page-level checks that need
/// only the cover (DEF-COVER-002) do not pay for a whole brief.
pub fn measure_first(pdf: &Path, n: usize) -> Res<Measured> {
    let regions = mask::regions_for(pdf)?;
    let raw = poppler::read_upto(pdf, Some(n))?;
    Ok(Measured {
        schema: SCHEMA,
        source: pdf.display().to_string(),
        sha256: sha256_file(pdf)?,
        fonts: raw.fonts,
        pages: build::pages(raw.pages, &regions),
    })
}

/// Measured form of `p`: a measured.json is read as is; a PDF is measured, through the cache in
/// `$root/out/measure/<sha256>-<schema>-<masks and fb build>.json`.
pub fn load(p: &Path) -> Res<Measured> {
    load_pleading(p, 0)
}

/// `load` of a PDF on pleading paper of `pleading` numbered lines a page (0: none; measure_pleading). A measured.json
/// is read as is.
pub fn load_pleading(p: &Path, pleading: usize) -> Res<Measured> {
    if p.extension().is_some_and(|e| e == "json") {
        let text =
            std::fs::read_to_string(p).map_err(|e| fail(2, format!("fb: {}: {e}", p.display())))?;
        let m: Measured = serde_json::from_str(&text)
            .map_err(|e| fail(2, format!("fb: {}: not a measured.json: {e}", p.display())))?;
        return Ok(m);
    }
    let regions = mask::regions_for(p)?;
    // The key covers the PDF, the masks, the schema and the fb binary itself (rebuilt = remeasured).
    let exe = std::env::current_exe()
        .and_then(std::fs::metadata)
        .map(|m| format!("{:?}{}", m.modified().ok(), m.len()))
        .unwrap_or_default();
    let key = format!(
        "{}-{SCHEMA}-{:x}.json",
        sha256_file(p)?,
        Sha256::digest(
            format!(
                "{}{exe}{}",
                serde_json::to_string(&regions).unwrap_or_default(),
                [pleading]
                    .iter()
                    .filter(|n| **n > 0)
                    .map(|n| format!(" pleading {n}"))
                    .collect::<String>()
            )
            .as_bytes()
        )
    );
    let cache = crate::repo_root()
        .ok()
        .map(|r| r.join("out/measure").join(key));
    if let Some(m) = cache.as_ref().and_then(|c| read_cache(c)) {
        return Ok(Measured {
            source: p.display().to_string(),
            ..m
        });
    }
    let m = measure_pleading(p, &regions, pleading)?;
    if let Some(c) = cache {
        let _ = std::fs::create_dir_all(c.parent().unwrap_or(Path::new(".")));
        let _ = std::fs::write(&c, serde_json::to_string(&m).unwrap_or_default());
    }
    Ok(m)
}

fn read_cache(c: &Path) -> Option<Measured> {
    let text = std::fs::read_to_string(c).ok()?;
    serde_json::from_str::<Measured>(&text)
        .ok()
        .filter(|m| m.schema == SCHEMA)
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let usage = "usage: fb measure <pdf> [-o measured.json] [--page N] [--pleading N]";
    let mut pdf: Option<PathBuf> = None;
    let mut out: Option<PathBuf> = None;
    let mut page: Option<usize> = None;
    let mut pleading = 0;
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "-o" => out = it.next().map(PathBuf::from),
            "--page" => page = it.next().and_then(|n| n.parse().ok()),
            "--pleading" => {
                pleading = it
                    .next()
                    .and_then(|n| n.parse().ok())
                    .ok_or_else(|| fail(2, usage))?
            }
            s if !s.starts_with('-') && pdf.is_none() => pdf = Some(PathBuf::from(s)),
            _ => return Err(fail(2, usage)),
        }
    }
    let pdf = pdf.ok_or_else(|| fail(2, usage))?;
    let mut m = load_pleading(&pdf, pleading)?;
    if let Some(n) = page {
        m.pages.retain(|p| p.n == n);
    }
    let json = serde_json::to_string_pretty(&m).map_err(|e| fail(2, format!("fb: {e}")))?;
    match out {
        Some(o) => std::fs::write(&o, json + "\n")
            .map_err(|e| fail(2, format!("fb: {}: {e}", o.display())))?,
        None => println!("{json}"),
    }
    Ok(ExitCode::SUCCESS)
}
