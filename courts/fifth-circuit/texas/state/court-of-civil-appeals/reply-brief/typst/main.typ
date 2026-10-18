#import "texapp-reply-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-texapp-reply-brief-sample.md"))
#render(src)
