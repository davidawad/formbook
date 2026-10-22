use super::*;

const SPEC: &str = r#"<?xml version="1.0"?>
<reference xmlns:w="w" xmlns:r="r" theme-font="Times New Roman" strip-theme-fonts="true">
<w:docDefaults><w:rPrDefault/></w:docDefaults>
<w:style w:type="paragraph" w:styleId="Normal"><w:name w:val="Normal"/></w:style>
<w:style w:type="paragraph" w:styleId="New"><w:name w:val="New"/></w:style>
<footer id="rIdF"><w:p><w:r><w:t>1</w:t></w:r></w:p></footer>
<header id="rIdH"><w:p/></header>
<w:sectPr><w:footerReference r:id="rIdF"/></w:sectPr>
</reference>
"#;

#[test]
fn parses_every_piece() {
    let s = parse(SPEC, None).unwrap();
    assert!(!s.replace_styles && s.strip_theme_fonts);
    assert_eq!(s.theme_font.as_deref(), Some("Times New Roman"));
    assert_eq!(
        s.defaults.as_deref(),
        Some("<w:docDefaults><w:rPrDefault/></w:docDefaults>")
    );
    assert_eq!(s.styles.len(), 2);
    assert_eq!(s.headers, vec![("rIdH".to_string(), "<w:p/>".to_string())]);
    assert_eq!(
        s.footers,
        vec![(
            "rIdF".to_string(),
            "<w:p><w:r><w:t>1</w:t></w:r></w:p>".to_string()
        )]
    );
    assert_eq!(
        s.sect.as_deref(),
        Some(r#"<w:sectPr><w:footerReference r:id="rIdF"/></w:sectPr>"#)
    );
    assert!(parse("<reference styles=\"x\"/>", None).is_err());
    assert!(parse("<reference><w:style></reference>", None).is_err());
}

#[test]
fn merge_replaces_same_ids_and_appends_the_rest() {
    let base = "<w:styles>\n<w:docDefaults><old/></w:docDefaults>\n<w:style w:styleId=\"Normal\"><w:rFonts w:asciiTheme=\"minorHAnsi\" w:ascii=\"A\"/></w:style>\n<w:style w:styleId=\"Keep\"><w:rFonts w:hAnsiTheme=\"x\"/></w:style>\n</w:styles>";
    let got = styles(base, &parse(SPEC, None).unwrap()).unwrap();
    assert!(!got.contains("<old/>") && got.contains("<w:rPrDefault/>"));
    assert_eq!(got.matches("w:styleId=\"Normal\"").count(), 1);
    assert!(got.contains("<w:name w:val=\"Normal\"/>") && got.contains("w:styleId=\"New\""));
    assert!(got.contains("w:styleId=\"Keep\"><w:rFonts/>"));
    assert!(got.find("w:styleId=\"New\"") < got.find("</w:styles>"));
    assert!(got.find("<w:name w:val=\"Normal\"/>") < got.find("w:styleId=\"Keep\""));
}

#[test]
fn replace_keeps_only_the_spec() {
    let spec = SPEC.replace("<reference ", "<reference styles=\"replace\" ");
    let got = styles(
        "<w:styles><w:style w:styleId=\"Old\"/></w:styles>",
        &parse(&spec, None).unwrap(),
    )
    .unwrap();
    assert!(
        !got.contains("Old")
            && got.contains("w:styleId=\"New\"")
            && got.contains("<w:rPrDefault/>")
    );
}

#[test]
fn theme_sets_major_and_minor_latin() {
    let t = "<a:majorFont><a:latin typeface=\"Aptos Display\"/></a:majorFont><a:minorFont><a:latin typeface=\"Aptos\"/></a:minorFont>";
    assert_eq!(
        theme(t, "Times New Roman"),
        "<a:majorFont><a:latin typeface=\"Times New Roman\"/></a:majorFont><a:minorFont><a:latin typeface=\"Times New Roman\"/></a:minorFont>"
    );
}

#[test]
fn elements_do_not_confuse_style_and_styles() {
    assert_eq!(
        elements(
            "<w:latentStyles w:count=\"1\"/><w:style a=\"2\"/>",
            "w:latentStyles"
        ),
        ["<w:latentStyles w:count=\"1\"/>"]
    );
    assert_eq!(
        elements(
            "<w:styles><w:style a=\"1\">x</w:style></w:styles>",
            "w:style"
        ),
        ["<w:style a=\"1\">x</w:style>"]
    );
}

#[test]
fn font_comes_from_the_typst_face() {
    let spec = "<reference theme-font=\"{font}\"><w:style w:styleId=\"N\"><w:rFonts w:ascii=\"{font}\"/></w:style></reference>";
    let s = parse(spec, Some("TeX Gyre Schola")).unwrap();
    assert_eq!(s.theme_font.as_deref(), Some("TeX Gyre Schola"));
    assert!(s.styles[0].contains("w:ascii=\"TeX Gyre Schola\""));
    assert!(parse(spec, None).is_err());
    assert!(parse("<reference/>", None).is_ok());
}

#[test]
fn a_whole_styles_part_is_written_verbatim() {
    let spec = "<reference pandoc-from=\"markdown-smart\">\n<w:styles xmlns:w=\"w\">\n  <w:style w:styleId=\"A\"/>\n</w:styles>\n<part name=\"word/settings.xml\"><w:settings xmlns:w=\"w\"/></part>\n</reference>";
    let s = parse(spec, None).unwrap();
    assert!(s.styles.is_empty() && s.defaults.is_none());
    assert_eq!(s.pandoc_from.as_deref(), Some("markdown-smart"));
    assert_eq!(
        s.parts,
        vec![(
            "word/settings.xml".to_string(),
            "<w:settings xmlns:w=\"w\"/>".to_string()
        )]
    );
    assert_eq!(
        styles("<ignored/>", &s).unwrap(),
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<w:styles xmlns:w=\"w\">\n  <w:style w:styleId=\"A\"/>\n</w:styles>\n"
    );
    let mixed = spec.replace("<part", "<w:style w:styleId=\"B\"/><part");
    assert!(parse(&mixed, None).is_err());
}

#[test]
fn xengine_base_needs_its_parameters_and_a_face() {
    let spec = "<reference base=\"xengine\" size=\"28\" body=\"588\" single=\"340\"/>";
    let s = parse(spec, Some("Times New Roman")).unwrap();
    assert_eq!(s.xengine.unwrap().font, "Times New Roman");
    assert!(parse(spec, None).is_err());
    assert!(parse("<reference base=\"xengine\" size=\"28\"/>", Some("X")).is_err());
    assert!(parse("<reference base=\"other\"/>", Some("X")).is_err());
}

#[test]
fn extra_namespaces_go_on_the_styles_part() {
    let spec = "<reference xmlns:w=\"w\" xmlns:r=\"r\" xmlns:w14=\"x14\" mc:Ignorable=\"w14\" xmlns:mc=\"m\"><w:style w:styleId=\"A\"/></reference>";
    let s = parse(spec, None).unwrap();
    assert_eq!(
        s.ns,
        "xmlns:w14=\"x14\" mc:Ignorable=\"w14\" xmlns:mc=\"m\" "
    );
    let got = styles("<w:styles xmlns:w=\"w\">\n</w:styles>", &s).unwrap();
    assert!(got.starts_with(
        "<w:styles xmlns:w14=\"x14\" mc:Ignorable=\"w14\" xmlns:mc=\"m\" xmlns:w=\"w\">"
    ));
    assert!(parse("<reference xmlns:w=\"w\" xmlns:r=\"r\"/>", None)
        .unwrap()
        .ns
        .is_empty());
}

#[test]
fn an_xengine_spec_may_replace_the_recipes_footer() {
    let base = "<reference base=\"xengine\" size=\"24\" body=\"480\" single=\"280\">";
    let s = parse(&format!("{base}</reference>"), Some("X")).unwrap();
    let f = crate::docxxengine::footers(&s.footers, s.xengine.as_ref());
    assert_eq!(f.len(), 1);
    assert_eq!(
        (f[0].0.as_str(), f[0].1.as_str()),
        ("rIdFooter1", crate::docxxengine::FOOTER)
    );
    let own = format!("{base}<footer id=\"rIdFooter1\"><w:p/></footer><footer id=\"rIdF\"><w:p/></footer></reference>");
    let o = parse(&own, Some("X")).unwrap();
    let ids: Vec<String> = crate::docxxengine::footers(&o.footers, o.xengine.as_ref())
        .into_iter()
        .map(|(id, _)| id)
        .collect();
    assert_eq!(ids, ["rIdFooter1", "rIdF"]);
    let plain = parse(SPEC, None).unwrap();
    assert_eq!(
        crate::docxxengine::footers(&plain.footers, plain.xengine.as_ref()).len(),
        1
    );
}
