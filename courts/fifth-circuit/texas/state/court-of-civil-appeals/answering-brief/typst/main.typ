#import "texapp-answering-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "samples/answering-brief.md"))
#render(src)
