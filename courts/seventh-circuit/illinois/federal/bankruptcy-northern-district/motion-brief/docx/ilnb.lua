-- ilnb motion brief (memorandum of law in support of a motion), DOCX engine (docs/DOCX.md). The markdown
-- contract -> a Word document on docx/reference.docx (built by build-reference.sh, which defines the styles).
-- Mirrors typst/ilnb-motion-brief.typ: the court heading, the caption (a two-column table ruled on the right
-- and bottom), the title, the memorandum body with its heading labels, and the signature block. Every
-- case-specific word comes from the YAML frontmatter (schema: ../README.md).
-- Known limits (see the PR and README.md "Engines"): the caption table's borders, the signature layout
-- (Dated line stacked above the signature column) and the 15-page limit (ILNB-LIMIT-001, asserted only by the
-- typst build) are not verified here; the page count needs the docx.pdf, which needs soffice.

local TAB = '<w:r><w:tab/></w:r>'
local TEXT_W = 9360                    -- 6.5 in: 8.5 in page less 1 in margins (twips)
local LEFT_W, GAP_W = 4896, 432        -- party column 3.4 in, gutter 0.3 in (typst caption-left, column-gutter)
local RIGHT_W = TEXT_W - LEFT_W - GAP_W
local RULE = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local PAD = '<w:tcMar><w:right w:w="216" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/></w:tcMar>'

-- a required metadata field, or a stop with its name
local function need(meta, key)
  if meta[key] == nil then error("ilnb: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- a metadata value (markdown) as a list of inlines
local function inl(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function plain(v) return pandoc.utils.stringify(inl(v)) end

-- a paragraph in a named custom style (the names are defined in build-reference.sh)
local function sty(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines or {}) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- ---------------------------------------------------------------------------
-- Raw WordprocessingML for the caption table (inline markdown -> runs)
-- ---------------------------------------------------------------------------

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, f)
  local pr = ""
  if f.b then pr = pr .. "<w:b/><w:bCs/>" end
  if f.i then pr = pr .. "<w:i/><w:iCs/>" end
  if pr ~= "" then pr = "<w:rPr>" .. pr .. "</w:rPr>" end
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

local function runs(list, f, out)
  out = out or {}
  f = f or {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", f)
    elseif t == "Emph" then runs(el.content, { b = f.b, i = true }, out)
    elseif t == "Strong" then runs(el.content, { b = true, i = f.i }, out)
    elseif t == "Span" or t == "Link" then runs(el.content, f, out)
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], f)
      runs(el.content, f, out)
      out[#out + 1] = run(q[2], f)
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
  return out
end

local function p_xml(style, list)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. table.concat(runs(list or {}), "") .. "</w:p>"
end

local function cell(w, paras, borders, margins)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (borders or "") .. (margins or "")
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

-- The caption: party column (debtor, then the adversary parties) ruled on the right and bottom; case
-- column (chapter, case number, adversary number, judge). Form 416 wording (ILNB-CAP-001..003).
local function caption_table(meta)
  local cap = need(meta, "caption")
  local left, right = {}, {}
  local function party(pt)
    for _, n in ipairs(pt.names) do left[#left + 1] = p_xml("Single", inl(n)) end
    left[#left + 1] = p_xml("CaptionDesignation", inl(pt.designation))
  end
  left[#left + 1] = p_xml("Single", { pandoc.Str("In re:") })
  party(cap.in_re)
  if cap.adversary then
    left[#left + 1] = p_xml("CaptionEntry", {})
    for k, pt in ipairs(cap.adversary.parties) do
      if k > 1 then
        left[#left + 1] = p_xml("CaptionEntry", {})
        left[#left + 1] = p_xml("Single", { pandoc.Str("v.") })
        left[#left + 1] = p_xml("CaptionEntry", {})
      end
      party(pt)
    end
  end
  if cap.chapter then right[#right + 1] = p_xml("CaptionEntry", inl(cap.chapter)) end
  local no = { pandoc.Str("Case No. ") }
  for _, x in ipairs(inl(cap.case_number)) do no[#no + 1] = x end
  right[#right + 1] = p_xml("CaptionEntry", no)
  if cap.adversary then
    local adv = { pandoc.Str("Adv. Pro. No. ") }
    for _, x in ipairs(inl(cap.adversary.number)) do adv[#adv + 1] = x end
    right[#right + 1] = p_xml("CaptionEntry", adv)
  end
  if cap.judge then right[#right + 1] = p_xml("CaptionEntry", inl(cap.judge)) end
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. LEFT_W .. '"/><w:gridCol w:w="' .. GAP_W .. '"/><w:gridCol w:w="' .. RIGHT_W .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(LEFT_W, left, RULE, PAD)
    .. cell(GAP_W, { p_xml("Single", {}) })
    .. cell(RIGHT_W, right)
    .. "</w:tr></w:tbl>"
  return pandoc.RawBlock("openxml", tbl)
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

-- Heading labels as the typst template draws them: level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a.".
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local function label(level, k)
  if level == 1 then return (ROMAN[k] or tostring(k)) .. "."
  elseif level == 2 then return string.char(64 + k) .. "."
  elseif level == 3 then return tostring(k) .. "."
  elseif level == 4 then return string.char(96 + k) .. "."
  end
  return ""
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would print the title metadata as a Title paragraph above the cover; the cover prints it instead
  local title = need(meta, "title")
  meta.title = nil
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover (ILNB-CAP-001..003): court name, division, caption, title
  add(sty("Court Title", { pandoc.Str("IN THE UNITED STATES BANKRUPTCY COURT") }))
  add(sty("Court Title", { pandoc.Str("FOR THE NORTHERN DISTRICT OF ILLINOIS") }))
  add(sty("Blank", {}))
  add(sty("Court Title", { pandoc.Str(plain(need(meta, "division")):upper()) }))
  add(sty("Blank", {}))
  add(caption_table(meta))
  add(sty("Blank", {}))
  add(sty("Cover Title", inl(title)))
  add(sty("Blank", {}))

  -- the memorandum: the markdown body as written; headings take their labels here (ILNB-HEAD-001)
  local counts = { 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level >= 1 and b.level <= 4 then
      for l = b.level + 1, 4 do counts[l] = 0 end
      counts[b.level] = counts[b.level] + 1
      local content = pandoc.List({ pandoc.Str(label(b.level, counts[b.level])), pandoc.RawInline("openxml", TAB) })
      content:extend(b.content)
      add(pandoc.Header(b.level, content))
    else
      add(b)
    end
  end

  -- signature block (ILNB-SIG-001..002): the dated line, then the party, the signing attorney and counsel
  local sig = need(meta, "signature")
  add(sty("Blank", {}))
  local dated = { pandoc.Str("Dated: ") }
  for _, x in ipairs(inl(sig.date)) do dated[#dated + 1] = x end
  add(sty("Single", dated))
  add(sty("Caption Entry", {}))
  add(sty("Signature Column", { pandoc.Str("Respectfully submitted,") }))
  add(sty("Caption Entry", {}))
  add(sty("Signature Column", inl(sig.party)))
  add(sty("Caption Entry", {}))
  local s = { pandoc.Str("/s/ ") }
  for _, x in ipairs(inl(sig.signer)) do s[#s + 1] = x end
  add(sty("Signature Column", s))
  add(sty("Signature Column", inl(sig.role)))
  for k, g in ipairs(sig.counsel or {}) do
    if k > 1 then
      add(sty("Caption Entry", {}))
      add(sty("Signature Column", { pandoc.Str("- and -") }))
    end
    add(sty("Caption Entry", {}))
    for _, nm in ipairs(g.names or {}) do add(sty("Signature Column", inl(nm))) end
    for _, l in ipairs(g.lines or {}) do add(sty("Signature Column", inl(l))) end
  end

  doc.blocks = out
  return doc
end
