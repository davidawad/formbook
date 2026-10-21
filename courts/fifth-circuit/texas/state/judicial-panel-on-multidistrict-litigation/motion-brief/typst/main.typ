#import "texjpml-motion-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#render(src)
