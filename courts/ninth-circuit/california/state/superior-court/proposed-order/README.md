# calsuperct: proposed order

Doc type `proposed-order` for California Superior Courts (alias `calsuperct`), initially configured for Santa Clara County. Templates: `typst/calsuperct-proposed-order.typ` and `docx/calsuperct.lua`.

The sample is fictional and uses a Penal Code section 1538.5 suppression motion. The proposed-order block embedded in the motion sample is enclosed in an HTML comment so it can be omitted from the motion PDF; the standalone proposed-order sample renders that material as a filing.

## Rules (verified 2026-11-25)

- California Rules of Court 2.100–2.119 govern paper size, type, margins, line numbering, pagination and footer. See `../rules.md` for the rule numbers and Judicial Council URLs.
- California Rules of Court 3.1312(a)–(c) govern service and submission after a motion ruling, and require both a filed PDF attached to Judicial Council form EFS-020 and an editable word-processing version when the case is e-filed. CRC 3.1113(h) says a proposed order submitted with moving papers must be lodged and served, not attached. Sources: [CRC 3.1312](https://www.courts.ca.gov/cms/rules/index/three/rule3_1312), [CRC 3.1113](https://www.courts.ca.gov/cms/rules/index/three/rule3_1113).
- Santa Clara County Criminal Local Rule 11 (effective July 1, 2026) requires the order title in a footer on every page, including the signature page, and requires order text on the signature page. The template repeats the paper title in its footer and keeps the signature block with the final order text. Source: [Santa Clara Criminal Local Rules](https://santaclara.courts.ca.gov/system/files/rules/criminal.pdf).
- Verify the assigned department's standing order and filing instructions before submission.

The layout follows the calsuperct motion template's 28 numbered double-spaced lines, Times New Roman equivalent at 12 pt, Arabic page numbers and printed footer title. The DOCX engine produces the editable order as well as its PDF render.
