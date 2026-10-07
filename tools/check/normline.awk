# normline.awk: print each input line in the normal form of norm.awk.
# Usage: gawk -f norm.awk -f normline.awk
{ print norm1($0) }
