#import "texapp-reply-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "samples/reply-brief.md"))
#render(src)
