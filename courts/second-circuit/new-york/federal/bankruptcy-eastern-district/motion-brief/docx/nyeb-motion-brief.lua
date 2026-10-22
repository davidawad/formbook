-- nyeb motion with memorandum of law, DOCX engine (docs/DOCX.md). Mirrors typst/nyeb-motion-brief.typ:
--   the counsel block (top left, single spaced); the court title; the caption (a two-row table with the rules of the
--   typst caption, "v." between the parties, the numbers column centred on the parties); the title centred and bold;
--   body paragraphs with a 0.5 in first-line indent; headings; bullets (a typed bullet and a tab, the text hanging);
--   block quotations (single spaced, 1 in each side); the conclusion kept with the signature block (the place and
--   date at the left, the firm's lines from 3.25 in). The footer carries the frontmatter's matter number, so this
--   filter writes it ($FORMBOOK_FOOTERS) and the last section that names it ($FORMBOOK_FINAL); fb render
--   (tools/fb/src/docxpass.rs) adds both (was docx/render.sh's sed into the footer). The styles come from
--   docx/reference.xml (fb render builds the reference document from it). Every case word comes from the frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                  -- typst pitch-single
local TW = 9360                     -- the text width: 6.5 in
local QUOTE = 1440                  -- typst quote-indent 1 in
local CAP_LEFT = 5472               -- typst caption-left 3.8 in
local CAP_GUTTER = 288              -- typst caption-gutter 0.2 in
local CAP_RIGHT = TW - CAP_LEFT - CAP_GUTTER
local DESIGNATION = 1728            -- typst designation-indent 1.2 in
local RULE_SZ = 6                   -- typst caption-rule 0.75 pt (eighths of a point)
local INSET = 160                   -- typst caption-inset 8 pt
local RULE = 15                     -- LibreOffice sets each 0.75 pt rule inside the row (typst strokes take no room):
                                    -- the cell padding beside it is that much less, so a row is as tall as typst's
local TITLE_GAP = 120               -- typst title-gap 6 pt
local BLOCK_GAP = 480               -- typst block-gap 24 pt
local VERSUS_GAP = 240              -- typst versus-gap 12 pt
local QUOTE_SPACE = 240             -- typst quote-space 12 pt
local SIG_ABOVE = 480               -- typst signature-above 24 pt
local SIG_COL = 4680                -- typst signature-indent 3.25 in
local FOOTER_SIZE = 20              -- typst footer-size 10 pt (half points)
local FOOTER_ID = "rIdNyebFooter"

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

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- A paragraph: o = { before, after, pitch, left, right, hanging, jc, keep, tab, style }; single pitch by default.
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
-- Cover: counsel, court title, caption (FRBP 9004(b); E.D.N.Y. LBR 9004-2(a)), title
-- ---------------------------------------------------------------------------

local function court_title()
  return p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", before = BLOCK_GAP })
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
      left2[#left2 + 1] = p(xe.runs("v."), { jc = "center", before = VERSUS_GAP, after = VERSUS_GAP })
    end
    left2[#left2 + 1] = party_lines(party)
  end
  local right2 = p(xe.runs("Adv. Pro. No. " .. txt(m.adversary_number)))
  -- row 1 has a rule above and below, row 2 a rule below; each rule is taken off the padding beside it
  local function row(sides, top, bottom, l, r)
    return "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. cell(CAP_LEFT, sides, "top", top, bottom, l)
      .. cell(CAP_GUTTER, sides, "top", top, bottom, "")
      .. cell(CAP_RIGHT, sides, "center", top, bottom, r) .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="'
    .. CAP_RIGHT .. '"/></w:tblGrid>'
    .. row({ "top", "bottom" }, INSET - RULE, INSET - RULE, left1, right1)
    .. row({ "bottom" }, INSET, INSET - RULE, table.concat(left2), right2)
    .. "</w:tbl>"
end

local function cover(m)
  local out = {}
  for _, l in ipairs(items(m.counsel)) do out[#out + 1] = p(xe.inl(l)) end
  out[#out + 1] = court_title()
  -- the space above the table: an empty paragraph of that height
  out[#out + 1] = xe.para({ xe.spacing(0, 0, BLOCK_GAP) }, "")
  out[#out + 1] = caption(m)
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { jc = "center", before = BLOCK_GAP, after = BLOCK_GAP })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block, footer, last section
-- ---------------------------------------------------------------------------

-- typst signature: line for line, the place and date at the left (a tab), the firm's lines from SIG_COL; single
-- spaced, kept on one page, after a space of its own.
local function signature(m)
  local sig = m.signature
  local dated, lines = items(sig.dated), items(sig.lines)
  local n = math.max(#dated, #lines)
  local out = {}
  for i = 1, n do
    local left = dated[i] and xe.inl(dated[i]) or ""
    local right = lines[i] and xe.inl(lines[i]) or ""
    out[#out + 1] = p(left .. xe.runs("\t") .. right, { before = i == 1 and SIG_ABOVE or 0, left = SIG_COL,
      hanging = SIG_COL, tab = SIG_COL, keep = i < n })
  end
  return table.concat(out)
end

-- typst footer: the matter number at the left (10 pt), the page number centred (a centre tab), in a single-pitch line.
local function footer(m)
  return '<w:p><w:pPr><w:tabs><w:tab w:val="center" w:pos="' .. (TW // 2) .. '"/></w:tabs>'
    .. xe.spacing(0, 0, SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("left") .. "</w:pPr>"
    .. xe.runs(txt(m.matter_number), { sz = FOOTER_SIZE }) .. xe.runs("\t")
    .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
end

-- Letter page (E.D.N.Y. LBR 9004-1(a)(ii)), 1 in margins, the footer's line box ending 0.5 in above the page edge.
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="' .. FOOTER_ID .. '"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function body(blocks, keep_last)
  local out = {}
  local last_keep -- the last paragraph or bullet, and its kept style
  local function quote(b)
    for _, q in ipairs(b.content) do
      if q.t == "Para" or q.t == "Plain" then
        out[#out + 1] = xe.raw(p(xe.inl(q.content), { left = QUOTE, right = QUOTE, before = QUOTE_SPACE, after = QUOTE_SPACE }))
      elseif q.t == "BlockQuote" then
        quote(q)
      else
        error("nyeb-motion-brief.lua: unexpected block in a quotation: " .. q.t)
      end
    end
  end
  for _, b in ipairs(blocks) do
    last_keep = nil
    if b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), b.content)
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs("\u{2022}\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Bullet", inl)
      end
      last_keep = "Bullet Keep"
    elseif b.t == "BlockQuote" then
      quote(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled("Body Text", b.content)
      last_keep = "Body Text Keep"
    else
      error("nyeb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  -- the conclusion stays with the signature block (a signature never stands alone on a page)
  if keep_last and last_keep then out[#out].attributes["custom-style"] = last_keep end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("548(a)(1)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
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

-- A sign and the token after it are one box in typst ("§ 548(a)", "¶¶ 51–55"; lib/typst/xengine.typ and the
-- template): a doubled sign is bound to its number by a no-break space (xe.inl binds a single sign only), and the
-- token takes a word joiner (U+2060) after an en dash, where LibreOffice would break.
local function bind_doubled_signs(l)
  for i = 1, #l - 2 do
    local s = l[i]
    if s.t == "Str" and l[i + 1].t == "Space" and s.text:match("^[\u{00A7}\u{00B6}]+$") then
      if s.text ~= "\u{00A7}" and s.text ~= "\u{00B6}" then l[i + 1] = pandoc.Str("\u{00A0}") end
      local n = l[i + 2]
      if n.t == "Str" and n.text:find("\u{2013}", 1, true) then
        l[i + 2] = pandoc.Str((n.text:gsub("\u{2013}", "\u{2013}\u{2060}")))
      end
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  if m.caption == nil or m.caption.debtor == nil or m.caption.parties == nil then
    error("nyeb docx: FRBP 9004(b), LBR 9004-2(a): caption.debtor and caption.parties are required", 0)
  end
  write_file("FORMBOOK_FOOTERS", FOOTER_ID .. "\t" .. footer(m) .. "\n")
  write_file("FORMBOOK_FINAL", SECT)
  local out = pandoc.Blocks(body(doc.blocks, m.signature ~= nil))
  out = out:walk({ Inlines = xe.inlines })
  if m.signature then out:insert(xe.raw(signature(m))) end
  out:insert(1, xe.raw(cover(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules }, { Inlines = no_break_before_stop }, { Inlines = bind_doubled_signs }, { Pandoc = finish } }
