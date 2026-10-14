// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/tenth-circuit/new-mexico/federal/bankruptcy-district/adversary-complaint samples/<id>.md
#import "nmb-adversary-complaint.typ": nmb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-johnson-v-marker-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#nmb-adversary-complaint(meta, body)
