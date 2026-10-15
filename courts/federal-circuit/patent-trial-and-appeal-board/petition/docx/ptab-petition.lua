-- docx engine, PTAB petition for inter partes review (37 C.F.R. 42.100 et seq.). The typst template (../typst/ptab-petition.typ)
-- is the reference for the form. This filter writes what pandoc's markdown cannot express as WordprocessingML: the
-- cover, the contents, the signature block and the two certificates. The body is pandoc's, styled by reference.docx.
-- Everything here comes from the frontmatter of the sample (schema: ../README.md, "Markdown contract"); no text is
-- specific to a case. render.sh adds the running header and the footers, and sets the body's section.
--
-- Sections: cover (no number), contents (lower-case roman), body and certificates (arabic from 1).

local LIMIT = 14000 -- PTAB-PET-LEN-001: 37 C.F.R. 42.24(a)(1)(i), the petition limit (14,000 words for an IPR)
local BOLD = "<w:b/><w:bCs/>"
local FIELD_BEGIN = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
local FIELD_END = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
-- page: letter, one inch on all sides (PTAB-PET-FORM-001, -004); header and footer 0.5 in from the edge
local PAGE = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(s, rpr)
  return "<w:r>" .. (rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or "") .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

-- one paragraph; o.sect is a sectPr that ends a section (it goes last in pPr)
local function para(o)
  local ppr = ""
  if o.style then ppr = ppr .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.pbb then ppr = ppr .. "<w:pageBreakBefore/>" end
  if o.before then ppr = ppr .. '<w:spacing w:before="' .. o.before .. '"/>' end
  if o.sect then ppr = ppr .. o.sect end
  return "<w:p>" .. (ppr ~= "" and ("<w:pPr>" .. ppr .. "</w:pPr>") or "") .. (o.runs or "") .. "</w:p>"
end

local function sect(extra)
  return "<w:sectPr>" .. (extra or "") .. PAGE .. "</w:sectPr>"
end

-- 10543 -> "10,543"
local function thousands(n)
  local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (s:gsub("^,", ""))
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do
      s = s .. v[2]
      n = n - v[1]
    end
  end
  return s
end

local function cover(m)
  local out = {}
  local function line(s, o)
    o = o or {}
    local style = o.right and "CoverRight" or "CoverCenter"
    out[#out + 1] = para({ style = style, before = o.before, sect = o.sect, runs = run(s, o.bold and BOLD or nil) })
  end
  line("UNITED STATES PATENT AND TRADEMARK OFFICE")
  line("BEFORE THE PATENT TRIAL AND APPEAL BOARD", { before = 240 })
  line(txt(m.petitioner.name), { bold = true, before = 680 })
  line(txt(m.petitioner.role), { right = true })
  line("v.", { before = 340 })
  line(txt(m["patent-owner"].name), { bold = true, before = 340 })
  line(txt(m["patent-owner"].role), { right = true })
  line(txt(m["patent-number"]), { before = 680 })
  line(txt(m["patent-title"]), { before = 240 })
  line(txt(m["case-number"]), { before = 170 })
  -- the last cover paragraph ends section 1: no footer, no page number
  line(txt(m.title), { bold = true, before = 680, sect = sect() })
  return out
end

-- Contents: one TOC field whose cached result lists the headings (levels 1 and 2, typst toc-depth 2). Page numbers
-- are not in the cached result: LibreOffice cannot compute them here, and Word fills them in on open (updateFields).
local function contents(headings)
  local out = { para({ style = "CenteredHeading", runs = run("TABLE OF CONTENTS") }) }
  local entries = {}
  local c1, c2 = 0, 0
  for _, h in ipairs(headings) do
    local label
    if h.level == 1 then
      c1 = c1 + 1
      c2 = 0
      label = roman(c1):upper() .. "."
    else
      c2 = c2 + 1
      label = string.char(64 + c2) .. "."
    end
    entries[#entries + 1] = { style = h.level == 1 and "TOC1" or "TOC2", text = label .. " " .. h.text }
  end
  if #entries == 0 then entries[1] = { style = "TOC1", text = "" } end
  for i, e in ipairs(entries) do
    local runs = (i == 1 and FIELD_BEGIN or "") .. (e.text ~= "" and run(e.text) or "") .. (i == #entries and FIELD_END or "")
    local o = { style = e.style, runs = runs }
    -- the last contents paragraph ends section 2 (roman numbers, the contents page)
    if i == #entries then
      o.sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooterRoman"/>' .. PAGE .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
    end
    out[#out + 1] = para(o)
  end
  return out
end

local function signature_block(m)
  local sig = m.signature
  local out = {}
  if m.date then out[#out + 1] = para({ style = "SingleLine", before = 240, runs = run("Dated: " .. txt(m.date)) }) end
  out[#out + 1] = para({ style = "SignatureBlock", before = 340, runs = run("/s/ " .. txt(sig.signer)) })
  out[#out + 1] = para({ style = "SignatureBlock", runs = run(txt(sig["signer-name"]) .. " (Reg. No. " .. txt(sig["reg-no"]) .. ")") })
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = para({ style = "SignatureBlock", runs = run(txt(l)) })
  end
  return out
end

local function certificate_of_word_count(m)
  local words = tonumber(txt(m["word-count"]))
  if words == nil then error("ptab-petition: word-count must be a number") end
  if words > LIMIT then
    error("ptab-petition: word count " .. words .. " exceeds the " .. LIMIT .. "-word limit (42.24(a)(1)(i))")
  end
  local out = { para({ style = "CenteredHeading", pbb = true, runs = run("CERTIFICATION UNDER 37 C.F.R. § 42.24") }) }
  out[#out + 1] = para({
    style = "CertificateText",
    runs = run("Under the provisions of 37 C.F.R. § 42.24, the undersigned hereby certifies that the word count for the foregoing Petition for inter partes review (excluding the table of contents, table of authorities, mandatory notices, certificate of service or word count, and appendix of exhibits or claim listing) totals " .. thousands(words) .. " words, which is within the word limit allowed under 37 C.F.R. § 42.24(a)(1)(i)."),
  })
  for _, p in ipairs(signature_block(m)) do out[#out + 1] = p end
  return out
end

local function certificate_of_service(m)
  local svc = m.service
  local out = { para({ style = "CenteredHeading", pbb = true, runs = run("CERTIFICATE OF SERVICE") }) }
  out[#out + 1] = para({
    style = "CertificateText",
    runs = run("Pursuant to 37 C.F.R. §§ 42.6(e) and 42.105(a), the undersigned hereby certifies service on the Patent Owner of a copy of this Petition and its respective exhibits, by " .. txt(svc.manner) .. ", on the following at the addresses shown:"),
  })
  for _, r in ipairs(svc.recipients or {}) do
    out[#out + 1] = para({ style = "ServiceRecipient", before = 240, runs = run(txt(r.name)) })
    for _, l in ipairs(r.lines or {}) do
      out[#out + 1] = para({ style = "ServiceRecipient", before = 0, runs = run(txt(l)) })
    end
  end
  for _, p in ipairs(signature_block(m)) do out[#out + 1] = p end
  return out
end

-- the table of contents reads the headings of the body (levels 1 and 2)
local function headings_of(blocks)
  local hs = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= 2 then
      hs[#hs + 1] = { level = b.level, text = txt(b.content) }
    end
  end
  return hs
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function raw(list)
    out[#out + 1] = pandoc.RawBlock("openxml", table.concat(list, ""))
  end

  -- cover: section 1
  raw(cover(m))

  -- contents: section 2
  raw(contents(headings_of(doc.blocks)))

  -- body: section 3 (render.sh gives it the arabic numbering and the running header)
  local body = {}
  for i, b in ipairs(doc.blocks) do body[i] = b end
  -- the conclusion stays on the page of the signature block (typst: block(breakable: false))
  local last = body[#body]
  if last and (last.t == "Para" or last.t == "Plain") then
    body[#body] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "Body Keep Next" }))
  end
  for _, b in ipairs(body) do out[#out + 1] = b end
  raw(signature_block(m))

  -- certificates: same section as the body
  raw(certificate_of_word_count(m))
  raw(certificate_of_service(m))

  -- pandoc would print the title and the date as a title block ahead of the cover; the cover carries them
  doc.meta.title = nil
  doc.meta.date = nil
  return pandoc.Pandoc(out, doc.meta)
end
