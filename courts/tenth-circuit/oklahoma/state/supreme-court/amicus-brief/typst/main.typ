#import "okla-amicus-brief.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-amicus-brief.md"))
#render(src)
