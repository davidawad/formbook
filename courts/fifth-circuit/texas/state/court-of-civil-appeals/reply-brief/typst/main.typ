#import "texapp-reply-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-reply-brief.md"))
#render(src)
