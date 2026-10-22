-- NMCCA brief, DOCX engine (docs/DOCX.md), on the cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md,
-- "Cross-engine gate"): the typst render (../typst/nmcca-*.typ) is the reference this one breaks every line and page
-- alike with. Every paragraph has exact line spacing at a typst pitch (body 672 twips, single 336), the spaces
-- between blocks are typst's (pt x 20), and the text goes through xe.inl / xe.runs / xe.inlines (the break rules of
-- typst: no-break hyphen before a digit, no abbreviation no-break spaces, section signs bound to their number).
-- pandoc writes the body text (paragraphs, quotations, lists, footnotes) with the styles of docx/reference.xml; this
-- filter writes:
--   * the cover (its own section, 2 in bottom margin, no page number; Appendix I, NMCCA-FORM-004);
--   * the Index of Brief (its own section, lower-roman page numbers from ii), its rows with a dot leader to the page
--     number, which fb render's multi-pass build fills in (tools/fb/src/docxpass.rs: the needles this filter writes
--     to FORMBOOK_NEEDLES, the pages it reads from FORMBOOK_PAGES);
--   * the headings with their labels (NMCCA-CONT-004: Argument I. A. 1. a.; elsewhere A. 1. a. (1)) and outline
--     levels; the body (arabic from 1; FORMBOOK_FINAL), the signature block kept with the last paragraph, and the
--     certificate of filing and service on a new page.
-- Footers: fb render's rIdFtrNone and rIdFtrPage. Headings are read at the top level of the body.

local xe = require("docx.xengine")
local runs, inl, para, raw, style, ind, jc = xe.runs, xe.inl, xe.para, xe.raw, xe.style, xe.ind, xe.jc
local spacing, KEEP, BREAK = xe.spacing, xe.KEEP, xe.BREAK
local stringify = pandoc.utils.stringify

-- The typst template's numbers, in twips (pt x 20).
local TEXT_W = 9360       -- 6.5 in
local SINGLE = 336        -- pitch-single, 16.8 pt
local DOUBLE = 672        -- pitch-double, 33.6 pt (NMCCA-FORM-002)
local INDENT = 720        -- para-indent, 0.5 in
local HALF = 4320         -- 3 in: counsel and signature blocks
local LABEL = 567         -- label-box, 28.35 pt
local TOC_IND = 420       -- toc-indent, 21 pt
local TOC_COL = 720       -- toc-page-col, 36 pt
local SP = {
  section = 392, sub = 308, toc_row = 168,
  cover_small = 336, cover_mid = 336, cover_large = 504,
  sig = 336, sig_line = 672,
}
local PAGE_H = 15840
local MARGIN_TOP = 1440
local MARGIN_BOTTOM = 1520  -- 1 in + 4 pt
local COVER_BOTTOM = 2880   -- 2 in (NMCCA-FORM-003)
local FOOTER = 727          -- the page number sits where typst puts it (footer-descent 30 % of the 76 pt bottom margin)
local NEEDLE_MAX = 60
-- Before an index row's leader tab: a no-break space widened to 0.75 em (10.5 pt, 210 twips), the least leader typst's
-- listing-row keeps after the text (h(0.75em)); xe.LEAD's three no-break spaces are 0.75 em only in a face whose
-- space is 0.25 em. EB Garamond's no-break space is 2.8 pt (56 twips).
local SPACE_W = 56
local LEAD_RUN = '<w:r><w:rPr><w:spacing w:val="' .. (210 - SPACE_W) .. '"/></w:rPr><w:t xml:space="preserve">\u{00A0}</w:t></w:r><w:r><w:tab/></w:r>'

local META = {}

local function meta(k)
  return META[k]
end

local function meta_list(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, item in ipairs(v) do out[#out + 1] = item end
    return out
  end
  return { v }
end

local function P(props, body)
  return raw(para(props, body or ""))
end

local function upper_inlines(x)
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Sections: the paragraph that ends a section carries its properties (footer, page numbers, margins)
-- ---------------------------------------------------------------------------

local function sect_pr(footer, bottom, fmt, start)
  local pg = fmt and string.format('<w:pgNumType w:fmt="%s" w:start="%d"/>', fmt, start or 1) or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. string.format('<w:pgMar w:top="%d" w:right="1440" w:bottom="%d" w:left="1440" w:header="720" w:footer="%d" w:gutter="0"/>',
      MARGIN_TOP, bottom, FOOTER)
    .. pg .. "</w:sectPr>"
end

local function section_break(footer, bottom, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, bottom, fmt, start) .. "</w:pPr></w:p>")
end

-- ---------------------------------------------------------------------------
-- Needles and pages (docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function opening(text)
  local out = ""
  for w in text:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end

local function need(id, text, context)
  local short = opening(text)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, "B", long, short }, "\t")
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function write_file(var, text)
  local path = os.getenv(var)
  if not path or path == "" then return end
  local f = io.open(path, "w")
  if not f then return end
  f:write(text)
  f:close()
end

-- The text of a block as printed, up to its first footnote (the PDF has the note's number there, not its text).
local function printed(b)
  local out = {}
  local stop = false
  local function walk(x)
    for _, el in ipairs(x) do
      if stop then return end
      if el.t == "Note" then stop = true return end
      if el.content and type(el.content) == "table" and el.t ~= "Str" then
        walk(el.content)
      elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then
        out[#out + 1] = " "
      else
        out[#out + 1] = stringify(el)
      end
    end
  end
  if b.t == "Para" or b.t == "Plain" or b.t == "Header" then
    walk(b.content)
  else
    return stringify(b)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover(): Appendix I, NMCCA-FORM-004)
-- ---------------------------------------------------------------------------

local B = { b = true }

local function line(before, body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = KEEP end
  if o.frame then props[#props + 1] = o.frame end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = spacing(before, o.after or 0, o.line or SINGLE)
  if o.left or o.first then props[#props + 1] = ind(o.left or 0, nil, o.first) end
  if o.center then props[#props + 1] = jc("center") end
  return para(props, body)
end

local function cover(out)
  out[#out + 1] = raw(line(0, runs("IN THE UNITED STATES NAVY-MARINE CORPS", B), { center = true }))
  out[#out + 1] = raw(line(0, runs("COURT OF CRIMINAL APPEALS", B), { center = true }))
  out[#out + 1] = raw(line(SP.cover_mid, runs("Before ") .. inl(meta("panel")), { center = true, after = SP.cover_large }))

  -- caption: two columns (1fr, 1fr) with a 14 pt gutter; left: parties, right: number and title
  local left = {
    line(0, inl(meta("appellee"))),
    line(SP.cover_small, inl(meta("appellee_role")), { center = true }),
    line(SP.cover_small, runs("v.")),
    line(SP.cover_small, inl(meta("appellant"))),
  }
  for _, l in ipairs(meta_list(meta("appellant_lines"))) do left[#left + 1] = line(0, inl(l, { i = true })) end
  left[#left + 1] = line(SP.cover_small, inl(meta("appellant_role")), { center = true })
  local right = {
    line(0, runs("NMCCA No. ") .. inl(meta("nmcca_no"))),
    line(SP.cover_small, inl(upper_inlines(meta("title")), B)),
  }
  local function cell(w, ps)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
  end
  out[#out + 1] = raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4540"/><w:gridCol w:w="280"/><w:gridCol w:w="4540"/></w:tblGrid>'
    .. "<w:tr>" .. cell(4540, left) .. cell(280, { line(0, "") }) .. cell(4540, right) .. "</w:tr></w:tbl>")

  out[#out + 1] = raw(line(SP.cover_large, runs("TO THE HONORABLE, THE JUDGES OF THE UNITED STATES", B), { center = true }))
  out[#out + 1] = raw(line(0, runs("NAVY-MARINE CORPS COURT OF CRIMINAL APPEALS", B), { center = true }))
  out[#out + 1] = raw(line(SP.cover_mid, inl(meta("tried_at"))))

  -- counsel: at the foot of the cover from 3 in (typst: place(bottom)); a frame whose foot is the foot of the text
  -- area, as tall as its lines (a long line wraps in it as in typst)
  local counsel = meta_list(meta("counsel"))
  local frame = string.format('<w:framePr w:w="%d" w:hSpace="0" w:wrap="around" w:vAnchor="margin" w:hAnchor="page" '
    .. 'w:x="%d" w:yAlign="bottom"/>', TEXT_W - HALF, 1440 + HALF)
  for _, l in ipairs(counsel) do out[#out + 1] = raw(line(0, inl(l), { frame = frame })) end
end

-- ---------------------------------------------------------------------------
-- Heading labels (typst heading-labels(); NMCCA-CONT-004)
-- ---------------------------------------------------------------------------

local UNLAB = { ["standard of review"] = true, ["principles of law"] = true, discussion = true, conclusion = true }

local function upper_roman(n)
  local s = ""
  for _, p in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

local function label_text(kind, n)
  if kind == "R" then return upper_roman(n) .. "." end
  if kind == "A" then return string.char(64 + n) .. "." end
  if kind == "a" then return string.char(96 + n) .. "." end
  if kind == "n" then return tostring(n) .. "." end
  return "(" .. tostring(n) .. ")"
end

local ARG_KINDS = { "R", "A", "n", "a" }
local OTH_KINDS = { "A", "n", "a", "p" }

-- ---------------------------------------------------------------------------
-- Signature block and certificate (typst signature-block(), certificate())
-- ---------------------------------------------------------------------------

-- the 3 in signature line: an underlined tab to the end of the line (typst: a 3 in rule under the baseline)
local function sig_line(out, before)
  out[#out + 1] = raw(line(before, '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    { keep = true, left = HALF, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (HALF + HALF) .. '"/></w:tabs>' }))
end

local function sig_lines(out)
  local sig = meta("signature") or {}
  local lines = meta_list(sig.lines)
  out[#out + 1] = raw(line(0, inl(sig.signer), { keep = #lines > 0, left = HALF }))
  for i, l in ipairs(lines) do
    out[#out + 1] = raw(line(0, inl(l, { i = true }), { keep = i < #lines, left = HALF }))
  end
end

local function signature(out)
  out[#out + 1] = raw(line(SP.sig, runs("Respectfully submitted."), { keep = true, left = HALF }))
  sig_line(out, SP.sig_line)
  sig_lines(out)
end

local function certificate(out)
  out[#out + 1] = raw(para({ KEEP, BREAK, spacing(0, 0, SINGLE), jc("center") },
    runs("CERTIFICATE OF FILING AND SERVICE", B)))
  out[#out + 1] = raw(line(SP.cover_mid,
    runs("I certify that the foregoing was delivered to the Navy-Marine Corps Court of Criminal Appeals, and that a copy was served on ")
      .. inl(meta("served_on")) .. runs(" on ") .. inl(meta("date")) .. runs("."),
    { keep = true, line = DOUBLE, first = INDENT }))
  sig_line(out, SP.sig_line)
  sig_lines(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function is_heading(b) return b.t == "Header" end

-- pandoc reads "II. WHETHER ..." (and "A. ...", "a. ...") as a list; typst's CommonMark reader has only numbered
-- lists, so such a list is set as the paragraphs it is in the typst render, the label as written.
local function unfancy(blocks)
  local out = pandoc.Blocks({})
  for _, b in ipairs(blocks) do
    local st = b.t == "OrderedList" and b.listAttributes.style or nil
    local simple = st and st ~= "Decimal" and st ~= "DefaultStyle"
    if simple then
      for _, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then simple = false end
      end
    end
    if simple then
      local n = b.listAttributes.start
      for _, item in ipairs(b.content) do
        local lab
        if st == "UpperRoman" then lab = upper_roman(n)
        elseif st == "LowerRoman" then lab = pandoc.text.lower(upper_roman(n))
        elseif st == "UpperAlpha" then lab = string.char(64 + n)
        else lab = string.char(96 + n) end
        local d = b.listAttributes.delimiter
        lab = d == "OneParen" and (lab .. ")") or d == "TwoParens" and ("(" .. lab .. ")") or (lab .. ".")
        local inl = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
        inl:extend(item[1].content)
        out:insert(pandoc.Para(inl))
        n = n + 1
      end
    else
      out:insert(b)
    end
  end
  return out
end

function Pandoc(doc)
  META = doc.meta
  load_pages()
  local blocks = unfancy(doc.blocks)

  -- headings: labels, the Argument's points, needles (index entries: levels 1 and 2)
  local counts = { 0, 0, 0, 0, 0, 0 }
  local arg = false
  local heads = {}
  for i, b in ipairs(blocks) do
    if is_heading(b) then
      local text = pandoc.text.lower(stringify(b.content)):gsub("^%s+", ""):gsub("%s+$", "")
      local lab = nil
      if b.level == 1 then
        arg = (text == "argument")
        counts = { 0, 0, 0, 0, 0, 0 }
      else
        for j = b.level + 1, 6 do counts[j] = 0 end
        if not UNLAB[text] and b.level <= 5 then
          counts[b.level] = counts[b.level] + 1
          lab = label_text((arg and ARG_KINDS or OTH_KINDS)[b.level - 1], counts[b.level])
        end
      end
      heads[i] = { level = b.level, label = lab, point = (b.level == 2 and arg), id = "H:" .. i }
    end
  end
  local function shown(i)
    local b, h = blocks[i], heads[i]
    if not h then return printed(b) end
    local t = printed(b)
    if h.level == 1 then t = pandoc.text.upper(t) end
    return (h.label and (h.label .. " ") or "") .. t
  end
  local first_id = nil
  for i, b in ipairs(blocks) do
    local h = heads[i]
    if h and h.level <= 2 then
      need(h.id, shown(i), blocks[i + 1] and shown(i + 1) or "")
      first_id = first_id or h.id
    end
  end

  local out = {}
  cover(out)
  out[#out + 1] = section_break("rIdFtrNone", COVER_BOTTOM)

  -- Index of Brief (typst index-of-brief(): listing-row)
  out[#out + 1] = raw(line(0, runs("INDEX OF BRIEF", B), { center = true }))
  local first = true
  for i, b in ipairs(blocks) do
    local h = heads[i]
    if h and h.level <= 2 then
      local indent = h.level == 1 and 0 or TOC_IND
      local lw = h.label and LABEL or 0
      local body = (h.label and runs(h.label .. "\t") or "") .. inl(b.content)
      out[#out + 1] = raw(para({ xe.LINES, xe.leader_tab(TEXT_W), spacing(first and SP.cover_mid or SP.toc_row, 0, SINGLE),
        ind(indent + lw, h.label and lw or nil, nil, TOC_COL) }, body .. LEAD_RUN .. runs(labels[h.id] or "1")))
      first = false
    end
  end
  out[#out + 1] = section_break("rIdFtrPage", MARGIN_BOTTOM, "lowerRoman", 2)

  -- the body; paragraphs indented when they follow a paragraph (typst first-line-indent); the last paragraph kept
  -- with the signature block
  local last_para = nil
  for i = #blocks, 1, -1 do
    if blocks[i].t ~= "Null" then
      if blocks[i].t == "Para" then last_para = i end
      break
    end
  end
  local prev = nil
  for i, b in ipairs(blocks) do
    local h = heads[i]
    if h then
      local before = (h.id == first_id) and 0 or (h.level == 1 and SP.section or SP.sub)
      local content = h.level == 1 and upper_inlines(b.content) or b.content
      local props = { style("Heading" .. math.min(h.level, 5)), KEEP, spacing(before, 0, SINGLE) }
      if h.label then props[#props + 1] = ind(LABEL, LABEL) else props[#props + 1] = ind(0) end
      props[#props + 1] = jc(h.level == 1 and "center" or "left")
      local body = (h.label and runs(h.label .. "\t", B) or "") .. inl(content, { b = true, i = h.point })
      out[#out + 1] = P(props, body)
    elseif b.t == "Para" then
      local after_par = prev ~= nil and prev.t == "Para"
      local st = after_par and "Body Text" or "First Paragraph"
      if i == last_para then st = after_par and "Body Keep" or "First Keep" end
      out[#out + 1] = pandoc.Div({ b:walk({ Inlines = xe.inlines }) }, pandoc.Attr("", {}, { ["custom-style"] = st }))
    else
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x:walk({ Inlines = xe.inlines }) end
    end
    prev = b
  end
  signature(out)
  certificate(out)

  local nl = needles
  if first_id then nl[#nl + 1] = "#section\t" .. first_id .. "\tdecimal\t" end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", MARGIN_BOTTOM, "decimal", 1))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
