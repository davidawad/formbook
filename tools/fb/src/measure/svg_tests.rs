//! Tests of svg.rs.
use super::*;

const SVG: &str = r##"<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="612" height="792">
<defs><g><g id="glyph-0-0"><path d="M 1 -9 L 2 -9 Z"/></g></g>
<clipPath id="clip-0"><path clip-rule="nonzero" d="M 200 201 L 411 201 L 411 234.5 L 200 234.5 Z"/></clipPath>
<image id="source-5" x="0" y="0" width="644" height="103" xlink:href="data:image/png;base64,AA"/>
</defs>
<g fill="rgb(0%, 0%, 0%)" fill-opacity="1"><use xlink:href="#glyph-0-0" x="228.84" y="84.12"/></g>
<path fill-rule="nonzero" fill="rgb(0%, 0%, 0%)" d="M 510.5 115.6 L 540 115.6 L 540 114.9 L 510.5 114.9 Z M 510.5 115.6 "/>
<path fill="rgb(100%, 100%, 100%)" d="M 0 0 L 612 0 L 612 792 Z"/>
<path fill="none" stroke-width="1.5" stroke="rgb(0%, 0%, 0%)" d="M 0 0.0014 L 468 0.0014 " transform="matrix(1, 0, 0, -1, 72, 264.06)"/>
<rect x="100" y="300" width="50" height="40" fill="none" stroke="rgb(0%,0%,0%)" stroke-width="1"/>
<g clip-path="url(#clip-0)"><g mask="url(#mask-0)"><rect x="-61.2" y="-79.2" width="734.4" height="950.4" fill="rgb(0%, 0%, 0%)"/></g></g>
</svg>"##;

#[test]
fn glyph_baselines_rules_boxes_images() {
    let p = parse(SVG).unwrap();
    assert_eq!(p.glyphs, vec![(228.84, 84.12)]);
    assert_eq!(p.rules.len(), 2, "{:?}", p.rules);
    assert!((p.rules[1].y0 - (264.06 - 0.0014 - 0.75)).abs() < 1e-6);
    assert_eq!(p.rules[0].x1, 540.0);
    assert_eq!(p.boxes.len(), 1);
    assert_eq!(
        p.images,
        vec![Rect {
            x0: 200.0,
            y0: 201.0,
            x1: 411.0,
            y1: 234.5
        }]
    );
    assert!(
        p.vectors.is_empty(),
        "white fill is skipped: {:?}",
        p.vectors
    );
}

#[test]
fn use_of_a_defs_group_draws_it() {
    let x = r##"<svg xmlns:xlink="http://www.w3.org/1999/xlink"><defs><g id="glyph-0-0"><path d="M 0 0 L 1 1"/></g>
<clipPath id="clip-0"><path d="M 0 0 L 612 0 L 612 792 L 0 792 Z"/></clipPath>
<g id="source-5" clip-path="url(#clip-0)"><use xlink:href="#glyph-0-0" x="269.26" y="91.14"/>
<path fill="none" stroke="rgb(0%,0%,0%)" stroke-width="1" d="M 72 108 L 540 108"/></g></defs>
<use xlink:href="#source-5" x="3.6"/></svg>"##;
    let p = parse(x).unwrap();
    assert_eq!(p.glyphs.len(), 1);
    assert!((p.glyphs[0].0 - 272.86).abs() < 1e-9 && p.glyphs[0].1 == 91.14);
    assert_eq!(p.rules.len(), 1);
    assert!((p.rules[0].x0 - 75.1).abs() < 1e-9, "{:?}", p.rules);
}

#[test]
fn path_numbers_and_relative() {
    assert_eq!(path_points("M1-2L3 4"), vec![(1.0, -2.0), (3.0, 4.0)]);
    assert_eq!(
        path_points("m 10 10 h 5 v 5 z"),
        vec![(10.0, 10.0), (15.0, 10.0), (15.0, 15.0)]
    );
}

#[test]
fn transforms_compose() {
    let m = parse_transform("translate(10, 20) scale(2)");
    assert_eq!(apply(&m, 1.0, 1.0), (12.0, 22.0));
}

#[test]
fn shapes_end_at_the_page_edge() {
    let svg = r#"<svg width="612" height="792" viewBox="0 0 612 792"><path fill="none" stroke="rgb(0%,0%,0%)" stroke-width="0.5" d="M 72 654 L 14112 654"/><path fill="rgb(0%,0%,0%)" d="M 700 10 L 800 10 L 800 20 L 700 20 Z"/></svg>"#;
    let p = parse(svg).unwrap();
    assert_eq!(p.rules.len(), 1, "{:?}", p.rules);
    assert_eq!(p.rules[0].x1, 612.0);
    assert!(p.boxes.is_empty() && p.vectors.is_empty(), "{p:?}");
}
