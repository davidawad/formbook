#import "okla-brief-on-the-merits.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-brief-on-the-merits.md"))
#render(src)
