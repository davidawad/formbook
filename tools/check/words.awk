# words.awk: `pdftotext -tsv` -> one record per word, exact to 0.01 pt.
#
# Usage: pdftotext -tsv file.pdf - | gawk -f words.awk > words.tsv
# Record: PAGE LEFT TOP RIGHT BOTTOM HEIGHT TEXT
BEGIN { FS = "\t"; OFS = "\t" }
$1 == 5 { print $2, $7, $8, $7 + $9, $8 + $10, $10, $12 }
