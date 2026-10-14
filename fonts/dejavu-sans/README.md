# DejaVu Sans

- Role: visual fallback for Tahoma. It is NOT metric-compatible with Tahoma: DejaVu Sans is wider, so line breaks and pagination may differ from real Tahoma. No free metric-compatible Tahoma exists (see `fonts/TAHOMA-NOTE.md`).
- Styles: Regular, Bold, Oblique (italic), BoldOblique (4 TTFs). Typst selects the oblique faces for `style: "italic"`.
- Licence: Bitstream Vera licence plus public-domain DejaVu changes (`LICENSE.txt`). Free to redistribute with this GPL v3 repository; the fonts are bundled unmodified, and the licence forbids selling them on their own or reusing the Bitstream/DejaVu names for modified versions.
- Source: see `SOURCE.md` (release URL, archive and file SHA-256).
- Typst: `#set text(font: "DejaVu Sans")`; proof in `fonts/tests/dejavu-sans.typ`.
