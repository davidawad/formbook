#import "texjpml-reply-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-reply-brief.md"))
#render(src)
