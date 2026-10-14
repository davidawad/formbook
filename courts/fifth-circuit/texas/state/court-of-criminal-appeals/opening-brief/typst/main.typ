#import "texcrimapp-opening-brief.typ": opening-brief
#let sample = read("/" + sys.inputs.at("sample", default: "samples/INPUT-becerra-merits.md"))
#opening-brief(sample)
