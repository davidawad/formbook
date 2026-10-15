-- D. Mass. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/mad-complaint.typ. Content-agnostic: every case word comes from the sample's frontmatter or
-- body; the court name lines are the court's own form text. Numbered paragraphs use Word numbering (the
-- "Allegation" style, numId 9001); prayer items use the "Prayer Item" style (numId 9002). Styles are defined
-- in reference.docx (build-reference.sh). The caption is a two-cell table, with OOXML child order kept valid.

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
    cellp("GapBody", {}),
    cellp("SingleLine", inls(meta.title), true),
  }
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="4680"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/>' .. rule
    .. '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/><w:tcMar><w:left w:w="504" w:type="dxa"/></w:tcMar></w:tcPr>'
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

  -- court title (MAD-CAP-001), then the caption
  add(styled("Court Title", str("UNITED STATES DISTRICT COURT")))
  add(styled("Court Title", str("FOR THE DISTRICT OF MASSACHUSETTS")))
  add(gap("GapDouble"))
  add(pandoc.RawBlock("openxml", caption_xml(meta)))
  add(gap("GapDouble"))

  if meta.lead_in then add(pandoc.Para(inls(meta.lead_in))) end

  -- the body: numbered paragraphs (Fed. R. Civ. P. 10(b)); headings, quotations, the prayer and any
  -- WHEREFORE paragraph are not numbered
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local s = pandoc.utils.stringify(b)
      if s:match("^WHEREFORE") then
        add(b)
      else
        add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" })))
      end
    elseif b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        local first = true
        for _, blk in ipairs(item) do
          if first and (blk.t == "Plain" or blk.t == "Para") then
            add(pandoc.Div({ pandoc.Para(blk.content) }, pandoc.Attr("", {}, { ["custom-style"] = "Prayer Item" })))
            first = false
          else
            add(blk)
          end
        end
      end
    else
      add(b)
    end
  end

  if meta.jury_demand then
    add(styled("Jury Demand", inls(meta.jury_demand)))
  end

  -- signature block (MAD-SIG-001: the board of bar overseers number under each attorney's name)
  local sig = meta.signature
  add(gap("GapSig"))
  for _, l in ipairs(sig.party) do add(styled("Sig Indent", inls(l))) end
  add(gap("GapSig"))
  add(styled("Sig Indent", cat(str("/s/ "), inls(sig.signer))))
  for _, a in ipairs(sig.attorneys) do
    add(gap("GapSig"))
    add(styled("Sig Indent", cat(inls(a.name), str(" (BBO# "), inls(a.bbo), str(")"))))
    add(styled("Sig Indent", inls(a.email)))
  end
  add(gap("GapSig"))
  for _, l in ipairs(sig.firm) do add(styled("Sig Indent", inls(l))) end
  add(gap("GapBody"))
  add(styled("Single Line", cat(str("Dated: "), inls(meta.date))))

  -- title and date are set in the caption and the signature, not as the document title (pandoc would write them first)
  meta.title = nil
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
