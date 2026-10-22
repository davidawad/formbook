-- W.D. Ky. adversary complaint (kywb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document. Mirrors
-- ../typst/kywb-adversary-complaint.typ:
--   * the court lines, then one borderless table: the debtor block beside the bankruptcy identifiers, the parties
--     (ruled at the right and foot, cell borders) beside the adversary number; then the title;
--   * allegations numbered here, one per top-level paragraph, the number in a half-inch box (a tab to 1 in); a
--     paragraph whose text starts with "~" is not numbered;
--   * the relief list lettered A., B., C., the letter hanging in a half-inch box;
--   * the signature block 3 in from the left margin, kept whole, then each exhibit on its own page as a ruled table.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter. Font, spacing,
-- margins and the page number are styles and section settings in docx/reference.xml (fb render builds the reference
-- document from it). Requirement IDs (KYWB-...) are in ../README.md.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, HALF = 480, 280, 240     -- typst pitch-body 24 pt, pitch-single 14 pt, half 12 pt
local TEXT_W = 9360                          -- typst text-width 6.5 in
local LEFT_COL = 5040                        -- typst caption-left 3.5 in
local CELL_PAD, CELL_TOP, CELL_BOTTOM = 288, 96, 144 -- typst cell-pad 14.4 pt, cell-top 4.8 pt, cell-bottom 7.2 pt
local DESIG, V_IND, NAME_IND = 2592, 1296, 720 -- typst designation-indent 1.8 in, v-indent 0.9 in, 0.5 in
local SIG_IND = 4320                         -- typst signature-indent 3 in
local TABLE_INSET = 100                      -- typst table-inset 5 pt

local function need(meta, key)
  if meta[key] == nil then error("kywb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- A metadata value as plain text, as typst reads the YAML string: pandoc's abbreviation no-break spaces undone.
local function txt(v)
  return v and (pandoc.utils.stringify(v):gsub("\u{00A0}", " ")) or ""
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

-- A single-spaced paragraph: o = { before, after, line, left, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function line(v, o)
  return xe.runs(txt(v), o)
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function mar(o)
  local x = '<w:tcMar>'
  for _, side in ipairs({ "top", "left", "bottom", "right" }) do
    if o[side] then x = x .. '<w:' .. side .. ' w:w="' .. o[side] .. '" w:type="dxa"/>' end
  end
  return x .. '</w:tcMar>'
end

local TBL_NO_MAR = '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
  .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
local LOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- ---------------------------------------------------------------------------
-- The caption (Fed. R. Bankr. P. 9004(b), 7010: Form 416 layout) and the title
-- ---------------------------------------------------------------------------

local function caption(m)
  local c = need(m, "caption")
  local out = {}
  local court = items(need(m, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(txt(l):upper(), { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  local debtor = {}
  for i, n in ipairs(items(c.debtor_names)) do debtor[#debtor + 1] = p(line(n), { left = i == 1 and 0 or NAME_IND }) end
  debtor[#debtor + 1] = p(line(c.debtor_designation), { left = DESIG, before = HALF })
  local numbers = {}
  for _, l in ipairs(items(c.bankruptcy_lines)) do numbers[#numbers + 1] = p(line(l)) end
  local parties = {}
  local sides = need(c, "parties")
  for i, side in ipairs(sides) do
    for k, n in ipairs(items(side.names)) do
      parties[#parties + 1] = p(line(n), { before = (i > 1 and k == 1) and HALF or 0 })
    end
    parties[#parties + 1] = p(line(side.designation), { left = DESIG })
    if i < #sides then parties[#parties + 1] = p(xe.runs("v."), { left = V_IND, before = HALF }) end
  end
  local number = txt(c.adversary_number)
  if number == "" then number = string.rep("_", 12) end
  local adversary = { p(xe.runs("Adv. Proc. No. " .. number)) }
  if c.judge ~= nil then adversary[#adversary + 1] = p(line(c.judge), { before = HALF }) end
  local right_w = TEXT_W - LEFT_COL
  local borders = '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right") .. '</w:tcBorders>'
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. TBL_NO_MAR .. LOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. LEFT_COL .. '"/><w:gridCol w:w="' .. right_w
    .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(LEFT_COL, table.concat(debtor), mar({ right = CELL_PAD }))
    .. cell(right_w, table.concat(numbers), mar({ left = CELL_PAD }))
    .. '</w:tr><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(LEFT_COL, table.concat(parties), borders .. mar({ top = CELL_TOP, right = CELL_PAD, bottom = CELL_BOTTOM }))
    .. cell(right_w, table.concat(adversary), mar({ top = CELL_TOP, left = CELL_PAD }))
    .. '</w:tr></w:tbl>'
  out[#out + 1] = p(xe.runs(txt(need(m, "title")):upper(), { b = true }), { jc = "center", before = BODY, after = HALF })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block and exhibits
-- ---------------------------------------------------------------------------

-- typst: one unbreakable block 24 pt below the text; here every line but the last is kept with the next.
local function signature(m)
  local sig = need(m, "signature")
  local lines = {}
  local firm = sig.firm_lines and items(sig.firm_lines) or { sig.firm }
  for _, l in ipairs(firm) do lines[#lines + 1] = { line(l, { b = true }), 0 } end
  lines[#lines + 1] = { xe.runs("/s/ " .. txt(sig.signer)), HALF }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = { line(l), 0 } end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { left = SIG_IND, before = i == 1 and BODY or l[2], keep = i < #lines })
  end
  return table.concat(out)
end

local function exhibit(ex)
  local out = { p(xe.runs(txt(ex.title):upper(), { b = true, u = true }), { jc = "center", brk = true, after = BODY }) }
  local header = items(ex.header)
  local ws = items(ex.widths)
  local fr, sum = {}, 0
  for c = 1, #header do
    fr[c] = ws[c] and tonumber(txt(ws[c])) or 1
    sum = sum + fr[c]
  end
  local widths, used = {}, 0
  for c = 1, #header do
    widths[c] = math.floor(fr[c] * TEXT_W / sum + 0.5)
    used = used + widths[c]
  end
  widths[#widths] = widths[#widths] + (TEXT_W - used)
  local right = {}
  for _, r in ipairs(items(ex.right)) do right[tonumber(txt(r)) + 1] = true end
  local function row(vals, bold, head)
    local x = '<w:tr><w:trPr><w:cantSplit/>' .. (head and '<w:tblHeader/>' or '') .. '</w:trPr>'
    for c = 1, #widths do
      local v = vals[c] and txt(vals[c]) or ""
      x = x .. cell(widths[c], p(xe.runs(v, { b = bold and v ~= "" }), { jc = right[c] and "right" or "left" }))
    end
    return x .. '</w:tr>'
  end
  local b = '<w:%s w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  local borders = '<w:tblBorders>'
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    borders = borders .. string.format(b, side)
  end
  borders = borders .. '</w:tblBorders>'
  local t = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>' .. '<w:tblInd w:w="' .. TABLE_INSET .. '" w:type="dxa"/>' .. borders
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="' .. TABLE_INSET .. '" w:type="dxa"/><w:left w:w="'
    .. TABLE_INSET .. '" w:type="dxa"/><w:bottom w:w="' .. TABLE_INSET .. '" w:type="dxa"/><w:right w:w="'
    .. TABLE_INSET .. '" w:type="dxa"/></w:tblCellMar>' .. LOOK .. '</w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do t[#t + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  t[#t + 1] = '</w:tblGrid>'
  t[#t + 1] = row(header, true, true)
  for _, r in ipairs(ex.rows or {}) do t[#t + 1] = row(items(r), false) end
  local total = items(ex.total)
  if #total > 0 then t[#t + 1] = row(total, true) end
  t[#t + 1] = '</w:tbl>'
  out[#out + 1] = table.concat(t)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body: numbered allegations, headings, the lettered relief list
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(I)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function starts_with_tilde(b)
  local first, second = b.content[1], b.content[2]
  return first and first.t == "Str" and first.text == "~" and second and second.t == "Space"
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function letter(n)
  local s = ""
  while n > 0 do
    n = n - 1
    s = string.char(65 + n % 26) .. s
    n = n // 26
  end
  return s
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "court", "caption", "title", "signature" }) do local _ = need(m, k) end

  local out = { xe.raw(caption(m)) }
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- In capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
      local c = b.content:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      out[#out + 1] = pandoc.Header(1, c)
    elseif b.t == "Para" or b.t == "Plain" then
      if starts_with_tilde(b) then
        local c = pandoc.Inlines({})
        for k = 3, #b.content do c:insert(b.content[k]) end
        out[#out + 1] = styled("Body Text", c)
      else
        n = n + 1
        local c = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        c:extend(b.content)
        out[#out + 1] = styled("Allegation", c)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (letter(k) .. ".") or "\u{2022}"
        local c = pandoc.Inlines({ pandoc.Str(lab), TAB })
        c:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Prayer Item", c)
        k = k + 1
      end
    else
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m)))
  for _, ex in ipairs(items(m.exhibits)) do body:insert(xe.raw(exhibit(ex))) end
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
