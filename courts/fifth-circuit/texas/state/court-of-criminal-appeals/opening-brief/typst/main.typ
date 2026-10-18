#import "texcrimapp-opening-brief.typ": opening-brief
#let sample = read("/" + sys.inputs.at("sample", default: "usage/INPUT-texcrimapp-opening-brief-becerramerits.md"))
#opening-brief(sample)
