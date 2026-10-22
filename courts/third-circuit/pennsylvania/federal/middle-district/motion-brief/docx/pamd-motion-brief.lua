-- M.D. Pa. brief in support of a motion, docx engine. Mirrors typst/pamd-motion-brief.typ: the court title
-- (centred single lines), the caption (a table: one single line per caption row of the sample, the party text with
-- its indent on the left, a ":" on every row, the right column's text), the title, the body (paragraphs with a
-- half-inch first-line indent; headings flush left; single-spaced blocks, a paragraph with the author's hard line
-- breaks: the Statement of Questions, the service list), and the signature block. Every case word comes from the
-- frontmatter. The footer (the page number, centred, 12 pt) and the last section are written for fb render
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); font, body styles, headings and margins are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 640 the body, 320 a single line, 276 the footer), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE, FOOT = 640, 320, 276      -- typst pitch-body, pitch-single, pitch-footer
local TW = 9360                               -- the text width: 6.5 in
local CAP_LEFT, CAP_COLON = 4896, 576         -- typst caption-left 3.4 in, caption-colon 0.4 in
local CAPTION_ABOVE = 320                     -- typst caption-above 16 pt
local TITLE_ABOVE = 640                       -- typst title-above 32 pt
local TEXT_ABOVE = 320                        -- typst text-above 16 pt
local BLOCK_GAP = 320                         -- typst block-gap 16 pt
local SIG_ABOVE = 640                         -- typst sig-above 32 pt
local FIRM_ABOVE, BY_ABOVE, LINES_ABOVE = 120, 640, 120 -- typst firm-above 6 pt, by-above 32 pt, lines-above 6 pt
local SIG_COL, SIG_RULE = 4032, 4608          -- typst sig-col 2.8 in, sig-rule 3.2 in
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("pamd motion brief docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tabs, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.lines then props[#props + 1] = xe.LINES end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging or o.first then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
  return xe.para(props, body or "")
end

local function tab(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- Inlines as runs, the author's hard line breaks (typst linebreak()) as Word line breaks.
local function inl_br(inlines)
  local out, seg = {}, pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "LineBreak" then
      out[#out + 1] = xe.inl(seg) .. xe.BR
      seg = pandoc.Inlines({})
    else
      seg:insert(el)
    end
  end
  out[#out + 1] = xe.inl(seg)
  return table.concat(out)
end

local function has_break(inlines)
  for _, el in ipairs(inlines) do if el.t == "LineBreak" then return true end end
  return false
end

-- ---------------------------------------------------------------------------
-- Footer and section (LR 5.1(c))
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local SZ12 = '<w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
local FOOTER_P = xe.para({ xe.spacing(0, 0, FOOT), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r>' .. SZ12 .. '<w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r>' .. SZ12 .. '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r>' .. SZ12 .. '<w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r>' .. SZ12 .. '<w:t>1</w:t></w:r>'
  .. '<w:r>' .. SZ12 .. '<w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdPamdFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Page one: court title, caption, title
-- ---------------------------------------------------------------------------

local function tc(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. paras .. "</w:tc>"
end

local function cover(m)
  local out = {}
  for _, l in ipairs({ "IN THE UNITED STATES DISTRICT COURT", "FOR THE MIDDLE DISTRICT OF PENNSYLVANIA" }) do
    out[#out + 1] = p(xe.runs(l), { jc = "center" })
  end
  local left, colons, right = {}, {}, {}
  for _, r in ipairs(items(m.caption)) do
    local ind = math.floor((tonumber(txt(r.indent)) or 0) * 1440 + 0.5)
    left[#left + 1] = p(r.left and xe.inl(r.left) or "", { left = ind })
    colons[#colons + 1] = p(xe.runs(":"), { jc = "center" })
    right[#right + 1] = p(r.right and xe.inl(r.right) or "")
  end
  local right_w = TW - CAP_LEFT - CAP_COLON
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_COLON .. '"/><w:gridCol w:w="' .. right_w .. '"/>'
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(CAP_LEFT, table.concat(left)) .. tc(CAP_COLON, table.concat(colons)) .. tc(right_w, table.concat(right))
    .. "</w:tr></w:tbl>"
  out[#out + 1] = p(xe.runs(txt(m.title):upper(), { b = true }), { before = TITLE_ABOVE, jc = "center" })
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature
-- ---------------------------------------------------------------------------

-- The signature block (typst signature-block): "Dated:" at the left of the first line (a tab) and "Respectfully
-- submitted," from SIG_COL, the firm, "By:" with the signature line (an underlined tab to 3.2 in), the signer's
-- lines; kept on one page.
local function signature(m)
  local date = m.date and ("Dated: " .. txt(m.date)) or ""
  local out = { p(xe.runs(date .. "\t") .. xe.runs("Respectfully submitted,"),
    { before = SIG_ABOVE, left = SIG_COL, hanging = SIG_COL, tabs = tab(SIG_COL), keep = true }) }
  for k, l in ipairs(items(m.signature.firm)) do
    out[#out + 1] = p(xe.inl(l), { before = k == 1 and FIRM_ABOVE or 0, left = SIG_COL, keep = true })
  end
  out[#out + 1] = p(xe.runs("By:") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    { before = BY_ABOVE, left = SIG_COL, tabs = tab(SIG_COL + SIG_RULE), keep = true })
  local lines = items(m.signature.lines)
  for k, l in ipairs(lines) do
    out[#out + 1] = p(xe.inl(l), { before = k == 1 and LINES_ABOVE or 0, left = SIG_COL, keep = k < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- A single-spaced block (typst single-block): no first-line indent, a blank single line around it, kept whole.
local function single_block(inlines)
  return p(inl_br(inlines), { before = BLOCK_GAP, after = BLOCK_GAP, lines = true })
end

local function body(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      out[#out + 1] = p(xe.inl(level == 1 and upper(b.content) or b.content),
        { style = "Heading" .. level, keep = true, pitch = BODY })
    elseif b.t == "Para" or b.t == "Plain" then
      if has_break(b.content) then
        out[#out + 1] = single_block(b.content)
      else
        out[#out + 1] = p(xe.inl(b.content), { style = "BodyText", pitch = BODY })
      end
    elseif b.t == "OrderedList" and b.listAttributes.style == "UpperAlpha" then
      -- "A.  question\ answer": pandoc reads the author's letters as a list; typst sets them as text
      for j, item in ipairs(b.content) do
        local content = pandoc.Inlines({ pandoc.Str(string.char(64 + b.listAttributes.start + j - 1) .. "."),
          pandoc.Space() })
        content:extend(pandoc.utils.blocks_to_inlines(item))
        check(has_break(content), "a lettered item is a single-spaced block (a question and its answer)")
        out[#out + 1] = single_block(content)
      end
    else
      error("pamd-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  for i, x in ipairs(out) do out[i] = xe.raw(x) end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 1331"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  check(m.caption ~= nil, "Fed. R. Civ. P. 10(a): the caption is required")
  check(m.title ~= nil, "Fed. R. Civ. P. 10(a): the title of the paper is required")
  check(m.signature ~= nil and m.signature.lines ~= nil, "Fed. R. Civ. P. 11(a): the signature block is required")
  write_file("FORMBOOK_FOOTERS", "rIdPamdFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
