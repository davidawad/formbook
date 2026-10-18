#import "texapp-answering-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-texapp-answering-brief-sample.md"))
#render(src)
