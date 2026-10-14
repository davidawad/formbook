#import "texapp-opening-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-opening-brief.md"))
#render(src)
