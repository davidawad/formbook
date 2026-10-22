-- N.D. Ohio complaint (ohnd), docx engine. Mirrors typst/ohnd-complaint.typ:
--   * page 1: the 1 1/2 in first-page top margin (L.R. 10.1) as the space before the court title (Word keeps the
--     space above the first paragraph of a section), the court title centered, the caption (a borderless table: one
--     row per line of the party column, a ")" on every line of it, the case number on the first row and the judge on
--     the third), the title of the paper bold and centered, and the lead-in;
--   * the body: paragraphs numbered 1, 2, ... (Fed. R. Civ. P. 10(b)); a paragraph beginning with the marker
--     <!--u--> is unnumbered (the WHEREFORE clause); a paragraph that is only bold text is an unnumbered run-in
--     label kept with the next; markdown ordered lists lettered A., B., ... (the markdown number is the letter's
--     position); headings at the type size on the body pitch;
--   * the jury demand when asked for, and the signature block, kept on one page with the last paragraph.
-- Numbers and letters are typed text, as the typst template types them. Every case word comes from the sample. The
-- footer (a centered page number, L.R. 10.1) and the last section are written for fb render ($FORMBOOK_FOOTERS,
-- $FORMBOOK_FINAL); font, body styles and headings are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276                 -- typst pitch-body (27.6 pt), pitch-single (13.8 pt)
local TW = 9360                               -- typst text-width: 6.5 in
local INDENT = 720                            -- typst para-indent, number-box, item-indent, letter-box: 0.5 in
local FIRST_TOP = 720                         -- typst first-page-top - margin: 0.5 in
local CAP_LEFT, CAP_PAREN = 4752, 432         -- typst caption-left 3.3 in, caption-paren 0.3 in
local CAP_INSET = 432                         -- typst caption-right-inset 0.3 in
local SIG_COL = 4032                          -- typst sig-col 2.8 in
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge
local UNNUMBERED = "<!--u-->"

local function check(cond, msg)
  if not cond then error("ohnd complaint docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- ---------------------------------------------------------------------------
-- Line count of a caption name (typst measures the name in the party column and sets that many ")"; this computes
-- the same). Times New Roman's advances in 1/1000 em (the vendored face typst and Word set, without kerning or
-- ligatures: a line's width is the sum of its advances), printable ASCII in code order, then the other characters
-- a caption may use; first fit at the spaces, as typst breaks (linebreaks: "simple").
-- ---------------------------------------------------------------------------

local ASCII = { 250, 333.01, 408.2, 500, 500, 833.01, 777.83, 180.18, 333.01, 333.01, 500, 563.96, 250, 333.01, 250,
  277.83, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 277.83, 277.83, 563.96, 563.96, 563.96, 443.85, 920.9,
  722.17, 666.99, 666.99, 722.17, 610.84, 556.15, 722.17, 722.17, 333.01, 389.16, 722.17, 610.84, 889.16, 722.17,
  722.17, 556.15, 722.17, 666.99, 556.15, 610.84, 722.17, 722.17, 943.85, 722.17, 722.17, 610.84, 333.01, 277.83,
  333.01, 469.24, 500, 333.01, 443.85, 500, 443.85, 500, 443.85, 333.01, 500, 500, 277.83, 277.83, 500, 277.83,
  777.83, 500, 500, 500, 500, 333.01, 389.16, 277.83, 500, 500, 722.17, 500, 500, 443.85, 479.98, 200.2, 479.98,
  541.02 }
local OTHER = { ["\u{2019}"] = 333.01, ["\u{2018}"] = 333.01, ["\u{201C}"] = 443.85, ["\u{201D}"] = 443.85,
  ["\u{2013}"] = 500, ["\u{2014}"] = 1000, ["\u{00A7}"] = 500, ["\u{00B6}"] = 453.13, ["\u{2026}"] = 1000 }

-- The width of a word at 12 pt, in twips.
local function width(word)
  local w = 0
  for _, c in utf8.codes(word) do
    w = w + ((c >= 32 and c <= 126) and ASCII[c - 31] or OTHER[utf8.char(c)] or 500)
  end
  return w * 12 / 1000 * 20
end

-- The lines a text takes in a column `measure` twips wide.
local function line_count(text, measure)
  local n, line = 1, nil
  local space = width(" ")
  for word in text:gsub("\u{00A0}", " "):gmatch("%S+") do
    local w = width(word)
    if line == nil then
      line = w
    elseif line + space + w <= measure + 0.2 then
      line = line + space + w
    else
      n, line = n + 1, w
    end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Footer and section (L.R. 10.1: consecutive page numbers)
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_P = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdOhndFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Page one: court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

local function cell(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function cover(m)
  local out = {}
  local court = { "UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF OHIO" }
  if m.division then court[#court + 1] = pandoc.text.upper(txt(m.division)) end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l), { jc = "center", before = i == 1 and FIRST_TOP or 0, keep = true })
  end
  local rows = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then
      rows[#rows + 1] = ""
      rows[#rows + 1] = "v."
      rows[#rows + 1] = ""
    end
    for _, n in ipairs(items(party.names)) do rows[#rows + 1] = n end
    rows[#rows + 1] = party.designation
  end
  local judge = txt(m.judge)
  local trs = {}
  for i, r in ipairs(rows) do
    -- the caption stands a double line below the court title (typst: the caption block's above)
    local before = i == 1 and BODY or 0
    local s = txt(r)
    local parens = {}
    for j = 1, math.max(1, line_count(s, CAP_LEFT)) do
      parens[#parens + 1] = p(xe.runs(")"), { before = j == 1 and before or 0 })
    end
    local right = i == 1 and "Case No. " .. txt(m.case_number) or i == 3 and "Judge: " .. judge or ""
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. cell(CAP_LEFT, p(s == "" and "" or (type(r) == "string" and xe.runs(r) or xe.inl(r)), { before = before }))
      .. cell(CAP_PAREN, table.concat(parens))
      .. cell(TW - CAP_LEFT - CAP_PAREN, p(xe.runs(right), { before = before, left = CAP_INSET })) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_PAREN .. '"/>'
    .. '<w:gridCol w:w="' .. (TW - CAP_LEFT - CAP_PAREN) .. '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { before = BODY, jc = "center" })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body and signature
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- The letter of item n (typst numbering "A."): A ... Z, AA, AB, ...
local function letter(n)
  local s = ""
  while n > 0 do
    local r = (n - 1) % 26
    s = string.char(65 + r) .. s
    n = (n - 1 - r) // 26
  end
  return s .. "."
end

-- Headings at the type size on the body pitch, no space of their own, kept with the next block: level 1 centered
-- bold capitals, level 2 centered bold, level 3 bold italic at the margin.
local function heading(level, content)
  level = math.min(level, 3)
  return p(xe.inl(level == 1 and upper(content) or content, { b = true, i = level == 3 }),
    { style = "Heading" .. level, keep = true, pitch = BODY, jc = level <= 2 and "center" or "left" })
end

-- true when the paragraph starts with the unnumbered marker; the marker is removed from the paragraph
local function strip_marker(para)
  local first = para.content[1]
  if first and first.t == "RawInline" and first.format:match("html") and first.text == UNNUMBERED then
    para.content:remove(1)
    while para.content[1] and (para.content[1].t == "Space" or para.content[1].t == "SoftBreak") do
      para.content:remove(1)
    end
    return true
  end
  return false
end

-- The body as paragraph builders (keep -> xml); the last one is kept with the signature.
local function body(blocks)
  local out = {}
  local n = 0
  local unnumbered = false
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level, content = b.level, b.content
      out[#out + 1] = function() return heading(level, content) end
    elseif b.t == "RawBlock" and b.format:match("html") and b.text == UNNUMBERED then
      unnumbered = true
    elseif b.t == "Para" or b.t == "Plain" then
      local content = b.content
      if unnumbered or strip_marker(b) then
        unnumbered = false
        out[#out + 1] = function(keep)
          return p(xe.inl(content), { pitch = BODY, first = INDENT, keep = keep })
        end
      elseif #content == 1 and content[1].t == "Strong" then
        -- an unnumbered run-in label, at the margin, kept with the next block
        out[#out + 1] = function()
          return p(xe.inl(content), { pitch = BODY, keep = true })
        end
      else
        n = n + 1
        local label = n .. ".\t"
        out[#out + 1] = function(keep)
          return p(xe.runs(label) .. xe.inl(content), { pitch = BODY, first = INDENT, tab = 2 * INDENT, keep = keep })
        end
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local content = pandoc.utils.blocks_to_inlines(item)
        local label = letter(start + i - 1) .. "\t"
        out[#out + 1] = function(keep)
          return p(xe.runs(label) .. xe.inl(content), { pitch = BODY, left = 2 * INDENT, hanging = INDENT,
            tab = 2 * INDENT, keep = keep })
        end
      end
    else
      error("ohnd-complaint.lua: unexpected block " .. b.t)
    end
  end
  local res = {}
  for i, f in ipairs(out) do res[i] = f(i == #out) end
  return res
end

-- Jury demand (Fed. R. Civ. P. 38(b)), kept with the signature.
local function jury(m)
  if not m.jury_demand then return "" end
  return heading(1, pandoc.Inlines({ pandoc.Str("JURY DEMAND") }))
    .. p(xe.runs("Plaintiff demands a trial by jury on all issues so triable."), { pitch = BODY, first = INDENT, keep = true })
end

-- The signature block (typst signature-block): single-spaced, a double line below the text; "Dated:" and the date
-- at the left of the first line (a tab to SIG_COL), "Respectfully submitted,", a blank line and the lines from
-- SIG_COL; kept on one page.
local function signature(m)
  local date = txt(m.date)
  local out = { p(xe.runs((date ~= "" and "Dated: " .. date or "") .. "\tRespectfully submitted,"),
    { before = BODY, left = SIG_COL, hanging = SIG_COL, tab = SIG_COL, keep = true }) }
  local lines = items(m.signature.lines)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.inl(l), { before = i == 1 and SINGLE or 0, left = SIG_COL, keep = i < #lines })
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12188(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("¶¶ 1-16"; the typst template boxes them): no-break spaces.
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
  check(m.caption ~= nil and m.caption.parties ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.case_number ~= nil, "Fed. R. Civ. P. 10(a): the sample has no case_number")
  check(m.title ~= nil, "Fed. R. Civ. P. 10(a): the sample has no title")
  check(m.signature ~= nil and m.signature.lines ~= nil, "L.R. 10.1: the sample has no signature lines")
  write_file("FORMBOOK_FOOTERS", "rIdOhndFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then
    -- a single line below the title (its first line box, at the body pitch, adds the rest of the double line)
    out:insert(xe.raw(p(xe.inl(m.lead_in), { before = SINGLE, pitch = BODY, first = INDENT })))
  end
  for _, x in ipairs(body(doc.blocks)) do out:insert(xe.raw(x)) end
  out:insert(xe.raw(jury(m) .. signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
