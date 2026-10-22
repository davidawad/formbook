-- alsd-complaint.lua (docx engine): the S.D. Ala. complaint as Word paragraphs and a caption table, so that it reads
-- and breaks as typst/alsd-complaint.typ does:
--   * the cover: court title, caption table (party column, a column of ")" marks, the civil action number on the
--     middle row; one row per line), title of the paper, and the jury line when jury_demand is set;
--   * the allegations: each prose paragraph is numbered 1, 2 ... (Civ. L.R. 10(a)); headings, lettered lists, block
--     quotations and unnumbered paragraphs (a bracketed record cite, a WHEREFORE lead-in) are not;
--   * the signature block at 3.0 in, kept together.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent, item-indent, quote-indent: 0.5 in
local LABEL = 576                         -- typst item-label, 0.4 in
local TEXTW = 9360                        -- 6.5 in
local PARTY_W, PAREN_W = 4608, 432        -- typst caption-party-w 3.2 in, caption-paren-w 0.3 in
local SIG_LEFT = 4320                     -- typst signature-indent 3.0 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function cell(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  for _, l in ipairs({ "IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF ALABAMA",
    pandoc.text.upper(plain(meta.division)) }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true })
  end
  local rows = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    for _, name in ipairs(party.names) do rows[#rows + 1] = xe.inl(name) end
    rows[#rows + 1] = xe.inl(party.designation)
    if k < #parties then
      rows[#rows + 1] = ""
      rows[#rows + 1] = xe.runs("v.")
      rows[#rows + 1] = ""
    end
  end
  local mid = math.floor(#rows / 2) + 1
  local trs = {}
  for i, r in ipairs(rows) do
    -- the caption stands a double line below the court title (typst: the caption block's above)
    local before = i == 1 and BODY or 0
    local right = i == mid and xe.runs("Civil Action No. ") .. xe.inl(meta.case_number) or ""
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(PARTY_W, p(r, { before = before })) ..
      cell(PAREN_W, p(xe.runs(")"), { before = before })) ..
      cell(TEXTW - PARTY_W - PAREN_W, p(right, { before = before })) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. PAREN_W .. '"/>' ..
    '<w:gridCol w:w="' .. (TEXTW - PARTY_W - PAREN_W) .. '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = BODY, jc = "center", keep = true })
  if meta.jury_demand == true then
    out[#out + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = SINGLE, jc = "center", keep = true })
  end
end

-- ---------------------------------------------------------------------------
-- Signature block (Gen. L.R. 5(a)(3)): one block that never breaks across a page
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local lines = { { body = xe.runs("Dated: ") .. xe.inl(meta.date), before = BODY },
    { body = xe.runs("Respectfully submitted,"), before = BODY, left = SIG_LEFT } }
  for k, block in ipairs(meta.signature.blocks) do
    for j, l in ipairs(block) do
      lines[#lines + 1] = { body = xe.inl(l), left = SIG_LEFT,
        before = j == 1 and (k == 1 and BODY or SINGLE) or 0 }
    end
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch: level 1 centered capitals, level 2 centered bold, level 3 bold italic; kept with the
-- text after them.
local function heading(el)
  local content, o = el.content, { b = true }
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  elseif el.level >= 3 then
    o.i = true
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, o))
end

-- Not numbered: a bracketed record cite or a WHEREFORE clause (typst: a chunk starting "[" or "WHEREFORE").
local function unnumbered(b)
  local s = pandoc.utils.stringify(b.content)
  return s:sub(1, 1) == "[" or s:sub(1, 9) == "WHEREFORE"
end

-- The marker of item n as typed ("(3)", "a.", "4)").
local function marker(attrs, n)
  local style, delim = tostring(attrs.style), tostring(attrs.delimiter)
  local m = tostring(n)
  if style == "LowerAlpha" then m = string.char(96 + n) elseif style == "UpperAlpha" then m = string.char(64 + n) end
  if delim == "OneParen" then return m .. ")" end
  if delim == "TwoParens" then return "(" .. m .. ")" end
  return m .. "."
end

-- Paragraphs of a quotation: a list item becomes a paragraph that starts with its marker.
local function flatten(list)
  local out = {}
  for _, b in ipairs(list) do
    if b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for k, ib in ipairs(flatten(item)) do
          local c = pandoc.Inlines(ib.content)
          if k == 1 then c:insert(1, pandoc.Space()); c:insert(1, pandoc.Str(marker(b.listAttributes, b.listAttributes.start + i - 1))) end
          out[#out + 1] = pandoc.Para(c)
        end
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = b
    else
      error("alsd-complaint.lua: unsupported block in a quotation " .. b.t)
    end
  end
  return out
end

local function blocks(doc, out)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered(b) then
        out[#out + 1] = p(xe.inl(b.content), { line = BODY })
      else
        -- the number in a box of para-indent after the first-line indent (typst: box(width: para-indent))
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT,
          tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lettered (a), (b) ...: the label half an inch in, the text hanging a label box after it
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and (b.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")\t") or "\u{2022}\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = INDENT + LABEL,
            hanging = LABEL })
        end
      end
    elseif b.t == "BlockQuote" then
      -- single-spaced, indented both sides, a single line off the text above and below
      -- (pandoc reads "(3) ..." as a list item; commonmark, and so typst, keeps it as typed)
      local qs = flatten(b.content)
      for k, q in ipairs(qs) do
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT,
          before = k == 1 and SINGLE or 0, after = k == #qs and SINGLE or 0 })
      end
    else
      error("alsd-complaint.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("d/b/a": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, before = SINGLE })
  end
  blocks(doc, out)
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
