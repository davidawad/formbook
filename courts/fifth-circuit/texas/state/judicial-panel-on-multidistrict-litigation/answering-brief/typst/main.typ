#import "texjpml-answering-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-answering-brief.md"))
#render(src)
