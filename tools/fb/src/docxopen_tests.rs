use super::*;

const TYPES: &str = r#"<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/xml"/><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>"#;
const ROOT_RELS: &str = r#"<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>"#;
const DOC_RELS: &str = r#"<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId9" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>"#;
const FOOTER: &str = r#"<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p/></w:ftr>"#;

fn doc(sect_id: &str) -> String {
    format!(
        r#"<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body><w:p/><w:sectPr><w:footerReference w:type="default" r:id="{sect_id}"/></w:sectPr></w:body></w:document>"#
    )
}

fn package(document: &str) -> BTreeMap<String, Vec<u8>> {
    [
        ("[Content_Types].xml", TYPES.to_string()),
        ("_rels/.rels", ROOT_RELS.to_string()),
        ("word/document.xml", document.to_string()),
        ("word/_rels/document.xml.rels", DOC_RELS.to_string()),
        ("word/footer1.xml", FOOTER.to_string()),
    ]
    .into_iter()
    .map(|(k, v)| (k.to_string(), v.into_bytes()))
    .collect()
}

#[test]
fn a_sound_package_has_no_problems() {
    assert_eq!(
        package_problems(&package(&doc("rId9"))),
        Vec::<String>::new()
    );
}

#[test]
fn a_dangling_relationship_id_is_found() {
    // fb-595.64: the filter's sectPr named rIdFooter1; pandoc had renumbered the footer rId9
    let got = package_problems(&package(&doc("rIdFooter1")));
    assert_eq!(got.len(), 1, "{got:?}");
    assert!(got[0].starts_with("word/document.xml: <w:footerReference r:id=\"rIdFooter1\">"));
}

#[test]
fn any_prefix_bound_to_the_relationships_namespace_counts() {
    let d = doc("rIdX")
        .replace("xmlns:r=", "xmlns:rel=")
        .replace("r:id=", "rel:id=");
    let got = package_problems(&package(&d));
    assert!(got.iter().any(|p| p.contains("rel:id=\"rIdX\"")), "{got:?}");
}

#[test]
fn malformed_xml_is_found() {
    let got = package_problems(&package("<w:document><w:body></w:document>"));
    assert!(
        got.iter()
            .any(|p| p.starts_with("word/document.xml is not well-formed XML")),
        "{got:?}"
    );
    let got = package_problems(&package("<a/><b/>"));
    assert!(got.iter().any(|p| p.contains("2 root elements")), "{got:?}");
    let got = package_problems(&package("<a>&nope;</a>"));
    assert!(got.iter().any(|p| p.contains("not well-formed")), "{got:?}");
}

#[test]
fn missing_targets_and_content_types_are_found() {
    let mut p = package(&doc("rId9"));
    p.remove("word/footer1.xml");
    let got = package_problems(&p);
    assert!(
        got.iter().any(|x| x.contains("rId9 targets footer1.xml")),
        "{got:?}"
    );
    let mut p = package(&doc("rId9"));
    p.insert("word/media/a.png".into(), vec![0]);
    let got = package_problems(&p);
    assert_eq!(
        got,
        vec!["word/media/a.png has no content type".to_string()]
    );
    let mut p = package(&doc("rId9"));
    p.remove("word/document.xml");
    let got = package_problems(&p);
    assert!(
        got.iter().any(|x| x.contains("names /word/document.xml")),
        "{got:?}"
    );
}

#[test]
fn relationship_targets_resolve_like_opc() {
    assert_eq!(
        resolve("word/document.xml", "footer1.xml"),
        "word/footer1.xml"
    );
    assert_eq!(
        resolve("word/document.xml", "../customXml/a.xml"),
        "customXml/a.xml"
    );
    assert_eq!(resolve("", "word/document.xml"), "word/document.xml");
    assert_eq!(
        resolve("word/document.xml", "/word/media/x.png"),
        "word/media/x.png"
    );
    assert_eq!(
        rels_source("word/_rels/document.xml.rels").as_deref(),
        Some("word/document.xml")
    );
    assert_eq!(rels_source("_rels/.rels").as_deref(), Some(""));
}

#[test]
fn declared_twice_is_found() {
    // a render script that adds the footer relationship pandoc already carried over (nywb, fb-595.64)
    let mut p = package(&doc("rId9"));
    let rels = DOC_RELS.replace(
        "</Relationships>",
        r#"<Relationship Id="rId9" Type="x" Target="footer1.xml"/></Relationships>"#,
    );
    let types = TYPES.replace(
        "</Types>",
        r#"<Override PartName="/word/document.xml" ContentType="x"/></Types>"#,
    );
    p.insert("word/_rels/document.xml.rels".into(), rels.into_bytes());
    p.insert("[Content_Types].xml".into(), types.into_bytes());
    let got = package_problems(&p);
    assert!(
        got.contains(
            &"word/_rels/document.xml.rels: relationship id rId9 is declared twice".to_string()
        ),
        "{got:?}"
    );
    assert!(
        got.contains(&"[Content_Types].xml overrides /word/document.xml twice".to_string()),
        "{got:?}"
    );
}
