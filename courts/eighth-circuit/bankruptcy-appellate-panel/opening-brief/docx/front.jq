# front.jq: the cover, the front matter and the back matter of the brief, as pandoc markdown, from the
# frontmatter of the sample (as JSON). Mirrors bap8-*.typ (cover-body, certifications, certificates).
# Input: the frontmatter as JSON. Args: $words (formatted word count), $doc_kind_limit not used here.
# Output: {"cover": md, "front": md, "back": md}. docx/render.sh assembles them around the body.

def div(s; b): "::: {custom-style=\"\(s)\"}\n\(b)\n:::\n\n";
def nb: " ";
def gap: div("CoverGap"; nb);
def rule(s): div(s; nb);
def hard(xs): xs | join("\\\n");
def raw(x): "```{=openxml}\n\(x)\n```\n\n";
def pagebreak: raw("<w:p><w:r><w:br w:type=\"page\"/></w:r></w:p>");
def pgsz: "<w:pgSz w:w=\"12240\" w:h=\"15840\"/><w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/>";
def section_end(footer; fmt):
  raw("<w:p><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"20\" w:lineRule=\"exact\"/><w:sectPr>"
      + (if footer then "<w:footerReference w:type=\"default\" r:id=\"rIdBapFooter\"/>" else "" end)
      + pgsz
      + (if fmt then "<w:pgNumType w:fmt=\"\(fmt)\" w:start=\"1\"/>" else "" end)
      + "</w:sectPr></w:pPr></w:p>");
def lines(t): t | split("\n") | map(select(test("\\S"))) | map(sub("^\\s*[-*]\\s+"; ""));
def formsig: div("SigGap"; nb) + div("Signature"; hard(["/s/ \(.signature.signer)", "Attorney for \(.signature."for" // "")"] + (if has("date") then ["Dated: \(.date)"] else [] end)));

def cover: . as $root
  | div("CoverCenter"; "**BAP No. \(.case_number)**")
  + gap + rule("DoubleRule") + gap
  + div("CoverCenter"; "**UNITED STATES BANKRUPTCY APPELLATE PANEL FOR THE EIGHTH CIRCUIT**")
  + gap + rule("ShortRule") + gap
  + ( (.caption | length) as $n | .caption | to_entries | map(
        ( .value.names | map(div("CoverCenter"; .)) | join("") )
        + div("CoverIndent"; .value.designation)
        + (if .key < ($n - 1) then gap + div("CoverCenter"; "v\\.") + gap else "" end) ) | join("") )
  + gap + rule("ShortRule") + gap
  + div("CoverCenter"; .proceeding)
  + (if (has("district_court_case") or has("judge")) then
       div("CoverCenter"; (if has("district_court_case") then "Underlying case: \(.district_court_case)" else "" end)
         + (if has("district_court_case") and has("judge") then "; " else "" end)
         + (if has("judge") then .judge else "" end)) else "" end)
  + gap + rule("ShortRule") + gap
  + div("CoverCenter"; "**\(.brief_title | ascii_upcase)**")
  + gap + rule("ShortRule") + gap
  + ( (.counsel | length) as $m | .counsel | to_entries | map(
        ( .value.names | map(div("CoverIndent"; .)) | join("") )
        + ( (.value.lines // []) + (if .key == ($m - 1) then [$root.phone, $root.email] else [] end)
            | map(div("CoverIndent"; "*\(.)*")) | join("") ) ) | join("") )
  + rule("DoubleRule")
  + section_end(false; null);

def cert_interested:
  div("FrontHeading"; "Certification of Interested Parties")
  + div("Single"; "BAP No. \(.case_number)")
  + div("Single"; "The undersigned, counsel of record for \(.signature."for" // ""), certifies that the following listed party (or parties) has (have) an interest in the outcome of this appeal. These representations are made to enable the judges of the panel to evaluate possible disqualification or recusal.")
  + (lines(.interested_parties) | map(div("BulletItem"; .)) | join(""))
  + formsig
  + pagebreak
  + div("FrontHeading"; "Certification of Related Cases")
  + (lines(.related_cases) | map(div("Indented"; .)) | join(""))
  + formsig;

def front:
  (if has("disclosure") then
     div("FrontHeading"; "Disclosure Statement")
     + (lines(.disclosure) | map(div("Single"; .)) | join(""))
     + pagebreak
   else "" end)
  + cert_interested
  + pagebreak
  + "::: {custom-style=\"TOCPlaceholder\"}\n@@TOC@@\n:::\n\n"
  + pagebreak
  + "::: {custom-style=\"TOAPlaceholder\"}\n@@TOA@@\n:::\n\n";

def back($words):
  div("SigGap"; nb)
  + div("Signature"; "Respectfully submitted,")
  + div("SigGap"; nb)
  + div("Signature"; hard(["/s/ \(.signature.signer)", "\(.signature.signer | ascii_upcase)"] + (.signature.lines // []) | map("\(.)")))
  + (if has("date") then div("Single"; "\(.date)") else "" end)
  + pagebreak
  + div("FrontHeading"; "Certificate of Compliance")
  + div("Single"; "1\\. This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g):")
  + div("CertBox"; "\\[X\\] this brief contains \($words) words.")
  + div("Single"; "2\\. This brief complies with the typeface requirements of Fed. R. Bankr. P. 8015(a)(5) and the type-style requirements of Fed. R. Bankr. P. 8015(a)(6) because:")
  + div("CertBox"; "\\[X\\] this brief has been prepared in a proportionally spaced typeface using \(.word_processor) in 14-point \(.typeface) roman type.")
  + div("Signature"; hard(["/s/ \(.signature.signer)", "Attorney for \(.signature."for" // "")"] + (if has("date") then ["Dated: \(.date)"] else [] end)))
  + (if ((.service.certificate // false) or ((.service.unregistered // []) | length > 0)) then
       pagebreak
       + div("FrontHeading"; "Certificate of Service")
       + div("Single"; "I hereby certify that on \(.date // "\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_"), I electronically filed the foregoing with the Clerk of the United States Bankruptcy Appellate Panel for the Eighth Circuit by using the CM/ECF system, which will send notification of such filing to all counsel of record.")
       + (if ((.service.unregistered // []) | length > 0) then
            div("Single"; "I further certify that on the same date I served one paper copy of the foregoing by mail on the following persons who are not registered for electronic filing (L.R. BAP 8th Cir. 8014A(c)):")
            + (.service.unregistered | map(div("Indented"; "\(.name), \(.address)")) | join(""))
          else "" end)
       + div("Signature"; hard(["/s/ \(.signature.signer)", "Attorney for \(.signature."for" // "")"] + (if has("date") then ["Dated: \(.date)"] else [] end)))
     else "" end);

{ cover: cover, front: (front + section_end(true; "lowerRoman")), back: back($words) }
