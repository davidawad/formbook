//! `xmllint --format`, byte for byte, for the WordprocessingML parts fb writes (docxref.rs builds the styles of the
//! cross-engine recipe the way lib/docx/xengine-reference.sh did: perl edits, then `xmllint --format`).
//!
//! libxml2's rules: whitespace-only text is dropped where it only separates markup (kept inside `xml:space="preserve"`,
//! as the sole content of an element, or beside other text); an element whose children are all elements, comments or
//! processing instructions is written one child a line, indented two spaces a level; an element without children is
//! `<a/>`; namespace declarations come before the other attributes; `<`, `>`, `&` (and `"`, tab, CR, LF in attributes)
//! are escaped. The declaration is written as parsed (version, encoding, standalone).
use quick_xml::events::{BytesStart, Event};
use quick_xml::Reader;

#[derive(Debug)]
enum Node {
    Element {
        name: String,
        attrs: Vec<(String, String)>,
        children: Vec<Node>,
    },
    Text(String),
    Comment(String),
    CData(String),
    Pi(String),
}

/// An element's attributes, namespace declarations first.
type Attrs = Vec<(String, String)>;

fn err(e: impl std::fmt::Display) -> String {
    format!("xmlfmt: {e}")
}

fn start(s: &BytesStart) -> Result<(String, Attrs, bool), String> {
    let name = String::from_utf8_lossy(s.name().as_ref()).into_owned();
    let mut ns = vec![];
    let mut other = vec![];
    let mut preserve = false;
    for a in s.attributes() {
        let a = a.map_err(err)?;
        let k = String::from_utf8_lossy(a.key.as_ref()).into_owned();
        let v = a.unescape_value().map_err(err)?.into_owned();
        if k == "xml:space" && v == "preserve" {
            preserve = true;
        }
        if k == "xmlns" || k.starts_with("xmlns:") {
            ns.push((k, v));
        } else {
            other.push((k, v));
        }
    }
    ns.extend(other);
    Ok((name, ns, preserve))
}

struct Open {
    name: String,
    attrs: Vec<(String, String)>,
    children: Vec<Node>,
    preserve: bool,
}

/// Parse `text` (the declaration apart) into its root, keeping whitespace as libxml2 with `noblanks` does.
fn parse(text: &str) -> Result<(Option<String>, Node), String> {
    let mut r = Reader::from_str(text);
    let mut events = vec![];
    let mut decl = None;
    loop {
        match r.read_event().map_err(err)? {
            Event::Eof => break,
            Event::Decl(d) => {
                let v = d.version().map_err(err)?;
                let mut s = format!("<?xml version=\"{}\"", String::from_utf8_lossy(&v));
                if let Some(e) = d.encoding() {
                    s.push_str(&format!(
                        " encoding=\"{}\"",
                        String::from_utf8_lossy(&e.map_err(err)?)
                    ));
                }
                if let Some(sa) = d.standalone() {
                    s.push_str(&format!(
                        " standalone=\"{}\"",
                        String::from_utf8_lossy(&sa.map_err(err)?)
                    ));
                }
                decl = Some(s + "?>");
            }
            e => events.push(e.into_owned()),
        }
    }
    let mut stack: Vec<Open> = vec![];
    let mut root = None;
    let push = |stack: &mut Vec<Open>, root: &mut Option<Node>, n: Node| {
        if let Some(top) = stack.last_mut() {
            top.children.push(n);
        } else if matches!(n, Node::Element { .. }) {
            *root = Some(n);
        }
    };
    for (i, e) in events.iter().enumerate() {
        match e {
            Event::Start(s) => {
                let (name, attrs, p) = start(s)?;
                let preserve = p || stack.last().is_some_and(|o| o.preserve);
                stack.push(Open {
                    name,
                    attrs,
                    children: vec![],
                    preserve,
                });
            }
            Event::Empty(s) => {
                let (name, attrs, _) = start(s)?;
                push(
                    &mut stack,
                    &mut root,
                    Node::Element {
                        name,
                        attrs,
                        children: vec![],
                    },
                );
            }
            Event::End(_) => {
                let o = stack.pop().ok_or_else(|| err("unbalanced end tag"))?;
                let n = Node::Element {
                    name: o.name,
                    attrs: o.attrs,
                    children: o.children,
                };
                push(&mut stack, &mut root, n);
            }
            Event::Text(t) => {
                let s = t.unescape().map_err(err)?.into_owned();
                let Some(top) = stack.last() else { continue };
                let blank = s.chars().all(|c| matches!(c, ' ' | '\t' | '\n' | '\r'));
                let sole =
                    top.children.is_empty() && matches!(events.get(i + 1), Some(Event::End(_)));
                let beside_text = matches!(top.children.first(), Some(Node::Text(_)))
                    || matches!(top.children.last(), Some(Node::Text(_)));
                if blank && !top.preserve && !sole && !beside_text {
                    continue;
                }
                push(&mut stack, &mut root, Node::Text(s));
            }
            Event::CData(c) => {
                let s = String::from_utf8_lossy(c).into_owned();
                push(&mut stack, &mut root, Node::CData(s));
            }
            Event::Comment(c) => {
                let s = String::from_utf8_lossy(c).into_owned();
                push(&mut stack, &mut root, Node::Comment(s));
            }
            Event::PI(p) => {
                let s = String::from_utf8_lossy(p).into_owned();
                push(&mut stack, &mut root, Node::Pi(s));
            }
            _ => {}
        }
    }
    Ok((decl, root.ok_or_else(|| err("no root element"))?))
}

fn escape(s: &str, attr: bool, out: &mut String) {
    for c in s.chars() {
        match c {
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '&' => out.push_str("&amp;"),
            '\r' => out.push_str("&#13;"),
            '"' if attr => out.push_str("&quot;"),
            '\n' if attr => out.push_str("&#10;"),
            '\t' if attr => out.push_str("&#9;"),
            c => out.push(c),
        }
    }
}

fn write(n: &Node, level: usize, out: &mut String) {
    match n {
        Node::Text(t) => escape(t, false, out),
        Node::CData(t) => out.push_str(&format!("<![CDATA[{t}]]>")),
        Node::Comment(t) => out.push_str(&format!("<!--{t}-->")),
        Node::Pi(t) => out.push_str(&format!("<?{t}?>")),
        Node::Element {
            name,
            attrs,
            children,
        } => {
            out.push('<');
            out.push_str(name);
            for (k, v) in attrs {
                out.push(' ');
                out.push_str(k);
                out.push_str("=\"");
                escape(v, true, out);
                out.push('"');
            }
            if children.is_empty() {
                out.push_str("/>");
                return;
            }
            out.push('>');
            let format = !children
                .iter()
                .any(|c| matches!(c, Node::Text(_) | Node::CData(_)));
            if format {
                out.push('\n');
            }
            for c in children {
                if format {
                    out.push_str(&"  ".repeat(level + 1));
                }
                write(c, level + 1, out);
                if format {
                    out.push('\n');
                }
            }
            if format {
                out.push_str(&"  ".repeat(level));
            }
            out.push_str(&format!("</{name}>"));
        }
    }
}

/// `xmllint --format` of the document `text`.
pub fn format(text: &str) -> Result<String, String> {
    let (decl, root) = parse(text)?;
    let mut out = decl.unwrap_or_else(|| "<?xml version=\"1.0\"?>".into());
    out.push('\n');
    write(&root, 0, &mut out);
    out.push('\n');
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn indents_element_only_content_and_closes_empty_elements() {
        let got = format(
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<a x=\"1\">\n  <b />\n<c><d>t</d></c></a>",
        )
        .unwrap();
        assert_eq!(
            got,
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<a x=\"1\">\n  <b/>\n  <c>\n    <d>t</d>\n  </c>\n</a>\n"
        );
    }

    #[test]
    fn keeps_mixed_content_preserved_space_and_sole_blanks() {
        let got =
            format("<a><p>x <i>y</i> z</p><t xml:space=\"preserve\"> </t><e>  </e></a>").unwrap();
        assert_eq!(
            got,
            "<?xml version=\"1.0\"?>\n<a>\n  <p>x <i>y</i> z</p>\n  <t xml:space=\"preserve\"> </t>\n  <e>  </e>\n</a>\n"
        );
    }

    #[test]
    fn namespaces_first_and_escapes() {
        let got = format("<w:s a=\"&quot;&lt;\" xmlns:w=\"u\"><w:t>&amp;&gt;</w:t></w:s>").unwrap();
        assert_eq!(
            got,
            "<?xml version=\"1.0\"?>\n<w:s xmlns:w=\"u\" a=\"&quot;&lt;\">\n  <w:t>&amp;&gt;</w:t>\n</w:s>\n"
        );
    }
}
