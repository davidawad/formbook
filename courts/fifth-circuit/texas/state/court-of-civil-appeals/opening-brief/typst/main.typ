#import "texapp-opening-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief.md"))
#render(src)
