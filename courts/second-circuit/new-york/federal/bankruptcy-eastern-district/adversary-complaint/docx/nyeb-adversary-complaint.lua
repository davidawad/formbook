-- nyeb adversary complaint, DOCX engine (docs/DOCX.md). Mirrors typst/nyeb-adversary-complaint.typ:
--   the court title; the caption (a two-row table with the rules of the typst caption: the party column, a gutter,
--   the numbers column centred on the parties); the lead-in; numbered allegations (Fed. R. Civ. P. 10(b): the number
--   at 0.5 in, a tab, the text at 1 in, wrapped lines back at 1 in); lettered prayer items; the last paragraph kept
--   with the signature block. The page number, the styles and the margins come from docx/reference.xml (fb render
--   builds the reference document from it). Every case word comes from the frontmatter; the signature lines as
--   written ($FORMBOOK_META), so a line of underscores stays the signature rule it is in typst.
-- Known limit (see the README, "Engines"): the paragraph numbers and prayer letters are typed text followed by a
-- tab, not Word list numbering, as the typst template types them; they do not renumber when a paragraph is added.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                  -- typst pitch-single
local TW = 9360                     -- the text width: 6.5 in
local INDENT = 720                  -- typst para-indent
local CAP_LEFT = 5472               -- typst caption-left 3.8 in
local CAP_GUTTER = 288              -- typst caption-gutter 0.2 in
local CAP_RIGHT = TW - CAP_LEFT - CAP_GUTTER
local DESIGNATION = 1728            -- typst designation-indent 1.2 in
local RULE_SZ = 6                   -- typst caption-rule 0.75 pt (eighths of a point)
local INSET = 160                   -- typst caption-inset 8 pt
local RULE = 15                     -- LibreOffice sets each 0.75 pt rule inside the row (typst strokes take no room):
                                    -- the cell padding beside it is that much less, so a row is as tall as typst's
local TITLE_GAP = 120               -- typst title-gap 6 pt
local CAPTION_ABOVE = 480           -- typst caption-above 24 pt
local CAPTION_BELOW = 480           -- typst caption-below 24 pt
local AGAINST_GAP = 240             -- typst against-gap 12 pt
local QUOTE_SPACE = 240             -- typst quote-space 12 pt
local SIG_ABOVE = 480               -- typst signature-above 24 pt
local SIG_COL = 4680                -- typst signature-indent 3.25 in

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function read_file(path)
  if not path or path == "" then return nil end
  local f = io.open(path, "rb")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- A paragraph: o = { before, after, pitch, left, hanging, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and 0 or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- ---------------------------------------------------------------------------
-- Court title and caption (FRBP 9004(b), 7010; E.D.N.Y. LBR 9004-2(a))
-- ---------------------------------------------------------------------------

local function court_title()
  return p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" })
    .. p(xe.runs("EASTERN DISTRICT OF NEW YORK", { b = true }), { jc = "center", before = TITLE_GAP })
end

-- One side of the caption: its names, then its designation set in from the left.
local function party_lines(party)
  local out = {}
  for _, n in ipairs(items(party.names)) do out[#out + 1] = p(xe.inl(n)) end
  out[#out + 1] = p(xe.inl(party.designation), { left = DESIGNATION })
  return table.concat(out)
end

local function border(sides)
  local out = {}
  for _, s in ipairs(sides) do
    out[#out + 1] = "<w:" .. s .. ' w:val="single" w:sz="' .. RULE_SZ .. '" w:space="0" w:color="000000"/>'
  end
  return "<w:tcBorders>" .. table.concat(out) .. "</w:tcBorders>"
end

local function cell(width, sides, valign, top, bottom, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. border(sides)
    .. '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="' .. bottom
    .. '" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar><w:vAlign w:val="' .. valign .. '"/></w:tcPr>'
    .. (paras ~= "" and paras or p("")) .. "</w:tc>"
end

local function caption(m)
  local debtor = m.caption.debtor
  local left1 = p(xe.runs("In re:")) .. party_lines(debtor)
  local right1 = p(xe.runs("Case No. " .. txt(m.case_number))) .. p(xe.runs("Chapter " .. txt(m.chapter)))
  local left2 = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then
      left2[#left2 + 1] = p(xe.runs("-against-"), { jc = "center", before = AGAINST_GAP, after = AGAINST_GAP })
    end
    left2[#left2 + 1] = party_lines(party)
  end
  local right2 = p(xe.runs("Adv. Pro. No. " .. txt(m.adversary_number))) .. p("")
    .. p(xe.inl(m.title, { b = true }))
  -- row 1 has a rule above and below, row 2 a rule below; each rule is taken off the padding beside it
  local function row(sides, top, bottom, l, r)
    return "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. cell(CAP_LEFT, sides, "top", top, bottom, l)
      .. cell(CAP_GUTTER, sides, "top", top, bottom, "")
      .. cell(CAP_RIGHT, sides, "center", top, bottom, r) .. "</w:tr>"
  end
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="'
    .. CAP_RIGHT .. '"/></w:tblGrid>'
    .. row({ "top", "bottom" }, INSET - RULE, INSET - RULE, left1, right1)
    .. row({ "bottom" }, INSET, INSET - RULE, table.concat(left2), right2)
    .. "</w:tbl>"
  -- the space above the table (an empty paragraph of that height) and below it (on the paragraph after)
  return xe.para({ xe.spacing(0, 0, CAPTION_ABOVE) }, "") .. tbl
end

-- ---------------------------------------------------------------------------
-- Signature block
-- ---------------------------------------------------------------------------

-- A signature line, as written in the frontmatter: a line of underscores alone is the signature rule, typed as is
-- (pandoc would read it as a horizontal rule); anything else is inline markdown, as typst reads it.
local function sig_line(raw, parsed)
  if type(raw) == "string" and raw:match("^_+$") then return xe.runs(raw) end
  return xe.inl(parsed)
end

-- typst signature: single-spaced from SIG_COL, the date at the left of its first line (a tab), kept on one page.
local function signature(m, raw)
  local sig = m.signature
  local lines = items(sig.lines)
  local rlines = (raw and raw.signature and raw.signature.lines) or {}
  local out = {}
  for i, l in ipairs(lines) do
    local body = sig_line(rlines[i], l)
    local keep = i < #lines
    if i == 1 then
      out[#out + 1] = p(xe.runs("Dated: " .. txt(sig.date) .. "\t") .. body,
        { before = SIG_ABOVE, left = SIG_COL, hanging = SIG_COL, tab = SIG_COL, keep = keep })
    else
      out[#out + 1] = p(body, { left = SIG_COL, keep = keep })
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- A typed label ("1.", "(a)") and a tab, then the text.
local function labelled(style, label, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label .. "\t")) })
  inl:extend(content)
  return styled(style, inl)
end

local function body(blocks, keep_last)
  local out = {}
  local n = 0
  local last_keepable -- index in out of the last paragraph, and the style that keeps it with the signature
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), b.content)
      last_keepable = nil
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- the prayer: one lettered item per list item, the letter at 0.5 in and the text at 1 in
      for k, item in ipairs(b.content) do
        out[#out + 1] = labelled("Allegation", "(" .. string.char(96 + k) .. ")", pandoc.utils.blocks_to_inlines(item))
        last_keepable = #out
      end
    elseif b.t == "BlockQuote" then
      -- a quotation: single-spaced, indented on both sides
      local text = pandoc.utils.blocks_to_inlines(b.content)
      out[#out + 1] = xe.raw(p(xe.inl(text), { left = INDENT, right = INDENT, before = QUOTE_SPACE, after = QUOTE_SPACE }))
      last_keepable = nil
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        -- the prayer's lead-in is unnumbered and kept with the first item
        out[#out + 1] = styled("Body Text Keep", b.content)
        last_keepable = nil
      else
        n = n + 1
        out[#out + 1] = labelled("Allegation", n .. ".", b.content)
        last_keepable = #out
      end
    else
      error("nyeb-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  -- the last paragraph or prayer item stays with the signature block (a signature never stands alone)
  if keep_last and last_keepable == #out and #out > 0 then
    out[#out].attributes["custom-style"] = "Allegation Keep"
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  if m.caption == nil or m.caption.debtor == nil or m.caption.parties == nil then
    error("nyeb docx: FRBP 9004(b), LBR 9004-2(a): caption.debtor and caption.parties are required", 0)
  end
  local raw = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)
  local out = pandoc.Blocks({})
  if m.lead_in then out:insert(styled("Body Text", m.lead_in)) end
  out:extend(body(doc.blocks, m.signature ~= nil))
  out = out:walk({ Inlines = xe.inlines })
  if m.signature then out:insert(xe.raw(signature(m, raw))) end
  -- the caption's space below is the first body paragraph's space above
  out:insert(1, xe.raw(court_title() .. caption(m) .. xe.para({ xe.spacing(0, 0, CAPTION_BELOW) }, "")))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
