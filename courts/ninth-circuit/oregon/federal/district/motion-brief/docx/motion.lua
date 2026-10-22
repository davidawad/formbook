-- D. Or. motion with memorandum, docx engine. Mirrors typst/ord-motion-brief.typ: on page 1 the counsel block upper
-- left (LR 10-2(a)), the court title one inch below it, capitalized, centered and double-spaced (LR 10-2(b)), and the
-- caption (a borderless table: the parties single-spaced at the left margin, LR 10-2(d); from the page center the case
-- number on the first plaintiff's line, the title in capitals, single-spaced, LR 10-2(f)-(g), and the legend); from
-- page 2 the body (headings, paragraphs with a first-line indent, block quotations single-spaced and indented on both
-- sides, LR 10-1(b); motions are not numbered), the signature block kept on one page with the last paragraph, and the
-- certificate of service on a page of its own. Every case word comes from the frontmatter. The footer (LR 10-1(e)(1):
-- "Page", the page number, " - " and the sample's footer_title in capitals, 12 pt) and the last section are written
-- for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); font, body styles, headings and margins are in
-- docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TW = 9360                               -- typst text-width: 6.5 in
local INDENT = 720                            -- typst quote-inset, service-indent: 0.5 in
local CAP_SPLIT, CAP_GAP = 4680, 432          -- typst caption-split 3.25 in, caption-gap 0.3 in
local SIG_COL = 4464                          -- typst sig-col 3.1 in
local COUNSEL_BELOW = 1440                    -- typst counsel-below 1 in
local CAPTION_ABOVE = 240                     -- typst caption-above 12 pt
local TITLE_ABOVE, LEGEND_ABOVE = 480, 240    -- typst title-above 24 pt, legend-above 12 pt
local QUOTE_GAP = 240                         -- typst quote-gap 12 pt
local SIG_ABOVE, SIG_BY_GAP = 480, 240        -- typst sig-above 24 pt, sig-by-gap 12 pt
local SERVICE_GAP, SERVICE_SIG_ABOVE = 240, 480 -- typst service-gap 12 pt, service-sig-above 24 pt
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("ord motion-brief docx: " .. msg, 0) end
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

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- A paragraph: o = { before, after, pitch, left, right, hanging, jc, keep, brk, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and 0 or nil, o.right)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- A borderless table without cell padding: widths (twips), rows of cells (each cell: paragraphs as a string).
local function grid(widths, rows)
  local total, cols = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, cell in ipairs(row) do
      cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>'
        .. (cell ~= "" and cell or p("")) .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Footer and section (LR 10-1(d), (e)(1))
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function footer(title)
  return xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs("Page ") .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>' .. xe.runs(" - " .. title:upper()))
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdOrdFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Page one: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, c in ipairs(items(m.counsel)) do out[#out + 1] = p(txt(c) == "" and "" or line(c)) end
  local court = {}
  for _, l in ipairs(items(m.court)) do court[#court + 1] = txt(l):upper() end
  if m.division then court[#court + 1] = txt(m.division):upper() end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", pitch = BODY, before = i == 1 and COUNSEL_BELOW or 0 })
  end
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("vs.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(line(n)) end
    left[#left + 1] = p(line(party.designation))
  end
  local right = { p(xe.runs("Case No. " .. txt(m.case_number))) }
  right[#right + 1] = p(xe.runs(txt(m.brief_title):upper(), { b = true }), { before = TITLE_ABOVE })
  if m.legend then right[#right + 1] = p(xe.inl(m.legend), { before = LEGEND_ABOVE }) end
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = grid({ CAP_SPLIT - CAP_GAP, CAP_GAP, TW - CAP_SPLIT }, { { table.concat(left), "", table.concat(right) } })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body, signature and certificate of service
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local function heading(level, inlines, brk)
  return p(xe.inl(level == 1 and upper(inlines) or inlines), { style = "Heading" .. level, keep = true, brk = brk, pitch = BODY })
end

-- The body as raw paragraphs, from page 2; the last paragraph is kept with the signature.
local function body(blocks)
  local out = {}
  for i, b in ipairs(blocks) do
    local brk = i == 1
    if b.t == "Header" then
      out[#out + 1] = heading(math.min(b.level, 3), b.content, brk)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { style = "BodyText", keep = i == #blocks, brk = brk, pitch = BODY })
    elseif b.t == "BlockQuote" then
      for k, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = QUOTE_GAP, after = QUOTE_GAP, left = INDENT, right = INDENT,
          brk = brk and k == 1, keep = i == #blocks })
      end
    else
      error("motion.lua: unexpected block " .. b.t)
    end
  end
  return table.concat(out)
end

-- The signature block (typst signature-block): single-spaced from SIG_COL, "DATED:" and the date at the left of its
-- first line (a tab), kept on one page, a space of its own above.
local function signature(m)
  local sig = m.signature
  local lines = {}
  for _, f in ipairs(items(sig.firm)) do lines[#lines + 1] = { line(f), 0 } end
  lines[#lines + 1] = { xe.runs("By: /s/ " .. txt(sig.signer)), SIG_BY_GAP }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = { line(l), 0 } end
  local out = {}
  for i, l in ipairs(lines) do
    local before = i == 1 and SIG_ABOVE or l[2]
    local keep = i < #lines
    if i == 1 then
      out[#out + 1] = p(xe.runs("DATED: " .. txt(m.date) .. "\t") .. l[1], { before = before, left = SIG_COL,
        hanging = SIG_COL, tab = SIG_COL, keep = keep })
    else
      out[#out + 1] = p(l[1], { before = before, left = SIG_COL, keep = keep })
    end
  end
  return table.concat(out)
end

-- Certificate of service (typst certificate-of-service): the form wording, with the document title, the date, the
-- parties served and the method, on a page of its own.
local function certificate(m)
  local cos = m.certificate_of_service
  if cos == nil then return "" end
  local signer = txt(m.signature.signer)
  local text = "The undersigned declares under penalty of perjury, under the laws of the State of Oregon, that on "
    .. txt(cos.date) .. ", I arranged for service of the foregoing " .. txt(m.brief_title):upper()
    .. " on the party to this action as follows:"
  local out = {
    heading(1, pandoc.Inlines({ pandoc.Str("CERTIFICATE OF SERVICE") }), true),
    p(xe.runs(text), { style = "BodyText", pitch = BODY }),
  }
  for k, l in ipairs(items(cos.served)) do
    out[#out + 1] = p(line(l), { left = INDENT, before = k == 1 and SERVICE_GAP or 0 })
  end
  out[#out + 1] = p(xe.runs("by: " .. txt(cos.method)), { left = INDENT, before = SERVICE_GAP })
  out[#out + 1] = p(xe.runs("s/ " .. signer), { left = SIG_COL, before = SERVICE_SIG_ABOVE, keep = true })
  out[#out + 1] = p(xe.runs(signer), { left = SIG_COL })
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("7-1(a)(1)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("¶¶ 28-29."; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  check(m.counsel ~= nil and #items(m.counsel) > 0, "LR 10-2(a): counsel information is required on page 1")
  check(m.court ~= nil, "Fed. R. Civ. P. 10(a): the court's name is required")
  check(m.caption ~= nil and m.caption.parties ~= nil, "LR 10-2(d): the caption must name the parties")
  check(txt(m.case_number) ~= "", "LR 10-2(f): the case number is required")
  check(m.brief_title ~= nil, "LR 10-2(g): the title of the paper is required")
  check(txt(m.footer_title) ~= "", "LR 10-1(e)(1): the sample has no footer_title")
  check(#doc.blocks > 0, "the sample has no body")
  write_file("FORMBOOK_FOOTERS", "rIdOrdFooter\t" .. footer(txt(m.footer_title)) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m) .. body(doc.blocks) .. signature(m) .. certificate(m)) })
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
