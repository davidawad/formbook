#import "texcrimapp-opening-brief.typ": opening-brief
#let sample = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief.md"))
#opening-brief(sample)
