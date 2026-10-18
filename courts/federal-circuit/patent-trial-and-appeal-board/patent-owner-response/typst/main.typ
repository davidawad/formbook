// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ptab-patent-owner-response.typ": patent-owner-response

#let src = read("/" + sys.inputs.at("sample"))
#let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
#if m == none { panic("the sample must start with a YAML frontmatter block") }
#let meta = yaml(bytes(m.captures.at(0)))
#let body = src.slice(m.end)
#patent-owner-response(meta, body)
