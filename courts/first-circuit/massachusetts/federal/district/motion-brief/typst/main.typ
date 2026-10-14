// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/first-circuit/massachusetts/federal/district/motion-brief samples/INPUT-smith-college-motion-to-dismiss.md
#import "mad-motion-brief.typ": mad-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-smith-college-motion-to-dismiss.md"))
#let (meta, body) = split-frontmatter(src)
#mad-motion-brief(meta, body)
