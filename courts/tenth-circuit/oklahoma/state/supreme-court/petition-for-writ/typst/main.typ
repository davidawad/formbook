#import "okla-petition-for-writ.typ": render
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-writ.md"))
#render(src)
