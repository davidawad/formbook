-- D. Mass. memorandum supporting a motion, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- on reference.docx. Mirrors typst/mad-motion-brief.typ. Content-agnostic: every case word comes from the
-- sample's frontmatter or body; the court name lines, the certificate sentence and the headings are the court's
-- form text. Body paragraphs are unnumbered (first-line indent, from the BodyText style); footnotes are native.
-- The caption is a two-cell table (raw OOXML, so the rule sits on one cell only; child order kept valid).

local function copy(list)
  local out = {}
  for _, x in ipairs(list) do out[#out + 1] = x end
  return out
end

-- a metadata value (MetaInlines, or a plain string) as a list of inlines
local function inls(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaInlines" then return copy(v) end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function cat(...)
  local out = {}
  for _, l in ipairs({ ... }) do
    for _, x in ipairs(l) do out[#out + 1] = x end
  end
  return out
end

local function str(s) return { pandoc.Str(s) } end

-- a paragraph in a named paragraph style (the style name, as in the reference)
local function styled(name, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- an empty paragraph in a spacing style (v(...) in the typst form); raw, because pandoc drops empty paragraphs
local function gap(style_id)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style_id .. '"/></w:pPr></w:p>')
end

-- ---------------------------------------------------------------------------
-- Caption table (raw OOXML: pandoc cannot draw a rule on one cell only)
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inline content as runs; markup kept: strong, emphasis, quotes
local function runs(list, bold)
  local out = {}
  local function emit(text, b, i)
    local rpr = (b and "<w:b/><w:bCs/>" or "") .. (i and "<w:i/>" or "")
    out[#out + 1] = "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
      .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  local function walk(l, b, i)
    for _, el in ipairs(l) do
      local t = el.t
      if t == "Str" then
        emit(el.text, b, i)
      elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
        emit(" ", b, i)
      elseif t == "Strong" then
        walk(el.content, true, i)
      elseif t == "Emph" then
        walk(el.content, b, true)
      elseif t == "Quoted" then
        local dq = el.quotetype == "DoubleQuote"
        emit(dq and "\u{201C}" or "\u{2018}", b, i)
        walk(el.content, b, i)
        emit(dq and "\u{201D}" or "\u{2019}", b, i)
      else
        emit(pandoc.utils.stringify(el), b, i)
      end
    end
  end
  walk(list, bold, false)
  return table.concat(out)
end

-- a cell paragraph in a style (styleId, as in the reference)
local function cellp(style_id, list, bold)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style_id .. '"/></w:pPr>' .. runs(list or {}, bold) .. "</w:p>"
end

local function caption_xml(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = cellp("SingleLine", {})
      left[#left + 1] = cellp("CaptionVs", str("v."))
      left[#left + 1] = cellp("SingleLine", {})
    end
    for _, n in ipairs(p.names) do left[#left + 1] = cellp("SingleLine", inls(n)) end
    left[#left + 1] = cellp("SingleLine", {})
    left[#left + 1] = cellp("CaptionDesignation", inls(p.designation))
  end
  local right = {
    cellp("SingleLine", cat(str("Civil Action No. "), inls(meta.case_number))),
  }
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="4320"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa"/>' .. rule
    .. '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/><w:tcMar><w:left w:w="504" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

-- ---------------------------------------------------------------------------
-- Entry
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- court title (MAD-CAP-001), the caption, then the title of the memorandum
  add(styled("Court Title", str("IN THE UNITED STATES DISTRICT COURT")))
  add(styled("Court Title", str("FOR THE DISTRICT OF MASSACHUSETTS")))
  add(gap("GapDouble"))
  add(pandoc.RawBlock("openxml", caption_xml(meta)))
  add(gap("GapDouble"))
  add(styled("Centered Single", { pandoc.Strong(str(pandoc.utils.stringify(meta.title):upper())) }))
  add(gap("GapBody"))

  -- body: unnumbered paragraphs, headings, quotations and footnotes as the markdown gives them
  for _, b in ipairs(doc.blocks) do add(b) end

  -- signature (MAD-SIG-001: the board of bar overseers number under each attorney's name)
  local sig = meta.signature
  add(gap("GapBody"))
  add(styled("Dated Line", cat(str("DATED: "), inls(meta.date))))
  add(gap("GapBody"))
  for _, l in ipairs(sig.lead) do add(styled("Sig Indent", inls(l))) end
  add(gap("GapSig"))
  add(styled("Sig Indent", cat(str("By: /s/ "), inls(sig.signer))))
  for _, a in ipairs(sig.attorneys) do
    add(gap("GapSig"))
    add(styled("Sig Indent", cat(inls(a.name), str(" (BBO# "), inls(a.bbo), str(")"))))
    add(styled("Sig Indent", inls(a.email)))
  end
  add(gap("GapSig"))
  for _, l in ipairs(sig.firm) do add(styled("Sig Indent", inls(l))) end

  -- certificate of service (MAD-CERT-001; Fed. R. Civ. P. 5(d)(1)(B)): when the sample has one
  if meta.service then
    local svc = meta.service
    add(gap("GapBody"))
    add(styled("Centered Single", { pandoc.Strong(str("CERTIFICATE OF SERVICE")) }))
    add(gap("GapBody"))
    add(pandoc.Para(cat(
      str("I hereby certify that on "), inls(svc.date),
      str(", a true copy of the foregoing document was electronically filed through the Court\u{2019}s ECF system on all counsel of record:"))))
    add(gap("GapBody"))
    for ci, c in ipairs(svc.counsel) do
      if ci > 1 then add(gap("GapSig")) end
      for _, l in ipairs(c) do add(styled("Single Line", inls(l))) end
    end
    add(gap("GapBody"))
    add(styled("Single Line", cat(str("/s/ "), inls(sig.signer))))
    add(styled("Single Line", inls(sig.signer)))
  end

  -- certificate of consultation (MAD-CERT-002; L.R. 7.1(a)(2)): when the sample has one
  if meta.consultation then
    add(gap("GapBody"))
    add(styled("Centered Single", { pandoc.Strong(str("CERTIFICATE OF CONSULTATION")) }))
    add(gap("GapBody"))
    add(pandoc.Para(inls(meta.consultation)))
  end

  -- title and date are set in the caption and the signature, not as the document title (pandoc would write them first)
  meta.title = nil
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
