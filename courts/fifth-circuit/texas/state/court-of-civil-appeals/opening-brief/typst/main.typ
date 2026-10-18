#import "texapp-opening-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-texapp-opening-brief-sample.md"))
#render(src)
