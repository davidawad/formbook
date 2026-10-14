#import "texapp-answering-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-answering-brief.md"))
#render(src)
