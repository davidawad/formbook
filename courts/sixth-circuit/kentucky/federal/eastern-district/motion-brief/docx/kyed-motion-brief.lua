-- E.D. Ky. memorandum in support of a motion, DOCX engine (docs/DOCX.md). The same markdown contract as the
-- typst template (typst/kyed-motion-brief.typ; contract in ../README.md). Styles come from docx/reference.docx;
-- this filter builds the caption, the keep-together of the conclusion with the signature block, the signature
-- line with its date, and the certificate of service (a new page). No case-specific text and no forced line breaks.
--
-- Word-native parts: the footnotes are pandoc's native footnotes (style "footnote text", 12 pt, single); the
-- headings keep with the next paragraph (keepNext in the heading styles). No table of contents or table of
-- authorities is produced (see ../README.md).

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function px(style, text, ppr)
  local run = ""
  if text ~= "" then run = '<w:r><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>' end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. run .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- KYED-FIRST-001, KYED-FIRST-002: court title, case number label, caption (party block), title of the paper
local function caption(m)
  local out = {}
  for _, l in ipairs(m.court) do out[#out + 1] = raw(px("CourtTitle", plain(l):upper())) end
  local label = m.case_label and plain(m.case_label) or "Civil Action No."
  out[#out + 1] = raw(px("Centered", label .. " " .. plain(m.case_number), '<w:spacing w:before="480"/>'))
  out[#out + 1] = raw(px("CaptionRule", ""))
  for i, p in ipairs(m.caption) do
    if i > 1 then out[#out + 1] = raw(px("PartyV", "v.")) end
    for _, n in ipairs(p.names) do out[#out + 1] = raw(px("Single", plain(n))) end
    local d = plain(p.designation)
    if d ~= "" then out[#out + 1] = raw(px("PartyDesig", d)) end
  end
  out[#out + 1] = raw(px("CaptionRule", ""))
  out[#out + 1] = raw(px("CaptionTitle", plain(m.title):upper()))
  return out
end

-- KYED-SIG-001: "Dated:" at the left margin, "Respectfully submitted," at the right half, single spaced.
-- The tab stop at 3.4 in (the right column of the typst grid) keeps the two on one line.
local function signature(m)
  local sig = m.signature
  local out = {}
  out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="SigDated"/></w:pPr><w:r><w:t xml:space="preserve">Dated: '
    .. esc(plain(m.date)) .. '</w:t></w:r><w:r><w:tab/></w:r><w:r><w:t>Respectfully submitted,</w:t></w:r></w:p>')
  local pre = sig.preamble or {}
  for i, l in ipairs(pre) do out[#out + 1] = raw(px(i == 1 and "SigGap" or "SigKeep", plain(l))) end
  out[#out + 1] = raw(px("SigGap", plain(sig.sign_line)))
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do out[#out + 1] = raw(px(i == #lines and "SigLast" or "SigKeep", plain(l))) end
  return out
end

-- KYED-SIG-002: optional certificate of service, on a new page; single-spaced service blocks
local function certificate(m)
  local c = m.certificate
  if c == nil then return {} end
  local out = {}
  out[#out + 1] = raw(px("CertHeading", "CERTIFICATE OF SERVICE"))
  out[#out + 1] = pandoc.Div({ pandoc.Para(c.text) }, pandoc.Attr("", {}, { ["custom-style"] = "CertText" }))
  for _, s in ipairs(c.services) do
    local n = #s
    for i, l in ipairs(s) do
      out[#out + 1] = raw(px(i == n and "ServiceLast" or "ServiceKeep", plain(l)))
    end
  end
  out[#out + 1] = raw(px("SigTop", plain(c.sign_line)))
  out[#out + 1] = raw(px("SigLast", plain(c.designation)))
  return out
end

function Pandoc(doc)
  local m = doc.meta
  local out = caption(m)
  -- the conclusion and the signature block are kept together (KYED-SIG-001): every conclusion paragraph keeps with
  -- the next, and the signature lines keep with each other
  local conc = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):upper() == "CONCLUSION" then conc = i break end
  end
  for i, b in ipairs(doc.blocks) do
    if conc and i > conc and b.t == "Para" then
      out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" }))
    else
      out[#out + 1] = b
    end
  end
  for _, b in ipairs(signature(m)) do out[#out + 1] = b end
  for _, b in ipairs(certificate(m)) do out[#out + 1] = b end
  doc.blocks = out
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end
